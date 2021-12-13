clc;
clear;
close all;

%datafile='../data/23084450（600-800）/有镜头/';
%datafile='../data/24080150（400-600）/有镜头/';
% datafile='../data/49482450（600-800）/有镜头/';
% datafile='../datanew/400-600/23080550(F3019010621)/';%01 
% change_index=[3 5 4 6 8 7 0 2 1];
% cuttop=1;
% cutleft=2;

% datafile='../datanew/400-600/23084850(F3019011037)/';%00
% change_index=[6 8 7 0 2 1 3 5 4];
% cuttop=1;
% cutleft=1;
% 
% datafile='../datanew/400-600/36187750(F5120010378)/';%01
% change_index=[3 5 4 6 8 7 0 2 1];
% cuttop=1;
% cutleft=2;
% 
% datafile='../datanew/400-600/36188250(F5120010357)/';%11
% change_index=[0 2 1 3 5 4 6 8 7];
% cuttop=2;
% cutleft=2;


% datafile='../datanew/600-800/08781150(F3118161773)/';

% datafile='../datanew/600-800/23084050(F3019010826)/';%00
% % change_index=[4 3 5 7 6 8 1 0 2];
% cuttop=2;
% cutleft=2;

% datafile='../datanew/600-800/23084250(F3019011043)/';%01
% %change_index=[4 3 5 7 6 8 1 0 2];
% cuttop=2;
% cutleft=3;

% datafile='../datanew/600-800/23084450(F3019010830)/';%11
% %change_index=[6 8 7 0 2 1 3 5 4];
% cuttop=2;
% cutleft=2;

datafile='../data/600-800/36187650(F3019010638)/';%11
%change_index=[6 8 7 0 2 1 3 5 4];
cuttop=2;
cutleft=2;

% datafile='../datanew/600-800/36187650(F3019010638)/';
% change_index=[6 7 8 0 1 2 3 4 5];
% cuttop=2;
% cutleft=1;
% 
% datafile='../datanew/600-800/36187650(F3019010638)/';
% change_index=[3 5 4 6 8 7 0 2 1];
% cuttop=1;
% cutleft=2;

% datafile='../datanew/600-800/36187650(F3019010638)/';
% % change_index=[3 4 5 6 7 8 0 1 2];
% cuttop=1;
% cutleft=1;



waveRange=600800;
% cuttop=1;
% cutleft=2;

savepath=[datafile,'4select1AllChannelsIndex'];
if exist(savepath,'dir')
    rmdir(savepath,'s');
end 
mkdir(savepath);



if waveRange==400600
    target = [453 467 483 495 512 528 539 555 569];
    pic_name=[400:5:600];
elseif waveRange==600800
    target = [633 653 674 690 712 732 745 764 781];
    pic_name=[600:5:800];
end


change_index=[6 8 7 0 2 1 3 5 4];
% change_index=[3 5 4 6 8 7 0 2 1];
target=target(change_index+1);
pic_name=target;


for wi=1:9%切第几张原图
    wave_name_config=abs(pic_name-target(wi));
    [~,min_indwnc]=min(wave_name_config);
    wave_picname_index(1,wi)=min_indwnc;
    wave_picname(1,wi)=pic_name(1,min_indwnc);    
end
wl=wave_picname;

  

% savepath1='./mat992';

I0=imread([datafile,'0.tif']);

for i = 1:length(target)
    str = [datafile,num2str(wl(i)),'.tif'];
    Inameused(i)=wl(i);
    I(:,:,i) = double(imread(str));
    Ii=double(imread(str));
    I(:,:,i) = double(Ii)./double(I0);   
end

[sortI,indexI] = sort(I,3,'descend');
rateI = sortI(:,:,2) ./ sortI(:,:,1);
indexUsed = indexI(:,:,1);


% %%   indexUsed 2048*2048的每个点的通道标签,校正indexUsed
% [classmat_correcti,nochixy_nexti]=correct_ClassMat(indexUsed(cuttop+1:cuttop+2040,cutleft+1:cutleft+2040));
% [classmat_correcti,nochixy_nexti]=correct_ClassMat(classmat_correcti);
% funruntime=1;
% while isempty(nochixy_nexti)==0
%     
%     [classmat_correcti,nochixy_nexti]=correct_ClassMat(classmat_correcti);
%     funruntime=funruntime+1;
% end
% indexUsed(cuttop+1:cuttop+2040,cutleft+1:cutleft+2040)=classmat_correcti;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
final = zeros([size(I(:,:,1)),9]);

for i = 1:9
    for ii = 1:340
        for jj = 1:340
