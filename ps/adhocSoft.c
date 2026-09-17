#include "AdhocSoft.h"
#include "pcie_tx.h"

/* 符号表分片上传（case 134）：每包 512 字 = 1028 字节。
 * BPSK 一张表 262144 字（512 KB）分 512 包，QPSK 一张表 32768 字（64 KB）分 64 包。
 * 包头 2..3 是包序号（不是字偏移），总包数随 table_sel 变。 */
#define TX_TABLE_CHUNK_WORDS (512)
#define TX_TABLE_WORDS_BPSK  (262144)
#define TX_TABLE_WORDS_QPSK  (32768)
#define TX_TABLE_CHUNKS_BPSK (TX_TABLE_WORDS_BPSK / TX_TABLE_CHUNK_WORDS)
#define TX_TABLE_CHUNKS_QPSK (TX_TABLE_WORDS_QPSK / TX_TABLE_CHUNK_WORDS)
#define TX_TABLE_WORDS_MAX   TX_TABLE_WORDS_BPSK
#define TX_TABLE_CHUNKS_MAX  TX_TABLE_CHUNKS_BPSK
#define TX_TABLE_PKT_LEN     (4 + 2 * TX_TABLE_CHUNK_WORDS)

/* 缓冲区，不写 RAM（512 KB → .bss）：两张表共用的填充区 + 512 包的到齐标记 */
static u16 tx_table_buf[TX_TABLE_WORDS_MAX];
static u8  tx_table_got[TX_TABLE_CHUNKS_MAX];
static U16 tx_table_cnt;

char localIPDef[20] = "192.168.1.10";
char hostIPDef[20] = "192.168.1.1";
ID_INFO_TYPE localIDInfo;
ID_INFO_TYPE JoinIDInfo;
ID_INFO_TYPE NodeIDInfo;
unsigned short  localId = 0x9184;
unsigned short QueryID;					// 查询链路质量ID
unsigned char g_TransparentTrans = 1;
unsigned char logMask = 7;

int SyncStartFlag = 0;
unsigned short  freqUseValue;
unsigned char   channelType = 1;
unsigned char   velocityType = 0;
int modeflag;
int mac_initial_flag = 1;
SemaphoreHandle_t FreqBinSem;
SemaphoreHandle_t clusterInfoSem;
U8 recvUartBuffer[UART_BUFFER_SIZE] = {0};
int uartBufferdataLen = 0;
U8  CMDBuf[1400] = {0};
U16 cmdLen = 0;
U8  sendBuff[1400] = {0};
U8  NetworkFlag[MAX_ROUTETBLE_NUM] = {0};
U8  firstSendSyncData = 0;
U32 boardRoutePeriod = 500;
U32 aliveTimeout = 0;
u32 RegValue;
U8 nodeAddressingMode = NODE_ADDRESSING_MODE_INCLUDE_CLUSTER_INFO;
int NodeNum;//模拟节点（路由表）数量
CLU_INFO_TYPE cluInfo;
//U16 quitnetFlag[256] = {0};

unsigned char g_testRateStart = 0;
unsigned char g_testRateEnd = 0;
unsigned char g_DllSendPkt = 0;
U32 g_StatisticStartPkt = 0;
U32 g_StatisticEndPkt = 0;
uint64_t g_StatisticStartT = 0;
uint64_t g_StatisticEndT = 0;
unsigned char g_SegDataLen = 128;
unsigned char SendRate = 1;			// 当前发送速率，默认发送速率为2Mbps，0为4Mbps， 1为2Mbps， 2为1Mbps， 3为500Kbps， 4为250Kbps
int TimeHopeFlag = 1; 	// TimeHopeFlag为0为非跳时（连续发送），1为跳时
U16 DutyRatio = 2;		// 当TimeHopeFlag为0时起作用，配置占空比，根据配置速率进行选择, 4Mbps设置为2
int RateUpFlag;			// RateUpFlag为1开始上报链路质量数据，为0时停止数据上报
unsigned char StateFlag;	// 定频配置参数，0为定频， 1为跳频
unsigned char StatePoint;	// 定频频点
U16 NetworkSendFlag;	// 统计网络层发包
DLLSEND_CTRL_TYPE dllSendCtrl;
U8 businessPlanSendData = 0;
TimerHandle_t businessPlanTimer = NULL;
TimerHandle_t recvPktStaticTimer = NULL;
uint64_t recvPktStaticTime = 0;
U32 recvPktStaticPktNum = 0;
u16 pktPS = 0;
U8 GPSEnable = 0;
U8 allNodesQuitFlag = 0;

//20260902 edit
/* defaults keep legacy tx_init: 100/200MHz, 0dB, channels on */
double fre_bpsk = 100;
double fre_qpsk = 200;
double atten_bpsk = 0;
double atten_qpsk = 0;
u8 ctrl_bpsk = 1;
u8 ctrl_qpsk = 1;
u8 tx_rate_sel = 0;    /* 速率选择：0 -> bpsk 450k / qpsk 4.5M，1 -> bpsk 400k / qpsk 6.667M */
//20260902

#if 1
/* main function */
static inline void OsalDsb(void)
{
    __asm__ volatile("dsb sy" ::: "memory");
}

static inline void OsalIsb(void)
{
    __asm__ volatile("isb sy" ::: "memory");
}


/* 在任意任务里调用即可 */
void vTaskSoftReset(void)
{
	xil_printf("reset\r\n");
    /* 关闭中断，防止调度器继续切任务 */
    portDISABLE_INTERRUPTS();

    /* 2. 数据同步屏障 */
    OsalDsb();
    OsalIsb();


    /* 3. 触发 SoC 软复位（寄存器地址根据芯片 TRM） */
    Xil_Out32(CRL_APB_RESET_CTRL,
    		Xil_In32(CRL_APB_RESET_CTRL) | CRL_APB_RESET_CTRL_SOFT_RESET_MASK);

    /* 3. 死循环，防止继续跑任务 */
    for (;;) ;
}

// 通过dds生成正弦波信号从DAC发射（单位为MHz）
void write_freq_point_10M(double freq_point)
{
	printf("FreqPoint : %lf MHz \r\n",freq_point);
	int unit = 1;


	double data;
	double fs = 1.28 * (1e+8);
	data = 65536 * freq_point * (1e+6) * unit / fs;
	int i;
	u16 writeData;
	for(i = -1; i < 8; i++){
		if(i == -1){
			writeData = (u16)(data + 0.5);
			emc_write(0x220,writeData);
		}else{
			writeData = (u16)((data * i/8.0) + 0.5);
			emc_write(0x224 + 2*i,writeData);
		}
		printf("write freq point : %x \r\n",writeData);
	}
	xil_printf("Successfully FreqPoint config! \r\n");
}

int main(void)
{
	int ret;
	periodic_little_update = 300 + (localId&0x00FF);
	boardRoutePeriod = 5000 + (localId&0x00FF);
	init_LLData();
	PrintVersion();
	localIDInfo.ID = localId;
	aliveTimeout = boardRoutePeriod * 5;

	xil_printf("role: %d,accessNetNum:%d,taskNetNum:%d,NodeID:%d\n", localIDInfo.IDST.role,localIDInfo.IDST.accessNetNum,localIDInfo.IDST.taskNetNum,localIDInfo.IDST.NodeID);

	xil_printf("Init Local ID: %d\n", localId);

	ret = xTaskCreate((void *)main_thread, "main_thr", 20480, NULL, 2, NULL);
	if(ret != pdPASS)
		xil_printf("Initial: Failed to create main_thread.\n");

	StartTask();



	return 0;
}
#endif




void main_thread(void)
{
	int ret;

	xGpioInit();

	ret = lwip_func_init();
	if (ret != True) {
		xil_printf("Netif Init Failed\r\n");
	}
	xil_printf(" Netif Init Successfully\r\n");


//	U16 state = Xil_In16(TARGET_ADDRESS);


	ret = PL_init();
	if(ret == True){
		xil_printf("PL init successfully !\n");
	}else{
		xil_printf("PL init Failed !\n");
	}

	InitConsoleSocket();


	NwkInitial();

	if(False == DllInitial())
	{
		xil_printf("Init: DllInitial Fail.\r\n");
		return ;
	}
	//xil_printf("\n reset \n", localId);
	//emc_write(RX_CONFIG_COMPLETE, 0xff);
	//emc_write(0x0A6, 0); //配置完成

	// add by me
//	tx_init();
	// end
	
	emc_write(0x174, 15);	//配置跳时跳频使能控制
//	emc_write(0x0E6, 4788); //配置12脉冲组帧的总长度
	emc_write(0x0E6, 7956); //配置12脉冲组帧的总长度,原始是7956，测速改为4788

	emc_write(0x0fc, 2500);  //配置捕获门限，测速改为5000

//	emc_write(0x17E,1);   //0:衰减自动控制;1:衰减手动控制
//	emc_write(0x180,1);   //单载波模式1使能和0停止
//	emc_write(0x184,1);    //0正常发包；1发单载波
////////	//  配置DAC发射的正弦波频率(单位为MHz)
//	write_freq_point(5);
//	emc_write(222, 0);		// 10M输出使能控制
//	write_freq_point_10M(10);
	emc_write(0x18a,0x58);
	emc_write(0x190,0);//agc输入中心门限 0正常模式     1上位机控制
	emc_write(0x192,1);//有信号拉高 给个信号
	emc_write(0x196,0b111111);//6位手动增益
	emc_write(0x198,7);//大门限
	emc_write(0x19A,4);//小门限
	emc_write(0x19C,75);//中心门限
	emc_write(0x19E,7);//计算时间：一个符号 43为最小；两个符号45为最小 8
//	emc_write(0x20A,65535);//overthreshold计数时间
//	emc_write(0x20C,55);//暂停时钟周期


	//	TDMA相关寄存器
	emc_write(0x234,0);//EN_timebase
//	emc_write(0x236,2);//数据帧个数
//	emc_write(0x238,0);//前保护帧
//	emc_write(0x23A,1);//前保护帧和数据帧
//	emc_write(0x23C,1);//时隙个数
//	emc_write(0x23E,1);//RAM写时隙：0为收时隙，1为非广播发时隙，2为广播发射时隙
//	emc_write(0x23E,0);//RAM写时隙：0为收时隙，1为非广播发时隙，2为广播发射时隙
//	emc_write(0x23E,0);//RAM写时隙：0为收时隙，1为非广播发时隙，2为广播发射时隙
//	emc_write(0x23E,0);
//	emc_write(0x23E,0);
//	emc_write(0x23E,0);
//	emc_write(0x240,0);//为现有0时隙应调整为的时隙号
	emc_write(0x242,0b01);//控制调制速率  00-32M;01-16M;10-4M;11-2M 默认值01
//	emc_write(0x244,1);//主为1 从为0，跳从为2
	emc_write(0x246,7956);//帧计数器
	emc_write(0x248,31);//帧计数偏移值
//	emc_write(0x250,1);//TDMA/SPMA切换，0TDMA；1SPMA
	emc_write(0x17E,0);
	emc_write(0x218,1);
	emc_write(0x21A,1);
//	//ps控制射频配置，开启射频
	emc_write(0x176,0);// 射频
	emc_write(0x178,1);//发射接收切换 高接收 低发射
	emc_write(0x18C,1);//低噪放
//	emc_write(0x17A,0);//接收衰减
	emc_write(0x17C,0);//发射衰减

//	emc_write(0x304,1);//噪声

	//0:板间通信模式；1:板内自环模式；2：外环
	emc_write(0x182,0);
//	//  配置DAC发射的正弦波频率(单位为MHz)
//	emc_write(0x220,1);
//	write_freq_point(5);

	emc_write(0x210,1);//0跳频 1定频
//	emc_write(0x212,0);//定频频点选额（0-14共15个频点）
	FreqBinSem = xSemaphoreCreateBinary();

	//ADRV9009_init(LocalFrequency);

#if 0
	//open attenuation
	emc_write(0x0C0,0);
	emc_write(0x0C2,0);
	emc_write(0x0C4,100);

	emc_write(0x0C6,0);
	emc_write(0x0C8,0);
	emc_write(0x0CA,991);

	//close attenuation
	emc_write(0x0C0,0x0f);
	emc_write(0x0C2,0xff);
	emc_write(0x0C4,0xff);

	emc_write(0x0C6,0x0f);
	emc_write(0x0C8,0xff);
	emc_write(0x0CA,0xfe);
#endif

//	emc_write(0x200, 0);

	emc_write(0x0F0, 1);  // 0 波门  1 同步脉冲

	emc_write(0x0e8, 1);
	emc_write(0x0e8, 0);
	emc_write(0x18e,0);

//	xrfdc_selftest();

//	int aa;
//	emc_write(0x002,5);
//	aa = emc_read(0x802) & 0x0000ffff;
//	printf("aa = %d\r\n",aa);
//	emc_write(0x004,aa);


	InitTask();

	ret = axi_cdma_init();
	if(ret != XST_SUCCESS)
		xil_printf("Failed to Initial  AXI CDMA.\n");
	else
		xil_printf("Successfully Initial  AXI CDMA!\r\n");


	initIntrFunc(INTC_DEVICE_ID);
	xGpioIntEnable_1();
	xGpioIntEnable_2();

	//ret = xTaskCreate((void *)net_ctrl_thread , "net_thr" , 2048 , NULL , 2 , NULL);
	//if(ret != pdPASS)
		//LOGE("Initial: Failed to create net_ctrl_thread.\n");
//	freeBytes = xPortGetMinimumEverFreeHeapSize();
//	xil_printf("freeBytes: %d\n", freeBytes);


	/*ret = xTaskCreate((void *)eMMC_thread , "emmc_thr" , 8192 , NULL , 2 , NULL);
	if(ret != pdPASS)
		xil_printf("Initial: Failed to create eMMC_thread.\n");*/

//	ret = xTaskCreate((void *)Uart_Handler, "uart_thr", 8192, NULL, 2, NULL);
//	if(ret != pdPASS)
//		xil_printf("Initial: Failed to create Uart_Handler.\n");

	xil_printf("Init Finished! Local ID: %d\n", localId);





#ifdef CONSOLE_CONNECT_MODE_ETHERNET
		adhocCtrl();
#else
		UartCtrl();
#endif
		while(1);

}


