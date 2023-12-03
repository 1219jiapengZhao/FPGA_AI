function OPtmax_num = FindPlor_num(out_data_cz, Thresho_d, Slop, Bias)

[ViDSaLoc_row, ViDSaLoc_col] = find(out_data_cz);
% Thresho_d = 5;      %距离阈值，小于阈值则认为是一条线上的

CaPoint_d = inf(length(ViDSaLoc_row), 1);
for i = 1 : length(ViDSaLoc_row)
    CaPoint_d(i) = abs(Slop * ViDSaLoc_row(i) - ViDSaLoc_col(i) + Bias) / sqrt(1 + Slop ^ 2);
end
% DelLoc_point = find(CaPoint_d < Thresho_d) ;
OPtmax_num = length(find(CaPoint_d < Thresho_d));

