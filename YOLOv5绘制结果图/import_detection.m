function rs00000 = import_detection(filename, dataLines)
%IMPORTFILE 从文本文件中导入数据
%  RS00000 = IMPORTFILE(FILENAME)读取文本文件 FILENAME 中默认选定范围的数据。  以表形式返回数据。
%
%  RS00000 = IMPORTFILE(FILE, DATALINES)按指定行间隔读取文本文件 FILENAME
%  中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2 正整数标量数组。
%
%  示例:
%  rs00000 = import_detection("D:\MATLAB\project\YOLOv5绘制结果图\map_out\detection-results\rs00000.txt", [1, Inf]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2023-03-31 22:48:47 自动生成

%% 输入处理

% 如果不指定 dataLines，请定义默认范围
if nargin < 2
    dataLines = [1, Inf];
end

%% 设置导入选项并导入数据
opts = delimitedTextImportOptions("NumVariables", 6);

% 指定范围和分隔符
opts.DataLines = dataLines;
opts.Delimiter = " ";

% 指定列名称和类型
opts.VariableNames = ["guardrail", "VarName2", "Var3", "Var4", "Var5", "Var6"];
opts.SelectedVariableNames = ["guardrail", "VarName2"];
opts.VariableTypes = ["categorical", "double", "string", "string", "string", "string"];

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts.LeadingDelimitersRule = "ignore";

% 指定变量属性
opts = setvaropts(opts, ["Var3", "Var4", "Var5", "Var6"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["guardrail", "Var3", "Var4", "Var5", "Var6"], "EmptyFieldRule", "auto");

% 导入数据
rs00000 = readtable(filename, opts);

end