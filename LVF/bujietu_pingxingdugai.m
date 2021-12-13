clc;
clear;
close all;

%%
batch_num='11';
% col_num=[
% 778  4054%2-3
% % 786  4167
% % 778 4023
%
% ];
b_filter=1;
%设置平滑度如果光谱的宽度很大:范围在1~65比如:1、26、65
filter_window=1;
%截掉多余明亮的部分:范围在1900~2500左右
limit = 2300;
%可修改读取文件路径
data_file='C:\Users\CP\Desktop\table\matlab_lvguangpian_1108\3\';
%可修改日期
Date = '20211118';
%可修改保存的路径
pathp = ['E:\LVF_Data\',Date,'_Pra_Rat_Res'];
%固定创建文件夹
mkdir (pathp);
%固定保存的路径
savepath = [pathp,'\'];
%获取文件的列表
files_list = dir(fullfile(data_file));
for diri=3:size(files_list,1)
    %     fileName_folder = fullfile(data_file,files_list(i,1).name);
        %进入到文件列表里的路径
    card_datapath = files_list(diri,1).name;
    if isempty(strfind(card_datapath,'.xlsx'))==1
        
        % filepath = 'C:\Users\CGCP\Desktop\lvf_test_data\3-1\';
        filepath=[data_file,card_datapath,'\'];
        
        %% 所有图片裁剪，求行，寻峰
        wl=400:50:1000;
        pos=[];
        vwidths=[];
        
        kk=wl(1,2)-wl(1,1);
        bb=wl(1,1)-kk;
        
        
        
        figure;
        hold on;
        
        
        vi=(i-bb)/kk;
        
        I=imread(strcat(filepath,num2str(400),'.tif'));
        I = I(1:limit,:);
        [h,w]=size(I);
        
        x1=100;%左侧第一个点
        n=300;
        nx=floor((w-200)/(n-1));%两点间隔
        xi=x1:nx:w-100;
        %             I=I(:,col_num(1,1):col_num(1,2));
        for ii=1:n
            Ii=I(:,xi(ii):xi(ii)+100);
            sIi=sum(Ii,2);
            
            %% 寻峰
            
            %             [sI,posi,widths,locs,pks]=xunfeng(I,wl,vi);
            %             plot(sI,'-','color',[rand,rand,rand]);
            
            
            %             vwidths=[vwidths,widths];
            %             pos=[pos posi];
            [num loc] = findpeaks(sIi);
            [a_num,a_loc] = max(num);                          %在全部峰值里面找出最大的一个a_num，包含其位置a_loc
            location_in_x_1 = loc(a_loc);                      %最大的峰值对应的位置
            num(a_loc) = 0;                                    %在找出的全部峰值数组中，将最大的峰值赋值为0
            num_del_max = num;
            [b_num,b_loc] = max(num);                          %找剩下的峰值中的最大值
            location_in_x_2 = loc(b_loc);
            
            plot(sIi)%找第二大的峰值对应的位置
            %获取第一大和第二大的波峰取两个波峰的中点，如果两个波峰距离较远就选择第一个波峰
            if abs(location_in_x_1 - location_in_x_2) > 20 && abs(sIi(location_in_x_1)  - sIi(location_in_x_2)) > 30000
                plot((location_in_x_1+location_in_x_2)/2,(sIi(location_in_x_1)+sIi(location_in_x_2))/2,'r*');
            else
                plot(location_in_x_1,sIi(location_in_x_1),'r*');
            end
            
            
            
            %                 x = 1 : 1 : h;
            %                 y = sIi;
            %                 plot(y,'-','color',[rand,rand,rand]);
            %                 yy = sort(y);
            %                 xx = find(y == yy(end));
            %                 plot(xx,yy(end),'r*');
            
        end
        
        
        hold off;
        xlabel('row number');
        ylabel('row sum');
        title([card_datapath,32,'central wavelength position']);
%         saveas(gcf,[savepath,card_datapath,'_Parallelism_number_postion1.bmp']);
        
        % figure(2);
        % plot(wl,pos);
        % xlabel('WaveLength(nm)');
        % ylabel('Position(pixel)');
        % saveas(gcf,'./pic_saved/wl_p.bmp');
        
        
        %% 拟合
        
        % figure(3);
        % pn = polyfit(wl,pos,1);
        % pos_fit = polyval(pn,wl);
        % plot(wl,pos,'ko',wl,pos_fit,'r');
        % rr=norm(pos_fit-mean(pos))^2/norm(pos-mean(pos))^2;
        %
        % legend('data','fit');
        % xlabel('WaveLength(nm)');
        % ylabel('Position(pixel)');
        % if pn(1,2)>=0
        %     strt=['pos=',num2str(pn(1,1)),'wave+',num2str(pn(1,2)),32,32,'r^2=',num2str(rr)];
        % else
        %     strt=['pos=',num2str(pn(1,1)),'wave',num2str(pn(1,2)),32,32,'r^2=',num2str(rr)];
        % end
        % title(strt);
        % saveas(gcf,'wl_p拟合.bmp');
        
        
        %% 平行度测试
        
        n=20;
        t1=floor(w/3);%左侧第一个点
        nt=floor((w/3)/(n-1));%两点间隔
        ti=t1:nt:floor(2*w/3);
        
        %         wl=500:100:1000;
        pos5t=zeros(size(wl,2),n);
        pos5t1=zeros(size(wl,2),n);
        parall_kbrr=zeros(size(wl,2),4);
        
        for i=wl
            
            vi=(i-bb)/kk;
            
            I=imread(strcat(filepath,num2str(i),'.tif'));
            %             I=I(:,col_num(1,1):col_num(1,2));
            I = I(1:limit,:);
            
            %% 寻峰
            for ii=1:n
                Ii=I(:,ti(ii):ti(ii)+100);
                sIi=sum(Ii,2);
                if b_filter==1
                    windowSize = filter_window;
                    b = (1/windowSize)*ones(1,windowSize);
                    a = 1;
                    sIi = filter(b,a,sIi);
                end
                [num loc] = findpeaks(sIi);
                [a_num,a_loc] = max(num);                          %在全部峰值里面找出最大的一个a_num，包含其位置a_loc
                location_in_x_1 = loc(a_loc);                      %最大的峰值对应的位置
                num(a_loc) = 0;                                    %在找出的全部峰值数组中，将最大的峰值赋值为0
                num_del_max = num;
                [b_num,b_loc] = max(num);                          %找剩下的峰值中的最大值
                location_in_x_2 = loc(b_loc);
                
                %获取第一大和第二大的波峰取两个波峰的中点，如果两个波峰距离较远就选择第一个波峰
                if abs(location_in_x_1 - location_in_x_2) > 20 && abs(sIi(location_in_x_1)  - sIi(location_in_x_2)) > 30000
                    pos5t(vi,ii)=(location_in_x_1+location_in_x_2)/2;
                else
                    pos5t(vi,ii)=location_in_x_1;
                end
                
                
                %                 [max_sIi,index_max]=max(sIi);
                %                 min_sIi=min(sIi);
                %                 mid_sIi=mean([max(sIi),min(sIi)]);
                %                 c1=[];c2=[];
                %                 for iii=1:index_max
                %                     if sIi(index_max+1-iii)-mid_sIi<=0 && sIi(index_max+1-iii+1)-mid_sIi>0
                %                         c1(end+1)=index_max+1-iii;
                %                     end
                %                 end
                %                 for iii=index_max:size(Ii,1)-1
                %                     if sIi(iii)-mid_sIi>=0 && sIi(iii+1)-mid_sIi<0
                %                         c2(end+1)=iii;
                %                     end
                %                 end
                %                 if isempty(c1)==0 && isempty(c2)==0
                %                     locsi = mean([c1(1),c2(1)]);
                %                 elseif isempty(c1)==0 && isempty(c2)==1
                %                     locsi = c1(1);
                %                 elseif isempty(c1)==1 && isempty(c2)==0
                %                     locsi = c2(1);
                %                 end
                %                  pos5t(vi,ii) = locsi;
                
            end
        end
        
        clear i1 ii jj;
        %         figure;
        %         hold on;
        %         plot(pos5t);
        %         figure;
        %         hold on;
        %         plot(pos5t1);
        % pos5=pos5;
        figure;
        hold on;
        for i1=1:size(pos5t,1)
            % 五点拟合
            pni = polyfit(ti,pos5t(i1,:),1);
            pos_fiti = polyval(pni,ti);
            di=abs(pos_fiti-pos5t(i1,:));
            rri=norm(pos_fiti-mean(pos5t(i1,:)))^2/norm(pos5t(i1,:)-mean(pos5t(i1,:)))^2;
            parall_kbrr(i1,:)=[pni(1,1) pni(1,2) rri max(di)];
            plot(ti,pos5t(i1,:),'-o','color',[rand rand rand]);
        end
        hold off;
        xlabel('column number');
        ylabel('pos_i');
        title([card_datapath,32,'pos1-pos5']);
        saveas(gcf,[savepath,card_datapath,'_Parallelism_pos1-pos5.bmp']);
        
        d_lr=[];
        xleft=100;
        xright=w-100;
        for i3=1:size(wl,2)
            %             d_lr(i3,1)=abs(parall_kbrr(i3,1)*xleft+parall_kbrr(i3,2));
            %             d_lr(i3,2)=abs(parall_kbrr(i3,1)*xright+parall_kbrr(i3,2));
            d_lr(i3,1)=parall_kbrr(i3,1)*xleft+parall_kbrr(i3,2);
            d_lr(i3,2)=parall_kbrr(i3,1)*xright+parall_kbrr(i3,2);
            d_lr(i3,3)=d_lr(i3,1)-d_lr(i3,2);
        end
        aa = d_lr(:,3);
        bb = min(d_lr(:,3));
        d_lr(:,4)=d_lr(:,3)-min(d_lr(:,3));
        
        figure;
        plot(wl,d_lr(:,4),'b-o');
        xlabel('wavelength');
        ylabel('left-right');
        title([card_datapath,32,'left-right']);
        saveas(gcf,[savepath,card_datapath,'_Parallelism_wave_l_r.bmp']);
        
        
        %保存xslx
        xlswrite([savepath,card_datapath,'_Parallelism_pleft-right.xlsx'],wl',card_datapath,'A2');
        xlswrite([savepath,card_datapath,'_Parallelism_pleft-right.xlsx'],{'left','right','left-right','left-right0','max(left-right0)'},card_datapath,'B1');
        xlswrite([savepath,card_datapath,'_Parallelism_pleft-right.xlsx'],d_lr(:,1),card_datapath,'B2');
        xlswrite([savepath,card_datapath,'_Parallelism_pleft-right.xlsx'],d_lr(:,2),card_datapath,'C2');
        xlswrite([savepath,card_datapath,'_Parallelism_pleft-right.xlsx'],d_lr(:,3),card_datapath,'D2');
        xlswrite([savepath,card_datapath,'_Parallelism_pleft-right.xlsx'],d_lr(:,4),card_datapath,'E2');
        xlswrite([savepath,card_datapath,'_Parallelism_pleft-right.xlsx'],max(d_lr(:,4)),card_datapath,'F2');
        
        %         hang=parall_kbrr(:,1)*w/2+parall_kbrr(:,2);
        %         for i=1:size(hang,1)-1
        %             hang0(i,1)=floor((hang(i,1)+hang(i+1,1))/2);
        %         end
        %
        %         p1=imread(strcat(filepath,num2str(500),'.tif'));
        %         p1=p1';
        %         p1=p1(up_h:up_h+w0,:);
        %         pic59(1:hang0(1),:)=p1(1:hang0(1),:);
        %
        %         p1=imread(strcat(filepath,num2str(600),'.tif'));
        %         p1=p1';
        %         p1=p1(up_h:up_h+w0,:);
        %         pic59(hang0(1):hang0(2),:)=p1(hang0(1):hang0(2),:);
        %
        %         p1=imread(strcat(filepath,num2str(700),'.tif'));
        %         p1=p1';
        %         p1=p1(up_h:up_h+w0,:);
        %         pic59(hang0(2):hang0(3),:)=p1(hang0(2):hang0(3),:);
        %
        %         p1=imread(strcat(filepath,num2str(800),'.tif'));
        %         p1=p1';
        %         p1=p1(up_h:up_h+w0,:);
        %         pic59(hang0(3):hang0(4),:)=p1(hang0(3):hang0(4),:);
        %
        %         p1=imread(strcat(filepath,num2str(900),'.tif'));
        %         p1=p1';
        %         p1=p1(up_h:up_h+w0,:);
        %         pic59(hang0(4):size(p1,1),:)=p1(hang0(4):size(p1,1),:);
        %         % figure;
        %         % imshow(pic59);
        %
        %         figure;
        %         imshow(pic59);
        %         hold on;
        %         plot([xleft,xleft],[0,w],'b');
        %         plot([xright,xright],[0,w],'b');
        %
        %         % x=100:(w-200)/50:w-100;
        %         x=[100,ti,w-100];
        %         x1=0:w;
        %         for i4=1:size(wl,2)
        %             plot(x1,parall_kbrr(i4,1)*x1+parall_kbrr(i4,2),'m');
        %             plot(x,parall_kbrr(i4,1)*x+parall_kbrr(i4,2),'m-o');
        %         end
    end
    
    
end
















