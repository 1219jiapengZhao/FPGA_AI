function results4 = importfile_results(filename, dataLines)
%IMPORTFILE 从文本文件中导入数据
%  RESULTS4 = IMPORTFILE(FILENAME)读取文本文件 FILENAME 中默认选定范围的数据。  以表形式返回数据。
%
%  RESULTS4 = IMPORTFILE(FILE, DATALINES)按指定行间隔读取文本文件 FILENAME
%  中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2 正整数标量数组。
%
%  示例:
%  results4 = importfile_results("D:\MATLAB\project\YOLOv5绘制结果图\map_out\results\results.txt", [2, 84]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2023-04-01 19:31:46 自动生成

%% 输入处理

% 如果不指定 dataLines，请定义默认范围
if nargin < 2
    dataLines = [2, Inf];
end

%% 设置导入选项并导入数据
opts = delimitedTextImportOptions("NumVariables", 4);

% 指定范围和分隔符
opts.DataLines = dataLines;
opts.Delimiter = ":";

% 指定列名称和类型
opts.VariableNames = ["Precision", "VarName2", "Var3", "Var4"];
opts.SelectedVariableNames = ["Precision", "VarName2"];
opts.VariableTypes = ["string", "string", "string", "string"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 指定变量属性
opts = setvaropts(opts, ["Precision", "VarName2", "Var3", "Var4"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Precision", "VarName2", "Var3", "Var4"], "EmptyFieldRule", "auto");

% 导入数据
results4 = readtable(filename, opts);

end