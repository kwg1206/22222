clc;
clear;
close all;


% datafile='../data/23081450（600-800）/有镜头/';
datafile='../data/24080150（400-600）/有镜头/';
% datafile='../data/23084450（600-800）/有镜头/';
waveRange=400600;

if waveRange==400600
    pic_name=[400:5:600];
    wave_a=400;
    wave_b=600;
elseif waveRange==600800
    pic_name=[600:5:800];
    wave_a=600;
    wave_b=800;
end
%默认不漏光，漏光偏置为0,0
cdx=0;
cdy=0;

if wave_b==800
    wave_config=[633 653 674 690 712 732 745 764 781];
elseif wave_b==600
    wave_config=[453 467 483 495 512 528 539 555 569];
end

config_cp_str={
'[BandInfo]'
'BandNum=9'
''
'[FrameCut]'
};

config_dp_str={
'[Camera_0]'
'BandNum=9' 
};



%% 截取tif所在文件夹名   23081450（600-800） 有镜头
m_index=strfind(datafile,'/');
ca_id=[datafile(m_index(end-2)+1:m_index(end-1)-1),32,datafile(m_index(end-1)+1:m_index(end)-1)];

savepath=[datafile,'4select1'];
if exist(savepath,'dir')
    rmdir(savepath,'s');
end 
mkdir(savepath); 

Icutchannel=[];


for k=1 :length(pic_name)
    I=imread([datafile,num2str(pic_name(k)),'.tif']);
    I=I(2:end-1,2:end-1);
    
    xy0_index=1:2:2046;
    xy1_index=2:2:2046;    
    
    
    I00(:,:,k)=I(xy0_index,xy0_index);
    I01(:,:,k)=I(xy0_index,xy1_index);
    I10(:,:,k)=I(xy1_index,xy0_index);
    I11(:,:,k)=I(xy1_index,xy1_index);
    wl(1,k)=pic_name(k);

end





for xselect=0:1%0:wbin-1
    for yselect=0:1%0:hbin-1
        %xselect
        %yselect 
        
        saveway=[savepath,'/select',num2str(xselect),num2str(yselect)];
  
        if exist(saveway,'dir')
            rmdir(saveway,'s');
        end 
        mkdir(saveway);   
       
        eval(['Ixy=I',num2str(xselect),num2str(yselect),';']); 
        wl(1,k)=pic_name(k);
            
        xyi1=1:3:1023;
        xyi2=2:3:1023;
        xyi3=3:3:1023;
        
        ch1=double(Ixy(xyi1,xyi1,:));
        ch2=double(Ixy(xyi1,xyi2,:));
        ch3=double(Ixy(xyi1,xyi3,:));
        
        ch4=double(Ixy(xyi2,xyi1,:));
        ch5=double(Ixy(xyi2,xyi2,:));
        ch6=double(Ixy(xyi2,xyi3,:));
        
        ch7=double(Ixy(xyi3,xyi1,:));
        ch8=double(Ixy(xyi3,xyi2,:));
        ch9=double(Ixy(xyi3,xyi3,:));
        
        
