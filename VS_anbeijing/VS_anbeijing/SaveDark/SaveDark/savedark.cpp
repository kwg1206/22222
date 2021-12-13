#include "savedark.h"
#define _CRT_SECURE_NO_WARNINGS
#define HandleResult(res,place) if (res!=XI_OK) {printf("Error after %s (%d)\n",place,res);}

HANDLE m_cam;
HANDLE m_camTemp;
XI_RETURN m_camReturn;




SaveDark::SaveDark(QWidget *parent)
    : QMainWindow(parent)
{
    ui.setupUi(this);

	cout << "test ximea save dark program start..." << endl;
	cout << endl;
	cout << endl;
	cout << endl;

	LoadConfig();
	str_savedir = m_QstrSavePath.toStdString();
	cout << "savedir: " << str_savedir << endl;

	
	ConnectCamera();
	


	/*std::thread t1(GetFrame, m_cam);
	t1.detach();*/

	/*std::thread t2(CutFrame);
	t2.detach();*/

	/*std::thread t3(SaveData, str_dir);
	t3.join();*/


	cout << endl;
	cout << endl;
	cout << endl;
	cout << "test ximea save dark program end..." << endl;
	system("pause");






}







//导入配置文件函数
void SaveDark::LoadConfig()
{
	cout << "start load config..." << endl;

	WCHAR* lpPath = _T("./Config.ini");
	WCHAR res[256];
	QString t_QstrTemp;

	//导入曝光时间
	GetPrivateProfileString(_T("Camera"), _T("g_QstrExposureTimes"), _T(""), res, 256, lpPath);
	t_QstrTemp = QString::fromWCharArray(res);
	m_QstrExposureTimes = t_QstrTemp;
	
	m_QstrExposureTimesList = m_QstrExposureTimes.split(",");
	//cout << "m_QstrExposureTimesList.size(): " << m_QstrExposureTimesList.size() << endl;
	//cout << "m_QstrExposureTimesList[0]: " << m_QstrExposureTimesList[0].toInt() << endl;
	cout << "config m_QstrExposureTimesList[" << m_QstrExposureTimesList.size() << "]: " ;
	for (int i = 0; i < m_QstrExposureTimesList.size(); i++)
	{
		cout << m_QstrExposureTimesList[i].toInt() << ",";
	}
	cout << endl;
	
	//导入增益
	GetPrivateProfileString(_T("Camera"), _T("g_QstrGains"), _T(""), res, 256, lpPath);
	t_QstrTemp = QString::fromWCharArray(res);
	m_QstrGains = t_QstrTemp;

	m_QstrGainsList = m_QstrGains.split(",");
	//cout << "m_QstrGainsList.size(): " << m_QstrGainsList.size() << endl;
	//cout << "m_QstrGainsList[0]: " << m_QstrGainsList[0].toInt() << endl;
	cout << "config m_QstrGainsList[" << m_QstrGainsList.size() << "]: ";
	for (int i = 0; i < m_QstrGainsList.size(); i++)
	{
		cout << m_QstrGainsList[i].toDouble() << ",";
	}
	cout << endl;

	//同一曝光时间、增益存图次数
	m_saveTime = GetPrivateProfileInt(_T("Camera"), _T("SaveTime"), 0, lpPath);
	cout << "config savetime: " << m_saveTime << endl;

	//保存图片的路径
	GetPrivateProfileString(_T("Path"), _T("g_QstrSavePath"), _T(""), res, 256, lpPath);//储存路径名
	t_QstrTemp = QString::fromWCharArray(res);
	m_QstrSavePath = t_QstrTemp;
	cout << "config savepath: " << m_QstrSavePath.toStdString() << endl;

	//相机SN序列号
	m_cameraSN = GetPrivateProfileInt(_T("Camera"), _T("CameraSN"), 0, lpPath);
	cout << "config cameraSN: " << m_cameraSN << endl;

	//帧频
	m_FPS = GetPrivateProfileInt(_T("Camera"), _T("FPS"), 0, lpPath);
	cout << "config get_FPS: " << m_FPS << endl;



	cout << "load config end..." << endl;
}




