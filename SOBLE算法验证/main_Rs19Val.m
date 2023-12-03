
close all; clear; clc
tic
%% 导入数据

%% 好的
% Poto_Numb = '48';
% Poto_Numb = '64';
% Poto_Numb = '66';
% Poto_Numb = '75';
% Poto_Numb = '98';
% Poto_Numb = '111';
% Poto_Numb = '119';
% Poto_Numb = '121';
% Poto_Numb = '124';
% % Poto_Numb = '128';
% Poto_Numb = '163';              %重要图像%
% Poto_Numb = '172';%重要图像
% Poto_Numb = '180';%重要图像%
% Poto_Numb = '259';%重要图像%
Poto_Numb = '231';
%% 坏的
% Poto_Numb = '71';
Date_Name = strcat('./Rs19Val中的直线图/', Poto_Numb,'_image.png') ;
Date_MkName = strcat('./Rs19Val中的直线图/', Poto_Numb,'_pred_Mask.png') ;

%% 
Data = imread(Date_Name) ;
[ROW, COL] = size(Data(:, :, 1));   TempImg = zeros(ROW, COL);  clear m n;

Data_Mk =imread(Date_MkName) ;

%% 数据预处理
% data = rgb2ycbcr(Data);  %二值化处理
data = rgb2gray(Data);  %二值化处理
% data = imfilter(data, fspecial('gaussian', [5, 5], 1));  %高斯低通滤波，平滑但可能失真
data = medfilt2(data);  %中值滤波处理

k = 1 ;
figure(k)
imshow(Data)  %画图********
fprintf('图片%d是原始图片\n', k)

k = k + 1;
figure(k)
imshow(data)        %画图********
fprintf('图片%d是二值化加中值滤波处理后的图片\n', k)
k = k + 1;
%% 边缘检测模块
out_data_cz = edge(data, 'sobel', 'vertical');  %垂直方向的
out_data_cz = edge(out_data_cz, 'sobel', 'vertical');  %垂直方向的

out_data_sp = edge(data, 'sobel', 'horizontal');        %水平方向的
out_data_sp = edge(out_data_sp, 'sobel', 'horizontal');        %水平方向的

out_data = edge(data, 'sobel', 'both');     %所有方向的
out_data = edge(out_data, 'sobel', 'both');  %所有方向的

figure(k)
imshow(out_data_cz)     %画图********
fprintf('图片%d是垂直方向边缘检测的图片\n', k)
k = k + 1;
figure(k)
imshow(out_data_sp)         %画图********
fprintf('图片%d是水平方向边缘检测的图片\n', k)
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
fprintf('图片%d是所有方向上的边缘检测图片，已经将感兴趣区域筛选出来了还有橡皮擦大小\n', k)
k = k + 1;

%% 划分境界区域图像 
[Vidat_row, Vidat_col] = find(Data_Mk);     %返回警戒区域的行列坐标
[ROW, COL] = size(Data_Mk) ;
Amag_PoData_sp = ones(ROW, COL);
Amag_PoData_cz = ones(ROW, COL);
ViRow_max = max(Vidat_row); ViRow_min = min(Vidat_row) ;        %这里是输出HLS中需要的坐标数据的START_LOC和OVLYIMA_STRAT
ViCol_max = max(Vidat_col); ViCol_min = min(Vidat_col);
out_data_sp([1:ViRow_min, ViRow_max:ROW], :) = 0;
out_data_sp(:, [1:ViCol_min, ViCol_max:COL]) = 0;     %警戒区域内的水平方向上的图像

figure(k)
imshow(out_data_sp)         %画图********
fprintf('图片%d是感兴趣区域内水平方向检测图\n', k)
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
imshow(~Amag_PoData_sp)    %画图********
fprintf('图片%d是最小橡皮擦处理的水平图像的掩码图\n', k)
k = k + 1;

