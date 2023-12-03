function bar1 = createfigure_bar(xvector1, yvector1, Holdselect, figurename)
%CREATEFIGURE(xvector1, yvector1)
%  XVECTOR1:  bar xvector
%  YVECTOR1:  bar yvector
%  data 时总的数值
%Holdselect为0时候单独的，为1时候画在一起
% figurename图的名字
%  由 MATLAB 于 02-Apr-2023 14:52:13 自动生成
if Holdselect
    hold on
    bar1 = bar(xvector1,yvector1,'DisplayName','tp值/%','Horizontal','on'); 
else 
% 创建 figure
figure1 = figure('WindowState','maximized');

% 创建 axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% 创建 bar
bar1 = bar(xvector1,yvector1,'DisplayName','fp值/%','Horizontal','on');

% 下面一行演示创建数据提示的另一种方法。
% datatip(bar1,0.107142857142857,'person-group');
% 创建 datatip

% for i = 1 : length(data)
%     %     name = cellstr(xvector1(i));
%     %     datatip(bar1, data(i), name{1}, 'Location','northwest');
%     %     text(xvector1(i), i, num2str(data(i)))%\leftarrow表示左箭头
% %     annotation('textarrow', [yvector1(i) / 0.14 + 0.01, yvector1(i) / 0.14], [i / 22 , i / 22],'String',num2str(data(i)))
% annotation('textbox',[0.5 0.5 0.5 0.5],'String',num2str(data(i)))
% 
% end

% 创建 xlabel
xlabel('每一类的目标真实数量');

box(axes1,'on');
hold(axes1,'off');
% 设置其余坐标区属性
set(axes1,'FontSize',30);
% 创建 legend
legend(axes1,'show');

end