%             tempI = rateI((ii-1)*6+1:ii*6,(jj-1)*6+1:jj*6);%tempI 6*6的rateI
%             tempIndex = indexUsed((ii-1)*6+1:ii*6,(jj-1)*6+1:jj*6);%tempIndex 原始6*6的index
            tempI = rateI((ii-1)*6+cuttop+1:ii*6+cuttop,(jj-1)*6+1+cutleft:jj*6+cutleft);%tempI 6*6的rateI
            tempIndex = indexUsed((ii-1)*6+cuttop+1:ii*6+cuttop,(jj-1)*6+cutleft+1:jj*6+cutleft);%tempIndex 原始6*6的index
            
            
            tempI(tempIndex ~= i) = 0;
            tempLine = reshape(tempI,1,6*6);%6*6的rateI变成1*36tempLine
            [tempSort,tempIndex] = sort(tempLine);%从小到大排序
            for k = 1:36
                 if tempSort(k) > 0
                     tempLine(tempIndex(k)) = 1;
                     if k ~= 36
                         tempLine(tempIndex(k+1:end)) = 0;
                     end
                     break
                 end
            end
            %final((ii-1)*6+1:ii*6,(jj-1)*6+1:jj*6,i) = reshape(tempLine,6,6);%6*6的0 1矩阵
            final((ii-1)*6+1+cuttop:ii*6+cuttop,(jj-1)*6+cutleft+1:jj*6+cutleft,i) = reshape(tempLine,6,6);%6*6的0 1矩阵
        end
    end
end


classlabel=zeros(2048,2048);
for i=1:2048
    for j=1:2048
        for k=1:9
            if final(i,j,k)==1
                classlabel(i,j)=k;      
            end
        end
    end
end


%%   indexUsed 2048*2048的每个点的通道标签,校正indexUsed
[classlabel_correcti,nochixy_nexti]=correct_ClassMat(classlabel(cuttop+1:cuttop+2040,cutleft+1:cutleft+2040));
[classlabel_correcti,nochixy_nexti]=correct_ClassMat(classlabel_correcti);
funruntime=1;
while isempty(nochixy_nexti)==0
    
    [classlabel_correcti,nochixy_nexti]=correct_ClassMat(classlabel_correcti);
    funruntime=funruntime+1;
end
classlabel(cuttop+1:cuttop+2040,cutleft+1:cutleft+2040)=classlabel_correcti;

final_correct=zeros(2048,2048,9);
for i=1:2048
    for j=1:2048
        if classlabel(i,j)==1      
            final_correct(i,j,1)=1;
        elseif classlabel(i,j)==2        
            final_correct(i,j,2)=1;
        elseif classlabel(i,j)==3           
            final_correct(i,j,3)=1;
        elseif classlabel(i,j)==4            
            final_correct(i,j,4)=1;
        elseif classlabel(i,j)==5            
            final_correct(i,j,5)=1;
        elseif classlabel(i,j)==6           
            final_correct(i,j,6)=1;
        elseif classlabel(i,j)==7           
            final_correct(i,j,7)=1;
        elseif classlabel(i,j)==8           
            final_correct(i,j,8)=1;
        elseif classlabel(i,j)==9         
            final_correct(i,j,9)=1;           
        end     
    end
end

final=final_correct;


savepath1=[savepath,'/matdat'];
if exist(savepath1,'dir')
    rmdir(savepath1,'s');
end 
mkdir(savepath1); 


for pici=1:9
    for channel = 1:9
        for i = 1:340
            for j = 1:340
                %result(i,j,channel) = sum(sum(final((i-1)*6+1:i*6,(j-1)*6+1:j*6,channel).*I((i-1)*6+1:i*6,(j-1)*6+1:j*6,pici)));           
                result(i,j,channel) = sum(sum(final((i-1)*6+1+cuttop:i*6+cuttop,(j-1)*6+1+cutleft:j*6+cutleft,channel).*I((i-1)*6+1+cuttop:i*6+cuttop,(j-1)*6+1+cutleft:j*6+cutleft,pici)));
            end
        end

        mm=max(max(result(:,:,channel)));    
        picshow=uint8(result(:,:,channel)*255/double(mm));
    end 
    
    
    %mat
    eval(['cmat',num2str(wave_picname(1,pici)),'nm=result;']);
    savename_str=[savepath,'/matdat/cmat',num2str(wave_picname(1,pici)),'nm.mat']; 
    save(savename_str,['cmat',num2str(wave_picname(1,pici)),'nm']);
    %dat
    fid_cmati = fopen([savepath,'/matdat/cmat',num2str(wave_picname(1,pici)),'nm.dat'],'w');
    eval(['fwrite(fid_cmati,cmat',num2str(wave_picname(1,pici)),'nm,''double'');'])
    fclose(fid_cmati);    
end



