close all; clear; clc

%% 导入数据
% Poto_Numb = '0110_9';
% Poto_Numb = '1118_9';
% Poto_Numb = '0110_3';        %弯轨
% Poto_Numb = '0110_16';
% Poto_Numb = '0110_20';
% Poto_Numb = '0110_29' ;      %杂波较多
Poto_Numb = '0110_32';
% Poto_Numb = '0110_33';
% Poto_Numb = '0110_35';
% Poto_Numb = '0110_47';       %杂波较多
% Poto_Numb = '1118_1';           
% Poto_Numb = '1118_10';
% Poto_Numb = '1118_11';       %双轨道

%面对杂波较多的问题 可以在最后添加D-聚类算法解决小Count导致重定位问题 or 直接加大Count值
%但直接加大Count容易造成过拟合问题
%% 不好的图
% Poto_Numb = '0110_14';
% Poto_Numb = '0110_15';
% Poto_Numb = '0110_18';
% Poto_Numb = '0110_21';
% Poto_Numb = '0110_26';
% Poto_Numb = '0110_31';
% Poto_Numb = '0110_34';
% Poto_Numb = '0110_36';
% Poto_Numb = '1118_3';
% Poto_Numb = '5725';

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
%% 边缘检测模块
out_data_cz = edge(data, 'sobel', 'vertical');  %垂直方向的
out_data_cz = edge(out_data_cz, 'sobel', 'vertical');  %垂直方向的

out_data_sp = edge(data, 'sobel', 'horizontal');        %水平方向的
out_data_sp = edge(out_data_sp, 'sobel', 'horizontal');        %水平方向的

out_data = edge(data, 'sobel', 'both');     %所有方向的
out_data = edge(out_data, 'sobel', 'both');  %垂直方向的

figure(k)
imshow(out_data_cz)     %画图********
k = k + 1;
figure(k)
imshow(out_data_sp)         %画图********
k = k + 1;

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

%% 划分境界区域图像 
[Vidat_row, Vidat_col] = find(Data_Mk);     %返回警戒区域的行列坐标
[m, n] = size(Data_Mk) ;
Amag_PoData_sp = ones(m, n);
Amag_PoData_cz = ones(m, n);
ViRow_max = max(Vidat_row); ViRow_min = min(Vidat_row) ;        %这里是输出HLS中需要的坐标数据的START_LOC和OVLYIMA_STRAT
ViCol_max = max(Vidat_col); ViCol_min = min(Vidat_col);
out_data_sp([1:ViRow_min, ViRow_max:m], :) = 0;
out_data_sp(:, [1:ViCol_min, ViCol_max:n]) = 0;     %警戒区域内的水平方向上的图像

figure(k)
imshow(out_data_sp)         %画图********
k = k + 1;
%% 橡皮擦处理算法——使用最小的橡皮擦处理水平图像警戒区域密集的噪点
%得到Amag_PoData_sp是应该删去的点
Rubb_sp = ones(Rubb_minSz, Rubb_minSz);        %最小的那个橡皮擦
Rubb_Thsold_sp = 5;
for i = ViRow_min : Rubb_minSz : ViRow_max - Rubb_minSz
    for j = ViCol_min : Rubb_minSz : ViCol_max - Rubb_minSz
        Rub_Point = sum(sum(Rubb_sp.* out_data_sp(i : i+Rubb_minSz - 1, j : j + Rubb_minSz - 1)));
        if(Rub_Point > Rubb_Thsold_sp)
            out_data_sp(i : i+Rubb_minSz, j : j + Rubb_minSz) = 0;
            Amag_PoData_sp(i : i+Rubb_minSz, j : j + Rubb_minSz) = 0;
        end
    end
end

figure(k)
imshow(Amag_PoData_sp)    %画图********
k = k + 1;

figure(k)
%在垂直图像内删去Amag_PoData_sp
imshow(out_data_cz & Amag_PoData_sp)     %画图********叠加了Amag_PoData_sp
k = k + 1;
%% 橡皮擦处理算法——使用最大的橡皮擦处理垂直图像警戒区域非密集的噪点
Rubb_cz = ones(Rubb_maxSz, Rubb_maxSz);        %最大的那个橡皮擦
Rubb_Thsold_cz = 30;