void ProcCmd(unsigned char *pBuf, U16 len)
{
	int ret, i, Index;
	int retVal = 0;
	int SentCount =  0;

	unsigned char type;
	unsigned char tx_mode;
	unsigned char Threshold1;
	unsigned char power_ctr;
	unsigned char multip_para;
	unsigned char Multip_Mode;
	unsigned short Threshold2;
	unsigned short freqoff;
	unsigned short write_addr, read_addr;
	unsigned short write_para, read_para;
	unsigned short dstID;
	unsigned short srcID;
	unsigned short packet_num;
	unsigned char pluseType, dataType;
	unsigned char net_mode;
	unsigned char quitnet_mode;
	unsigned char txdelay;
	unsigned char chan_type, vel_type;
	unsigned char antenna_type;
	U16 dataLen = 0;
	U16 tempID = 0x0000;
	U8 cmdBuff[100] = {0};
	U16 delay=0;
	U32 DLLPktNum = 0;
	U32 crcErrNum = 0;
	U32 testNum = 0;
	U32 broadNum = 0;
	U32 NetWorkPktNum = 0;
	U32 tempU32 = 0;
	U16 ID = 0;
	U8 dstTaskNetID = 0;
	U8 dstAccessNetID = 0;
	U8 dstrole = 0;
	CLU_INFO_TYPE * pCluInfo = &cluInfo;
	ID_INFO_TYPE changeId;
	ID_INFO_TYPE indexId;
	ID_INFO_TYPE quitId;
	ID_INFO_TYPE tempId;
	ROUTE_ENTRY_TYPE *p;
	ROUTE_ENTRY_TYPE *tempPtr;
	U16 recvID = 0;
	U8 comRate = 0;
	U16 t_2 = 0;
	U16 t_1 = 0;
	U16 t_0 = 0;
	uint64_t t = 0;
	BUSINESS_PLAN_PAR_TYPE businessPlanPar;
	type = pBuf[0];
	//xil_printf("The type is %d .\r\n",type);

	switch(type)
	{
		case 1:
			xil_printf("[Set_TxMode]\r\n");//发射模式
			tx_mode = pBuf[1];
			xil_printf("The tx_mode is %d .\r\n", tx_mode);
			if(tx_mode == 0)
			{
				;
			}
			else if(tx_mode == 1)
			{
				SetTxMode(0x0170);
			}
			break;
		case 2:
			xil_printf("[Set_PulseNumThreshold]\r\n");//捕获门限
			Threshold1 = pBuf[1];
			SetPulseNumThreshold(Threshold1);
			xil_printf("The threshold is %d\r\n", Threshold1);
			break;
		case 3:
			xil_printf("[Set_PowerCtrl]\r\n");//功率控制
			power_ctr = pBuf[1];
			emc_write(TX_POWER_CONTROL, power_ctr);
			xil_printf("The power is %d\r\n", power_ctr);
			break;
		case 4:
			xil_printf("[Set_AGC]\r\n");//增益控制
			Multip_Mode = pBuf[1];
			multip_para = pBuf[2];
			if(Multip_Mode == 0)
			{
				emc_write(0x0be, 0x003b);
			}
			if(Multip_Mode == 1)
			{
				emc_write(0x0ba, multip_para);
				emc_write(0x0bc, multip_para);
				emc_write(0x0be, 0x803b);
			}
			xil_printf("The manual multip_para is %d\r\n", multip_para);
			break;
		case 5:
			xil_printf("[Set_CorThreshold]\r\n");//设置脉冲门限
			Threshold2 = 256*pBuf[2] + pBuf[1];
			SetCorThreshold(Threshold2);
			xil_printf("The threshold is %d\r\n", Threshold2);
			break;
		case 6:
			xil_printf("[Set_FreqOffset]\r\n");//设置射频频偏校正
			freqoff = 256*pBuf[2] + pBuf[1];
			emc_write(0x02a,0x8003);  //配置5683
			emc_write(0x028,freqoff);
			delay_AD9689(6000);
			emc_write(0x02a,0x0003);
			delay_AD9689(100);
			emc_write(0x02a,0x8003);
			delay_AD9689(10000);
			xil_printf("The freq_off is %d\r\n", freqoff);
			break;
		case 7:
			xil_printf("[EmcRead]\r\n");//读地址
			read_addr = 256*pBuf[2] + pBuf[1];
			read_para = emc_read(read_addr);
			//ReadParaShow(read_para);
			xil_printf("The read_addr is 0x%x %d.\r\n", read_addr, read_para);
			break;
		case 8:
			xil_printf("[EmcWrite]\r\n");//写地址
			write_addr = 256*pBuf[2] + pBuf[1];
			write_para = 256*pBuf[4] + pBuf[3];
			emc_write(write_addr, write_para);
			xil_printf("The write_addr is 0x%x .\r\n", write_addr);
			xil_printf("The write_para is %d .\r\n", write_para);
			break;
		case 9:
			xil_printf("[LoopSend]\r\n");//链路层发包
			srcID = (pBuf[2] << 8) | pBuf[1];
			dstID = (pBuf[4] << 8) | pBuf[3];
			packet_num = (pBuf[6] << 8) | pBuf[5];
			dataLen = pBuf[7];
			xil_printf("srcID:0x%x, dstID: 0x%x,packet_num:%d,dataLen:%d .\r\n", srcID, dstID, packet_num,dataLen);
			//pluseType = pBuf[4];
			//dataType = pBuf[5];
			/*cmdBuff[0] = 9;
			cmdBuff[1] = dstID;
			cmdBuff[2] = packet_num;
			cmdBuff[3] = (packet_num>>8);
			cmdBuff[4] = dataLen;
			Pack(cmdBuff,5,sendBuff);*/
			//while(1)
			//{

				//SentCount = XUartPs_Send(&Uart_Ps,sendBuff, 11);
				//vTaskDelay(pdMS_TO_TICKS(100000));
			//}
			//LoopSend(dstID, packet_num, pluseType, dataType);
			int ii = 0;
			for (ii=0 ; ii<packet_num ; ii++)
				LoopSend1(srcID, dstID, 1, 0, 1);
			xil_printf("send over!\r\n");
			//LoopSend(dstID, packet_num, 0, 1);
			break;
		case 10:
			xil_printf("[NwkSend]\r\n");//网络层发包
			srcID = 256*pBuf[2] + pBuf[1];
			dstID = 256*pBuf[4] + pBuf[3];
			packet_num = 256*pBuf[6] + pBuf[5];
			delay = 256*pBuf[8] + pBuf[7];
			dataLen = 256*pBuf[10] + pBuf[9];
			NetworkSendFlag = 0;		// 网络层发包计数清零
			xil_printf("dstID %d,packet_num %d,delay %d,dataLen %d.\r\n", dstID, packet_num,delay, dataLen);
			/*
			ROUTE_ENTRY_TYPE *p;
			int stateFlag = 0;
			for (i = 1; i <=256; i++)
			{
				printf("i = 0x%X, ID = 0x%X\r\n", i, routeTables[i]->head->srcID);
				p = routeTables[i]->head;
				while (p != NULL)
				{
					if (p->routeState == valid)
						stateFlag = 1;
					else if (p->routeState == invalid)
						stateFlag = 2;
					printf("srcID = 0x%X, nextID = 0x%X, destID = 0x%X, routestate = %d\r\n", p->srcID, p->nextID, p->destID, stateFlag);
					p = p->next;
				}
			}
			*/
			NwkSend(srcID, dstID, packet_num, 0, delay, typeD, 6);
			break;
		case 11:
			xil_printf("[RouteTablePrint]\r\n");//路由表打印
			RouteTablePrint();
			break;
		case 12:
			xil_printf("[WarnPrint]\r\n");//收发信息打印
			WarnPrint();
			break;
		case 13:
			xil_printf("[WarnReset]\r\n");//收发信息清零
			NwkWarnReset();
			DllWarnReset();
			//SrioWarnReset();
			break;
		case 14:
			xil_printf("[Set_NodeID]\r\n");//配置节点ID
			localId = pBuf[1];
			xil_printf("localId: %d\r\n", localId);
//				hostIP = 0;
			break;
		case 15:
			xil_printf("[Set_RouteAliveTime]\r\n");//配置路由生存时间
			alive_route_time = 256*pBuf[2] + pBuf[1];
			AliveTimeUpdate(alive_route_time);
			xil_printf("alive_route_time: %d\r\n", alive_route_time);
			break;
		case 16:
			xil_printf("[Set_PeriodicUpdateTime_stable]\r\n");//配置路由更新周期稳定后的
			periodic_update_time = 256*pBuf[2] + pBuf[1];
			xil_printf("periodic_update_time: %d\r\n", periodic_update_time);
			break;
		case 17:
			xil_printf("[Set_PeriodicUpdateTime_start]\r\n");//配置路由更新周期初始时刻的
			periodic_little_update = 256*pBuf[2] + pBuf[1];
			xil_printf("periodic_little_update: %d\r\n", periodic_little_update);
			break;
		case 18:
			xil_printf("[Set_Routemode]\r\n");//设置组网模式
			net_mode = pBuf[1];
			if(net_mode == 1)//组网模式
				routestopFlag = 1;
			else//点对点模式
				routestopFlag = 0;
			RemoteSetNetworkMode(net_mode);
			break;
		case 19:
			xil_printf("[SyncStart]\r\n");//控制同步开始
			SyncStartFlag = 1;
			firstSendSyncData = 1;
//			routestopFlag = 0;
			break;
		case 20:
			xil_printf("[SyncStop]\r\n");//控制同步停止
			SyncStartFlag = 0;
//			routestopFlag = 1;
			//RemoteSetNetworkMode(1);
			break;
		case 21:
			xil_printf("[Set_SyncNodesInterval]\r\n");//配置一跳节点之间的同步间隔
			syncNodesInterval = 256*pBuf[2] + pBuf[1];
			xil_printf("syncNodesInterval: %d\r\n", syncNodesInterval);
			break;
		case 22:
			//printf("[Set_SyncTurnsInterval]\r\n");//配置每轮次的同步间隔
			syncType = pBuf[1];
			syncTurnsInterval = 256*pBuf[3] + pBuf[2];
			xil_printf("syncType:%d,syncTurnsInterval: %d\r\n", syncType, syncTurnsInterval);
			break;
		case 23:
			xil_printf("route\r\n");//设置开启路由的遥控参数
			for(i = 1; i <= routeTableNum; i++)
			{
				if (NULL == routeTables[i])
					continue;
				if (NULL == routeTables[i]->head)
					continue;
				indexId.ID = routeTables[i]->head->srcID;
				if (indexId.IDST.role != ROLE_TYPE_TASK_NET_COMMON_NODE)
				{
					NetworkFlag[i] = 0xF0;
					//printf("ID: 0x%X\r\n", indexId.ID);
				}
			}
			masterId = localId;
			broadInterval = pBuf[1];
			routeStartDelay = pBuf[2];
			xil_printf("broadInterval: %d, routeStartDelay: %d\r\n", broadInterval, routeStartDelay);
			//routeStartTimeFlag = 1;
			RouteStartbroad();
			if (allNodesQuitFlag)
			{
				vTaskResume(nwkHello);
				allNodesQuitFlag = 0;
			}
			break;
		case 24:
			xil_printf("[NodeQuit]\r\n");	//设置固定节点退网的命令
			dstID = 256*pBuf[2] + pBuf[1];
			quitnet_mode = pBuf[3];//退网模式，0表示被动退网，1表示主动退网
			modeflag = 1;
			if (CheckID(dstID))
			{
				cmdBuff[0] = 24;				//发送起始退网统计时间
				cmdBuff[1] = 1;					//开始计时flag为1, 结束计时flag为0
				cmdBuff[2] = dstID & 0xFF;
				cmdBuff[3] = (dstID >> 8) & 0xFF;
				SendToConsole(cmdBuff,4,MODE_ETHERNET,32000);
				vTaskDelay(pdMS_TO_TICKS(1));
				DeleteClusterInfo(dstID);
				QuitNetActive(dstID);
				quitId.ID = dstID;
				if((ROLE_TYPE_ACCESS_NET_COMMON_NODE == quitId.IDST.role) || (ROLE_TYPE_ACCESS_NET_GATEWAY_NODE == quitId.IDST.role))
				{
					for(Index = 1; Index <= routeTableNum; Index++)
					{
						// 跳过空指针
						if (NULL == routeTables[Index])
							continue;
						if (NULL == routeTables[Index]->head)
							continue;
						p = routeTables[Index]->head;
						// 跳过退网节点
						if (dstID == p->srcID)
						{
							//xil_printf("node:0x%x,routetableLen:%d\r\n", p->srcID, routeTables[Index]->length);
							continue;
						}
						tempId.ID = p->srcID;
						if (quitId.IDST.taskNetNum == tempId.IDST.taskNetNum)
						{
							if (True == ChooseClusterHead(tempId.ID, quitId.ID))
							{
								break;
							}
						}
					}
					//vTaskDelay(pdMS_TO_TICKS(getRandNum(100)));
					xSemaphoreGive(routeStartSem);

				}
			}
			xil_printf("Quit Node %x, quitnet_mode: %d\r\n", dstID, quitnet_mode);
			/*p = routeTables[dstID & 0x00FF]->head;
			while (p != NULL)
			{
				printf("srcID = 0x%x, nextID = 0x%X, destID = 0x%X\r\n", p->srcID, p->nextID, p->destID);
				p = p->next;
			}*/
			//printf("routeTableslength: %d, routelastlength: %d\r\n", routeTables[0x94]->length, routelastlength[0x94]);
			break;
		case 25:
			xil_printf("[NodeJoin]\r\n");	//设置固定节点入网的命令
			dstID = 256*pBuf[2] + pBuf[1];
			masterId = localId;
			routeStartTimeFlag = 0;
			routeEndTimeFlag[dstID & 0x00FF] = 0;
			NetworkFlag[dstID & 0x00FF] = 0x0F;
			xil_printf("Join Node %x\r\n", dstID);
			//if (CheckID(dstID))
			if (dstID&0x0080)
			{
				routeStartTime = xTaskGetTickCount();
				routeTimeMax = routeStartTime;
				JoinIDInfo.ID = dstID;

				if (1 == rxQuitNetflag[dstID&0x00FF])
				{
					if ((ROLE_TYPE_ACCESS_NET_COMMON_NODE == JoinIDInfo.IDST.role)||
						(ROLE_TYPE_ACCESS_NET_GATEWAY_NODE == JoinIDInfo.IDST.role))
					{
						JoinIDInfo.IDST.role = ROLE_TYPE_TASK_NET_COMMON_NODE;
						p = routeTables[JoinIDInfo.IDST.NodeID]->head;
						p->srcID = JoinIDInfo.ID;
						p->nextID = JoinIDInfo.ID;
						p->destID = JoinIDInfo.ID;
						xil_printf("modify to task net common node:0x%x\r\n", JoinIDInfo.ID);
					}
				}
				rxQuitNetflag[dstID&0x00FF] = 0;
				UpdateClusterInfo(JoinIDInfo.ID);
				JoinNetActive(JoinIDInfo.ID, 0);
			}
			else
			{
				xil_printf("it is not a mointor node, 0x%x\r\n",dstID);
				JoinNetCtrl(dstID);
			}

			break;
		case 26:
			xil_printf("[Test_EndToEnd_Delay]\r\n");//测试端到端时延
			dstID = pBuf[1];
			SendEndtoendPkt(dstID);
			break;
		case 27:
			xil_printf("[LogFileClear]\r\n");//清空日志
			//LogFileClear(logFile);
			break;
		case 28:
			xil_printf("[PrintLogFile]\r\n");//打印日志
			//PrintLogFile(logFile);
			break;
		case 29:
			xil_printf("[Play_video]\r\n");//遥控播放视频
			dstID = pBuf[1];
			VideoPlayCtrl(1, dstID);
			xil_printf("Tell node %d play video\r\n", dstID);
			break;
		case 30:
			xil_printf("[End_Video_Play]\r\n");//结束播放视频
			dstID = pBuf[1];
			VideoPlayCtrl(4, dstID);
			xil_printf("Tell node %d stop video\r\n", dstID);
			break;
		case 31:
			xil_printf("[Set_FreqPoint]\r\n");//配置频点
			freqUseValue = 256 * pBuf[2] + pBuf[1];
			InitFreAndTime(0);
			FrequencyHoppingArrayInitial();
			if(False == FpgaInitial())
			{
				xil_printf("DllInitial: FpgaInitial fail\r\n");
				break;
			}
			TestFreqTakeOff(freqUseValue);
			xil_printf("Set freqPoint finish\r\n");
			break;
		case 32:
			xil_printf("[Let_Remote_send_nwkpkt]\r\n");//遥控远端节点给本机从网络层发包
			dstID = pBuf[1];
			packet_num = 256*pBuf[3] + pBuf[2];
			txdelay = pBuf[4];//发包延时
			MindRemoteSendNwkpkt(dstID, packet_num, txdelay);
			xil_printf("Tell Remote_send_nwkpkt finish\r\n");
			break;
		case 33:
			xil_printf("[Send_log_file]\r\n");//上传日志文件给上位机并保存
			//LogFileSend();
			break;
		case 34:
			xil_printf("[Set_Channel_Type]\r\n");//本机通道选择，0表示通道1zync，1表示通道2K7
			channelType = pBuf[1];
			xil_printf("The channelType is %d\r\n", channelType);
			break;
		case 35:
			xil_printf("[Set_Velocity_Type]\r\n");//本机速率选择，0表示2M，1表示64k
			velocityType = pBuf[1];
			xil_printf("The velocityType is %d\r\n", velocityType);
			break;
		case 36:
			xil_printf("[Remote_Set_Channel_Type]\r\n");//遥控设置远端节点的通道类型
			dstID = pBuf[1];
			chan_type = pBuf[2];
			Send_channel_velocity_SetCommand(dstID, 1, chan_type);
			xil_printf("The dstID %d chan_type is %d\r\n", dstID, chan_type);
			break;
		case 37:
			xil_printf("[Remote_Set_Channel_Type]\r\n");//遥控设置远端节点的速率类型
			dstID = pBuf[1];
			vel_type = pBuf[2];
			Send_channel_velocity_SetCommand(dstID, 2, vel_type);
			xil_printf("The dstID %d vel_type is %d\r\n", dstID, vel_type);
			break;
		case 38:
			xil_printf("[Choose_Antenna]\r\n");//选择发射天线
			antenna_type = pBuf[1];
			emc_write(0x200, antenna_type-1);
			xil_printf("The antenna_type is %d\r\n", antenna_type-1);
			break;
		case 39:
			xil_printf("[cluster ctrl]\n");
			for(i = 0; i < 5; i++)
			{
				banID[i] = pBuf[i+1];
				if(pBuf[i+1] == 1)
					printf("%d ", i+1);
			}
			printf("\n");
			break;
		case 40:
			xil_printf("[send recv info to host\n");
			//RecvInfoUpload();
			break;
		case 41:
			srcID = 256*pBuf[2] + pBuf[1];
			testNum = testPktRxNum[srcID & 0x00FF];
			broadNum = broadcastRxNum;
			crcErrNum = crc_err38;
			xil_printf("[testNum:%d,broadNum:%d,crcErrNum:%d\n",testNum,broadNum,crcErrNum);
			cmdBuff[0] = 41;
			cmdBuff[1] = testNum;
			cmdBuff[2] = (testNum>>8);
			cmdBuff[3] = (testNum>>16);
			cmdBuff[4] = (testNum>>24);
			cmdBuff[5] = broadNum;
			cmdBuff[6] = (broadNum>>8);
			cmdBuff[7] = (broadNum>>16);
			cmdBuff[8] = (broadNum>>24);
			cmdBuff[9] = crcErrNum;
			cmdBuff[10] = (crcErrNum>>8);
			cmdBuff[11] = (crcErrNum>>16);
			cmdBuff[12] = (crcErrNum>>24);

			SendToConsole(cmdBuff,13,MODE_ETHERNET,32000);

			break;
		case 42:
			xil_printf("[network]\n");
			srcID = 256*pBuf[2] + pBuf[1];
			NetWorkPktNum = rxTlDataIndNum[srcID&0x00FF];
			cmdBuff[0] = 42;
			cmdBuff[1] = NetWorkPktNum;
			cmdBuff[2] = (NetWorkPktNum>>8);
			cmdBuff[3] = (NetWorkPktNum>>16);
			cmdBuff[4] = (NetWorkPktNum>>24);
			printf("srcID: 0x%X, NetWorkPktNum: %d, NetworkSendFlag: %d\r\n", srcID, NetWorkPktNum, NetworkSendFlag);
			SendToConsole(cmdBuff,5,MODE_ETHERNET,32000);
			break;
		case 43:
			tempU32 = 256*256*256*pBuf[4] + 256*256*pBuf[3] + 256*pBuf[2] + pBuf[1];
			boardRoutePeriod = tempU32;
			routeTables[1]->head->aliveTimeout=boardRoutePeriod*5;
			aliveTimeout = boardRoutePeriod * 5;
			xil_printf("[boardRoutePeriod]:%d,aliveTimeout:%d\n",boardRoutePeriod, aliveTimeout);

			if(1 == periodChangeFlag)
			{
				xTimerChangePeriod(routeBroadcastTimer, pdMS_TO_TICKS(boardRoutePeriod), portMAX_DELAY);
				xTimerStart(routeBroadcastTimer, portMAX_DELAY);
			}

			RemoteSetRouteBroadPeriod();
			break;

		case 44://remote send data
			Remote_Loop_Send(pBuf);
			break;

		case 45://remote read data number
			Remote_Read_Num(pBuf);
			break;
		case 46:
			ret = qspi_erase_all();
			if (ret != XST_SUCCESS) {
				xil_printf("Qspi Erase Failed\r\n");
				return XST_FAILURE;
			}
			xil_printf("Successfully Erase Qspi\r\n");
			break;
		case 64:
			network_flash_process(pBuf, len);
			break;
		case 74://速率测试发送端开始发送数据
			if (1 == g_DllSendPkt)
			{
				LOGI("CONSOLE_CMD_TEST_RATE_START:dll send pkt now, please try again after a moment.\r\n");
				break;
			}
			if (1 == g_testRateStart)
			{
				LOGI("CONSOLE_CMD_TEST_RATE_START: test rate now, please stop test rate before start test rate!\r\n");
				break;
			}
			g_testRateStart = 1;
			g_testRateEnd = 0;

			dllSendCtrl.srcID = 256*pBuf[2] + pBuf[1];
			dllSendCtrl.dstID = 256*pBuf[4] + pBuf[3];
			dllSendCtrl.sendnwknum = 65535;
			dllSendCtrl.dataLen = g_SegDataLen;

			LOGI("test rate start send: srcID:0x%x, dstID: 0x%x packet_num:%d,dataLen:%d.\r\n", dllSendCtrl.srcID, dllSendCtrl.dstID, dllSendCtrl.sendnwknum, dllSendCtrl.dataLen);
			//vTaskSuspendAll();
			ret = xTaskCreate((void *)LoopSendProcess, "dll_send_pkt", 20480, (void *)&dllSendCtrl, 1, NULL);

			if(ret != pdPASS)
				LOGE("nwk_rx: Failed to create dll_send_pkt task.\r\n");
			break;
		case 75://速率测试发送端结束发送数据
			LOGI("test rate end send:.\r\n");
			g_testRateEnd = 1;
			break;
		case 76://速率测试接收端开始统计数据
			recvID = 256*pBuf[2] + pBuf[1];
			LOGI("test rate start recv, recvID:0x%x.\r\n", recvID);
			t_2 = emc_read(SYNC_TIME_SHOW_2);
			t_1 = emc_read(SYNC_TIME_SHOW_1);
			t_0 = emc_read(SYNC_TIME_SHOW_0);

			t = ((uint64_t)t_2 << 32) + ((uint64_t)t_1 << 16) + (uint64_t)t_0;
			t *= 8;//纳秒
			g_StatisticStartPkt = testPktRxNum[recvID & 0x00FF];

			g_StatisticStartT = t;
			break;
		case 77://速率测试接收端结束统计数据
			recvID = 256*pBuf[2] + pBuf[1];
			LOGI("test rate end recv,recvID:0x%x.\r\n", recvID);
			t_2 = emc_read(SYNC_TIME_SHOW_2);
			t_1 = emc_read(SYNC_TIME_SHOW_1);
			t_0 = emc_read(SYNC_TIME_SHOW_0);

			t = ((uint64_t)t_2 << 32) + ((uint64_t)t_1 << 16) + (uint64_t)t_0;
			t *= 8;//纳秒
			g_StatisticEndPkt = testPktRxNum[recvID & 0x00FF];
			g_StatisticEndT = t;
			g_StatisticEndPkt = g_StatisticEndPkt - g_StatisticStartPkt;
			g_StatisticEndT = g_StatisticEndT - g_StatisticStartT;
			cmdBuff[0] = 77;
			memcpy(&cmdBuff[1], &g_StatisticEndT, 8);
			memcpy(&cmdBuff[9], &g_StatisticEndPkt, 4);
			cmdBuff[13] = g_SegDataLen;
			LOGI("\n g_StatisticEndT = %llu, g_StatisticEndPkt=%u, g_SegDataLen=%u\n", g_StatisticEndT, g_StatisticEndPkt, g_SegDataLen);
			SendToConsolePort32000(cmdBuff, 14);
			break;
		case 82:
			dstID = pBuf[2];
			srcID = 256*pBuf[4] + pBuf[3];
			//Pack(pBuf,len,sendBuff);
			/*xil_printf("recv data,len=%d:\r\n",len);
			i = 0;
			while(i<len)
			{
				xil_printf("0x%x ",pBuf[i]);
				i++;
			}
			xil_printf("\r\n");*/
			NwkSendData(sendBuff, len+6, dstID,srcID);
			break;

		case 93:
			LOGI("CONSOLE_CMD_GPS\r\n");
			GPSEnable = pBuf[1];
		// net change
		case 96:
			xil_printf("[net change]\r\n");
			ID = pBuf[1];
			recvID = 256*pBuf[2] + pBuf[1];
			dstTaskNetID = pBuf[3];
			dstAccessNetID = pBuf[4];
			modeflag = 0;
			dstrole = 0;						// 默认为任务网普通节点

			if (0x0000 == (recvID & 0xFF00))
			{
				printf("This ID doesn't exist in Network\r\n");
				break;
			}
			// 新ID生成
			changeId.IDST.role = dstrole;
			changeId.IDST.accessNetNum = dstAccessNetID;
			changeId.IDST.taskNetNum = dstTaskNetID;
			changeId.IDST.NodeID = ID;

			if (changeId.ID == recvID)
			{
				printf("This ID has already exist in dsetTaskNet\r\n");
				break;
			}
			xil_printf("initial_ID: 0x%X, dest_ID: 0x%X, dstTaskNetID:0x%x, dstAccessNetID: 0x%X\r\n", recvID, changeId.ID, dstTaskNetID, dstAccessNetID);

			if (CheckID(recvID))
			{
				routeStartTime = xTaskGetTickCount();
//				printf("routeStartTime: %d\r\n", routeStartTime);
				routeTimeMax = routeStartTime;
				/*quit net*/
				QuitNetActive(recvID);
				/*join net*/
				// 修改路由条目
				p = routeTables[recvID & 0x00FF]->head;
				p->srcID = changeId.ID;
				p->nextID = changeId.ID;
				p->destID = changeId.ID;
				// 修改簇信息
				DeleteClusterInfo(recvID);
				// 簇信息添加更新后的节点
				UpdateClusterInfo(changeId.ID);


				quitId.ID = recvID;
				if((ROLE_TYPE_ACCESS_NET_COMMON_NODE == quitId.IDST.role) || (ROLE_TYPE_ACCESS_NET_GATEWAY_NODE == quitId.IDST.role))
				{
					for(Index = 1; Index <= routeTableNum; Index++)
					{
						// 跳过空指针
						if (NULL == routeTables[Index])
							continue;
						if (NULL == routeTables[Index]->head)
							continue;
						p = routeTables[Index]->head;
						// 跳过退网节点
						if (dstID == p->srcID)
						{
							//xil_printf("node:0x%x,routetableLen:%d\r\n", p->srcID, routeTables[Index]->length);
							continue;
						}
						tempId.ID = p->srcID;
						if (quitId.IDST.taskNetNum == tempId.IDST.taskNetNum)
						{
							if (True == ChooseClusterHead(tempId.ID, quitId.ID))
							{
								break;
							}
						}
					}
				}
				/*
				int k;
				// 打印交换网簇信息
				xil_printf("ExchangeClusterInfo:\r\n");
				xil_printf("ExchangeCluster NodeNum: %d\r\n", cluInfo.exchangeCount);
				xil_printf("ExchangeCluster NET: ");
				for(j = 0; j < cluInfo.exchangeCount; j++)
				{
					if (0 == cluInfo.exchangeCluster[j])
						xil_printf(" 0x000%X", cluInfo.exchangeCluster[j]);
					else
						xil_printf(" 0x%X", cluInfo.exchangeCluster[j]);
				}
				printf("\r\n");

				// 打印接入子网簇信息
				xil_printf("AccessClusterInfo:\r\n");
				xil_printf("AccessCluster NetNum: %d\r\n", cluInfo.accessRows);
				for(j = 0; j < cluInfo.accessRows; j++)
				{
					xil_printf("AccessCluster NET-0%d: ", j + 1);
					for(k = 0; k < cluInfo.accessCols[j]; k++)
					{
						if (0 == cluInfo.accessCluster[j][k])
							xil_printf(" 0x000%X", cluInfo.accessCluster[j][k]);
						else
							xil_printf(" 0x%X", cluInfo.accessCluster[j][k]);

					}
					printf("\r\n");
				}
				printf("\r\n");

				// 打印任务子网簇信息
				xil_printf("TaskClusterInfo:\r\n");
				xil_printf("TaskCluster NetNum: %d\r\n", cluInfo.taskRows);
				for(j = 0; j < cluInfo.taskRows; j++)
				{
					xil_printf("TaskCluster NET-0%d: ", j + 1);
					for(k = 0; k < cluInfo.taskCols[j]; k++)
					{
						if (0 == cluInfo.taskCluster[j][k])
							xil_printf(" 0x000%X", cluInfo.taskCluster[j][k]);
						else
							xil_printf(" 0x%X", cluInfo.taskCluster[j][k]);
					}
					printf("\r\n");
				}
				printf("\r\n");
				*/







				// 重新入网
				masterId = localId;
				routeStartTimeFlag = 0;
				routeEndTimeFlag[ID] = 0;
				NetworkFlag[changeId.IDST.NodeID] = 0x0F;
				JoinNetActive(changeId.ID, 0);
			}
			else
			{
				xil_printf("it is not a mointor node, 0x%x\r\n",tempID);
				JoinNetCtrl(dstID);
			}
			break;

		// 能力层级测试
		case 97:
			xil_printf("[send pkt route]\r\n");
			srcID = 256*pBuf[2] + pBuf[1];
			dstID = 256*pBuf[4] + pBuf[3];
			packet_num = 1;

			xil_printf("srcID: 0x%X, destID: 0x%X\r\n", srcID, dstID);
			NwkSend(srcID, dstID, packet_num, 0, 10, typeG, 6);
			break;

		// 接收簇信息
		case 99:
			DeleteRouteTables();
			routeStartTimeFlag = 1;
			NodeNum = 0;

			memset(pCluInfo, 0, sizeof(CLU_INFO_TYPE));
			NodeNum = pBuf[1];


			i = 2;
			if((clusterInfoSem = xSemaphoreCreateMutex()) == NULL)
			{
				printf("clusterInfoSem create error\n");
				return False;
			}
			 // 处理所有节点
			for (int nodeIndex = 0; nodeIndex < NodeNum; nodeIndex++)
			{
				// 组合两个字节形成节点ID (小端序: 低字节在前，高字节在后)
				NodeIDInfo.ID = (pBuf[i] << 8) | pBuf[i+1];
				i += 2; // 移动到下一个节点ID


				if(ROLE_TYPE_SWITCH_NET_NODE == NodeIDInfo.IDST.role)
				{
					if(False == UpdateExchangeClusterInfo(pCluInfo, NodeIDInfo))
					{
						xil_printf("UpdateExchangeCluster error\r\n");
					}
				}
				else if((ROLE_TYPE_ACCESS_NET_COMMON_NODE == NodeIDInfo.IDST.role) || (ROLE_TYPE_ACCESS_NET_GATEWAY_NODE == NodeIDInfo.IDST.role))
				{
					if(False == UpdateAccessClusterInfo(pCluInfo, NodeIDInfo))
					{
						xil_printf("UpdateAccessClusterInfo error\r\n");
					}
					if(False == UpdateTaskClusterInfo(pCluInfo, NodeIDInfo))
					{
						xil_printf("UpdateTaskClusterInfo error\r\n");
					}
				}
				else
				{
					if(False == UpdateTaskClusterInfo(pCluInfo, NodeIDInfo))
					{
						xil_printf("UpdateTaskClusterInfo error\r\n");
					}
				}
			}
			// 更新接入子网数
			for (i = 0; i < 15; i++)
			{
				if (0 != pCluInfo->accessCols[i])
				{
					pCluInfo->accessRows = i + 1;
				}
			}
			// 更新任务子网数
			for (i = 0; i < 100; i++)
			{
				if (0 != pCluInfo->taskCols[i])
					pCluInfo->taskRows = i + 1;
			}
			// 打印接收信息
			int j, k;
			xil_printf("Cluster Information:\r\n");

			// 打印交换网簇信息
			xil_printf("ExchangeClusterInfo:\r\n");
			xil_printf("ExchangeCluster NodeNum: %d\r\n", cluInfo.exchangeCount);
			xil_printf("ExchangeCluster NET: ");
			for(j = 0; j < cluInfo.exchangeCount; j++)
			{
				if (0 == cluInfo.exchangeCluster[j])
					xil_printf(" 0x000%X", cluInfo.exchangeCluster[j]);
				else
					xil_printf(" 0x%X", cluInfo.exchangeCluster[j]);
			}
			printf("\r\n");

			// 打印接入子网簇信息
			xil_printf("AccessClusterInfo:\r\n");
			xil_printf("AccessCluster NetNum: %d\r\n", cluInfo.accessRows);
			for(j = 0; j < cluInfo.accessRows; j++)
			{
				xil_printf("AccessCluster NET-0%d: ", j + 1);
				for(k = 0; k < cluInfo.accessCols[j]; k++)
				{
					if (0 == cluInfo.accessCluster[j][k])
						xil_printf(" 0x000%X", cluInfo.accessCluster[j][k]);
					else
						xil_printf(" 0x%X", cluInfo.accessCluster[j][k]);

				}
				printf("\r\n");
			}
			printf("\r\n");

			// 打印任务子网簇信息
			xil_printf("TaskClusterInfo:\r\n");
			xil_printf("TaskCluster NetNum: %d\r\n", cluInfo.taskRows);
			for(j = 0; j < cluInfo.taskRows; j++)
			{
				xil_printf("TaskCluster NET-0%d: ", j + 1);
				for(k = 0; k < cluInfo.taskCols[j]; k++)
				{
					if (0 == cluInfo.taskCluster[j][k])
						xil_printf(" 0x000%X", cluInfo.taskCluster[j][k]);
					else
						xil_printf(" 0x%X", cluInfo.taskCluster[j][k]);
				}
				printf("\r\n");
			}
			printf("\r\n");



			//RoutesCluInfoBroad(pBuf,len);


			InitClurouteTableForAll();
			/*
			printf("RouteTable initial\r\n");
			for(i = 1; i <= routeTableNum; i++)
			{
				if (NULL == routeTables[i]->head)
					continue;
				ID_INFO_TYPE indexId;
				indexId.ID = routeTables[i]->head->srcID;
				if (indexId.IDST.role != ROLE_TYPE_TASK_NET_COMMON_NODE)
				{
					printf("ID: 0x%X, Flag: 0x%X, routelastlength: %d, routeTableslength: %d\r\n", indexId.ID, NetworkFlag[i], routelastlength[i], routeTables[i]->length);
				}
			}
			*/
			break;
			/*
		case 119:
			comRate = pBuf[1];
			LOGD("\n[SERVER_CMD_SET_SLOT_LEN] set slot len = %d\n", comRate);
			SetComRate();
			*/
			break;
		case 120:
			cmdBuff[0] = GetComRate();
			LOGD("\n[SERVER_CMD_GET__COM_RATE] Get com rate = %d\n", cmdBuff[0]);
			SendToConsolePort32000(120, cmdBuff, 1);
			break;
		case 121:
			businessPlanPar.dataSizeMode = pBuf[1];
			businessPlanPar.dataSize = 256*pBuf[3]+pBuf[2];
			businessPlanPar.sendRate = pBuf[4];
			businessPlanPar.pktIntervalTime = 256*pBuf[6]+pBuf[5];
			businessPlanPar.priority = pBuf[7];
			businessPlanPar.sendId = 256*pBuf[9]+pBuf[8];
			businessPlanPar.recvId = 256*pBuf[11]+pBuf[10];
			businessPlanPar.startMode = pBuf[12];
			businessPlanPar.delayTime = 256*pBuf[14]+pBuf[13];
			businessPlanPar.sendMode = pBuf[15];
			businessPlanPar.sendPeriod = 256*pBuf[17]+pBuf[16];
			xil_printf("dataSizeMode:%d,dataSize:%d,sendRate:%d,priority:%d,srcID: 0x%x, destID: 0x%x,startMode:%d,delayTime:%d,sendMode:%d,sendPeriod:%d\r\n",
					businessPlanPar.dataSizeMode, businessPlanPar.dataSize,
					businessPlanPar.sendRate, businessPlanPar.priority,
					businessPlanPar.sendId, businessPlanPar.recvId,
					businessPlanPar.startMode,businessPlanPar.delayTime,
					businessPlanPar.sendMode, businessPlanPar.sendPeriod);
			if (True == CheckID(businessPlanPar.sendId))
			{
				ret = xTaskCreate((void *)BusinessPlanProcess, "business_plan_proc", 20480, (void *)&businessPlanPar, 3, NULL);
				if(ret != pdPASS)
					LOGE("nwk_rx: Failed to create dll_send_pkt task.\r\n");
			}

			break;
		case 122:
			businessPlanSendData = 0;
			break;
		case 123:								// 开始上报信道质量
			QueryID = 256*pBuf[2] + pBuf[1];
			RateUpFlag = 1;
			LOGD("[QUERY_ID_RATE_UPLOAD] QueryID: 0x%X\r\n", QueryID);
			break;
		case 124:								// 停止上报信道质量
			RateUpFlag = 0;
			LOGD("[RATE_UPLOAD_SUSPEND]\r\n");
			break;
		case 125:
			if (pBuf[1])//start report recvPktStatic info
			{
				printf("start report recvPktStatic info\r\n");
				xTimerStart(recvPktStaticTimer, portMAX_DELAY);
				t_2 = emc_read(SYNC_TIME_SHOW_2);
				t_1 = emc_read(SYNC_TIME_SHOW_1);
				t_0 = emc_read(SYNC_TIME_SHOW_0);

				t = ((uint64_t)t_2 << 32) + ((uint64_t)t_1 << 16) + (uint64_t)t_0;
				t *= 8;//纳秒

				recvPktStaticPktNum = int_38;
				recvPktStaticTime = t;
			}
			else//stop report recvPktStatic info
			{
				printf("stop report recvPktStatic info\r\n");
				xTimerStop(recvPktStaticTimer, portMAX_DELAY);
			}
			break;
		case 126:								// 时域配置
			TimeHopeFlag = pBuf[1];	// 配置跳时参数
			SendRate = pBuf[2];		// 配置发射速率
			if (0 == TimeHopeFlag)	// 配置调试间隔(非跳时时才会接收间隔）
				DutyRatio = 2;
				//DutyRatio = 256*pBuf[2] + pBuf[1];
			//SetComRate();
			break;
		case 127:								// 频域配置
			StateFlag = pBuf[1];		// 定频配置参数，0为定频， 1为跳频
			if (0 == StateFlag)
				StatePoint = pBuf[2];
			printf("StateFlag: %d, StatePoint: %d\r\n", StateFlag, StatePoint);
			if (1 == StateFlag)			// 跳频
			{
				emc_write(0x210,0);				// 配置定频跳频，0为跳频，1为定频
				emc_write(0x212,0);				// 定频频点选额（0-14共15个频点）
			}
			else if (0 == StateFlag)	// 定频
			{
				emc_write(0x210,1);				// 配置定频跳频，0为跳频，1为定频
				emc_write(0x212, StatePoint);	// 定频频点选额（0-14共15个频点）
			}
			break;
		case 132:
			printf("quit all nodes\r\n");
			allNodesQuitFlag = 1;
			periodicStartFlag = 0;		// 停发路由
			xTimerStop(routeBroadcastTimer, portMAX_DELAY);
			periodChangeFlag = 0;
			vTaskSuspend(nwkHello);

			for(i = 1; i <= routeTableNum; i++)
			{
				if (NULL == routeTables[i])
					continue;
				if (NULL == routeTables[i]->head)
					continue;
				rxQuitNetflag[i] = 0;
				rxJoinNetflag[i] = 0;
				//vTaskSuspend(nwkHello);

				// 删除QuitID对应的路由
				p = routeTables[i]->head;
				while(p != NULL)
				{

					if(p->destID == routeTables[i]->head->srcID)
					{
						xSemaphoreTake(routeTableSem, portMAX_DELAY);
						p->serialNumber = 0;
						xSemaphoreGive(routeTableSem);
						p = p->next;
					}
					else
					{
						tempPtr = p;
						p = p->next;
						RouteEntryDelete(tempPtr);
					}
				}
				routelastlength[i] = routeTables[i]->length;
			}
			txPeriodicPktNum = 0;
			break;
//20260902 edit
		case 133:
			printf("initialization setting\r\n");
			ctrl_bpsk = pBuf[1];
			memcpy(&fre_bpsk, &pBuf[2], 8);
			memcpy(&atten_bpsk, &pBuf[10], 8);
			ctrl_qpsk = pBuf[18];
			memcpy(&fre_qpsk, &pBuf[19], 8);
			memcpy(&atten_qpsk, &pBuf[27], 8);
			tx_rate_sel = (len >= 36) ? (u8)(pBuf[35] & 0x1) : 0;

			tx_init();

			printf("bpsk set as: enable = %d, dds_f = %f, attenuation = %f.\r\n", ctrl_bpsk, fre_bpsk, atten_bpsk);
			printf("qpsk set as: enable = %d, dds_f = %f, attenuation = %f.\r\n", ctrl_qpsk, fre_qpsk, atten_qpsk);
			printf("tx rate select = %d.\r\n", tx_rate_sel);
			break;
		case 134:
		{
			U16 chunk_idx;
			U16 n_chunks;
			U32 word_offset;
			int k;

			/* 超长包会被 lwip_read 静默截断，短包尾部是 memset 过的 0，
			 * 所以只认精确长度 —— 宁可丢包，也不能拿半截数据去填表 */
			if (len != TX_TABLE_PKT_LEN)
			{
				printf("tx table: bad len %d (expect %d), dropped\r\n",
				       len, TX_TABLE_PKT_LEN);
				break;
			}

			/* 包头 2..3 是包序号；表不同，总包数不同 */
			n_chunks  = (pBuf[1] == 0) ? TX_TABLE_CHUNKS_BPSK : TX_TABLE_CHUNKS_QPSK;
			chunk_idx = (U16)(pBuf[2] | ((U16)pBuf[3] << 8));
			if (pBuf[1] > 1 || chunk_idx >= n_chunks)
			{
				printf("tx table: bad sel/chunk %u/%u, dropped\r\n",
				       pBuf[1], chunk_idx);
				break;
			}
			word_offset = (U32)chunk_idx * TX_TABLE_CHUNK_WORDS;

			/* 包头一包开新表：丢掉上一张没收完的残包 */
			if (chunk_idx == 0)
			{
				memset(tx_table_got, 0, sizeof(tx_table_got));
				tx_table_cnt = 0;
			}

			/* 重复到达的包只覆盖数据，不重复计数 */
			if (!tx_table_got[chunk_idx])
			{
				tx_table_got[chunk_idx] = 1;
				tx_table_cnt++;
			}

			for (k = 0; k < TX_TABLE_CHUNK_WORDS; k++)
			{
				tx_table_buf[word_offset + k] =
					(U16)(pBuf[4 + 2 * k] | ((U16)pBuf[5 + 2 * k] << 8));
			}

			printf("tx table: sel %u chunk %u/%u got %u/%u\r\n",
			       pBuf[1], chunk_idx, n_chunks - 1,
			       tx_table_cnt, n_chunks);

			/* 整表到齐，一次性落地 */
			if (tx_table_cnt == n_chunks)
			{
				if (pBuf[1] == 0)
				{
					write_bpsk_ram(tx_table_buf, TX_TABLE_WORDS_BPSK);
				}
				else
				{
					write_qpsk_ram(tx_table_buf, TX_TABLE_WORDS_QPSK);
				}
				tx_table_cnt = 0;
				memset(tx_table_got, 0, sizeof(tx_table_got));
			}
			break;
		}
//20260902
		default:
			printf("debug: type %d wrong", type);
			break;
	}
}