%         for chi_index=1:9                          
%             % 每张图拆9张，一共9*9=81张
%             for pn=1:length(wl)
%                  %ci=reshape(mean(mean(ch1,1),2),1,size(wl,2));
%                 eval(['ci=reshape(mean(mean(ch',num2str(chi_index),',1),2),1,size(wl,2));']);                   
%                 [~,max_indexci]=max(ci);
%                 %cci=ch1(:,:,pn);
%                 eval(['cci=ch',num2str(chi_index),'(:,:,',num2str(pn),');']);         
%                 ccii=cci*255/double(max(max(cci)));
% 
%                 figure;
%                 imshow(uint8(ccii));
%                 title(['ch',num2str(chi_index),32,32,num2str(wl(pn)),'nm']);
%                 %saveas(gcf,['./select',num2str(xselect),num2str(yselect),'/ch',num2str(chi_index),32,32,num2str(wl(max_indexci)),'nm.bmp']);          
%                 imwrite(uint8(ccii),[saveway,'/ch',num2str(chi_index),32,32,num2str(wl(pn)),'nm.bmp']);
% 
%             
%             end         
%         end
        
        
        
        
        Iavgxy(1,:)=reshape(mean(mean(Ixy(xyi1,xyi1,:),1),2),1,length(wl));
        Iavgxy(2,:)=reshape(mean(mean(Ixy(xyi1,xyi2,:),1),2),1,length(wl));
        Iavgxy(3,:)=reshape(mean(mean(Ixy(xyi1,xyi3,:),1),2),1,length(wl));
        Iavgxy(4,:)=reshape(mean(mean(Ixy(xyi2,xyi1,:),1),2),1,length(wl));
        Iavgxy(5,:)=reshape(mean(mean(Ixy(xyi2,xyi2,:),1),2),1,length(wl));
        Iavgxy(6,:)=reshape(mean(mean(Ixy(xyi2,xyi3,:),1),2),1,length(wl));      
        Iavgxy(7,:)=reshape(mean(mean(Ixy(xyi3,xyi1,:),1),2),1,length(wl));
        Iavgxy(8,:)=reshape(mean(mean(Ixy(xyi3,xyi2,:),1),2),1,length(wl));
        Iavgxy(9,:)=reshape(mean(mean(Ixy(xyi3,xyi3,:),1),2),1,length(wl));
                 
        [wl_s,ind]=sort(wl);
        Iavgxy_s=Iavgxy(:,ind);
        
        figure;
        plot(wl_s',Iavgxy_s');
        xlim([wl(1) wl(end)]);
        xlabel('WaveLength(nm)');
        ylabel(['Iavg',num2str(xselect),num2str(yselect)]);
        title(['WaveLength - Iselect',num2str(xselect),num2str(yselect)]);
        legend('Location','northwest');
        saveas(gcf,[savepath,'/Iselect',num2str(xselect),num2str(yselect),'.png']);
        saveas(gcf,[savepath,'/Iselect',num2str(xselect),num2str(yselect),'.fig']);
    
        max_gray=zeros(1023,1023);
        for ii=1:1023
            for jj=1:1023
                [max_value,max_index]=max(Ixy(ii,jj,:));
                max_gray(ii,jj)=wl(max_index);              
            end
        end
        
        for ci=1:3
            for cj=1:3
            eval(['max_grayii=max_gray(xyi',num2str(ci),',xyi',num2str(cj),');']);
            figure;
            histogram(max_grayii(find(max_grayii)));
            xlim([wl(1) wl(end)]);
            set(gca,'xtick',wl(1):20:wl(end))    
            title(['channel',num2str((ci-1)*3+cj),' maxWL']);
            saveas(gcf,[saveway,'/ch',num2str((ci-1)*3+cj),'mxwl.bmp']);
            savefig([saveway,'/ch',num2str((ci-1)*3+cj),'mxwl.fig']);
            
            end
        end
        

        [~,maxI_ind]=max(Iavgxy_s,[],2);
        wl_center=wl_s(maxI_ind);
        [~,ch_ind]=sort(wl_center);
		[~,dp_ind] = sort(ch_ind);
        dp_ind = dp_ind - 1;
            
       %% 写config_cp        
        fid_cp=fopen([saveway,'/',ca_id,'_Config_ind_cp.ini'],'a');
        for cpi=1:size(config_cp_str,1)
            fprintf(fid_cp,config_cp_str{cpi,1});
            fprintf(fid_cp,'\r\n');            
            if cpi==2
                for bandii=1:9
                    fprintf(fid_cp,['BandIndex',num2str(bandii-1),'=',num2str(ch_ind(1,bandii)-1)]);
                    fprintf(fid_cp,'\r\n');
                    fprintf(fid_cp,['Band',num2str(bandii-1),'=',num2str(wave_config(1,bandii))]);
                    fprintf(fid_cp,'\r\n');                 
                end
            elseif cpi==4         
                fprintf(fid_cp,['CutTop_Fc =',num2str(1+xselect)]);
                fprintf(fid_cp,'\r\n');  
                fprintf(fid_cp,['CutLeft_Fc =',num2str(1+yselect)]);
                fprintf(fid_cp,'\r\n');    
            end
        end
        fclose(fid_cp); 
        
       %% 写config_dp      
        fid_dp=fopen([saveway,'/',ca_id,'_Config_ind_dp.ini'],'a');
        for dpi=1:size(config_dp_str,1)
            fprintf(fid_dp,config_dp_str{dpi,1});
            fprintf(fid_dp,'\r\n'); 
            if dpi==1
                fprintf(fid_dp,['CameraSerialNum=',ca_id]);
                fprintf(fid_dp,'\r\n');  
            elseif dpi==2
                for bandii=1:9
                    fprintf(fid_dp,['BandIndex',num2str(bandii-1),'=',num2str(dp_ind(1,bandii))]);
                    fprintf(fid_dp,'\r\n');                 
                end
                for bandii=1:9
                    fprintf(fid_dp,['Band',num2str(bandii-1),'=',num2str(wave_config(1,bandii))]);
                    fprintf(fid_dp,'\r\n');                 
                end  
                
                fprintf(fid_dp,['CutTop_Fc=',num2str(1+xselect)]);
                fprintf(fid_dp,'\r\n');   
                fprintf(fid_dp,['CutLeft_Fc=',num2str(1+yselect)]);
                fprintf(fid_dp,'\r\n'); 
                           
            end
        end
        fclose(fid_cp);  
      
    
        save([savepath,'/wl_Ich_select',num2str(xselect),num2str(yselect),'.mat']);
        disp(['save config',num2str(xselect),num2str(yselect),' finish!']);
        
        
        
        %% 画各通道图
        %load wl_Ich_avg11.mat;
        xy1=1:3:1023;
        xy2=2:3:1023;
        xy3=3:3:1023;

        for ci=1:3
            for cj=1:3
                %grayij=max_gray(xy1,xy1);
                eval(['grayij=max_gray(xy',num2str(ci),',xy',num2str(cj),');']);
                picij=zeros(size(grayij,1),size(grayij,2),3);
                for i=1:size(grayij,1)
                    for j=1:size(grayij,2)
                        if (grayij(i,j)-wave_config(1))^2<25
                            picij(i,j,1)=255;
                            picij(i,j,2)=0;
                            picij(i,j,3)=0;
                        elseif (grayij(i,j)-wave_config(2))^2<25
                            picij(i,j,1)=0;
                            picij(i,j,2)=255;
                            picij(i,j,3)=0;
                        elseif (grayij(i,j)-wave_config(3))^2<25
                            picij(i,j,1)=0;
                            picij(i,j,2)=0;
                            picij(i,j,3)=255;


                        elseif (grayij(i,j)-wave_config(4))^2<25
                            picij(i,j,1)=0;
                            picij(i,j,2)=255;
                            picij(i,j,3)=255;
                        elseif (grayij(i,j)-wave_config(5))^2<25
                            picij(i,j,1)=255;
                            picij(i,j,2)=0;
                            picij(i,j,3)=255;
                        elseif (grayij(i,j)-wave_config(6))^2<25
                            picij(i,j,1)=255;
                            picij(i,j,2)=255;
                            picij(i,j,3)=0;

                        elseif (grayij(i,j)-wave_config(7))^2<25
                            picij(i,j,1)=125;
                            picij(i,j,2)=0;
                            picij(i,j,3)=0;
                        elseif (grayij(i,j)-wave_config(8))^2<25
                            picij(i,j,1)=0;
                            picij(i,j,2)=125;
                            picij(i,j,3)=0;
                        elseif (grayij(i,j)-wave_config(9))^2<25
                            picij(i,j,1)=0;
                            picij(i,j,2)=0;
                            picij(i,j,3)=125;
                        end
                    end
                end

                figure;
                imshow(uint8(picij));
                title(['channel',num2str((ci-1)*3+cj)]);
                imwrite(uint8(picij),[saveway,'/channel',num2str((ci-1)*3+cj),'.bmp']);
                savefig([saveway,'/channel',num2str((ci-1)*3+cj),'.fig']);
            end
        end
        disp(['plot channel',num2str(xselect),num2str(yselect),' finish!']);
        
        
        
       %% 切各通道图
        mkdir([saveway,'/matdat']);
        for wi=1:9%切第几张原图
            wave_name_config=abs(pic_name-wave_config(wi));
            [~,min_indwnc]=min(wave_name_config);
            wave_picname_index(1,wi)=min_indwnc;
            wave_picname(1,wi)=pic_name(1,min_indwnc);
            for wii=1:9%当前原图的第几个通道
                %Icutchannel(:,:,wii)=chwii(:,:,wave_picname_index(1,wi));
                eval(['Icutchannel(:,:,',num2str(wii),')=ch',num2str(wii),'(:,:,wave_picname_index(1,wi));']);
            end
                        
            %mat
            eval(['cmat',num2str(wave_picname(1,wi)),'nm=Icutchannel;']);
            savename_str=[saveway,'/matdat/cmat',num2str(wave_picname(1,wi)),'nm.mat']; 
            save(savename_str,['cmat',num2str(wave_picname(1,wi)),'nm']);
            %dat
            fid_cmati = fopen([saveway,'/matdat/cmat',num2str(wave_picname(1,wi)),'nm.dat'],'w');
            eval(['fwrite(fid_cmati,cmat',num2str(wave_picname(1,wi)),'nm,''double'');'])
            fclose(fid_cmati);            
        end
    end
end
disp('finish all!');


























