
close all; clear; clc
tic
%% 导入数据
%% TRAIN
% Poto_Numb = '5';
% Poto_Numb = '9';
% Poto_Numb = '13';
% Poto_Numb = '14';
% Poto_Numb = 'IMG_6223';
% Poto_Numb = 'IMG_6229';
% Poto_Numb = 'IMG_6231';
% Date_Name = strcat('leftImg8bit\train\banbiTrain\', Poto_Numb,'_leftImg8bit.png') ;
% Date_MkName = strcat('gtFine\train\banbiTrain\', Poto_Numb,'_gtFine_polygons.json') ;

%% VAL
Poto_Numb = 'IMG_6235';

Date_Name = strcat('leftImg8bit\val\banbiVal\', Poto_Numb,'_leftImg8bit.png') ;
Date_MkName = strcat('gtFine\val\banbiVal\', Poto_Numb,'_gtFine_polygons.json') ;

%% 

Data = imread(Date_Name) ;
[ROW, COL] = size(Data(:, :, 1));   TempImg = zeros(ROW, COL);  clear m n;
jsonData = loadjson(Date_MkName); % jsonData是个struct结构
Data_Mk =roipoly(TempImg, jsonData.objects{1, 1}.polygon(:, 1), jsonData.objects{1, 1}.polygon(:, 2));

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
[ROW, COL] = size(Data_Mk) ;
Amag_PoData_sp = ones(ROW, COL);
Amag_PoData_cz = ones(ROW, COL);
ViRow_max = max(Vidat_row); ViRow_min = min(Vidat_row) ;        %这里是输出HLS中需要的坐标数据的START_LOC和OVLYIMA_STRAT
ViCol_max = max(Vidat_col); ViCol_min = min(Vidat_col);
out_data_sp([1:ViRow_min, ViRow_max:ROW], :) = 0;
out_data_sp(:, [1:ViCol_min, ViCol_max:COL]) = 0;     %警戒区域内的水平方向上的图像

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
plot(y_plot_anode(:, i), x_plot,'LineWidth',4,'Color','green')
end
k = k + 1;


%% 得到每条直线的rou和sita，还有中心点的xy坐标
HalfRow = ROW / 2;
Row_Vertical = - (slop_vaule .* bais_vaule) ./ (1 + slop_vaule .^2);        %是x值
Col_Vertical = Row_Vertical .* slop_vaule + bais_vaule;         %是y值
% Row_Vertical = floor( (col_loc + bais_vaule) / 2);
% Col_Vertical = (Row_Vertical - bais_vaule) ./ slop_vaule;
if(isempty(find(Row_Vertical > COL)) && isempty(find(Row_Vertical < 0)))
    fprintf('中心点的Col值没有问题\n')
    if(isempty(find(Col_Vertical > ROW)) && isempty(find(Col_Vertical < 0)))
        fprintf('中心点的Row值没有问题\n')
    else
        fprintf('中心点的Row值有问题，超出阈值了\n')
    end
else
    fprintf('中心点的Col值有问题，超出阈值了\n')
end
Rou = sqrt( Row_Vertical.^2 + Col_Vertical.^2);
Sita = zeros(1, length(Row_Vertical));      %预分配
for i = 1: length(Row_Vertical)
    if(Row_Vertical(i) > 0)
        Sita(i) = atan(Col_Vertical(i) ./ Row_Vertical(i));          %一四象限，sita值不加pi，二三象限的sita值加pi
    else
        Sita(i) = atan(Col_Vertical(i) ./ Row_Vertical(i)) + pi;          %arctan的取值范围是pi/2 ~ -pi/2
    end
end
RuSa_long = length(Rou);
KBNum_Value = zeros(3, RuSa_long);     %输出的最优K值 B值 和直线包含的最大点数值(与Rou一一对应)

RouThrsh = 80;      %阈值只有一半 正负50
SitaThrsh = pi / 6;           %阈值只有一半 正负30度
ThrshStep = 100;         %阈值的分割限度
OPtmax_num = 0; Best_Slop = 0; Best_Bias = 0;
RouThrsh = RouThrsh / ThrshStep; SitaThrsh = SitaThrsh / ThrshStep;
for i = 1 : RuSa_long
    for p = -(ThrshStep) : ThrshStep
            for k = -(ThrshStep) : ThrshStep
                x = (Rou(i) + p * (RouThrsh)) * cos(Sita(i) + k * SitaThrsh);
                y = (Rou(i) + p * (RouThrsh)) * sin(Sita(i) + k * SitaThrsh);
                Slop_plor = -1 / tan(Sita(i) + k * SitaThrsh);
                Bias_Plor  = y - x * Slop_plor;
                OPtmax_Temp = FindPlor_num(out_data_cz, 1, Slop_plor, Bias_Plor);
                if(OPtmax_num < OPtmax_Temp)
                    OPtmax_num = OPtmax_Temp;
                    Best_Slop = Slop_plor;
                    Best_Bias = Bias_Plor;
                end
                
                if(p == ThrshStep && k == ThrshStep)
                    if(OPtmax_num ~= 0)
                        KBNum_Value(:,i) = [Best_Slop; Best_Bias; OPtmax_num];
                        OPtmax_num = 0;
                    else
                        KBNum_Value(:,i) = [nan; nan; nan];
                        OPtmax_num = 0;
                    end
                end
            end
    end
end

%画待测直线
x_plot = ViRow_min : ViRow_max ;
y_plot_anode = x_plot' * KBNum_Value(1, :) + KBNum_Value(2, :);

figure(2)       
for i = 1 : Lines_num
hold on
plot(y_plot_anode(:, i), x_plot,'LineWidth',4,'Color','red')
end
k = k + 1;

%% 数据显示
toc