#ifdef CONSOLE_CONNECT_MODE_UART
U8 GetHeadPos(U16 startPos,U16 endPos,U16 *ptrHeadPos)
{
	U16 count = startPos;
	while(count<endPos)
	{
		if ((0xEB==recvUartBuffer[count])&&(0x90==recvUartBuffer[count+1]))//find head
		{
			*ptrHeadPos = count;
			break;
		}
		count++;
	}
	if(count>=endPos)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

U8 procUartData(void)
{
	U16 count = 0;
	U16 headPos = 0;

	U16 crc = 0;
	U16 recvCrc = 0;
	U16 temp = 0;
	U8 status = 0;
	U8 retVal = 0;
	U16 startPos = 0;
	U16 endPos = 0;

	if (uartBufferdataLen<7)
	{
		return FALSE;
	}
	/*xil_printf("recv cmd data:\r\n");
	count = 0;
	while (count<uartBufferdataLen)
	{
		xil_printf("0x%x ", recvUartBuffer[count]);
		count++;
	}
	xil_printf("\r\n");*/
	startPos = 0;
	endPos = uartBufferdataLen-1;
	if(1==GetHeadPos(startPos,endPos,&headPos))
	{
		status = 1;

		if ((startPos+3)<uartBufferdataLen)//fined cmd len
		{
			cmdLen = recvUartBuffer[startPos+3];
			cmdLen = ((cmdLen<<8)|recvUartBuffer[startPos+2]);
			//xil_printf("cmdLen=%d\r\n",cmdLen);
			if ((uartBufferdataLen-(headPos+4)) >= cmdLen+2)//crc
			{
				count = headPos;
				crc = 0;
				while(count < headPos+4+cmdLen)
				{
					crc += recvUartBuffer[count];
					count++;
				}
				recvCrc = recvUartBuffer[count+1];
				recvCrc = (recvCrc<<8)|recvUartBuffer[count];
				//xil_printf("recvCrc=0x%x,crc=0x%x\r\n",recvCrc, crc);
				if (crc==recvCrc)
				{
					status = 2;
				}
				else
				{
					status = 3;
				}
			}
		}
	}
	//xil_printf("status=%d!\r\n",status);
	switch (status)
	{
		case 0:
			recvUartBuffer[0] = recvUartBuffer[uartBufferdataLen-1];
			uartBufferdataLen = 1;
			break;
		case 1:
			startPos=headPos+2;
			endPos = uartBufferdataLen-1;
			if (1 == GetHeadPos(startPos,endPos,&count))
			{
				headPos = count;
			}
			memmove(recvUartBuffer, &recvUartBuffer[headPos], uartBufferdataLen-headPos);
			uartBufferdataLen = uartBufferdataLen-headPos;
			break;
		case 2:
			//xil_printf("recv cmd sucess!\r\n");
			memcpy(CMDBuf,&recvUartBuffer[headPos+4], cmdLen);
			memmove(recvUartBuffer, &recvUartBuffer[headPos+4+cmdLen+2], uartBufferdataLen-(headPos+4+cmdLen+2));
			uartBufferdataLen = uartBufferdataLen-(headPos+4+cmdLen+2);
			retVal = 1;
			break;
		case 3:
			startPos = headPos+2;
			endPos = uartBufferdataLen-1;
			if (1 == GetHeadPos(startPos,endPos,&count))
			{
				headPos = count;
				memmove(recvUartBuffer, &recvUartBuffer[headPos], uartBufferdataLen-headPos);
				uartBufferdataLen = uartBufferdataLen-headPos;
			}
			else
			{
				memmove(recvUartBuffer, &recvUartBuffer[headPos+4+cmdLen+2], uartBufferdataLen-(headPos+4+cmdLen+2));
				uartBufferdataLen = uartBufferdataLen-(headPos+4+cmdLen+2);
			}
			break;
		default:
			break;
	}
	return retVal;
}

void Pack(U8 *pData, U16 dataLen, U8 *pMsg)
{
	U16 count = 0;
	U16 crc = 0;

	pMsg[0] = 0xEB;
	pMsg[1] = 0x90;
	pMsg[2] = dataLen;
	pMsg[3] = (dataLen>>8);
	//xil_printf("pack data:\r\n");
	while(count<dataLen)
	{
		pMsg[count+4] = pData[count];
		//xil_printf("%d,",pData[count]);
		count++;
	}
	//xil_printf("\r\n");
	count = 0;
	while(count<(4+dataLen))
	{
		crc += pMsg[count];
		count++;
	}

	pMsg[4+dataLen] = crc;
	pMsg[4+dataLen+1] = (crc>>8);
}
void SendUartData(u8 *bufferPtr, u32 NumBytes)
{
	U32 SentCount = 0;
	U32 remainBytes = NumBytes;
	u8 *pData = bufferPtr;
	while(remainBytes>0)
	{
		if (remainBytes>50)
		{
			(void)XUartPs_Send(&Uart_Ps,pData, 50);
			remainBytes -= 50;
			pData += 50;
		}
		else
		{
			(void)XUartPs_Send(&Uart_Ps,pData, remainBytes);
			remainBytes = 0;
		}

	}
}

void UartCtrl()
{
	int ret,i;
	int ii;
	int retVal = 0;
	int SentCount =  0;

	ret = Iuartps_init();
	i = 0;
	char tf[20] = "successful init uart";
	SentCount = XUartPs_Send(&Uart_Ps,tf, sizeof(tf));
//	emc_write(0x200, 3);
//	LoopSend(100, 1, 0, 1);
	emc_write(0x200, 0);
	emc_write(0x21A, 0);

	while(1){
#if 1
		uartBufferdataLen = 0;
		while(1){
			//uart接收数据
			retVal = XUartPs_Recv(&Uart_Ps, &recvUartBuffer[uartBufferdataLen], (UART_BUFFER_SIZE - uartBufferdataLen));
			uartBufferdataLen += retVal;

			if (1 == procUartData())
			{
				ProcCmd(CMDBuf,cmdLen);
			}

			vTaskDelay(pdMS_TO_TICKS(100));
			//xil_printf("recv data len %d,uart buffer data len %d.\r\n", retVal, uartBufferdataLen);
			//retVal = 0;
			//xil_printf("receive data:%d.\n", Recv_uart_Buffer);

			//SentCount = XUartPs_Send(&Uart_Ps,recvUartBuffer, 1);
			//break;
		}
#endif
		//xil_printf("count:%d.\r\n",i);
		//XUartPs_Send(&Uart_Ps,recvUartBuffer, uartBufferdataLen);
		//NwkSend(2, 1, 0, 0);

		if(i >= 3)
		{
			i = 0;
		}
		emc_write(0x200 , i);
		i++;

		for (ii=1 ; ii<101 ; ii++)
		{
			LoopSend(1, 1, 0, 1);


			//vTaskDelay(pdMS_TO_TICKS(1000));
			continue;
		}
#if 0

	while(1){
		ReceivedCount = 0;
		//uart接收数据
		while (ReceivedCount < UART_BUFFER_SIZE) {
			ReceivedCount +=
				XUartPs_Recv(&Uart_Ps, &Recv_uart_Buffer[ReceivedCount],
						   (UART_BUFFER_SIZE - ReceivedCount));
		}
		ReceivedCount = 0;
		SentCount = XUartPs_Send(&Uart_Ps,Recv_uart_Buffer, sizeof(Recv_uart_Buffer));
	}
#endif
	}
}
#endif
void InitTask(void)
{
#ifndef CLOSE_NWK_TASK
	InitNwkTask();
#endif
	InitDllTask();
}

/*  @brief 版本打印   */
void PrintVersion(void)
{
	xil_printf("\n\n"
			   "***************************************\n");
	xil_printf("** \r\n**    Adhoc Software2024\r\n");
    xil_printf("** \r\n** Version: 20240817 advanced_version\n");
    xil_printf("** \r\n** ProjectName: ps_pl(reduce_pluse)_both_new_srio_all_command\n");
    xil_printf("** \r\n** SysMode: 	%s.\r\n** \r\n** MacMode: 	%s.\n**\n", SYS_MODE, MAC_MODE);
    xil_printf("** RadioType:   %s.\n**\n", RADIO_TYPE);
    xil_printf("***************************************\n");
}
/* --- Start  Task  --- */
void StartTask(void)
{
    vTaskStartScheduler();
    while(1);
}

/* --- get  Rand  Num ---  */
U32 getRandNum(U32 MaxNum)
{
    srand(xTaskGetTickCount());
    return rand()%MaxNum;
}

/* --- delay  AD9689 ---  */
void delay_AD9689(int t)
{
	int i;
	for (i=0;i<t;i++){
	}
}

void WarnPrint(void)
{
#if 1
    NwkPrint();
    DllPrint();
//    SrioPrint();
#else
    unsigned int   	_int_rx				=	int_rx,
                    _int_38             =   int_38;
    int_rx = 0;
    int_38 = 0;
    xil_printf("\r\n"
            "int_rx:%d \r\n", _int_rx);
    xil_printf("int_38:%d\r\n", _int_38);
#endif
}


#if 0
void recv_thread(){
	int recv_flag;
	int num = 0;
	int num_big = 0;
	emc_write(EMC_READ_PS_FLAG,0);
	emc_write(EMC_READ_PS_FLAG,1);
	u32 Index = 0;
	u32 SentCount;
	uart_frame Recv;
	while(1){
		recv_flag = 0;
		recv_flag = emc_read(EMC_READ_FLAG_ADDR) & 0x0003;
		if (recv_flag != 0){
			Recv.data[Index] = emc_read(EMC_RECV_ADDR) ;
			Recv.data[Index] = ((Recv.data[Index]<< 8 ) | (Recv.data[Index]>> 8 ))& 0x0000ffff;
			//SentCount = XUartPs_Send(&Uart_PS, &Index, 2);
			if(Index >= EMC_BUFFER_SIZE - 1){
				Index = 0;
				//将接收到的数据存入uart_frame Recv数据结构
				Recv.head   = 0xffff;
				Recv.length = sizeof(uart_frame) - 7;
				Recv.length = ((Recv.length<< 8 ) | (Recv.length>> 8 ))& 0x0000ffff;
				Recv.func   = 1;
				Recv.number = num + 1;
				Recv.num_big = num_big + 1;
				Recv.num_big = ((Recv.num_big << 8 ) | (Recv.num_big>> 8 ))& 0x0000ffff;
				Recv.tail = 0xff0f;
				num = num + 1;
				if(num >= 10){
					num = 0;
					num_big ++;
				}
				SentCount = 0;
				u8* uart_ptr;
				uart_ptr = &Recv;
				while(1){
					SentCount = SentCount + XUartPs_Send(&Uart_PS, uart_ptr + SentCount, sizeof(uart_frame) - SentCount);
					while (XUartPs_IsSending(&Uart_PS)) {
					}//将数据发送到uart
					//uart_ptr = uart_ptr + 40 ;
					if(SentCount >= sizeof(uart_frame))
						break;
				}
		}else{
			Index++;
		}
		emc_write(EMC_READ_OVER_FLAG,1);
		}
	}
}
#endif

//int Iuartps_init(){
//	int Status;
//	XUartPs_Config *Config;
//	Config = XUartPs_LookupConfig(UART_DEVICE_ID);
//	if (NULL == Config) {
//		return XST_FAILURE;
//	}
//
//	Status = XUartPs_CfgInitialize(&Uart_Ps, Config, Config->BaseAddress);
//	if (Status != XST_SUCCESS) {
//		return XST_FAILURE;
//	}
//
//	/* Check hardware build. */
//	Status = XUartPs_SelfTest(&Uart_Ps);
//	if (Status != XST_SUCCESS) {
//		return XST_FAILURE;
//	}
//
//	/* 设置uart模式 */
//	XUartPs_SetOperMode(&Uart_Ps, XUARTPS_OPER_MODE_NORMAL);
//	XUartPs_SetBaudRate(&Uart_Ps,115200);
//	return XST_SUCCESS;
//}

#if 0
int consoleSfd;
struct sockaddr_in consoleAddr;
void ReadParaShow(unsigned short para)
{
    socklen_t sockaddr_len = sizeof(struct sockaddr);
	CONSOLE_SEND_TYPE EmcreadParaPkt;
	char send_buf[10];
	int ret;

    EmcreadParaPkt.flag = 5;
    EmcreadParaPkt.AppSdu[0] = (unsigned char)(para & (0xff));
    EmcreadParaPkt.AppSdu[1] = (unsigned char)((para >> 8) & (0xff));
    memset((void *)send_buf, 0, sizeof(send_buf));
    memcpy((void *)send_buf, &EmcreadParaPkt, 3);

    if(mac_initial_flag == 1 && sockCanUseflag == 1)
    {
    	ret = socket_sendto(consoleSfd, (void *)&send_buf, 3, 0,
    	                      (struct sockaddr *)&consoleAddr, sockaddr_len);
    	if (ret < 0)
    	{
    	    xil_printf("error writing sock consoleSfd EmcreadPara %d %s.\r\n", errno, strerror(errno));
    	}
    }

	return;
}
#endif


void ReportInitState(u16 ID)
{
	U8 cmdBuff[10] = {0};
	cmdBuff[0] = 118;
	cmdBuff[1] = ID;
	cmdBuff[2] = (ID>>8);
	cmdBuff[3] = 1;
	SendToConsole(cmdBuff,4,MODE_ETHERNET,32000);
}

#ifdef CONSOLE_CONNECT_MODE_ETHERNET
void adhocCtrl(void)
{
    int ret, i;
    int adhocCtrlSfd = -1;
    struct sockaddr_in ctrlAddr;
    U16 t_2 = 0;
	U16 t_1 = 0;
	U16 t_0 = 0;
	uint64_t t = 0;

    xil_printf("Enter adhoc control task 2025.11.28.1\r\n");

    adhocCtrlSfd = lwip_socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);  // 创建socket
    if (adhocCtrlSfd < 0) {
        xil_printf("error creating socket.\r\n");
        vTaskDelete(NULL);
        return;
    }
//    else
//    	xil_printf("succeed to creating socket. %d\r\n", adhocCtrlSfd);


    memset((void *)&ctrlAddr, 0, sizeof(ctrlAddr));
    ctrlAddr.sin_family = AF_INET;
    ctrlAddr.sin_port = htons(14147);
    ctrlAddr.sin_addr.s_addr = IPADDR_ANY;//inet_addr("192.168.1.10");

    ret = lwip_bind(adhocCtrlSfd, (struct sockaddr *)&ctrlAddr, sizeof(ctrlAddr));
    if (ret < 0) {
        xil_printf("error binding sock.\r\n");
        vTaskDelete(NULL);
    }
    ReportInitState(0xFFFF);

    /*xTimerStart(recvPktStaticTimer, portMAX_DELAY);
	t_2 = emc_read(SYNC_TIME_SHOW_2);
	t_1 = emc_read(SYNC_TIME_SHOW_1);
	t_0 = emc_read(SYNC_TIME_SHOW_0);

	t = ((uint64_t)t_2 << 32) + ((uint64_t)t_1 << 16) + (uint64_t)t_0;
	t *= 8;//纳秒

	recvPktStaticPktNum = int_38;
	recvPktStaticTime = t;*/

    while(1)
    {
//        xil_printf("Before lwip_read.\r\n");
    	cmdLen = lwip_read(adhocCtrlSfd, CMDBuf, 1400);
        //xil_printf("lwip_read ret is %d.\r\n",ret);
//        xil_printf("After lwip_read.\r\n");

        if(cmdLen <= 0){
            xil_printf("error receiving data.\r\n");
            break;
        }
        else {
        	/*xil_printf("CMDBuf:\r\n");
			for (i=0;i<cmdLen;i++)
			{
				if((i%10)==0)
				{
					xil_printf("\r\n");
				}
				xil_printf("0x%x \r\n",CMDBuf[i]);
			}*/
			ProcCmd(CMDBuf,cmdLen);
            //xil_printf("adhocCtrl socket received.\r\n");
            memset((void *)CMDBuf, 0, sizeof(CMDBuf));
        }
    }
}


