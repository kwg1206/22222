#define _CRT_SECURE_NO_WARNINGS
#include "test_demo.h"

#define HandleResult(res,place) if (res!=XI_OK) {printf("Error after %s (%d)\n",place,res);}

HANDLE m_cam;
XI_RETURN m_camReturn;

//int m_wavelength_start;
//int m_wavelength_end;
//int m_wavelength[100]; //保存波长数组
int m_exposureTime;
int m_gain;
int m_FPS;
int pic_width = 2048;
int pic_height = 2;



int main()
{
	cout << "test cmv4000 program start..." << endl;
	cout << endl;
	cout << endl;
	cout << endl;

	ConnectCamera();
	string str_dir = "C:/Users/CGCP/Desktop/savedata4000/";
	

	std::thread t1(GetFrame, m_cam);
	t1.detach();

	/*std::thread t2(CutFrame);
	t2.detach();*/

	std::thread t3(SaveData, str_dir);
	t3.join();


	cout << endl;
	cout << endl;
	cout << endl;
	cout << "test cmv4000 program end..." << endl;
	system("pause");
}





//连接相机函数
void ConnectCamera()
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

	m_camReturn = xiOpenDevice(0, &m_cam);//默认连接找到的第一个相机
	HandleResult(m_camReturn, "xiDivecesOpen");

	m_camReturn = xiSetParamInt(m_cam, XI_PRM_AEAG, XI_OFF);//关闭自动曝光
	HandleResult(m_camReturn, "xiSetParam (AEAG off)");

	m_camReturn = xiSetParamInt(m_cam, XI_PRM_ACQ_TIMING_MODE, XI_ACQ_TIMING_MODE_FRAME_RATE);//关闭自动帧频
	HandleResult(m_camReturn, "xiSetAcquisitionTimingMode_FrameRate");

	int val = 0;
	m_camReturn = xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, &val);
	HandleResult(m_camReturn, "xiSetAcquisitionTimingMode_FrameRate");

	int setBufferSize = 25;
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, setBufferSize);
	int getBufferSizeMax = 0;
	xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE XI_PRM_INFO_MAX, &getBufferSizeMax);
	cout << "get buffersize max: " << getBufferSizeMax << endl;
	int getBufferSize = 0;
	m_camReturn = xiGetParamInt(m_cam, XI_PRM_BUFFERS_QUEUE_SIZE, &getBufferSize);
	//printf("get buffersize: %d", getBufferSize);
	cout << "get buffersize: " << getBufferSize << endl;

	//设置ROI
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_REGION_SELECTOR, 0);
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_WIDTH, pic_width); // This is the width for all regions
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_HEIGHT, pic_height); // Decrease height (to enable other regions)
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_OFFSET_X, 0);
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_OFFSET_Y, 100);  // This is th Y-offset of region 0



	xiSetParamInt(m_cam, XI_PRM_GPI_SELECTOR, 1);//设置GPI选择器
	HandleResult(m_camReturn, "xiSetGPISelector");
	xiSetParamInt(m_cam, XI_PRM_GPI_MODE, XI_GPI_TRIGGER);//设置GPI模式 扳机触发
	HandleResult(m_camReturn, "xiSetGPIMode");

	m_camReturn = xiSetParamInt(m_cam, XI_PRM_TRG_SOURCE, XI_TRG_EDGE_RISING);//设置扳机模式，上升沿触发
	HandleResult(m_camReturn, "xiSetTrigger_EdgeRising");




}



//采集相机原始图像函数
void GetFrame(HANDLE cam)
{
	m_rawFlag = true;
	int val = 0;
	xiGetParamInt(cam, XI_PRM_IS_DEVICE_EXIST, &val);
	XI_IMG temp_img;
	memset(&temp_img, 0, sizeof(temp_img));
	temp_img.size = sizeof(XI_IMG);
	int Height = pic_height;
	int Width = pic_width;
	int totalNum = Height * Width;
	int nChannels = 100;

	m_bGrabFlag = true;
	m_bCutFinished = false;

	WCHAR* lpPath = _T("./Config.ini");
	WCHAR res[256];

	//m_wavelength_start = GetPrivateProfileInt(_T("BandInfo"), _T("Wavelength_start"), 0, lpPath);//获取数值
	//m_wavelength_end = GetPrivateProfileInt(_T("BandInfo"), _T("Wavelength_end"), 0, lpPath);

	//for (int i = 0; i < nChannels; i++)
	//{
	//	m_wavelength[i] = i;
	//	m_wavelength[i] = m_wavelength_start + (m_wavelength_end - m_wavelength_start) / (nChannels * 2.0)*(2 * i + 1);
	//}

	m_exposureTime = GetPrivateProfileInt(_T("Camera"), _T("ExposureTime"), 0, lpPath);
	m_gain = GetPrivateProfileInt(_T("Camera"), _T("Gain"), 0, lpPath);
	m_FPS = GetPrivateProfileInt(_T("Camera"), _T("FPS"), 0, lpPath);
	
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_EXPOSURE, m_exposureTime);
	HandleResult(m_camReturn, "xiSetParam (exposure set)");
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_GAIN, m_gain);
	HandleResult(m_camReturn, "xiSetParam (gain set)");
	m_camReturn = xiSetParamInt(m_cam, XI_PRM_FRAMERATE, m_FPS);
	HandleResult(m_camReturn, "xiSetParam (gain set)");

	int get_exposureTime, get_gain, get_FPS;
	m_camReturn = xiGetParamInt(m_cam, XI_PRM_EXPOSURE, &get_exposureTime);
	HandleResult(m_camReturn, "xiGetParam (exposure set)");
	m_camReturn = xiGetParamInt(m_cam, XI_PRM_GAIN, &get_gain);
	HandleResult(m_camReturn, "xiGetParam (gain set)");
	/*m_camReturn = xiGetParamInt(m_cam, XI_PRM_FRAMERATE, &get_FPS);
	HandleResult(m_camReturn, "xiGetParam (gain set)");*/

	cout << endl;
	cout << "get_exposureTime: " << get_exposureTime << endl;
	cout << "get_gain: " << get_gain << endl;
	//cout << "get_FPS: " << get_FPS << endl;

	cout << "val: " << val << endl;
	

	int t_iFlag;
	int t_iCount = 0;

	if (val == 1)
	{
		xiStartAcquisition(cam);

		while (true)
		{
			t_iFlag = GetNextImage(cam);

	//		HandleResult(t_iFlag, "xiGetNextImage");
			if (t_iFlag == 10)
			{
				Sleep(20);
				continue;
			}
			//break;
			//if (t_iFlag == 9)
			//{
			//	continue;
			//}
			//else if (t_iFlag == 0)
			//{
			//	if (t_iCount++ == 1000)
			//		break;
			//}
			//else
			//{
			//	HandleResult(t_iFlag, "xiGetNextImage");
			//	break;
			//}
		}
		m_bGrabFlag == false;
		xiStopAcquisition(m_cam);


	}
	else
	{
		printf("No camera is exist!\n");
		
	}
	m_rawFlag = false;
}




