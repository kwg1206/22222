clc;
clear;
close all;

% datafile='../data/23081450（600-800）/有镜头/';
datafile='../data/24080150（400-600）/有镜头/';
%datafile='C:/Users/CGCP/Desktop/像元级三种方法对比/data/23084450（600-800）/有镜头/';
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

I=imread([datafile,num2str(pic_name(1)),'.tif']);
hh=size(I,1);ww=size(I,2);
hch=3;wch=3;
hbin=2;wbin=2;
xmin=0;xmax=2047;
ymin=0;ymax=2047;
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

savepath=[datafile,'4avg'];
if exist(savepath,'dir')
    rmdir(savepath,'s');
end 
mkdir(savepath); 

Icutchannel=[];

for xoffset=0:1%0:wbin-1
    for yoffset=0:1%0:hbin-1
        %xoffset
        %yoffset
        disp(['xoffset=',num2str(xoffset),32,32,'yoffset=',num2str(yoffset),32,'start...']);
        if ~exist([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/',ca_id,'_Config_ind_cp.ini'],'file')==0
            delete([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/',ca_id,'_Config_ind_cp.ini']);
        end
        if ~exist([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/',ca_id,'_Config_ind_dp.ini'],'file')==0
            delete([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/',ca_id,'_Config_ind_dp.ini']);
        end
        %mkdir([savepath,'/his_res',num2str(xoffset),num2str(yoffset)]);
        
       
        
        Ich=zeros(hch*wch,floor((ymax-ymin+1)/hch),floor((xmax-xmin+1)/wch),'uint8');
        wl=zeros(1,length(pic_name));Iavg=zeros(hch*wch,length(pic_name));
        for k=1 :length(pic_name)
            I=imread([datafile,num2str(pic_name(k)),'.tif']);
            wl(1,k)=pic_name(k);
            
            for i=1:hh
                for j=1:ww
                    vi=i+xoffset;vj=j+yoffset;
                    if ((ymax+1>=i)&&(ymin+1<=i)&&(xmax+1>=j)&&(xmin+1<=j))
                        ch_h=mod(floor((vi-1)/hbin)+1,hch);
                        if ch_h==0
                            ch_h=hch;
                        end
                        ch_w=mod(floor((vj-1)/wbin)+1,wch);
                        if ch_w==0
                            ch_w=wch;
                        end
                        ch=ch_w+(ch_h-1)*wch;
                        II(i,j)=ch;
                        ii=floor((i-1)/hbin/hch)*hbin+1+mod(i-1,hbin);
                        jj=floor((j-1)/wbin/wch)*wbin+1+mod(j-1,wbin);
                        Ich(ch,ii,jj)=I(i,j);
                    end
                end
            end
            for i=1:hch*wch
                Iavg(i,k)=mean(mean(Ich(i,:,:)));
            end
        end
        
        
        [wl_s,ind]=sort(wl);
        Iavg_s=Iavg(:,ind);
        plot(wl_s',Iavg_s');
%         xlim([400 1000]);
        xlim([wl(1) wl(end)]);
        xlabel('WaveLength(nm)');
        ylabel('Iavg');
        legend('Location','northwest');
        saveas(gcf,[savepath,'/Iavg',num2str(xoffset),num2str(yoffset),'.png']);
        saveas(gcf,[savepath,'/Iavg',num2str(xoffset),num2str(yoffset),'.fig']);
        
        i_=[];vch_id=[];
        for i=1:length(wl_s)
            if (wl_s(i)-wave_a)*(wl_s(i)-wave_b)<0  %波长范围
                i_=[i_ i];
            end
        end
        for i=1:hch*wch
            [~,ch_id]=max(Iavg_s(i,i_));
            ch_wl=wl_s(i_(ch_id));
            vch_id=[vch_id i_(ch_id)];
        end
        
        Ich_=zeros(hch*wch,floor((ymax-ymin+1)/hch),floor((xmax-xmin+1)/wch),hch*wch,'uint8');
        for k=1:length(pic_name)
%             vim_na=pic_name(k).name;            
%             wlwl=str2double(vim_na(1:end-4));
            wlwl=pic_name(k);
            
            
            n=0;
            for l=1:hch*wch
                if (wlwl~=wl_s(vch_id(l)))
                    n=n+1;
                else
                    ll=l;
                end
            end
            if n==hch*wch
                continue;
            end
%             I=imread(im_na(k).name);
            I=imread([datafile,num2str(pic_name(k)),'.tif']);
            
            
            for i=1:hh
                for j=1:ww
                    vi=i+xoffset;vj=j+yoffset;
                    if ((ymax+1>=i)&&(ymin+1<=i)&&(xmax+1>=j)&&(xmin+1<=j))
                        ch_h=mod(floor((vi-1)/hbin)+1,hch);
                        if ch_h==0
                            ch_h=hch;
                            
                        end
                        ch_w=mod(floor((vj-1)/wbin)+1,wch);
                        if ch_w==0
                            ch_w=wch;
                        end
                        ch=ch_w+(ch_h-1)*wch;
                        II(i,j)=ch;
                        ii=floor((i-1)/hbin/hch)*hbin+1+mod(i-1,hbin);
                        jj=floor((j-1)/wbin/wch)*wbin+1+mod(j-1,wbin);
                        Ich_(ch,ii,jj,ll)=I(i,j);
                    end
                end
            end
        end
        Ich_wlmax=zeros(hch*wch,floor((ymax-ymin+1)/hch),floor((xmax-xmin+1)/wch),'double');
        Ich_wlmaxIr=zeros(hch*wch,floor((ymax-ymin+1)/hch),floor((xmax-xmin+1)/wch),'double');
        Ich_wlmaxI=zeros(hch*wch,floor((ymax-ymin+1)/hch),floor((xmax-xmin+1)/wch),'double');
        meanwlmaxIr=[];maxwlmaxIr=[];maxminwlmax=[];maxwlmaxI=[];
        mkdir([savepath,'/his_res',num2str(xoffset),num2str(yoffset)]);
        for l=1:hch*wch
            minwlmax=1000;
            for ii=1:size(Ich,2)
                for jj=1:size(Ich,3)
                    [~,id]=sort([Ich_(l,ii,jj,:)]);
                    if Ich_(l,ii,jj,id(end))~=0
                        Ich_wlmaxIr(l,ii,jj)=double(Ich_(l,ii,jj,id(end-1)))/double(Ich_(l,ii,jj,id(end)));
                        Ich_wlmax(l,ii,jj)=wl_s(vch_id(id(end)));
                        Ich_wlmaxI(l,ii,jj)=Ich_(l,ii,jj,id(end));
                        if minwlmax>Ich_wlmax(l,ii,jj)
                            minwlmax=Ich_wlmax(l,ii,jj);
                        end
                    else
                        Ich_wlmaxIr(l,ii,jj)=0;
                        %Ich_wlmax(l,ii,jj)=wl_s(vch_id(id(end)));
                    end
                end
            end
            wlmax=[];
            wlmax(:,:)=Ich_wlmax(l,:,:);
            meanwlmaxIr(l)=mean(mean(Ich_wlmaxIr(l,:,:)));
            maxwlmaxIr(l)=max(max(Ich_wlmaxIr(l,:,:)));
            maxminwlmax(l)=max(max(Ich_wlmax(l,:,:)))-minwlmax;
            maxwlmaxI(l)=max(max(Ich_wlmaxI(l,:,:)));
            figure;
            histogram(Ich_wlmaxIr(l,:,:))
            
            title(['channel',num2str(l),' 2nd_maxI/maxI']);
            saveas(gcf,[savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/ch',num2str(l),'mxIr.tif']);
            figure;
            histogram(wlmax(find(wlmax)))
            xlim([wl(1) wl(end)]);
            title(['channel',num2str(l),' maxWL']);
            saveas(gcf,[savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/ch',num2str(l),'mxwl.tif']);
        end

        [~,maxI_ind]=max(Iavg_s,[],2);
        wl_center=wl_s(maxI_ind);
        [~,ch_ind]=sort(wl_center);
		[~,dp_ind] = sort(ch_ind);
        dp_ind = dp_ind - 1;
		
              
       %% 写config_cp      
        fid_cp=fopen([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/',ca_id,'_Config_ind_cp.ini'],'a');
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
                fprintf(fid_cp,['CutTop_Fa =',num2str(2+xoffset+cdx)]);
                fprintf(fid_cp,'\r\n');
                fprintf(fid_cp,['CutLeft_Fa =',num2str(2+yoffset+cdy)]);
                fprintf(fid_cp,'\r\n');         
            end
        end
        fclose(fid_cp); 
        
        
       %% 写config_dp
        fid_dp=fopen([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/',ca_id,'_Config_ind_dp.ini'],'a');
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
                fprintf(fid_dp,['CutTop_Fa=',num2str(2+xoffset)]);
                fprintf(fid_dp,'\r\n');   
                fprintf(fid_dp,['CutLeft_Fa=',num2str(2+yoffset)]);
                fprintf(fid_dp,'\r\n');   
                  
            end
        end
        fclose(fid_cp);  
        
        
        
        
        
       %% 切各通道图
        mkdir([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/matdat']);
        for wi=1:9
            wave_name_config=abs(pic_name-wave_config(wi));
            [~,min_indwnc]=min(wave_name_config);
            wave_picname(1,wi)=pic_name(min_indwnc);
                     
            I=imread([datafile,num2str(wave_picname(1,wi)),'.tif']);           
            Icut=I(xoffset+1:xoffset+2046,yoffset+1:yoffset+2046);  
            
            cxy0=1:2:2046;
            cxy1=2:2:2046;

            Icut102300=Icut(cxy0,cxy0);
            Icut102301=Icut(cxy0,cxy1);
            Icut102310=Icut(cxy1,cxy0);
            Icut102311=Icut(cxy1,cxy1);

            Icut1023=double(Icut102300+Icut102301+Icut102310+Icut102311);
            Icut10231=Icut1023*0.25;

            chxy0=1:3:1023;
            chxy1=2:3:1023;
            chxy2=3:3:1023;

            Icutchannel(:,:,1)=Icut10231(chxy0,chxy0);      
            Icutchannel(:,:,2)=Icut10231(chxy0,chxy1);
            Icutchannel(:,:,3)=Icut10231(chxy0,chxy2);

            Icutchannel(:,:,4)=Icut10231(chxy1,chxy0);
            Icutchannel(:,:,5)=Icut10231(chxy1,chxy1);
            Icutchannel(:,:,6)=Icut10231(chxy1,chxy2);

            Icutchannel(:,:,7)=Icut10231(chxy2,chxy0);
            Icutchannel(:,:,8)=Icut10231(chxy2,chxy1);
            Icutchannel(:,:,9)=Icut10231(chxy2,chxy2);
            
            %mat
            eval(['cmat',num2str(wave_picname(1,wi)),'nm=Icutchannel;']);
            savename_str=[savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/matdat/cmat',num2str(wave_picname(1,wi)),'nm.mat']; 
            save(savename_str,['cmat',num2str(wave_picname(1,wi)),'nm']);
            %dat
            fid_cmati = fopen([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/matdat/cmat',num2str(wave_picname(1,wi)),'nm.dat'],'w');
            eval(['fwrite(fid_cmati,cmat',num2str(wave_picname(1,wi)),'nm,''double'');'])
            fclose(fid_cmati);
            %%
                
%             fid_cmati = fopen([savepath,'/his_res',num2str(xoffset),num2str(yoffset),'/matdat/cmat780nm.dat'],'w');
%             fwrite(fid_cmati,cmat780nm,'double');
%             fclose(fid_cmati);    
                
        
            
      
            
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
         

   
       
        save([savepath,'/wl_Ich_avg',num2str(xoffset),num2str(yoffset),'.mat']);
        disp('************************');
    end
end
disp('finish!');