figure(k)
%在垂直图像内删去Amag_PoData_sp
imshow(out_data_cz & Amag_PoData_sp)     %画图********叠加了Amag_PoData_sp
fprintf('图片%d是叠加了最小橡皮擦处理的水平图像掩码图的垂直图像\n', k)
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
imshow(~Amag_PoData_cz)    %画图********
fprintf('图片%d是最大橡皮擦处理的垂直图像的掩码图\n', k)
k = k + 1;
figure(k)
imshow(out_data_cz)    %画图******** 叠加了Amag_PoData_sp & Amag_PoData_cz & Data_Mk
fprintf('图片%d是叠加了最小橡皮擦处理的水平图像掩码图和最大橡皮擦的垂直掩码图和ROI的垂直图像\n', k)
k = k + 1;
% %% 霍夫变换算法
% [H,T,R] = hough(out_data_cz,'RhoResolution',0.5,'Theta',-90:0.5:89);
% figure(k)
% imshow(H,[],'XData',T,'YData',R,...
%             'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% k = k + 1;
% 
% P  = houghpeaks(H,2,'threshold',ceil(0.3*max(H(:))));
% x = T(P(:,2)); y = R(P(:,1));
% plot(x,y,'s','color','w');      %极值点的坐标
%% 随机点霍夫变换算法
% x, y =find
[ViDSaLoc_row, ViDSaLoc_col] = find(out_data_cz);
Thresho_d = 1;      %距离阈值，小于阈值则认为是一条线上的
MxItertCnt = 500;        %最大迭代次数
Perc_DelPot = 0.95;     %删除点阈值
Lines_num = 10;         %待定位的直线个数
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
slop_vaule = Slop(loc);         %挑选出的斜率值
bais_vaule = Bias(loc);         %挑选出的偏移值



%画待测直线
x_plot = ViRow_min : ViRow_max ;
y_plot_anode = x_plot' * slop_vaule + bais_vaule;

figure(1)       
for i = 1 : Lines_num
hold on
plot(y_plot_anode(:, i), x_plot,'LineWidth',2,'Color','green')
end
%% Kmeans聚类   综合直线
Idx = kmeans([slop_vaule', bais_vaule'],2);
tem = [slop_vaule', bais_vaule'];
One = tem(Idx == 1, :); Two = tem(Idx == 2, :);
Line_One = [mean(One(:, 1)), mean(One(:, 2))];
Line_Two = [mean(Two(:, 1)), mean(Two(:, 2))];

x_plot = ViRow_min : ViRow_max ;
y_plot_One = x_plot' * Line_One(1) + Line_One(2);
y_plot_Two = x_plot' * Line_Two(1) + Line_Two(2);

% figure(2)
% hold on
% plot(y_plot_Two, x_plot,'LineWidth',2,'Color','green')
% hold on
% plot(y_plot_One, x_plot,'LineWidth',2,'Color','red')

RaisMask = false(size(Data_Mk));
for i = 1 : length(x_plot)
    for j = ceil(min(y_plot_One(i), y_plot_Two(i))) : ceil(max(y_plot_One(i), y_plot_Two(i)))
            RaisMask(x_plot(i), j) = 1;
    end
end
for i = 1 : 3       %%画在原图中
    Temp = Data(:, :, i);
    if i == 1
        Temp(RaisMask == 1) = 153;
    elseif i ==2
        Temp(RaisMask == 1) = 216;
    elseif i ==3
        Temp(RaisMask == 1) = 207;
    end
    Data1(:, :, i) = Temp;
end
figure(k)
imshow(Data1)
hold on
plot(y_plot_Two, x_plot,'LineWidth', 5,'Color','red')
hold on
plot(y_plot_One, x_plot,'LineWidth', 5,'Color','red')
k = k + 1;
for i = 1 : 3       %%画在空白图中
    Temp = zeros(size(Data(:, :, 1)));
    if i == 1
        Temp(RaisMask == 1) = 153;
    elseif i ==2
        Temp(RaisMask == 1) = 216;
    elseif i ==3
        Temp(RaisMask == 1) = 207;
    end
    Data(:, :, i) = Temp;
end
figure(k)
imshow(Data)
hold on
plot(y_plot_Two, x_plot,'LineWidth',5,'Color','red')
hold on
plot(y_plot_One, x_plot,'LineWidth',5,'Color','red')

k = k + 1;
%% 计算mIoU   PA(像素准确率)
%计算mIoU时，因为图中区域有多个所以mIoU不准
mIoU = length(intersect(find(RaisMask == 1), find(Data_Mk == 1)))/ length(union(find(RaisMask == 1), find(Data_Mk == 1)));
PA = sum(sum(Data_Mk(RaisMask == 1))) / sum(sum(RaisMask));
fprintf('像素点准确率PA：%d\n\n', PA)
fprintf('预测图像的平均交并比mIoU：%d\n', mIoU)
% %% 得到每条直线的rou和sita，还有中心点的xy坐标   修正所有直线
% HalfRow = ROW / 2;
% Row_Vertical = - (slop_vaule .* bais_vaule) ./ (1 + slop_vaule .^2);        %是x值
% Col_Vertical = Row_Vertical .* slop_vaule + bais_vaule;         %是y值
% % Row_Vertical = floor( (col_loc + bais_vaule) / 2);
% % Col_Vertical = (Row_Vertical - bais_vaule) ./ slop_vaule;
% if(isempty(find(Row_Vertical > COL, 1)) && isempty(find(Row_Vertical < 0, 1)))
%     fprintf('中心点的Col值没有问题\n')
%     if(isempty(find(Col_Vertical > ROW, 1)) && isempty(find(Col_Vertical < 0, 1)))
%         fprintf('中心点的Row值没有问题\n')
%     else
%         fprintf('中心点的Row值有问题，超出阈值了\n')
%     end
% else
%     fprintf('中心点的Col值有问题，超出阈值了\n')
% end
% Rou = sqrt( Row_Vertical.^2 + Col_Vertical.^2);
% Sita = zeros(1, length(Row_Vertical));      %预分配
% for i = 1: length(Row_Vertical)
%     if(Row_Vertical(i) > 0)
%         Sita(i) = atan(Col_Vertical(i) ./ Row_Vertical(i));          %一四象限，sita值不加pi，二三象限的sita值加pi
%     else
%         Sita(i) = atan(Col_Vertical(i) ./ Row_Vertical(i)) + pi;          %arctan的取值范围是pi/2 ~ -pi/2
%     end
% end
% RuSa_long = length(Rou);
% KBNum_Value = zeros(3, RuSa_long);     %输出的最优K值 B值 和直线包含的最大点数值(与Rou一一对应)
% 
% RouThrsh = 80;      %阈值只有一半 正负50
% SitaThrsh = pi / 6;           %阈值只有一半 正负30度
% ThrshStep = 100;         %阈值的分割限度
% OPtmax_num = 0; Best_Slop = 0; Best_Bias = 0;
% RouThrsh = RouThrsh / ThrshStep; SitaThrsh = SitaThrsh / ThrshStep;
% for i = 1 : RuSa_long
%     for p = -(ThrshStep) : ThrshStep
%             for k = -(ThrshStep) : ThrshStep
%                 x = (Rou(i) + p * (RouThrsh)) * cos(Sita(i) + k * SitaThrsh);
%                 y = (Rou(i) + p * (RouThrsh)) * sin(Sita(i) + k * SitaThrsh);
%                 Slop_plor = -1 / tan(Sita(i) + k * SitaThrsh);
%                 Bias_Plor  = y - x * Slop_plor;
%                 OPtmax_Temp = FindPlor_num(out_data_cz, 1, Slop_plor, Bias_Plor);
%                 if(OPtmax_num < OPtmax_Temp)
%                     OPtmax_num = OPtmax_Temp;
%                     Best_Slop = Slop_plor;
%                     Best_Bias = Bias_Plor;
%                 end
%                 
%                 if(p == ThrshStep && k == ThrshStep)
%                     if(OPtmax_num ~= 0)
%                         KBNum_Value(:,i) = [Best_Slop; Best_Bias; OPtmax_num];
%                         OPtmax_num = 0;
%                     else
%                         KBNum_Value(:,i) = [nan; nan; nan];
%                         OPtmax_num = 0;
%                     end
%                 end
%             end
%     end
% end
% 
% %画待测直线
% x_plot = ViRow_min : ViRow_max ;
% y_plot_anode = x_plot' * KBNum_Value(1, :) + KBNum_Value(2, :);
% 
% figure(2)       
% for i = 1 : Lines_num
% hold on
% plot(y_plot_anode(:, i), x_plot,'LineWidth',4,'Color','red')
% end
% k = k + 1;

%% 数据显示
toc