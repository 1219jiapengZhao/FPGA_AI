function [Slop, Bias, OPtmax_num, DelLoc_point] = FindMetPot_num(out_data_cz, Thresho_d, OptSaLoc)
%输入是二值化图像，距离阈值和删除共线后的散点位置坐标；
%OptSaLoc 第一列是row 第二列是col
%输出是随机到的直线k，b 、图像中有多少点在阈值内 和 要删除点的坐标

[ViDSaLoc_row, ViDSaLoc_col] = find(out_data_cz);
% Thresho_d = 5;      %距离阈值，小于阈值则认为是一条线上的

ViDSa_long = length(OptSaLoc(:, 1));
GetLoc_point = ceil(ViDSa_long * rand(1, 2));
Point1 = OptSaLoc(GetLoc_point(1), :);
Point2 = OptSaLoc(GetLoc_point(2), :);

Slop = (Point1(2) - Point2(2)) / (Point1(1) - Point2(1));
Bias = Point1(2) - Slop * Point1(1);
CaPoint_d = inf(length(ViDSaLoc_row), 1);
for i = 1 : length(ViDSaLoc_row)
    CaPoint_d(i) = abs(Slop * ViDSaLoc_row(i) - ViDSaLoc_col(i) + Bias) / sqrt(1 + Slop ^ 2);
end
DelLoc_point = find(CaPoint_d < Thresho_d) ;
OPtmax_num = length(DelLoc_point);
