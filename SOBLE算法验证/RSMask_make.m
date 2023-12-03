clear; clc
%%
file_path = './Rs19Val中的直线图/';
file_list = dir(strcat(file_path,'*.png'));%获取该文件夹中所有jpg格式的图像
k = 0;
for i = 1 : length(file_list)
    if rem(i, 3) == 1
        k = k + 1;
        image_Name(k) = {file_list(i).name};
    elseif rem(i, 3) == 2
        pred_Name(k) = {file_list(i).name};
    elseif rem(i, 3) == 0
        target_Name(k) = {file_list(i).name};
    end
end

% str2num(erase(Name, '_target.png'))
%%      17是轨道， 12是警戒区域
for i = 1 : length(target_Name)
    Target_Mask = imread(strcat(file_path, target_Name{i}));
    Mask_Temp = Target_Mask(:, :, 1);
%     Mask_Temp(Mask_Temp == 153) = 17;
%     Mask_Temp(Mask_Temp == 102) = 12;
    Mask_Temp(Mask_Temp == 153) = 1;
    Mask_Temp(Mask_Temp == 102) = 1;
    imwrite(Mask_Temp, strcat(file_path, erase(target_Name{i}, '.png'), '_Mask', '.png'));
end

for i = 1 : length(pred_Name)
    Pred_Mask = imread(strcat(file_path, pred_Name{i}));
    Mask_Temp = Pred_Mask(:, :, 1);
%     Mask_Temp(Mask_Temp == 153) = 17;
%     Mask_Temp(Mask_Temp == 102) = 12;
    Mask_Temp(Mask_Temp == 153) = 1;
    Mask_Temp(Mask_Temp == 102) = 1;
    imwrite(Mask_Temp, strcat(file_path, erase(pred_Name{i}, '.png'), '_Mask', '.png'));
end

