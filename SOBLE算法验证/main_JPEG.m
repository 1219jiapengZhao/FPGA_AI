close all; clear; clc
%% 导入数据
Poto_Numb = '0110_9';
% Poto_Numb = '1118_9';
% Poto_Numb = '0110_3'
% Poto_Numb = '0110_16'
% Poto_Numb = '0110_20'
% Poto_Numb = '0110_29'
% Poto_Numb = '0110_32'
% Poto_Numb = '0110_33'
% Poto_Numb = '0110_35'
% Poto_Numb = '0110_47'
% Poto_Numb = '1118_1'
% Poto_Numb = '1118_10'
% Poto_Numb = '1118_11'

%% 不好的图
% Poto_Numb = '0110_14'
% Poto_Numb = '0110_15'
% Poto_Numb = '0110_18'
% Poto_Numb = '0110_21'
% Poto_Numb = '0110_26'
% Poto_Numb = '0110_31'
% Poto_Numb = '0110_34'
% Poto_Numb = '0110_36'
% Poto_Numb = '1118_3'
% Poto_Numb = '5725'

Date_Name = strcat('JPEGImages\', Poto_Numb,'.jpg') ;
Date_MkName = strcat('SegmentationClass\', Poto_Numb,'.png') ;
Data = imread(Date_Name) ;
Data_Mk = imread(Date_MkName) ;

%% 数据预处理
% data = rgb2ycbcr(Data);  %二值化处理
data = rgb2gray(Data);  %二值化处理
% data = imfilter(data, fspecial('gaussian', [5, 5], 1));  %高斯低通滤波，平滑但可能失真
data = medfilt2(data);  %中值滤波处理

k = 1 ;
figure(k)
imshow(Data)  %画图********
k = k + 1;
figure(k)
imshow(data)        %画图********
k = k + 1;
%% 自带边缘检测函数
out_data_cz = edge(data, 'sobel', 'vertical');  %垂直方向的
out_data_cz = edge(out_data_cz, 'sobel', 'vertical');  %垂直方向的

out_data_sp = edge(data, 'sobel', 'horizontal');        %水平方向的
out_data_sp = edge(out_data_sp, 'sobel', 'horizontal');        %水平方向的
% out_data_sp = edge(out_data_sp, 'sobel', 'horizontal');        %水平方向的

out_data = edge(data, 'sobel', 'both');     %所有方向的
out_data = edge(out_data, 'sobel', 'both');  %垂直方向的

figure(k)
imshow(out_data_cz)     %画图********
k = k + 1;
figure(k)
imshow(out_data_sp)         %画图********
k = k + 1;

%% 自己编写的边缘检测函数
%可以直接改边缘检测算子

%% 橡皮擦算法
out_data(find(Data_Mk == 0)) = 0 ;          %将感兴趣区域筛选出来
% out_data_sp(find(Data_Mk == 0)) = 0 ;          %将感兴趣区域筛选出来
% out_data_cz(find(Data_Mk == 0)) = 0 ;          %将感兴趣区域筛选出来
Rubb_maxSz = 30 ;
Rubb_medSz = 20 ;
Rubb_minSz = 10 ;
out_data(10:10+Rubb_maxSz , 10:10+Rubb_maxSz) = 1;     %看看橡皮擦的大小
out_data(50:50+Rubb_medSz , 50:50+Rubb_medSz) = 1;     %看看橡皮擦的大小
out_data(90:90+Rubb_minSz , 90:90+Rubb_minSz) = 1;     %看看橡皮擦的大小

figure(k)
imshow(out_data)        %画图********
k = k + 1;

%% 返回警戒区域的列坐标
[Vidat_row, Vidat_col] = find(Data_Mk);
[m, n] = size(Data_Mk) ;
Amag_PoData_sp = ones(m, n);
Amag_PoData_cz = ones(m, n);
ViRow_max = max(Vidat_row); ViRow_min = min(Vidat_row) ;
ViCol_max = max(Vidat_col); ViCol_min = min(Vidat_col);
out_data_sp([1:ViRow_min, ViRow_max:m], :) = 0;
out_data_sp(:, [1:ViCol_min, ViCol_max:n]) = 0;

figure(k)
imshow(out_data_sp)         %画图********
k = k + 1;

Rubb_sp = ones(Rubb_minSz, Rubb_minSz);        %最小的那个橡皮擦
Rubb_Thsold_sp = 5;
for i = ViRow_min : Rubb_minSz : ViRow_max - Rubb_minSz
    for j = ViCol_min : Rubb_minSz : ViCol_max - Rubb_minSz
        Rub_Point = sum(sum(Rubb_sp.* out_data_sp([i : i+Rubb_minSz - 1], [j : j + Rubb_minSz - 1])));
        if(Rub_Point > Rubb_Thsold_sp)
            out_data_sp([i : i+Rubb_minSz], [j : j + Rubb_minSz]) = 0;
            Amag_PoData_sp([i : i+Rubb_minSz], [j : j + Rubb_minSz]) = 0;
        end
%         figure(6)
%         pause(0.00001)
%         imshow(out_data_sp)
    end
end

Rubb_cz = ones(Rubb_maxSz, Rubb_maxSz);        %最大的那个橡皮擦
Rubb_Thsold_cz = 30;

figure(k)
imshow(out_data_cz & Amag_PoData_sp)     %画图********
k = k + 1;
out_data_cz = out_data_cz & Amag_PoData_sp ;%& Data_Mk;
for i = ViRow_min : Rubb_maxSz : ViRow_max - Rubb_maxSz
    for j = ViCol_min : Rubb_maxSz : ViCol_max - Rubb_maxSz
        Rub_Point = sum(sum(Rubb_cz.* out_data_cz([i : i+Rubb_maxSz - 1], [j : j + Rubb_maxSz - 1])));
        if(Rub_Point < Rubb_Thsold_cz)
            out_data_cz([i : i+Rubb_maxSz], [j : j + Rubb_maxSz]) = 0;
            Amag_PoData_cz([i : i+Rubb_maxSz], [j : j + Rubb_maxSz]) = 0;
        end
%         figure(6)
%         pause(0.00001)
%         imshow(out_data_sp)
    end
end

out_data_cz = out_data_cz & Data_Mk;
% out_data_cz=imadjust(double(out_data_cz));%使边缘图像更明显

%% 
figure(k)
imshow(out_data_cz)    %画图********
k = k + 1;
[row, col] = find(out_data_cz);
%% 霍夫变换
[H,T,R] = hough(out_data_cz,'RhoResolution',0.5,'Theta',-90:0.5:89);
figure(k)
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
k = k + 1;

P  = houghpeaks(H,2,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');      %极值点的坐标

% lines = houghlines(out_data_cz,T,R,P,'FillGap',5,'MinLength',7);
% figure(8)
% hold on
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end

%所以
x = x ./ 180 .* pi;
K_anode = - cos(x(2)) / sin(x(2)) ; b_anode = y(2) / sin(x(2));
K_negtv = - cos(x(1)) / sin(x(1)) ; b_negtv = y(1) / sin(x(1));
% K_anode =-1 / tan(x(2)) ;
% K_negtv = -1 / tan(x(1)) ;
% x_anode = y(2) .* cos(x(2)); x_negtv = y(1) .* cos(x(1));
% y_anode = y(2) .* sin(x(2)); y_negtv = y(1) .* sin(x(1));
% b_anode = y_anode - K_anode * x_anode;
% b_negtv = y_negtv - K_negtv * x_negtv;

x_plot = ViCol_min : ViCol_max ;
y_plot_anode = K_anode .* x_plot + b_anode;
y_plot_negtv = K_negtv .* x_plot + b_negtv;
figure(2)
hold on
plot(x_plot, y_plot_anode,'LineWidth',2,'Color','green')
hold on
plot(x_plot, y_plot_negtv,'LineWidth',2,'Color','green')
k = k + 1;
%%
% output = my_edge(Data,'sobel');
% imshow(output)

%% 数据显示

figure(k)
imshow(Amag_PoData_sp)    %画图********
k = k + 1;
figure(k)
imshow(Amag_PoData_cz)    %画图********
k = k + 1;

% figure(5)
% imshow(out_data)
