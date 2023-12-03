close all;clear;clc
%需要500轮数据将dir中路径改一下即可，全局搜索“map_out-500轮的数据”改为“map_out-500轮的数据”
%% 数据导入
%Save_data 存储了所有的类的置信度数据
dir = dir("map_out-500轮的数据\detection-results\*.txt");   %文件夹下所有文件的名字
name = {dir.name}';
Save_data = struct();   %最终的数据位置

for i = 1 : length(dir)
    path = strcat("map_out-500轮的数据\detection-results\", name{i});
    source_data = import_detection(path, [1, Inf]);
    categorie = categories(source_data.guardrail);  %找到
    
    for j = 1 : length(categorie)
        newcategorie = replace(categorie{j},'-','_');   %将-号换成_，可以用于结构体中，该类的名字
        tdata = source_data(source_data.guardrail == categorie{j}, :);      %该类的所有数据
        if( any(categorical(fieldnames(Save_data)) == newcategorie) )    %Save_data的名字为元胞，转化为categorical类型,any判断是否有1
            Save_data = setfield(Save_data, newcategorie, [getfield(Save_data, newcategorie); tdata.VarName2]);          %在原来的基础上加上数据
        else
            Save_data = setfield(Save_data, newcategorie, tdata.VarName2);      %创建新的结构体结构
        end
    end
end

% S = struct2table(Save_data, 'AsArray', true);
% writetable('各类的置信度数据.xlsx',S);
%% 计算每一类的置信度区间，对应的数据
%Result_data中第一行是Precision，第二行是Recall，第三行是置信度
Result_data = struct();   %最终的数据位置
results_data = importfile_results("map_out-500轮的数据\results\results.txt", [2, 84]);results_data(1 : 4, :) = [];
for i = 1 : length(results_data.Precision) / 4
    tn = split(results_data.Precision(4 * (i - 1) + 1));      %分割名字
    name = replace(tn(3),'-','_');
    Precision = str2num(results_data.VarName2(4 * (i - 1) + 2));        %准确率数据
    Recall = str2num(results_data.VarName2(4 * (i - 1) + 3));   %召回率数据
    Confience = sort(getfield(Save_data, name), 'descend')';       %置信度数据，降序
    Result_data = setfield(Result_data, name, [Precision; Recall; Confience]);
    %     xlswrite('保存数据.xlsx',getfield(Result_data, name), name) %保存结果
end

%% 画图
close all
% 输入是x轴数据，y轴数据; classname是图例里曲线的名字
%PRslect = 1选择画P曲线，2画R曲线; Holdselect选择是否保持图像，0为画在一张图里，1为新建一个图
%figurenum是第几个图窗，可以省略
name = fieldnames(Result_data);
slect_name = ['train-car', 'car', 'track-sign-front','track-signal-front', 'rail', 'platform', 'crossing', 'person'];%挑出来几个好的对比一下

k = 0;
for i = 1 : length(name)
    if contains(slect_name, replace(name{i},'_','-'))
        k = k + 1;
        data = getfield(Result_data, name{i});
        if k == 1
            %画P曲线
            figure = Plot(data(3, :), data(1, :), replace(name{i},'_','-'), 1, 1);
        else
            Plot(data(3, :), data(1, :), replace(name{i},'_','-'), 1, 0, figure);
        end
    else
        continue;
    end
end

k = 0;
for i = 1 : length(name)
    if contains(slect_name, replace(name{i},'_','-'))
        k = k + 1;
        data = getfield(Result_data, name{i});
        if k == 1
            %画R曲线
            figure = Plot(data(3, :), data(2, :), replace(name{i},'_','-'), 0, 1);
        else
            Plot(data(3, :), data(2, :), replace(name{i},'_','-'), 0, 0, figure);
        end
    else
        continue;
    end
end

k = 0;
for i = 1 : length(name)
    if contains(slect_name, replace(name{i},'_','-'))
        k = k + 1;
        data = getfield(Result_data, name{i});
        if k == 1
            %画PR曲线
            figure = Plot(data(2, :), data(1, :), replace(name{i},'_','-'), 3, 1);
        else
            Plot(data(2, :), data(1, :), replace(name{i},'_','-'), 3, 0, figure);
        end
    else
        continue;
    end
end

k = 0;
for i = 1 : length(name)
    if contains(slect_name, replace(name{i},'_','-'))
        k = k + 1;
        data = getfield(Result_data, name{i});
        if k == 1
            %画F1曲线
            figure = Plot(data(3, :), (2 .* data(1, :) .* data(2, :)) ./ (data(1, :) + data(2, :)), replace(name{i},'_','-'), 4, 1);
        else
            Plot(data(3, :), (2 .* data(1, :) .* data(2, :)) ./ (data(1, :) + data(2, :)), replace(name{i},'_','-'), 4, 0, figure);
        end
    else
        continue;
    end
end
%% 导入训练的数据
% 画Loss曲线图
epochloss = table2array(importfile_epoch("map_out-500轮的数据\results\map-loss\epoch_loss.txt", [1, Inf]));
x = 1 : length(epochloss);
Smooth_epochloss = smooth(epochloss);
epoch_val_loss =table2array(importfile_epoch("map_out-500轮的数据\results\map-loss\epoch_val_loss.txt", [1, Inf]));
Smooth_epoch_val_loss = smooth(epoch_val_loss);
%画图
figure = Plot_loss(x, [epochloss, Smooth_epochloss], 0, 0);     %train曲线
Plot_loss(x, [epoch_val_loss, Smooth_epoch_val_loss], 1, 1, figure)     %val曲线

x = 0 : 10 : length(epochloss);
epoch_map = table2array(importfile_epoch("map_out-500轮的数据\results\map-loss\epoch_map.txt", [1, Inf]));
%画图
figure = Plot_loss(x, epoch_map, 2, 0);     %mAP@0.5曲线

%% ground-truth画图
groundtruth1 = importfile_ground_truth("map_out-500轮的数据\results\ground-truth.txt", [2, Inf]);
name = groundtruth1.VarName1;  data = groundtruth1.VarName2;
[data, I] = sort(data);  
newname = categorical(convertStringsToChars(name(I)));
newname = reordercats(newname, convertStringsToChars(name(I)));
plot_gt(newname, data)

%% tpfp画图
%导入ground-truth数据
tpfp = importfile_tpfp("map_out-500轮的数据\results\tpfp.txt", [3, Inf]);
total = tpfp.Number; tp = tpfp.of; fp = tpfp.detected; 
tp = tp ./ total; fp = fp ./ total;
[tp, I] = sort(tp);  
name = tpfp.VarName1;
newname = categorical(convertStringsToChars(name(I)));
newname = reordercats(newname, convertStringsToChars(name(I)));
bar1 = createfigure_bar(newname,fp(I), 0);   %

createfigure_bar(newname,tp, 1, bar1);   %







