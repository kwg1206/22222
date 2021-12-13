#pragma once
#include "xiApi.h"
#include <iostream>
#include <deque>
#include <fstream>
//#include <windows.h>
#include <tchar.h> 
#include <thread>



using namespace std;


#include <mutex>


//封装的函数
void ConnectCamera();
void GetFrame(HANDLE cam);
void SaveData(string str_dir);
int GetNextImage(HANDLE cam);

std::deque<unsigned char*> m_dequeFrame;//保存原图的图像指针；
//std::deque<unsigned char*> m_dequeSave;//保存储存图像的图像指针；

bool m_bGrabFlag = false; //采集标志位
bool m_bCutFinished = false;//切图线程结束
bool m_rawFlag = false; //采集标志位
clock_t start1, finish1;
double totaltime1;
condition_variable contion;
std::mutex mutex_deque;//队列deque锁
//void WriteDatHdr(const char* filename, unsigned char* PicData, int thread_num, int wavelength[]);

//bool SotpGrab();
//bool CutFrame();