#if 0
void InitAppSocketSem(void)
{
	if((g_AppSocketDataBufProtectSem = xSemaphoreCreateMutex()) == NULL)
	{
		LOGE("g_AppSocketDataBufProtectSem create error\r\n");
	}
	else
	{
		LOGD("g_AppSocketDataBufProtectSem create sucess\r\n");
	}
}
#endif
void SendToConsolePort32000(unsigned char *pData, unsigned short dataLen)
{
	socklen_t sockaddr_len = sizeof(struct sockaddr);

	int ret = 0;
	if(mac_initial_flag == 1 && sockCanUseflag == 1)
	{
		memset((void *)&consoleAddr, 0, sizeof(consoleAddr));
		consoleAddr.sin_family = AF_INET;
		consoleAddr.sin_port = htons(32000);
		consoleAddr.sin_addr.s_addr = inet_addr(hostIPDef);
		ret = lwip_sendto(consoleSfd, (void *)pData, dataLen, 0,
							  (struct sockaddr *)&consoleAddr, sockaddr_len);
		if (ret < 0)
		{
			xil_printf("error writing sock consoleSfd %d %s.\r\n", errno, strerror(errno));
		}
		else
		{
			//xil_printf("send socket sucess!");
		}
	}
	else
	{
		xil_printf("can't send socket!");
	}
	//xSemaphoreGive(g_AppSocketDataBufProtectSem);
}
#if 1