int GetNextImage(HANDLE cam)
{
	int totalNum = pic_width * pic_height;

	int val = 0;
	xiGetParamInt(cam, XI_PRM_IS_DEVICE_EXIST, &val);
	XI_IMG temp_img;
	memset(&temp_img, 0, sizeof(temp_img));
	temp_img.size = sizeof(XI_IMG);

	unsigned char * img = new unsigned char[totalNum];

	if (val == 1)
	{
		DWORD timeOut = 1000;
		m_camReturn = xiGetImage(cam, timeOut, &temp_img);
		HandleResult(m_camReturn, "xiGetNextImage0");



	//	mutex_deque.lock();
		if (m_camReturn == 0)
		{
			
			memcpy(img, temp_img.bp, totalNum);
			unique_lock<mutex> locker(mutex_deque);
			m_dequeFrame.push_back(img);
			locker.unlock();
			contion.notify_all();
		}
		return m_camReturn;
	//	mutex_deque.unlock();



	}

	else
	{
		printf("No camera is exist!\n");
		return m_camReturn;
	}

}






void SaveData(string str_dir)
{
	int saveCount = 0;
	auto start = std::chrono::high_resolution_clock::now();

	auto start1 = std::chrono::high_resolution_clock::now();
	while (m_bGrabFlag==true || m_rawFlag==true || m_dequeFrame.size()>0)
	{

	//	mutex_deque.lock();

		if (m_dequeFrame.size() <= 2)
		{
			Sleep(20);
			//cout << "sleep 20..." ;
			continue;
		}

		saveCount = saveCount + 1;
		//Mat outImg = Mat::zeros(pic_height, pic_width, CV_8UC1);
		//unique_lock<mutex> locker(mutex_deque);
		//memcpy(outImg.data, m_dequeFrame.front(), pic_height*pic_width);
		//locker.unlock();
		//contion.notify_all();
		//string str_pic;
	/*	if (saveCount == 1000)
		{
			int a = 0;
		}*/

		//if (saveCount < 10)
		//{
		//	str_pic = str_dir + "0000" + to_string(saveCount) + ".bmp";
		//}
		//else if (saveCount < 100)
		//{
		//	str_pic = str_dir + "000" + to_string(saveCount) + ".bmp";
		//}
		//else if (saveCount < 1000)
		//{
		//	str_pic = str_dir + "00" + to_string(saveCount) + ".bmp";
		//}
		//else if (saveCount < 10000)
		//{
		//	str_pic = str_dir + "0" + to_string(saveCount) + ".bmp";
		//}
		//else
		//{
		//	str_pic = str_dir + to_string(saveCount) + ".bmp";
		//}
		//str_pic = str_dir + "00.bmp";
		//

		//imwrite(str_pic, outImg);




		
		
		if (saveCount % 1000 == 0) {
			auto finish = std::chrono::high_resolution_clock::now();
			std::chrono::duration<double> elapsed = finish - start;
			start = std::chrono::high_resolution_clock::now();
			cout << "saveCount: " << saveCount <<"             " << elapsed.count()  << "s" << "             m_dequeFrame.size():" << m_dequeFrame.size() << endl;
			
		}//if (saveCount % 180 == 1) {

		//	auto finish1 = std::chrono::high_resolution_clock::now();
		//	std::chrono::duration<double> elapsed1 = finish1 - start1;
		//	cout << "180 count save time:" << elapsed1.count()*1000 <<"ms"<< endl;
		//	start1 = std::chrono::high_resolution_clock::now();
		//}

		unique_lock<mutex> locker1(mutex_deque);
		contion.wait(locker1, []() {return !m_dequeFrame.empty(); });
		delete m_dequeFrame[0];
		m_dequeFrame.pop_front();
		locker1.unlock();

	//	mutex_deque.unlock();
		
	}
}