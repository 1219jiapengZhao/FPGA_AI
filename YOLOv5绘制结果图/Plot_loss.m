function figure1 = Plot_loss(X1, YMatrix1, TVselect, Holdselect, figurenum)
%CREATEFIGURE(X1, YMatrix1)
%  X1:  x 数据的向量
%  YMATRIX1:  y 数据的矩阵
%	TVselect为0时，画训练参数；为1时候，画验证参数；2时画map参数
%   Holdselect为1时画在一张图里，为0时不画在一张图里
%   figurenum是打开图几

%  由 MATLAB 于 02-Apr-2023 11:51:16 自动生成
ftsize = 30;

switch TVselect
    case 0
        name_plot1 = 'train loss';
        name_plot2 = 'smooth train loss';
    case 1
        name_plot1 = 'val loss';
        name_plot2 = 'smooth val loss';
    case 2
        name_plot1 = 'train map';
end

if Holdselect
    figure(figurenum);
    hold on
    if(TVselect == 2)
        plot1 = plot(X1,YMatrix1,'DisplayName',name_plot1, 'LineWidth',5);
    else
        plot1 = plot(X1,YMatrix1,'LineWidth',5);
        set(plot1(1),'DisplayName',name_plot1);
        set(plot1(2),'DisplayName',name_plot2,'LineStyle','--');
    end
    
else
    % 创建 figure
    figure1 = figure('WindowState','maximized');
    
    % 创建 axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    
    % 使用 plot 的矩阵输入创建多行
    if(TVselect == 2)
        plot1 = plot(X1,YMatrix1,'DisplayName',name_plot1, 'MarkerSize',16,...
        'Marker','x',...
        'LineWidth',5);
        % 创建 ylabel
        ylabel('平均AP值(mAP)');
        % 创建 title
        title('mAP@0.5曲线');
    else
        plot1 = plot(X1,YMatrix1,'LineWidth',5);
        set(plot1(1),'DisplayName',name_plot1);
        set(plot1(2),'DisplayName',name_plot2,'LineStyle','--');
        % 创建 ylabel
        ylabel('损失值(Loss)');
        % 创建 title
        title('Loss曲线');
    end
    % 创建 xlabel
    xlabel('训练回合数(Epoch)');
    
    
    
    box(axes1,'on');
    hold(axes1,'off');
    % 设置其余坐标区属性
    set(axes1,'FontSize',ftsize);
    % 创建 legend
    legend(axes1,'show');
    
end

