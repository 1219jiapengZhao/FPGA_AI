function bar1 = plot_gt(newname, data)
figure1 = figure('WindowState','maximized');
% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');
% 创建 bar
barh(newname, data,'DisplayName','gt值');
% 创建 xlabel
xlabel('每一类的目标真实数量');
title('ground-truth柱状图')
box(axes1,'on');
hold(axes1,'off');
% 设置其余坐标区属性
set(axes1,'FontSize',30);
% 创建 legend
legend(axes1,'show');
end