out_data_cz = out_data_cz & Amag_PoData_sp ;%& Data_Mk;
for i = ViRow_min : Rubb_maxSz : ViRow_max - Rubb_maxSz
    for j = ViCol_min : Rubb_maxSz : ViCol_max - Rubb_maxSz
        Rub_Point = sum(sum(Rubb_cz.* out_data_cz(i : i+Rubb_maxSz - 1, j : j + Rubb_maxSz - 1)));
        if(Rub_Point < Rubb_Thsold_cz)
            out_data_cz(i : i+Rubb_maxSz, j : j + Rubb_maxSz) = 0;
            Amag_PoData_cz(i : i+Rubb_maxSz, j : j + Rubb_maxSz) = 0;
        end
    end
end

out_data_cz = out_data_cz & Data_Mk;        %垂直图像直接叠加境界区域即可
% out_data_cz=imadjust(double(out_data_cz));%使边缘图像更明显

figure(k)
imshow(Amag_PoData_cz)    %画图********
k = k + 1;
figure(k)
imshow(out_data_cz)    %画图******** 叠加了Amag_PoData_sp & Amag_PoData_cz & Data_Mk
k = k + 1;

%% 随机点霍夫变换算法
% x, y =find
[ViDSaLoc_row, ViDSaLoc_col] = find(out_data_cz);
Thresho_d = 1;      %距离阈值，小于阈值则认为是一条线上的
MxItertCnt = 500;        %最大迭代次数
Perc_DelPot = 0.95;     %删除点阈值
Lines_num = 8;         %待定位的直线个数
ViDSaLoc = [ViDSaLoc_row, ViDSaLoc_col];
OptSaLoc = [ViDSaLoc_row, ViDSaLoc_col];

Itert_cnt = 1; DelLoc_point = [];
while(1)
    [k_vau, b, optnum, delloc] = FindMetPot_num(out_data_cz, Thresho_d, OptSaLoc);
    Slop(Itert_cnt) = k_vau ;       %提取直线信息
    Bias(Itert_cnt) = b;
    OPtmax_num(Itert_cnt) = optnum;
    DelLoc_point = union(DelLoc_point, delloc);     %取并集，制造下次随机点生成源OptSaLoc
    OptSaLoc = ViDSaLoc;
    OptSaLoc(DelLoc_point, :) = [];
    

    if(Itert_cnt > MxItertCnt || (length(DelLoc_point) > Perc_DelPot * length(ViDSaLoc_row)))   %count阈值和删除点个数大于95%阈值
        break
    else
        Itert_cnt = Itert_cnt + 1;
    end
end

[Optnum, loc] = SeekLines(OPtmax_num, Lines_num);       %定位待测直线
slop_vaule = Slop(loc);
bais_vaule = Bias(loc);

%画待测直线
x_plot = ViRow_min : ViRow_max ;
y_plot_anode = x_plot' * slop_vaule + bais_vaule;

figure(2)       
for i = 1 : Lines_num
hold on
plot(y_plot_anode(:, i), x_plot,'LineWidth',4,'Color','green')
end
k = k + 1;

%% 
% %% 霍夫变换
% [H,T,R] = hough(out_data_cz,'RhoResolution',0.5,'Theta',-90:0.5:89);
% figure(k)
% imshow(H,[],'XData',T,'YData',R,...
%     'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% k = k + 1;
% 
% P  = houghpeaks(H,2,'threshold',ceil(0.3*max(H(:))));
% x = T(P(:,2)); y = R(P(:,1));
% plot(x,y,'s','color','white');      %极值点的坐标
% 
% 
% %所以
% x = x ./ 180 .* pi;
% K_anode = - cos(x(2)) / sin(x(2)) ; b_anode = y(2) / sin(x(2));
% K_negtv = - cos(x(1)) / sin(x(1)) ; b_negtv = y(1) / sin(x(1));
% 
% x_plot = ViCol_min : ViCol_max ;
% y_plot_anode = K_anode .* x_plot + b_anode;
% y_plot_negtv = K_negtv .* x_plot + b_negtv;
% figure(2)
% hold on
% plot(x_plot, y_plot_anode,'LineWidth',2,'Color','green')
% hold on
% plot(x_plot, y_plot_negtv,'LineWidth',2,'Color','green')
% k = k + 1;

%% 数据显示
