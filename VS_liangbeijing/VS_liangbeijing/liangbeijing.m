clc;
clear;
close all;


list_camera = [36187850,36187950,36188450];
list_cameramode = [8,16];
list_exposuretime = [1500,3000,6000];
list_gain = -1.5 : 0.1 : 6;
num_camera = length(list_camera);
num_cameramode = length(list_cameramode);
num_exposuretime = length(list_exposuretime);
num_gain = length(list_gain);

for modei = 1 : num_cameramode
    for cami = 1 : num_camera
        %读取相机
        str_camera = num2str(list_camera(cami));
        if modei == 1
            datdir = ['.\',str_camera,'-8\data\'];
        else
            datdir = ['.\',str_camera,'-16\data\'];
        end
        pic_exp_gain = [];
        
        for gaini = 1 : num_gain
            %设置读取gain部分.dat的名字
            str_gain = num2str(list_gain(gaini),'%1.2f');
            
            for expi = 1 : num_exposuretime
                
                %设置读取exposuretime部分.dat的名字
                if list_exposuretime(expi) < 10
                    str_exp = ['00000',num2str(list_exposuretime(expi))];
                elseif list_exposuretime(expi) < 100
                    str_exp = ['0000',num2str(list_exposuretime(expi))];
                elseif list_exposuretime(expi) < 1000
                    str_exp = ['000',num2str(list_exposuretime(expi))];
                elseif list_exposuretime(expi) < 10000
                    str_exp = ['00',num2str(list_exposuretime(expi))];
                elseif list_exposuretime(expi) < 100000
                    str_exp = ['0',num2str(list_exposuretime(expi))];
                elseif list_exposuretime(expi) < 1000000
                    str_exp = [num2str(list_exposuretime(expi))];
                end
                
                %连接起来
                str_pic = [datdir,str_exp,'us',str_gain,'gain01','.dat'];
                %读取文件设置读取方式
                if(modei == 1)
                    fid=fopen(str_pic,'r');
                    a=fread(fid,2048*2048,'uint8');
                    fclose(fid);
                    I = reshape(a,2048,2048)';
                    y_grey((cami-1)*num_camera+expi,gaini) = mean(mean(I));
                else
                    fid=fopen(str_pic,'r');
                    b=fread(fid,2048*2048,'uint16');
                    fclose(fid);
                    II = reshape(b,2048,2048)';
                    y_grey((cami-1)*num_camera+expi,gaini) = mean(mean(II));
                end
                
            end
        end
        %    for exi = 1 : length(list_exposuretime)
        %
        %         %设置纵坐标，改变矩阵形状变成三维数组
        %         y_dark = reshape(pic_exp_gain(:,:,exi,:),[256*256],num_gain);
        %         %取平均值
        %         y_dark = mean(y_dark);
        %         figure;
        %         plot(list_gain,y_dark,'-');
        %         xlabel('gain');
        %         ylabel('gray');
        %         title([num2str(list_exposuretime(1,exi)),'us',32,32,'raw']);
        %         xlim([list_gain(1,1),list_gain(1,end)]);
        %
        %    end
    end
    figure;
    plot(list_gain,y_grey);
end

