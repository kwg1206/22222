#pragma once

#include <QtWidgets/QMainWindow>
#include "ui_savedark.h"

#include "xiApi.h"
#include <iostream>
#include <deque>
#include <fstream>
//#include <windows.h>
#include <tchar.h> 
#include <thread>


#include <opencv2/opencv.hpp>
using namespace cv;
using namespace cv::ml;
using namespace std;
//#include <mutex>




#include<windows.h>    //头文件  
#include<iostream> 

#include <QFile>

class SaveDark : public QMainWindow
{
    Q_OBJECT

public:
    SaveDark(QWidget *parent = Q_NULLPTR);
	bool WriteData(QString str, const char *data, int length);


	//封装的函数
	void LoadConfig();
	void ConnectCamera();
	void GetFrame(HANDLE cam);
	/*void SaveData(string str_dir);*/
	int GetNextImage(HANDLE cam);

	std::deque<unsigned char*> m_dequeFrame;//保存原图的图像指针；
											//std::deque<unsigned char*> m_dequeSave;//保存储存图像的图像指针；

	bool m_bGrabFlag = false; //采集标志位
	bool m_bCutFinished = false;//切图线程结束
	bool m_rawFlag = false; //采集标志位

	QString m_QstrExposureTimes;
	QStringList m_QstrExposureTimesList;
	QString m_QstrGains;
	QStringList m_QstrGainsList;

	QString m_QstrSavePath;
	int m_cameraSN;

	int m_saveTime;
	int m_exposureTime;
	int m_gain;
	int m_FPS;
	int pic_width = 2048;
	int pic_height = 2048;

	Mat outImg = Mat::zeros(pic_height, pic_width, CV_8UC1);
	int totalNum = pic_width * pic_height;
	unsigned short * img = new unsigned short[totalNum];
	QString qstr_pic;

	string str_savedir;

	//std::mutex mutex_deque;//队列deque锁


private:
    Ui::SaveDarkClass ui;
};
