function [Optnum, loc] = SeekLines(OPtmax_num, Lines_num)
% 输入是直线最大检测点矩阵，待检测条数
%输出是这几条直线的最大的检测点，在检测点矩阵中的位置

[xsorted, i] = sort(OPtmax_num) ;
long = length(xsorted) ;
Optnum = xsorted(long - Lines_num + 1 :  long);
loc = i(long - Lines_num + 1 :  long);


end
