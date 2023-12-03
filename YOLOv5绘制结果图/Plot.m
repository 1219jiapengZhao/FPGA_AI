function figure1 = Plot(X1, Y1, classname, PRslect, Holdselect, figurenum)
%CREATEFIGURE(X1, Y1)
%  X1:  x 数据的向量
%  Y1:  y 数据的向量
% 输入是x轴数据，y轴数据，PRslect = 1选择画P曲线，2画R曲线；Holdselect选择是否保持图像，0为画在一张图里，1为新建一个图
%classname是图例里曲线的名字, Figure如果画在一张图里给出上一个图的信息, figurenum是第几个图窗
ftsize = 30;

if Holdselect
    % 创建 figure
    figure1 = figure('WindowState','maximized');
    
    % 创建 axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    
    % 创建 plot
    
    plot(X1,Y1,'DisplayName',classname,'MarkerSize',10,...
        'Marker','x',...
        'LineWidth',3);
    
    switch PRslect
        case 1
            % 创建 xlabel
            xlabel('置信度(Confidence)');
            % 创建 ylabel
            ylabel('准确率(Precision)');
            % 创建 title
            title('P曲线');
        case 0
            % 创建 xlabel
            xlabel('置信度(Confidence)');
            ylabel('召回率(Recall)');
            % 创建 title
            title('R曲线');
        case 3
            ylabel('准确率(Precision)');
            xlabel('召回率(Recall)');
            % 创建 title
            title('AP曲线');
        case 4
            % 创建 xlabel
            xlabel('置信度(Confidence)');
            ylabel('F1分数(F1-Score)');
            % 创建 title
            title('F1分数曲线');
    end
    
    
    if PRslect ~= 3     %PR曲线不限定范围了
        % 取消以下行的注释以保留坐标区的 X 范围
        xlim(axes1,[0 1]);
        % 取消以下行的注释以保留坐标区的 Y 范围
        ylim(axes1,[0 1]);
    end
    box(axes1,'on');
    hold(axes1,'off');
    % 设置其余坐标区属性
    set(axes1,'FontSize',ftsize);
    % 创建 legend
    legend(axes1,'show');
    
else
    figure(figurenum);
    hold on
    plot(X1,Y1,'DisplayName',classname,'MarkerSize',10,...
        'Marker','x',...
        'LineWidth',3);
    
end

