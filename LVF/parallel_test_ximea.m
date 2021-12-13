clc
clear
close all

% for i = 500:100:1000
%     I = imread(strcat(num2str(i),'.tif'));
%     I = I(1:1800,2254:3658);
%
%     for j = 1:46
%         range = round(1405/50*j);
%         I_test = mean(I(range-20:range,:));
%         mid = max(I_test)*0.8;
%         index1 = [];
%         for k = 1:1404
%             if (I_test(k)-mid)*(I_test(k+1)-mid) <= 0
%                 index1 = [index1 k];
%             end
%         end
%         indexf(i/100-4,j) = (index1(1) + index1(2))/2;
%     end
%
% end
%
%
% plot(1:46,indexf);
%
% for i = 1:46
%     result(1,i) = indexf(4,i) - indexf(1,i);
%     result(2,i) = indexf(6,i) - indexf(4,i);
%     result(3,i) = result(2,i) - result(1,i);
% end
% figure
% plot(1:46,result(1,:));
% figure
% plot(1:46,result(2,:));
% figure
% plot(1:46,result(3,:));-
while 2>1

    data_file='C:\Users\CP\Desktop\table\matlab_lvguangpian_1108\2\2-6\';
    files_list = dir(fullfile(data_file));
    last_file=files_list(end).name;
    I=imread([data_file,last_file]);

%     I=imread('1.tif');
%     imshow(I);
    
    x_range = 1:2048; %列范�?
    y_range = 1:2048; %行范�?
    I = I(y_range,x_range);
    xx = 1:46;
    
    for ii = xx
        i = round(length(y_range)/50*ii);
        I_test = mean(I(:,i-20:i),2); %条纹水平
        %    I_test = mean(I(i-10:i+10,:)); %条纹竖直
        mid = max(I_test)*0.7;%改峰值误�?
        index1 = [];
        for j = 1:length(y_range)-1
            if (I_test(j)-mid)*(I_test(j+1)-mid) <= 0
                index1 = [index1 j];
            end
        end
        if i == 36
            a = 0;
        end
        
        
        indexf(ii) =length(y_range) - (index1(1) + index1(2))/2;
    end
    
    pn = polyfit(xx,indexf,1);
    k = pn(1);
    yy = polyval(pn,xx);
    ymid = yy(25);
    plot(xx,indexf,'o',xx,yy);
    dim = [.7 .7 .2 .2];
    st = num2str(k);
    
    str = ['k = ',num2str(k),'  max-min = ',num2str(max(indexf)-min(indexf)),'  left-rigt = ',num2str(abs(indexf(1) - indexf(46)))];
    annotation('textbox',dim,'String',str)
    drawnow;
    if(length(files_list) > 10)
        for i = 1 : 10
            delete([data_file,files_list(i).name]);
        end
    end
end
% i=1;
% I1=I(:,i);[max1,ind1]=max(I1);
% plot(I1);
% i=round(2048/5);
% I2=I(:,i);[max2,ind2]=max(I2);
% plot(I2);
% i=round(2048/5*2);
% I3=I(:,i);[max3,ind3]=max(I3);
% plot(I3);
% i=round(2048/5*3);
% I4=I(:,i);[max4,ind4]=max(I4);
% plot(I4);
% i=round(2048/5*4);
% I5=I(:,i);[max5,ind5]=max(I5);
% plot(I5);
% i=2048;
% I6=I(:,i);[max6,ind6]=max(I6);