void SendToConsolePort27000(unsigned char *pData, unsigned short dataLen)
{
	socklen_t sockaddr_len = sizeof(struct sockaddr);
	int ret = 0;

	if(mac_initial_flag == 1 && sockCanUseflag == 1)
	{
		memset((void *)&syncAddr, 0, sizeof(syncAddr));
		syncAddr.sin_family = AF_INET;
		syncAddr.sin_port = htons(27000);
		syncAddr.sin_addr.s_addr = inet_addr(hostIPDef);
		ret = lwip_sendto(syncSfd, (void *)pData, dataLen, 0,
							  (struct sockaddr *)&syncAddr, sockaddr_len);
		if (ret < 0)
		{
			LOGE("error writing sock syncSfd syncInfo %d %s.\r\n", errno, strerror(errno));
		}
		//LOGD("SlaveNodeInfoShow: SlaveNodeInfo send to console!\r\n");
	}
	else
	{
		LOGD("can't send socket!");
	}
	//xSemaphoreGive(g_AppSocketDataBufProtectSem);
}

void SendToConsolePort22000(unsigned char *pData, unsigned short dataLen)
{
	socklen_t sockaddr_len = sizeof(struct sockaddr);
	int ret = 0;
	if (NULL == pData)
	{
		LOGD("ERROR:NULL == pData!");
	}
	//LOGD("mac_initial_flag=%d,sockCanUseflag=%d,dataLen=%d!",mac_initial_flag,sockCanUseflag,dataLen);
	if(mac_initial_flag == 1 && sockCanUseflag == 1)
	{
		memset((void *)&RouteEntryAddr, 0, sizeof(RouteEntryAddr));
		RouteEntryAddr.sin_family = AF_INET;
		RouteEntryAddr.sin_port = htons(22000);
		RouteEntryAddr.sin_addr.s_addr = inet_addr(hostIPDef);
		ret = lwip_sendto(RouteEntrySfd, (void *)pData, dataLen, 0,
							  (struct sockaddr *)&RouteEntryAddr, sockaddr_len);
		if (ret < 0)
		{
			LOGE("error writing RouteEntrySfd %d %s.\r\n", errno, strerror(errno));
		}
		/*else
		{
			LOGD("send socket sucess!");
		}*/
	}
	else
	{
		LOGD("can't send socket!");
	}
}
#endif

