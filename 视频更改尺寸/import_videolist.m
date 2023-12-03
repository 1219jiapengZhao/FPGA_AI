function videolist = import_videolist(filename, dataLines)
%IMPORTFILE 从文本文件中导入数据
%  VIDEOLIST = IMPORTFILE(FILENAME)读取文本文件 FILENAME 中默认选定范围的数据。  以表形式返回数据。
%
%  VIDEOLIST = IMPORTFILE(FILE, DATALINES)按指定行间隔读取文本文件 FILENAME
%  中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2 正整数标量数组。
%
%  示例:
%  videolist = importfile("D:\MATLAB\WORK\视频更改尺寸\videolist.txt", [1, Inf]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2023-03-20 17:36:11 自动生成

%% 输入处理

% 如果不指定 dataLines，请定义默认范围
if nargin < 2
    dataLines = [1, Inf];
end

%% 设置导入选项并导入数据
opts = delimitedTextImportOptions("NumVariables", 1);

% 指定范围和分隔符
opts.DataLines = dataLines;
opts.Delimiter = ",";

% 指定列名称和类型
opts.VariableNames = "mp4";
opts.VariableTypes = "string";

% 指定文件级属性
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% 指定变量属性
opts = setvaropts(opts, "mp4", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "mp4", "EmptyFieldRule", "auto");

% 导入数据
videolist = readtable(filename, opts);

end