cmat=[];
cmatxy=[];
num=[];
for chi=1:9
%     eval(['cmat',num2str(chi),'=final(5:end-4,5:end-4,',num2str(chi),');']);
    eval(['cmat',num2str(chi),'=final(cuttop+1:cuttop+2040,cutleft+1:cutleft+2040,',num2str(chi),');']);
    eval(['cmat(:,:,chi)=cmat',num2str(chi),';']);
    cmati_=cmat(:,:,chi)';
    [x,y]=find(cmati_==1);
    num(1,chi)=length(x);
    xy=[y,x];
    [value,value_index]=sort(y);
    xysort=xy(value_index,:);
    cmatxy=[cmatxy;xysort];
    
    eval(['save([savepath1,''/cmat',num2str(chi),'.mat''],''cmat',num2str(chi),''');']);      
    fid_cmati = fopen([savepath1,'/cmat',num2str(chi),'.dat'],'w');
    eval(['fwrite(fid_cmati,cmat',num2str(chi),',''double'');']);
    fclose(fid_cmati);    
end


for i=1:3060
    cmatxyi=cmatxy(340*(i-1)+1:340*i,:);
    [vi,ini]=sort(cmatxyi(:,2));
    cmatxy(340*(i-1)+1:340*i,:)=cmatxyi(ini,:);   
end

cmatxy=cmatxy-1;







save([savepath1,'/cmatxy.mat'],'cmatxy');
fid_cmati = fopen([savepath1,'/cmatxy.dat'],'w');
fwrite(fid_cmati,cmatxy,'ushort');
fclose(fid_cmati);







%%   画光谱曲线
for i = 1:length(target)
    str = [datafile,num2str(wl(i)),'.tif'];
    Inameused(i)=wl(i);
    I(:,:,i) = double(imread(str));
    Ii=double(imread(str));
    I(:,:,i) = double(Ii);   
end

matrix0=[];
for pici=1:9
    for channel = 1:9
        for i = 1:340
            for j = 1:340
                %result(i,j,channel) = sum(sum(final((i-1)*6+1:i*6,(j-1)*6+1:j*6,channel).*I((i-1)*6+1:i*6,(j-1)*6+1:j*6,pici)));
                result(i,j,channel) = sum(sum(final((i-1)*6+1+cuttop:i*6+cuttop,(j-1)*6+1+cutleft:j*6+cutleft,channel).*I((i-1)*6+1+cuttop:i*6+cuttop,(j-1)*6+1+cutleft:j*6+cutleft,pici)));
         
            
            end
        end      
    end 
     
    linei=reshape(mean(mean(result,1),2),1,9);
    matrix0(pici,:)=linei;
    %plot(wave_picname,linei); 

end



[wave_picnamesort,indexwi]=sort(wave_picname);
matrix0sort=matrix0(:,indexwi);

figure;
hold on;
for i=1:9
    plot(wave_picnamesort,matrix0sort(:,i));   
end
xlim([wave_picnamesort(1) wave_picnamesort(end)]);
xlabel('WaveLength(nm)');
ylabel(['I4select1AllChannels']);
title(['WaveLength - I4select1AllChannels']);
legend('Location','northwest');
saveas(gcf,[savepath,'/I4select1AllChannels.png']);
saveas(gcf,[savepath,'/I4select1AllChannels.fig']);



%%

cmatxy=cmatxy+1;
cmatx3060340=[];
cmaty3060340=[];
for i=1:340*9
    cmatxi=cmatxy(340*(i-1)+1:340*i,1)';
    cmatx3060340=[cmatx3060340;cmatxi];
    
    cmatyi=cmatxy(340*(i-1)+1:340*i,2)';
    cmaty3060340=[cmaty3060340;cmatyi]; 
end

cmatx3403409=[];
cmaty3403409=[];
for i=1:9
    cmatxii=cmatx3060340(340*(i-1)+1:340*i,:);
    cmatx3403409(:,:,i)=cmatxii;
    
    cmatyii=cmaty3060340(340*(i-1)+1:340*i,:);
    cmaty3403409(:,:,i)=cmatyii; 
end

savepath2=[savepath,'/pic'];
if exist(savepath2,'dir')
    rmdir(savepath2,'s');
end 
mkdir(savepath2);
save([savepath2,'/cmatx3403409.mat'],'cmatx3403409');
fid_cmati = fopen([savepath2,'/cmatx3403409.dat'],'w');
fwrite(fid_cmati,cmatx3403409,'double');
fclose(fid_cmati);  
save([savepath2,'/cmaty3403409.mat'],'cmaty3403409');
fid_cmati = fopen([savepath2,'/cmaty3403409.dat'],'w');
fwrite(fid_cmati,cmaty3403409,'double');
fclose(fid_cmati); 

for pn=1:length(wave_picname)
    pici=imread([datafile,num2str(wave_picname(pn)),'.tif']);
    pici=double(pici(cuttop+1:cuttop+2040,cutleft+1:cutleft+2040));
    
    ppici=[];
    for k=1:9
        for i=1:340
            for j=1:340               
                ppici(i,j,k)=pici(cmatx3403409(i,j,k),cmaty3403409(i,j,k));                          
            end
        end
        
%         figure;
%         imshow(uint8(ppici(:,:,k)));
        imwrite(uint8(ppici(:,:,k)),[savepath2,'/',num2str(wl(pn)),'nm',32,32,'ch',num2str(k),'.bmp']);   
    end
end