#endif

//struct TMV_DATA_REQ_type {
//    U32 dataType;///< 数据分类，指示发送寄存器
//    U32 Link_Num;///< 逻辑信道标识，与Dest_Addr唯一对应
//    U32 Priority;///< 优先级，指示发送顺序
//    U32 NextAddr;
//    //U32 Freq_chan;
//    U32 sendingPower;//发送功率
//    U32 antenna;//上下天线
//    //U32 MACBLOCK_Length;///< 发送长度
//    U8 MACBLOCK[MAX_MACBLOCK_LENGTH];///< 数据块
//} ;
//typedef struct TMV_DATA_REQ_type TMV_DATA_REQ_TYPE;
//void testCode(void)
//{
//    printf("testCode\n");
//    TMV_DATA_REQ_TYPE TmvReq;
//    TMV_DATA_REQ_TYPE* pTmvReq;
//    memset(&TmvReq, 0, sizeof(TMV_DATA_REQ_TYPE));
//    pTmvReq = &TmvReq;
//    U32 bitoffset = 0;
//
//    U32 destID = 5;
//
//    U32 dstid = 0, nxtid = 0, bit_offset = 19, _destID = 0, _dstid, _nxtid;
//
//    int i;
//    for(i=0;i<2;i++){
//        memset(pTmvReq, 0, sizeof(TMV_DATA_REQ_TYPE));
//        bitoffset = 0;
//        if(i == 0)
//            destID = 0xFFFF;
//        else if(i==1)
//            destID = 5;
//        printf("id = %d\n", destID);
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 0, 2);
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 1, 1);
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 2, 3);
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 3, 5);
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 4, 8);
//        if(destID == 0xFFFF){
//            printf("id = %d\n", destID);
//            IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 0xFF, 8);
//            IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 0xFF, 8);
//        }
//        else{
//            printf("id = %d\n", destID);
//            IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, destID, 8);
//            IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, destID + 1, 8);
//        }
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 7, 3);
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 6, 3);
//        IntAdd2Char(pTmvReq->MACBLOCK, &bitoffset, 117, 7);
//
//        dstid = 0;
//        nxtid = 0;
//        bit_offset = 19;
//        _destID = 0;
//        dstid = GetBits(pTmvReq->MACBLOCK, &bit_offset, 8);
//        nxtid = GetBits(pTmvReq->MACBLOCK, &bit_offset, 8);
//        _destID = (((dstid & 0x00FF) << 8) & 0xFF00) + (nxtid & 0x00FF);
//        printf("dstid = %d  nxtid = %d  _destID = %d\n", dstid, nxtid, _destID);
//        _dstid = ((_destID & 0xFF00) >> 8) & 0x00FF;
//        _nxtid = _destID & 0x00FF;
//        printf("_dstid = %d  _nxtid = %d\n", dstid, nxtid);
//    }
//}


