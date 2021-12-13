clc;
clear;
close all;

b_filter=1;
%设置平滑度如果光谱的宽度很大:范围在1~65比如:1、26、65
filter_window=65;
%截掉多余明亮的部分:范围在1900~2500左右
limit = 2048;
%可修改读取文件路径
data_file='C:\Users\CP\Desktop\table\matlab_lvguangpian_1108\1\';
%可修改日期
Date = '20211208';
%可修改保存的路径
pathp = ['E:\LVF_Data\',Date,'_Pra_Rat_Res'];
%固定创建文件夹
mkdir (pathp);
%固定保存的路径
savepath = [pathp,'\'];
%分辨率的差值
loca = [];
F = [];
%获取文件的列表
files_list = dir(fullfile(data_file));
for diri=3:size(files_list,1)
    %进入到文件列表里的路径
    card_datapath = files_list(diri,1).name;
    if isempty(strfind(card_datapath,'.xlsx'))==1
        filepath=[data_file,card_datapath,'\'];
        wl=400:50:1000;
        kk=wl(1,2)-wl(1,1);
        bb=wl(1,1)-kk;
        for i= wl
            vi=(i-bb)/kk;
            I=imread(strcat(filepath,num2str(i),'.tif'));
            I = I(1:limit,:);
            %将I的行数全部加起来
            sI=sum(I,2);
            %             hold on;
            %画波段线
            %             plot(sI);
            %取得sI的中值
            mid_sI = (max(sI)+min(sI))/2;
            %             mid_sI = (max(sI)+mid_sI)/2;
            x = [0,limit];
            y = [mid_sI,mid_sI];
            %画中值线
            %              plot(x,y);
            c = [0,0];
            j = 1;
            %计算距离中值最近的交叉点
            for ii = 1 : limit - 1
                if sI(ii) <= mid_sI && sI(ii + 1) > mid_sI;
                    c(j) = ii;
                    j = j + 1;
                    
                elseif sI(ii) > mid_sI && sI(ii + 1) < mid_sI;
                    c(j) = ii + 1;
                    j = j + 1;
                elseif c(2) == 0
                    c(2) = c(1);
                end
            end
            %画最近的交叉点
            %             plot(c,sI(c),'*r');
            
            
            
            [num loc] = findpeaks(sI);
            [a_num,a_loc] = max(num);                          %在全部峰值里面找出最大的一个a_num，包含其位置a_loc
            location_in_x_1 = loc(a_loc);
            loca((i-350)/50) = location_in_x_1;
            %             plot(location_in_x_1,sI(location_in_x_1),'*b');
            
            
            
            
            F((i-350)/50) = c(2)-c(1);
        end
        for i = 1 : 13
            JBL = 600/(loca(1) - loca(13));
            F(i) = JBL*F(i);
            wl(i) = (i*50+350);
        end
        
        hold on;
        plot(wl,F);
        saveas(gcf,[savepath,card_datapath,'_Resolution_400-1000.bmp']);
        savefig([savepath,card_datapath,'_Resolution_400-1000.fig']);
    end
    xlswrite([savepath,card_datapath,'_Resolution.xlsx'],{'wavelength';'mid'},card_datapath,'A1');
    str_num=wl;
    xlswrite([savepath,card_datapath,'_Resolution.xlsx'],str_num,card_datapath,'B1');
    xlswrite([savepath,card_datapath,'_Resolution.xlsx'], F,card_datapath,'B2');
end
