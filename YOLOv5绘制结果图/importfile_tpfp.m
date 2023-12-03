function groundtruth1 = importfile_tpfp(filename, dataLines)
%IMPORTFILE 从文本文件中导入数据
%  GROUNDTRUTH1 = IMPORTFILE(FILENAME)读取文本文件 FILENAME 中默认选定范围的数据。
%  以表形式返回数据。
%
%  GROUNDTRUTH1 = IMPORTFILE(FILE, DATALINES)按指定行间隔读取文本文件 FILENAME
%  中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2 正整数标量数组。
%
%  示例:
%  groundtruth1 = importfile("D:\MATLAB\project\YOLOv5绘制结果图\map_out\results\ground-truth.txt", [3, Inf]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2023-04-02 14:32:48 自动生成

%% 输入处理

% 如果不指定 dataLines，请定义默认范围
if nargin < 2
    dataLines = [3, Inf];
end

%% 设置导入选项并导入数据
opts = delimitedTextImportOptions("NumVariables", 4);

% 指定范围和分隔符
opts.DataLines = dataLines;
opts.Delimiter = " ";

% 指定列名称和类型
opts.VariableNames = ["VarName1", "Number", "of", "detected"];
opts.VariableTypes = ["string", "double", "double", "double"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% 指定变量属性
opts = setvaropts(opts, "VarName1", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "VarName1", "EmptyFieldRule", "auto");

% 导入数据
groundtruth1 = readtable(filename, opts);

end