void SendToConsole(unsigned char *pMsg, U16 len, U8 connectMode, U16 portNum)
{
	//LOGD("connectMode=%d,portNum=%d!",connectMode,portNum);
	if (connectMode == MODE_ETHERNET)
	{
		if (portNum == 32000)
		{
			SendToConsolePort32000(pMsg, len);
		}
		else if (portNum == 27000)
		{
			SendToConsolePort27000(pMsg, len);
		}
		else if (portNum == 22000)
		{
			//LOGD("enter SendToConsole!");
			SendToConsolePort22000(pMsg, len);
		}
	}
	else
	{
#ifdef CONSOLE_CONNECT_MODE_UART
		Pack(pMsg, len, sendBuff);
		(void)XUartPs_Send(&Uart_Ps,sendBuff, len+6);
#endif
	}
	//xil_printf("SendToConsole over\n");
}



Bool UpdateExchangeClusterInfo(CLU_INFO_TYPE * pCluInfo, ID_INFO_TYPE NodeIDInfo)
{
    if (pCluInfo == NULL || pCluInfo->exchangeCount == 3)
    {
        return False;
    }
    int i;
    xSemaphoreTake(clusterInfoSem, portMAX_DELAY);
    // 检测非法ID
    if (0 != pCluInfo->exchangeCluster[NodeIDInfo.IDST.accessNetNum-1])
    {
    	xil_printf("illegal exchange nodeID: %d\r\n", NodeIDInfo.ID);
    	return False;
    }
    // 写入簇信息
    else
    {
    	pCluInfo->exchangeCluster[NodeIDInfo.IDST.accessNetNum-1] = NodeIDInfo.ID;
    	// 更新交换节点计数
		if (NodeIDInfo.IDST.accessNetNum > pCluInfo->exchangeCount)
			pCluInfo->exchangeCount = NodeIDInfo.IDST.accessNetNum;
    }
    xSemaphoreGive(clusterInfoSem);
    return True;
}
Bool UpdateAccessClusterInfo(CLU_INFO_TYPE * pCluInfo, ID_INFO_TYPE NodeIDInfo)
{
    if (pCluInfo == NULL || pCluInfo->accessRows == 15)
    {
        return False;
    }
    int i;
    xSemaphoreTake(clusterInfoSem, portMAX_DELAY);
    if (ROLE_TYPE_ACCESS_NET_GATEWAY_NODE == NodeIDInfo.IDST.role)
    {
    	// 检测非法ID
    	if (0 != pCluInfo->accessCluster[NodeIDInfo.IDST.accessNetNum-1][0])
    	{
    		xil_printf("illegal Access nodeID: %d\r\n", NodeIDInfo.ID);
			return False;
    	}
    	// 写入簇信息
    	else
    	{
    		pCluInfo->accessCluster[NodeIDInfo.IDST.accessNetNum-1][0] = NodeIDInfo.ID;
    		// 更新接入子网内节点数
			if (1 > pCluInfo->accessCols[NodeIDInfo.IDST.accessNetNum-1])
				pCluInfo->accessCols[NodeIDInfo.IDST.accessNetNum-1] = 1;
    	}
    }



    else
    {
    	for(i = 1; i < 15; i++)
    	{
    		if (0 == pCluInfo->accessCluster[NodeIDInfo.IDST.accessNetNum-1][i])
    		{
    			// 写入簇信息
    			pCluInfo->accessCluster[NodeIDInfo.IDST.accessNetNum-1][i] = NodeIDInfo.ID;
    			// 更新接入子网内节点数
    			if (i + 1 > pCluInfo->accessCols[NodeIDInfo.IDST.accessNetNum-1])
    				pCluInfo->accessCols[NodeIDInfo.IDST.accessNetNum-1] = i + 1;
    			break;
    		}
    	}
     }
    xSemaphoreGive(clusterInfoSem);
    return True;
}
Bool UpdateTaskClusterInfo(CLU_INFO_TYPE * pCluInfo, ID_INFO_TYPE NodeIDInfo)
{
    if (pCluInfo == NULL || pCluInfo->taskRows == 254)
    {
        return False;
    }

    xSemaphoreTake(clusterInfoSem, portMAX_DELAY);
    int i;
    if (ROLE_TYPE_ACCESS_NET_GATEWAY_NODE == NodeIDInfo.IDST.role || ROLE_TYPE_ACCESS_NET_COMMON_NODE == NodeIDInfo.IDST.role)
    {
    	pCluInfo->taskCluster[NodeIDInfo.IDST.taskNetNum-1][0] = NodeIDInfo.ID;
    	// 更新接入子网内节点数
    	if (1 > pCluInfo->taskCols[NodeIDInfo.IDST.taskNetNum-1])
			pCluInfo->taskCols[NodeIDInfo.IDST.taskNetNum-1] = 1;
    }
    else
    {
    	for(i = 1; i < 100; i++)
    	{
    		if (0 == pCluInfo->taskCluster[NodeIDInfo.IDST.taskNetNum-1][i])
    		{
    			pCluInfo->taskCluster[NodeIDInfo.IDST.taskNetNum-1][i] = NodeIDInfo.ID;
    			if (i + 1 > pCluInfo->taskCols[NodeIDInfo.IDST.taskNetNum-1])
					pCluInfo->taskCols[NodeIDInfo.IDST.taskNetNum-1] = i + 1;
    			break;
    		}
    	}
     }
    xSemaphoreGive(clusterInfoSem);
    return True;
}

Bool CheckID(unsigned short nodeID)
{
	int i, j;
	CLU_INFO_TYPE * pCluInfo = &cluInfo;
	// 遍历交换网节点
	for (i = 0; i < pCluInfo->exchangeCount; i++)
	{
		if (nodeID == pCluInfo->exchangeCluster[i])
		{
			return True;
		}
	}
	// 遍历接入子网节点
	for (i = 0; i < pCluInfo->accessRows; i++)
	{
		for (j = 0; j < pCluInfo->accessCols[i]; j++)
		{
			if (nodeID == pCluInfo->accessCluster[i][j])
			{
				return True;
			}
		}
	}
	// 遍历任务子网节点
	for (i = 0; i < pCluInfo->taskRows; i++)
	{
		for (j = 0; j < pCluInfo->taskCols[i]; j++)
		{
			if (nodeID == pCluInfo->taskCluster[i][j])
			{
				return True;
			}
		}
	}
	return False;
}

void LoopSendProcess(void *p)
{
	DLLSEND_CTRL_TYPE *pCtrl = (DLLSEND_CTRL_TYPE *)p;
	unsigned short srcId = pCtrl->srcID;
	unsigned short destId = pCtrl->dstID;
	unsigned char length = pCtrl->dataLen;
	unsigned short num = pCtrl->sendnwknum;
	int count = 0;
	//xil_printf("LoopSendProcess,srcID:0x%x, dstID:0x%x, p->sendnwknum:%d! \r\n", pCtrl->srcID, pCtrl->dstID, pCtrl->sendnwknum);

	if (65535 == num)
	{
		while(1)
		{
			//xil_printf("LoopSendProcess! \r\n");
			LoopSend1(srcId, destId, 1, 0, 1);
			if ((1 == g_testRateStart) && (1 == g_testRateEnd))
			{
				g_testRateStart = 0;
				break;
			}
		}
	}
	else
	{
		for (count=0 ; count<num ; count++)
		{
			LoopSend1(srcId, destId, 1, 0, 1);
		}
	}
	g_DllSendPkt = 0;
	g_testRateStart = 0;
	vTaskDelete(NULL);
}

void BusinessPlanTimerOut(void)
{
	businessPlanSendData = 0;
}

void BusinessPlanProcess(void *p)
{
	BUSINESS_PLAN_PAR_TYPE *pCtrl = (BUSINESS_PLAN_PAR_TYPE *)p;
	U32 packet_num = 0;
	U16 sendTime = 0;//s
	unsigned int startTime = 0;
	unsigned int endTime = 0;
	U16 sendId = pCtrl->sendId;
	U16 recvId = pCtrl->recvId;
	U8 dataSizeMode = pCtrl->dataSizeMode;
	U16 dataSize = pCtrl->dataSize;
	U16 pktIntervalTime = pCtrl->pktIntervalTime;
	U8 priority = pCtrl->priority;
	U32 count = 0;

	//printf("BusinessPlanProcess,recvId :%d, dataSizeMode:%d,priority:%d !\r\n", pCtrl->recvId, pCtrl->dataSizeMode, priority);
	if (0 == dataSizeMode)//data size
	{
		packet_num = (dataSize*1000*1000/8/100);
	}
	else if (1 == dataSizeMode)//send time
	{
		sendTime = dataSize;
	}
	else
	{
		printf("dataSizeMode error!\r\n");
		vTaskDelete(NULL);
		return;
	}
	//SetComRate(pCtrl->sendRate);
	if (0 == pCtrl->startMode)//at once
	{
		//do nothing
	}
	else if (1 == pCtrl->startMode)//delay
	{
		vTaskDelay(pdMS_TO_TICKS(pCtrl->delayTime*1000));//ms
	}
	else
	{
		printf("startMode error!\r\n");
		vTaskDelete(NULL);
		return;
	}
	//printf("BusinessPlanProcess1,recvId :0x%x, dataSizeMode:%d,packet_num:%d !\r\n", recvId, dataSizeMode, packet_num);
	while(1)
	{
		if (packet_num != 0)
		{
			businessPlanSendData = 1;
			for (count = 0; count < packet_num; count++)
			{
				if (count != (packet_num-1))
				{
					NwkSend(sendId, recvId, 1, 0, pktIntervalTime, typeD, priority);
				}
				else
				{
					NwkSend(sendId, recvId, 1, 0, pktIntervalTime, typeDOver, priority);
				}
				if (0 == businessPlanSendData)
				{
					break;
				}
			}

			//xil_printf("send complete.\r\n");
		}
		else
		{
			printf("dataSizeMode time :%d s!\r\n", sendTime);
			if (businessPlanTimer==NULL)
			{
				businessPlanTimer = xTimerCreate("SYNCTimer", pdMS_TO_TICKS(sendTime*1000), pdFALSE, (void *) 0, (TimerCallbackFunction_t)BusinessPlanTimerOut);
				if(NULL == businessPlanTimer)
					xil_printf("Init: syncTimer Create Failed.\r\n");
			}
			else
			{
				xTimerChangePeriod(businessPlanTimer, pdMS_TO_TICKS(sendTime*1000), portMAX_DELAY);
			}
			businessPlanSendData = 1;
			xTimerStart(businessPlanTimer, portMAX_DELAY);
			//printf("BusinessPlanProcess2,recvId :%d, dataSizeMode:%d,pktIntervalTime:%d !\r\n", pCtrl->recvId, pCtrl->dataSizeMode, pCtrl->pktIntervalTime);
			while (businessPlanSendData)
			{
				NwkSend(sendId, recvId, 1, 0, pktIntervalTime, typeD, priority);
			}
			NwkSend(sendId, recvId, 1, 0, pktIntervalTime, typeDOver, priority);
			xTimerStop(businessPlanTimer, portMAX_DELAY);

			//xil_printf("send complete1.\r\n");
		}
		if(0 == pCtrl->sendMode)
		{
			xil_printf("only send one time,complete.\r\n");
			break;
		}
		else if(1 == pCtrl->sendMode)
		{
			xil_printf("send continue.\r\n");
		}
		else if(2 == pCtrl->sendMode)
		{
			vTaskDelay(pdMS_TO_TICKS(pCtrl->sendPeriod*1000));//ms
		}
		else
		{
			xil_printf("send Mode error.\r\n");
			break;
		}
	}
	vTaskDelete(NULL);
}