//连接相机函数
void SaveDark::ConnectCamera()
{
	DWORD count;
	m_camReturn = xiGetNumberDevices(&count);
	cout << "avilable camera number: " << count << endl;
	HandleResult(m_camReturn, "xiDivecesNum");
	if (count == 0)
	{
		printf("No camera avilable!\n");
		//return;

		cout << endl;
		cout << endl;
		cout << endl;
		cout << "test cmv4000 program end..." << endl;
		system("pause");
	}
	else
	{
		for (int i = 0; i < count; i++)
		{
			char m_camSerial[15];

			m_camReturn = xiOpenDevice(i, &m_camTemp);
			HandleResult(m_camReturn, "xiDivecesOpen");
			m_camReturn = xiGetParamString(m_camTemp, XI_PRM_DEVICE_SN, &m_camSerial, 15);
			HandleResult(m_camReturn, "xiDivecesDiveceSerialNum");


			int serialNum_temp = atoi(m_camSerial);
			cout << "get camera SN: " << serialNum_temp << endl;


			if (serialNum_temp == m_cameraSN) //相机序列号匹配 则可以连接相机。
			{
				cout << "camera SN right..." << endl;				
				m_camReturn = xiCloseDevice(m_camTemp);//断开相机
				HandleResult(m_camReturn, "xiDivecesClose");
				m_camReturn = xiOpenDevice(i, &m_cam);//重新连接相机
				HandleResult(m_camReturn, "xiDivecesOpen");

				//设置16位图像格式
				m_camReturn = xiSetParamInt(m_cam, XI_PRM_IMAGE_DATA_FORMAT, XI_MONO16);
				HandleResult(m_camReturn, "xiSetDepthTo16");			

				//关闭自动曝光
				m_camReturn = xiSetParamInt(m_cam, XI_PRM_AEAG, XI_OFF);
				HandleResult(m_camReturn, "xiSetParam (AEAG off)");
			
				//关闭自动帧频
				/*m_camReturn = xiSetParamInt(m_cam, XI_PRM_ACQ_TIMING_MODE, XI_ACQ_TIMING_MODE_FRAME_RATE);
				HandleResult(m_camReturn, "xiSetAcquisitionTimingMode_FrameRate");*/

				//设置buffer_size
				int val = 0;
				m_camReturn = xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, &val);
				HandleResult(m_camReturn, "xiSetAcquisitionTimingMode_FrameRate");

				int setBufferSize = 10;
				m_camReturn = xiSetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, setBufferSize);
				int getBufferSize = 0;
				m_camReturn = xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, &getBufferSize);
				cout << "get buffersize: " << getBufferSize << endl;

				////设置ROI
				//m_camReturn = xiSetParamInt(m_cam, XI_PRM_REGION_SELECTOR, 0);
				//m_camReturn = xiSetParamInt(m_cam, XI_PRM_WIDTH, pic_width); // This is the width for all regions
				//m_camReturn = xiSetParamInt(m_cam, XI_PRM_HEIGHT, pic_height); // Decrease height (to enable other regions)
				//m_camReturn = xiSetParamInt(m_cam, XI_PRM_OFFSET_X, 0);
				//m_camReturn = xiSetParamInt(m_cam, XI_PRM_OFFSET_Y, 100);  // This is th Y-offset of region 0

				//xiSetParamInt(m_cam, XI_PRM_GPI_SELECTOR, 1);//设置GPI选择器
				//HandleResult(m_camReturn, "xiSetGPISelector");
				//xiSetParamInt(m_cam, XI_PRM_GPI_MODE, XI_GPI_TRIGGER);//设置GPI模式 扳机触发
				//HandleResult(m_camReturn, "xiSetGPIMode");

				//m_camReturn = xiSetParamInt(m_cam, XI_PRM_TRG_SOURCE, XI_TRG_EDGE_RISING);//设置扳机模式，上升沿触发
				//HandleResult(m_camReturn, "xiSetTrigger_EdgeRising");



				//开始存图

				xiStartAcquisition(m_cam);

				cout << "start save dark..." << endl;

				for (int expi = 0; expi < m_QstrExposureTimesList.size(); expi++)
				{
					//设置曝光时间
					cout << "************************************************************************************" << endl;
					int setexposuretime = m_QstrExposureTimesList[expi].toInt();
					m_camReturn = xiSetParamInt(m_cam, XI_PRM_EXPOSURE, setexposuretime);
					HandleResult(m_camReturn, "xiSetParam (exposure set)");

					for (int gaini = 0; gaini < m_QstrGainsList.size(); gaini++)
					{
						
						double setgain = m_QstrGainsList[gaini].toDouble();
						m_camReturn = xiSetParamFloat(m_cam, XI_PRM_GAIN, setgain);
						HandleResult(m_camReturn, "xiSetParam (gain set)");
						//m_camReturn = xiSetParamInt(m_cam, XI_PRM_FRAMERATE, m_FPS);
						//HandleResult(m_camReturn, "xiSetParam (m_FPS set)");
						cout << "setexposuretime: " << setexposuretime << "   setgain: " << setgain << "   setFPS: " << m_FPS << endl;
						Sleep(10);

						int get_exposureTime, get_FPS;
						float get_gain;
						m_camReturn = xiGetParamInt(m_cam, XI_PRM_EXPOSURE, &get_exposureTime);
						HandleResult(m_camReturn, "xiGetParam (exposure get)");
						m_camReturn = xiGetParamFloat(m_cam, XI_PRM_GAIN, &get_gain);
						HandleResult(m_camReturn, "xiGetParam (gain get)");
						m_camReturn = xiGetParamInt(m_cam, XI_PRM_FRAMERATE, &get_FPS);
						HandleResult(m_camReturn, "xiGetParam (FPS get)");						
						cout << "getexposureTime: " << get_exposureTime << "   getgain: " << get_gain << "   getFPS: " << get_FPS << endl;
						
						string str_setexposuretime;
						if (setexposuretime<10)
						{
							str_setexposuretime = "00000" + to_string(setexposuretime);
						}
						else if(setexposuretime<100)
						{
							str_setexposuretime = "0000" + to_string(setexposuretime);
						}
						else if (setexposuretime<1000)
						{
							str_setexposuretime = "000" + to_string(setexposuretime);
						}
						else if (setexposuretime<10000)
						{
							str_setexposuretime = "00" + to_string(setexposuretime);
						}
						else if (setexposuretime<100000)
						{
							str_setexposuretime = "0" + to_string(setexposuretime);
						}
						else if (setexposuretime<1000000)
						{
							str_setexposuretime = to_string(setexposuretime);
						}
						
						int pn = 1;
						while (pn < m_saveTime + 1)
						{
							string str_pn;
							if (pn<10)
							{
								str_pn = "0" + to_string(pn);
							}
							else
							{
								str_pn = to_string(pn);
							}

							string str_pic;
							str_pic = str_savedir + "/" + str_setexposuretime + "us" + format("%.2f",setgain) + "gain" + str_pn + ".dat";
							//cout << str_pic << endl;
							cout << str_pn << "  ";
							qstr_pic = QString::fromStdString(str_pic);
							//cout << qstr_pic.toStdString() << endl;
							
							
							GetNextImage(m_cam);
							
							string str_pic1;
							str_pic1 = str_savedir + "1/" + str_setexposuretime + "us" + format("%.2f", setgain) + "gain" + str_pn + ".bmp";
							//imwrite(str_pic1, outImg);	

							//GetFrame(m_cam);
							WriteData(qstr_pic, (char*)img, pic_height * pic_width * sizeof(unsigned short));

							pn++;
						}
						cout << endl;

						//cout << "******************************************************" << endl;
						Sleep(10);



					}
				}

				xiStopAcquisition(m_cam);
			
			}
			else
			{
				cout << "avaliable camera" << i << " is not wanted camera..." << endl;
				m_camReturn = xiCloseDevice(m_camTemp);//断开相机
				HandleResult(m_camReturn, "xiDivecesClose");
			}
		}
	}


}




