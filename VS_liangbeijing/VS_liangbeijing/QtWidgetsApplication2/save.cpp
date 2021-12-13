#include "save.h"
#define _CRT_SECURE_NO_WARNINGS
#define HandleResult(res,place) if (res!=XI_OK) {printf("Error after %s (%d)\n",place,res);}

HANDLE m_cam;
HANDLE m_camTemp;
XI_RETURN m_camReturn;
double GainList[76] = { 0 };

int num;



Save::Save(QWidget *parent)

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

	cout << endl;
	cout << endl;
	cout << endl;
	cout << "test ximea save dark program end..." << endl;
	system("pause");
}

void Save::LoadConfig() {
	cout << "start load config..." << endl;

	WCHAR* lpPath = _T("./Config.ini");
	WCHAR res[256];
	QString t_QstrTemp;

	//导入曝光时间
	GetPrivateProfileString(_T("Camera"), _T("g_QstrExposureTimes"), _T(""), res, 256, lpPath);
	t_QstrTemp = QString::fromWCharArray(res);
	m_QstrExposureTimes = t_QstrTemp;

	m_QstrExposureTimesList = m_QstrExposureTimes.split(",");
	cout << "config m_QstrExposureTimesList[" << m_QstrExposureTimesList.size() << "]: ";
	for (int i = 0; i < m_QstrExposureTimesList.size(); i++)
	{
		cout << m_QstrExposureTimesList[i].toInt() << ",";
	}
	cout << endl;

	//导入增益
	//导入增益
	GetPrivateProfileString(_T("Camera"), _T("g_QstrGains"), _T(""), res, 256, lpPath);
	t_QstrTemp = QString::fromWCharArray(res);
	m_QstrGains = t_QstrTemp;

	m_QstrGainsList = m_QstrGains.split(":");

	temp = 76;
	cout << "config m_QstrGainsList[" << ((m_QstrGainsList[2].toDouble() - m_QstrGainsList[0].toDouble()) / m_QstrGainsList[1].toDouble()) << "]: ";
	for (int i = 0; i <= temp; i++) {
		GainList[i] = m_QstrGainsList[0].toDouble() + m_QstrGainsList[1].toDouble()*i;
		cout << GainList[i] << ",";
	}
	cout << endl;
	//m_QstrGainsList = m_QstrGains.split(":");

	//temp = (m_QstrGainsList[2].toDouble() - m_QstrGainsList[0].toDouble()) / m_QstrGainsList[1].toDouble();
	//cout << "config m_QstrGainsList[" << ((m_QstrGainsList[2].toDouble() - m_QstrGainsList[0].toDouble()) / m_QstrGainsList[1].toDouble()) << "]: ";
	//for (int i = 0; i <= temp; i++) {
	//	GainList[i] = m_QstrGainsList[0].toDouble() + m_QstrGainsList[1].toDouble()*i;
	//	cout << "[" << GainList[i] << "]  ";
	//}
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

	//设置8位还是16位
	swich = 0;
	if (swich == 1)
		cout << "XI_PRM_IMAGE_DATA_FORMAT:8" << endl;
	else
		cout << "XI_PRM_IMAGE_DATA_FORMAT:16" << endl;
	cout << "load config end..." << endl;
}
void Save::ConnectCamera() {
	int sum = 0;
	DWORD count;
	xiGetNumberDevices(&count);
	cout << "avilable camera number: " << count << endl;

	if (count == 0)
	{
		printf("No camera avilable!\n");
		//return;

		cout << endl;
		cout << endl;
		cout << endl;
		cout << "test cmv4000 program end..." << endl;

	}
	else
	{
		for (int i = 0; i < count; i++)
		{
			char m_camSerial[15];

			xiOpenDevice(i, &m_camTemp);
			xiGetParamString(m_camTemp, XI_PRM_DEVICE_SN, &m_camSerial, 15);


			int serialNum_temp = atoi(m_camSerial);
			cout << "get camera SN: " << serialNum_temp << endl;

			if (serialNum_temp == m_cameraSN) //相机序列号匹配 则可以连接相机。
			{
				cout << "camera SN right..." << endl;
				xiCloseDevice(m_camTemp);//断开相机

				xiOpenDevice(i, &m_cam);//重新连接相机

										//设置16位图像格式
				if(swich == 1)
					xiSetParamInt(m_cam, XI_PRM_IMAGE_DATA_FORMAT, XI_MONO8);
				else
					xiSetParamInt(m_cam, XI_PRM_IMAGE_DATA_FORMAT, XI_MONO16);


				//关闭自动曝光
				xiSetParamInt(m_cam, XI_PRM_AEAG, XI_OFF);

				//关闭自动帧频
				xiSetParamInt(m_cam, XI_PRM_ACQ_TIMING_MODE, XI_ACQ_TIMING_MODE_FRAME_RATE);

				//设置buffer_size
				int val = 0;
				xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, &val);

				int setBufferSize = 10;
				m_camReturn = xiSetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, setBufferSize);
				HandleResult(m_camReturn, "setBufferSize");
				int getBufferSizeMax = 0;
				xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE XI_PRM_INFO_MAX, &getBufferSizeMax);
				cout << "get buffersize max: " << getBufferSizeMax << endl;
				int getBufferSize = 0;
				xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, &getBufferSize);
				cout << "get buffersize: " << getBufferSize << endl;

				//开始存图

				xiStartAcquisition(m_cam);

				cout << "start save dark..." << endl;

				for (int expi = 0; expi < m_QstrExposureTimesList.size(); expi++)
				{

					int setexposuretime = m_QstrExposureTimesList[expi].toInt();
					xiSetParamInt(m_cam, XI_PRM_EXPOSURE, setexposuretime);
					for (int gaini = 0; gaini < temp; gaini++)
					{

						double setgain = GainList[gaini];
						xiSetParamFloat(m_cam, XI_PRM_GAIN, setgain);
						float temp;
						xiGetParamFloat(m_cam, XI_PRM_GAIN, &temp);
						cout << "set gain:" << setgain<< "---" <<"get gain:" << temp << endl;

						xiSetParamInt(m_cam, XI_PRM_FRAMERATE, m_FPS);
						Sleep(100);

						int get_exposureTime, get_FPS;
						float get_gain;
						xiGetParamInt(m_cam, XI_PRM_EXPOSURE, &get_exposureTime);
						xiGetParamFloat(m_cam, XI_PRM_GAIN, &get_gain);
						xiGetParamInt(m_cam, XI_PRM_FRAMERATE, &get_FPS);

						string str_setexposuretime;
						if (setexposuretime < 10)
						{
							str_setexposuretime = "00000" + to_string(setexposuretime);
						}
						else if (setexposuretime < 100)
						{
							str_setexposuretime = "0000" + to_string(setexposuretime);
						}
						else if (setexposuretime < 1000)
						{
							str_setexposuretime = "000" + to_string(setexposuretime);
						}
						else if (setexposuretime < 10000)
						{
							str_setexposuretime = "00" + to_string(setexposuretime);
						}
						else if (setexposuretime < 100000)
						{
							str_setexposuretime = "0" + to_string(setexposuretime);
						}
						else if (setexposuretime < 1000000)
						{
							str_setexposuretime = to_string(setexposuretime);
						}
						int pn = 1;
						while (pn < m_saveTime + 1)
						{
							string str_pn;
							if (pn < 10)
							{
								str_pn = "0" + to_string(pn);
							}
							else
							{
								str_pn = to_string(pn);
							}
							string str_pic;
							str_pic = str_savedir + "/" + str_setexposuretime + "us" + format("%.2f", setgain) + "gain" + str_pn + ".dat";

							qstr_pic = QString::fromStdString(str_pic);


							GetNextImage(m_cam);
							if(swich == 1)
								WriteData(qstr_pic, (char*)img8, pic_height * pic_width * sizeof(unsigned char));
							else
								WriteData(qstr_pic, (char*)img16, pic_height * pic_width * sizeof(unsigned short));
							num++;

							pn++;
							
							cout << "save img sum :" << expi<<"-"<< gaini<<"-"<<num << endl;
						}

					}
				}
				cout << "sum :" << sum << endl;
				xiStopAcquisition(m_cam);
			}
			else
			{
				cout << "avaliable camera" << i << " is not wanted camera..." << endl;
				xiCloseDevice(m_camTemp);//断开相机
			}
		}

	}
}

int Save::GetNextImage(HANDLE cam)
{


	int val = 0;
	xiGetParamInt(cam, XI_PRM_IS_DEVICE_EXIST, &val);
	XI_IMG temp_img;
	memset(&temp_img, 0, sizeof(temp_img));
	temp_img.size = sizeof(XI_IMG);

	if (val == 1)
	{
		DWORD timeOut = 1000;
		xiGetImage(cam, timeOut, &temp_img);


		if (m_camReturn == 0)
		{
			if(swich == 1)
				memcpy(img8, temp_img.bp, totalNum * sizeof(unsigned char));
			else
				memcpy(img16, temp_img.bp, totalNum * sizeof(unsigned short));
		}
		return m_camReturn;

	}
	else
	{
		printf("No camera is exist!\n");
		return m_camReturn;
	}
}



//写dat文件函数
bool Save::WriteData(QString str, const char *data, int length)
{
	QFile QFData(str);
	if (QFData.open(QIODevice::WriteOnly) == false)
		return false;
	QDataStream WriteDataStream(&QFData);
	WriteDataStream.writeRawData(data, length);
	QFData.close();
	return true;
}
