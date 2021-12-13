clc;
clear;
close all;


%可修改读取文件路径
data_file='C:\Users\CP\Desktop\table\LVF\标尺\2-4\';
%日期
Date = '20211116';
%可修改的保存路径
pathp = ['E:\LVF_Data\',Date,'_Ruler'];
%固定的创建文件
mkdir (pathp);
%可修改创建的文件夹
mdir = [pathp,'\2-1'];
mkdir (mdir);
%固定的保存的位置
savepath = [mdir,'\'];
aa = cell(2,7);
files_list = dir(fullfile(data_file));
for diri=3:size(files_list,1)
    card_datapath = files_list(diri,1).name;
    tif0 = [data_file,card_datapath,'\400.tif'];
    tif1000 = [data_file,card_datapath,'\1000.tif'];
    % [agray,amap]=imread('0.tif');
    height=3232;weight=4864;xk=weight/50.67;yk=height/33.67;
    imshow (tif0);
    %设置点击次数
    n = 2;
    [x,y] = ginput1(n);
    imshow (tif1000);
    n = 2;
    [x1,y1] = ginput1(n);
    roixst=x(1);roixed=x1(1);roiyst=y(1);roiyed=y(2);
    %roixst=1002;roixed=1588;roiyst=1438;roiyed=1482;
    
    
    
    
    % acut=agray(roiyst:roiyed,roixst:roixed);
    % %roi=[1676 3143 52 1079];
    % %roi1=[3143 1676 1079 52];
    % acut=imrotate(acut,-90);
    % %agray1=imrotate(agray,90);
    % thresh=graythresh(acut);     %鑷姩纭畾浜屽?鍖栭槇鍊?
    % acut2=imbinarize(acut,thresh);       %瀵瑰浘鍍忎簩鍊煎寲
    % aocr=ocr(acut,'TextLayout','Block','CharacterSet' ,'0123456789');
    % Iocr=insertObjectAnnotation(acut, 'rectangle', ...
    %     aocr.WordBoundingBoxes, ...
    %     aocr.WordConfidences);
    % figure; imshow(Iocr);
    
    
    h = imshow(tif0);
    prompt = {'要选择几个点去拟合'};
    dlgtitle = '输入';
    definput = {'3'};
    dims = [1 15];
    opts.Interpreter = 'tex';
    a = inputdlg(prompt,dlgtitle,dims,definput,opts);
    n = str2num(cell2mat(a(1,1)));
    x1 = ones(n,4);
    y1 = ones(n,4);
    hp = ones(n,10);
    xx = [];
    yy = [];
    answer = 'no';
    pause;
    i = 1;
    while i < n + 1
            hold on;
            [x1(i,1),y1(i,1)] = ginput1(1);
            hp(i,10) = plot(x1(i,1),y1(i,1),'*r');
            [x1(i,2),y1(i,2)] = ginput1(1);
            hp(i,1:2) = plot([x1(i,1),x1(i,2)],[y1(i,1),y1(i,2)],x1(i,2),y1(i,2),'*r');
            [x1(i,3),y1(i,3)] = ginput1(1);
            hp(i,3) = plot([x1(i,2),x1(i,3)],[y1(i,2),y1(i,3)]);
            x1(i,4) = x1(i,3)+x1(i,1)-x1(i,2);
            y1(i,4) = y1(i,1)+y1(i,3)-y1(i,2);
            hp(i,4) = plot([x1(i,1),x1(i,4)],[y1(i,1),y1(i,4)]);
            hp(i,5:6) = plot([x1(i,3),x1(i,4)],[y1(i,3),y1(i,4)],[x1(i,3),x1(i,4)],[y1(i,3),y1(i,4)],'*r');
            hp(i,7) = plot([x1(i,1)+(x1(i,2) - x1(i,1))/2,x1(i,3)+(x1(i,4) - x1(i,3))/2],[y1(i,1)+(y1(i,2) - y1(i,1))/2 - 70,y1(i,3)+(y1(i,4) - y1(i,3))/2 + 70]);
            hp(i,8) = plot([x1(i,1)+(x1(i,4) - x1(i,1))/2 - 70,x1(i,2)+(x1(i,3) - x1(i,2))/2 + 70],[y1(i,1)+(y1(i,4) - y1(i,1))/2,y1(i,2)+(y1(i,3) - y1(i,2))/2]);
            xx(i) = mean(x1(i,1:4));
            yy(i) = mean(y1(i,1:4));
            hp(i,9) = plot(xx(i), yy(i),'*r');
            h;
            pause;
            answer = questdlg('确定你的选择?','选择拟合点','ok','no','ok');
            if(answer == 'no')
               delete(hp(i,:));
               i = i - 1;
            end
            i = i + 1;
            h;
            pause;
    end
    
    xx = xx/96;
    yy = yy/96;
    
    xx=round(xx*xk);
    yy=round(yy*yk);
    figure;
    % imshow(agray);
    hold on;
    yb_num=3:2 + n;
    % for i=1:length(aocr.WordConfidences)
    %     if (aocr.WordConfidences(i)>0.7)
    %         yy=[yy roiyed+1-aocr.WordBoundingBoxes(i,1)-aocr.WordBoundingBoxes(i,3)/2];
    %         xx=[xx roixst-1+aocr.WordBoundingBoxes(i,2)+aocr.WordBoundingBoxes(i,4)/2];
    
    %             yb_num=[yb_num str2num(aocr.Words{i})];
    %
    %         plot(xx(end),yy(end),'r*');
    %     end
    % end
    plot(xx,yy,'r*');
    p1=polyfit(xx,yy,1);
    p0=polyfit(yb_num,xx,1);
    p00=polyfit(xx,yb_num,1);
    hold off;
    wl=400:100:1000;height=3232;weight=4864;xk=weight/50.67;yk=height/33.67;
    xst=round(roixst);xed=round(roixed);yst=round(roiyst);yed=round(roiyed);
    %xst=1716;xed=3580;yst=1780;yed=2540;
    xc=[];yc=[];yb=[];ybd=[];
    N=4;
    x11 = [];
    y11 = [];
    for i=wl
        figure;
        I=imread(strcat(data_file,card_datapath,'\',num2str(i),'.tif'));vx=[];vy=[];
        imshow(I);hold on;
        for j=0:N
            sI=double(I(round(yst+(yed-yst)*j/N),xst:xed));
            [pks,locs,widths,proms] = findpeaks(sI,'NPeaks',1,'MinPeakProminence',5,'MinPeakWidth',0,'MaxPeakWidth',5000);
            [~,vlocs]=max(sI);vlocs=vlocs+xst-1;
            for k=vlocs:xed
                if I(round(yst+(yed-yst)*j/N),k)<=0.5*(max(sI)+min(sI))
                    x1=k;break;
                end
            end
            for k=vlocs:-1:xst
                if I(round(yst+(yed-yst)*j/N),k)<=0.5*(max(sI)+min(sI))
                    x2=k;break;
                end
            end
            vy=[vy round(yst+(yed-yst)*j/N)];
            %vx=[vx locs+xst-1];
            vx=[vx (x1+x2)/2];
        end
        plot(vx,vy,'r*');

        p2=polyfit(vx,vy,1);
        xc=[xc -(p1(2)-p2(2))/(p1(1)-p2(1))];
        yc=[yc polyval(p1,xc(end))];
        yb=[yb polyval(p00,xc(end))];
        ybd=[ybd (xc(end)-xx(1))/(xx(end)-xx(1))*(yb_num(end)-yb_num(1))+yb_num(1)-polyval(p00,xc(end))];
        plot(xc(end),yc(end),'r*');
        if i==700
            p20=polyfit(vy,vx,1);
            plot([1 weight],[polyval(p1,1) polyval(p1,weight)]);
            plot([polyval(p20,1) polyval(p20,height)],[1 height]);
            for j=1:30
                plot(polyval(p0,j),polyval(p1,polyval(p0,j)),'b+');
            end
        end
        hold off;
        if i==700
            saveas(gcf,[savepath,card_datapath,'_wl_yb_700.bmp']);
        end
    end
    re=[wl;yb];
    y11 = yb;
    x11 = 400:100:1000;
    p(diri - 2,:) = polyfit(x11,y11,1);
    xx1 = 400:1:1000;
    yy1(diri - 2,:) = xx1*p(diri-2,1)+p(diri-2,2);

    
    
    aa(diri - 2,:) = num2cell(yb);
    xlswrite([savepath,'wl_yb.xlsx'],{'wavelength';'L_incline';'R_incline'},'sheet1','A1');
    str_num=wl;
    xlswrite([savepath,'wl_yb.xlsx'],str_num,'sheet1','B1');
    xlswrite([savepath,'wl_yb.xlsx'], aa(1,:),'sheet1','B2');
    xlswrite([savepath,'wl_yb.xlsx'], aa(2,:),'sheet1','B3');
end
    xlswrite([savepath,'wl_yb_xi.xlsx'],{'wavelength','L_incline','R_incline'},'sheet1','A1')
    xlswrite([savepath,'wl_yb_xi.xlsx'],xx1','sheet1','A2');
    xlswrite([savepath,'wl_yb_xi.xlsx'],yy1(1,:)','sheet1','B2');
    xlswrite([savepath,'wl_yb_xi.xlsx'],yy1(2,:)','sheet1','C2');