//采集相机原始图像函数
void SaveDark::GetFrame(HANDLE cam)
{
	int val = 0;
	xiGetParamInt(cam, XI_PRM_IS_DEVICE_EXIST, &val);
	XI_IMG temp_img;
	memset(&temp_img, 0, sizeof(temp_img));
	temp_img.size = sizeof(XI_IMG);
	int Height = pic_height;
	int Width = pic_width;
	int totalNum = Height * Width;
	
	int t_iFlag;
	int t_iCount = 0;
	if (val == 1)
	{
		xiStartAcquisition(cam);

		//while (true)
		//{
		//	t_iFlag = GetNextImage(cam);
		//	//HandleResult(t_iFlag, "xiGetNextImage");
		//	if (t_iFlag == 20)
		//	{
		//		Sleep(20);
		//		continue;
		//	}			
		//}

		t_iFlag = GetNextImage(cam);
		xiStopAcquisition(cam);
	}
	else
	{
		printf("No camera is exist!\n");
	}	
}



int SaveDark::GetNextImage(HANDLE cam)
{
	/*int totalNum = pic_width * pic_height;
	unsigned char * img = new unsigned char[totalNum];*/

	int val = 0;
	xiGetParamInt(cam, XI_PRM_IS_DEVICE_EXIST, &val);
	XI_IMG temp_img;
	memset(&temp_img, 0, sizeof(temp_img));
	temp_img.size = sizeof(XI_IMG);

	if (val == 1)
	{
		DWORD timeOut = 1000;
		m_camReturn = xiGetImage(cam, timeOut, &temp_img);
		HandleResult(m_camReturn, "xiGetNextImage");

		//mutex_deque.lock();
		if (m_camReturn == 0)
		{
			memcpy(img, temp_img.bp, totalNum*sizeof(unsigned short));		
			//m_dequeFrame.push_back(img);
			//memcpy(outImg.data, temp_img.bp, pic_height*pic_width);
			
		}
		return m_camReturn;
		//mutex_deque.unlock();
	}
	else
	{
		printf("No camera is exist!\n");
		return m_camReturn;
	}
}



//写dat文件函数
bool SaveDark::WriteData(QString str, const char *data, int length)
{
	QFile QFData(str);
	if (QFData.open(QIODevice::WriteOnly) == false)
		return false;
	QDataStream WriteDataStream(&QFData);
	WriteDataStream.writeRawData(data, length);
	QFData.close();
	return true;
}