void SetComRate(void)
{
	unsigned int delay;
	unsigned int comHope = TimeHopeFlag;
	unsigned int comRate = SendRate;
	switch (comHope)
	{
		case 0:		// 非跳时
			switch (comRate)
			{
				case 0:			// 4Mbps
					emc_write(0x0E6, 4788); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x08);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					emc_write(0x006, 0);							// 配置时延
					emc_write(0x206, 0);
					break;
				case 1:			// 2Mbps
					emc_write(0x0E6, 4788); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x08);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					delay = 0x927C;
					emc_write(0x006, delay);						// 配置时延
					emc_write(0x206, delay >> 16);
					break;
				case 2:			// 1Mbps
					emc_write(0x0E6, 4788); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x08);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					delay = 0x1B774;
					emc_write(0x006, delay);						// 配置时延
					emc_write(0x206, delay >> 16);
					break;
				case 3:			// 500Kbps
					emc_write(0x0E6, 4788); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x08);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					delay = 0x40164;
					emc_write(0x006, delay);						// 配置时延
					emc_write(0x206, delay >> 16);
					break;
				default:
					printf("Wrong SendRate under TimeHope\r\n");
					break;
			}
			break;
		case 1:		// 跳时
			switch (comRate)
			{
				case 1:			// 2Mbps
					emc_write(0x0E6, 7956); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x0F);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					emc_write(0x006, 0);							// 配置时延
					emc_write(0x206, 0);
					break;
				case 2:			// 1Mbps
					emc_write(0x0E6, 7956); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x0F);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					delay = 0xF424;
					emc_write(0x006, delay);							// 配置时延
					emc_write(0x206, delay >> 16);
					break;
				case 3:			// 500Kbps
					emc_write(0x0E6, 7956); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x0F);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					delay = 0x2DC6C;
					emc_write(0x006, delay);						// 配置时延
					emc_write(0x206, delay >> 16);
					break;
				case 4:			// 250Kbps
					emc_write(0x0E6, 7956); 						// 配置12脉冲组帧的总长度,原始是7956，测速改为4788
					emc_write(0x174, 0x0F);							// 配置跳时跳频使能控制,跳时设置为X1使能（0x08）,非跳时设置为X1/X2/X3/X4使能（0x0F)
					WriteSyncAndPatternTestDoubleId(254, 0xFFFF);
					delay = 0x6ACFC;
					emc_write(0x006, delay);						// 配置时延
					emc_write(0x206, delay >> 16);
					break;
				default:
					printf("Wrong SendRate under TimeHope\r\n");
					break;
			}
			break;
		default:
			printf("Wrong TimeHoping Parameter\r\n");
			break;
	}
	LOGD("SetComRate complete!\r\n");
}

unsigned char GetComRate(void)
{
	return SendRate;
}


void recvPktStaticTimerOut(void)
{
	U16 t_2 = 0;
	U16 t_1 = 0;
	U16 t_0 = 0;
	u16 ID = 0xFFFF;
	uint64_t t = 0;
	U8 cmdBuff[16] = {0};
	t_2 = emc_read(SYNC_TIME_SHOW_2);
	t_1 = emc_read(SYNC_TIME_SHOW_1);
	t_0 = emc_read(SYNC_TIME_SHOW_0);

	t = ((uint64_t)t_2 << 32) + ((uint64_t)t_1 << 16) + (uint64_t)t_0;
	t *= 8;//纳秒
	recvPktStaticPktNum = int_38 - recvPktStaticPktNum;
	recvPktStaticTime = t - recvPktStaticTime;
	pktPS = recvPktStaticPktNum;
	/*report to console*/
	cmdBuff[0] = 125;
	memcpy(&cmdBuff[1], &ID, 2);
	memcpy(&cmdBuff[3], &recvPktStaticPktNum, 4);
	memcpy(&cmdBuff[7], &recvPktStaticTime,8);
	//LOGI("\n recvPktStaticTime = %llu, recvPktStaticPktNum=%u,int_38:%d\n", recvPktStaticTime, recvPktStaticPktNum, int_38);
	SendToConsole(cmdBuff,15,MODE_ETHERNET,32000);

	recvPktStaticPktNum = int_38;
	recvPktStaticTime = t;
}
U16 GetDynDelay(U8 priority)
{

	U16 delay = 0;
	switch (priority)
	{
		case 0:
			if (pktPS>100)
			{
				delay = 50;
			}
			else if (pktPS>50)
			{
				delay = 32;
			}
			else if (pktPS>20)
			{
				delay = 16;
			}
			else
			{
				delay = 8;
			}
			break;
		case 1:
			if (pktPS>100)
			{
				delay = 45;
			}
			else if (pktPS>50)
			{
				delay = 27;
			}
			else if (pktPS>20)
			{
				delay = 15;
			}
			else
			{
				delay = 8;
			}
			break;
		case 2:
			if (pktPS>100)
			{
				delay = 40;
			}
			else if (pktPS>50)
			{
				delay = 23;
			}
			else if (pktPS>20)
			{
				delay = 14;
			}
			else
			{
				delay = 8;
			}
			break;
		case 3:
			if (pktPS>100)
			{
				delay = 35;
			}
			else if (pktPS>50)
			{
				delay = 21;
			}
			else if (pktPS>20)
			{
				delay = 13;
			}
			else
			{
				delay = 8;
			}
			break;
		case 4:
			if (pktPS>100)
			{
				delay = 30;
			}
			else if (pktPS>50)
			{
				delay = 19;
			}
			else if (pktPS>20)
			{
				delay = 12;
			}
			else
			{
				delay = 8;
			}
			break;
		case 5:
			if (pktPS>100)
			{
				delay = 25;
			}
			else if (pktPS>50)
			{
				delay = 16;
			}
			else if (pktPS>20)
			{
				delay = 11;
			}
			else
			{
				delay = 8;
			}
			break;
		case 6:
			if (pktPS>100)
			{
				delay = 20;
			}
			else if (pktPS>50)
			{
				delay = 14;
			}
			else if (pktPS>20)
			{
				delay = 10;
			}
			else
			{
				delay = 8;
			}
			break;
		case 7:
			if (pktPS>100)
			{
				delay = 12;
			}
			else if (pktPS>50)
			{
				delay = 10;
			}
			else if (pktPS>20)
			{
				delay = 9;
			}
			else
			{
				delay = 8;
			}
			break;
	}
	return delay;

}
Bool ChooseClusterHead(U16 Id, U16 quitId)
{
	int i, j, k;
	U16 tempId  = Id;
	ROUTE_ENTRY_TYPE *p = NULL;
	ROUTE_ENTRY_TYPE *tempPtr = NULL;
	U16 ID = 0;
	U16 Index = 0;
	if (NULL == routeTables[Id&0x00FF])
		return False;
	p = routeTables[Id&0x00FF]->head;
	//printf("Id:0x%x,quitId:0x%x\r\n",Id, quitId);
	while(p != NULL)
	{
		if ((valid == p->routeState)&&((tempId&0x00FF)>(p->destID&0x00FF)))
		{
			//printf("p->destID:0x%x\r\n",p->destID);
			tempId  = p->destID;
			p = p->next;
		}
		else
		{
			p = p->next;
		}
	}
	//printf("Id:0x%x,tempId:0x%x\r\n",Id,tempId);
	if (tempId == Id)
	{
		rxQuitNetflag[Id&0x00FF] = 1;
		rxJoinNetflag[Id&0x00FF] = 0;
		QuitNetactiveBroadBecomeClusterHead(Id);		// 广播退网信息
		tempId = ((Id&0x00FF) | (quitId&0xFF00));

		p = routeTables[Id&0x00FF]->head;
		p->srcID = tempId;
		p->nextID = tempId;
		p->destID = tempId;
		while(p != NULL)
		{
			if(p->destID == tempId)
			{
				xSemaphoreTake(routeTableSem, portMAX_DELAY);
				p->serialNumber = 0;
				xSemaphoreGive(routeTableSem);
				p = p->next;
			}
			else
			{
				tempPtr = p;
				p = p->next;
				RouteEntryDelete(tempPtr);
			}
		}
		routelastlength[tempId&0x00FF] = routeTables[tempId&0x00FF]->length;
		/*xil_printf("tables index:0x%x,routeTablesLen:%d,srcID:0x%x,nextID:0x%x,destID:0x%x\r\n",tempId&0x00FF, routeTables[0x88]->length,
				routeTables[0x88]->head->srcID,routeTables[0x88]->head->nextID,routeTables[0x88]->head->destID);*/


		// 删除存在QuitID路由条目
		//xil_printf("enter route entry delete\r\n");
		for(Index = 1; Index <= routeTableNum; Index++)
		{
			// 跳过空指针
			if (NULL == routeTables[Index])
				continue;
			if (NULL == routeTables[Index]->head)
				continue;
			p = routeTables[Index]->head;
			// 跳过退网节点
			if (tempId == p->srcID)
				continue;

			// 删除路由
			while(p != NULL)
			{
				tempPtr = p;
				p = p->next;
				if((Id == tempPtr->nextID) || (Id == tempPtr->destID))
				{
					RouteEntryDelete(tempPtr);
				}
			}
			routelastlength[Index] = routeTables[Index]->length;
		}

		/*modify cluster info start*/
		DeleteClusterInfo(Id);
		// 打印接入子网簇信息
		UpdateClusterInfo(tempId);
		/*modify cluster info end*/
		// 打印接入子网簇信息
		rxQuitNetflag[tempId&0x00FF] = 0;

		/*p = routeTables[0x88]->head;
		for(Index=0;Index<routeTables[0x88]->length;Index++)
		{
			xil_printf("routetable[0x88]:srcID:0x%x,nextID:0x%x,destID:0x%x\r\n",p->srcID,p->nextID,p->destID);
			p = p->next;
		}*/

		JoinNetActive(tempId, 1);

		/*p = routeTables[0x88]->head;
		for(Index=0;Index<routeTables[0x88]->length;Index++)
		{
			xil_printf("1routetable[0x88]:srcID:0x%x,nextID:0x%x,destID:0x%x\r\n",p->srcID,p->nextID,p->destID);
			p = p->next;
		}*/

		return True;
	}
	else
		return False;
}

void DeleteClusterInfo(U16 Id)
{
	CLU_INFO_TYPE * pCluInfo = &cluInfo;
	// 遍历任务子网节点，将tempID置为零
	int i, j;
	ID_INFO_TYPE deleteId;
	deleteId.ID = Id;

	switch (deleteId.IDST.role)
	{
		case ROLE_TYPE_TASK_NET_COMMON_NODE:
			// 遍历任务子网节点，将ID置为零
			for (i = 0; i < pCluInfo->taskRows; i++)
			{
				for (j = 0; j < pCluInfo->taskCols[i]; j++)
				{
					if (Id == pCluInfo->taskCluster[i][j])
					{
						pCluInfo->taskCluster[i][j] = 0;
					}
				}
			}
			break;
		case ROLE_TYPE_ACCESS_NET_COMMON_NODE:
			// 遍历任务子网节点，将ID置为零
			for (i = 0; i < pCluInfo->taskRows; i++)
			{
				if (Id == pCluInfo->taskCluster[i][0])
				{
					pCluInfo->taskCluster[i][0] = 0;
				}
			}
			// 遍历接入子网节点，将ID置为零
			for (i = 0; i < pCluInfo->accessRows; i++)
			{
				for (j = 0; j < pCluInfo->accessCols[i]; j++)
				{
					if (Id == pCluInfo->accessCluster[i][j])
					{
//						printf("Id: 0x%X, srID: 0x%X\r\n", Id, pCluInfo->accessCluster[i][j]);
						pCluInfo->accessCluster[i][j] = 0;
					}
				}
			}
			break;
		case ROLE_TYPE_ACCESS_NET_GATEWAY_NODE:
			// 遍历任务子网节点，将ID置为零
			for (i = 0; i < pCluInfo->taskRows; i++)
			{
				if (Id == pCluInfo->taskCluster[i][0])
				{
					pCluInfo->taskCluster[i][0] = 0;
				}
			}
			// 遍历接入子网节点，将ID置为零
			for (i = 0; i < pCluInfo->accessRows; i++)
			{
				if (Id == pCluInfo->accessCluster[i][0])
				{
					pCluInfo->accessCluster[i][0] = 0;
				}
			}
			break;
		default :
			// 遍历交换子网节点，将ID置为零
			for (i = 0; i < pCluInfo->exchangeCount; i++)
			{
				if (Id == pCluInfo->exchangeCluster[i])
				{
					pCluInfo->exchangeCluster[i] = 0;
				}
			}
			break;
	}
}
void UpdateClusterInfo(U16 Id)
{
	CLU_INFO_TYPE * pCluInfo = &cluInfo;
	// 遍历任务子网节点，将tempID置为零
	ID_INFO_TYPE updateId;
	updateId.ID = Id;

	switch (updateId.IDST.role)
	{
		case ROLE_TYPE_TASK_NET_COMMON_NODE:
			// 更新任务子网簇信息
			if(False == UpdateTaskClusterInfo(pCluInfo, updateId))
			{
				xil_printf("UpdateTaskClusterInfo error\r\n");
			}
			break;
		case ROLE_TYPE_ACCESS_NET_COMMON_NODE:
			// 更新任务子网簇信息
			if(False == UpdateTaskClusterInfo(pCluInfo, updateId))
			{
				xil_printf("UpdateTaskClusterInfo error\r\n");
			}
			// 更新接入子网簇信息
			if(False == UpdateAccessClusterInfo(pCluInfo, updateId))
			{
				xil_printf("UpdateAccessClusterInfo error\r\n");
			}
			break;
		case ROLE_TYPE_ACCESS_NET_GATEWAY_NODE:
			// 更新任务子网簇信息
			if(False == UpdateTaskClusterInfo(pCluInfo, updateId))
			{
				xil_printf("UpdateTaskClusterInfo error\r\n");
			}
			// 更新接入子网簇信息
			if(False == UpdateAccessClusterInfo(pCluInfo, updateId))
			{
				xil_printf("UpdateAccessClusterInfo error\r\n");
			}
			break;
		default :
			// 更新交换子网簇信息
			if(False == UpdateExchangeClusterInfo(pCluInfo, updateId))
			{
				xil_printf("UpdateExchangeClusterInfo error\r\n");
			}
			break;
	}
}
