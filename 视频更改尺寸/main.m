clear ;clc
%将一种视频格式转向另一种格式或者修改尺寸
videolist = import_videolist("D:\MATLAB\WORK\视频更改尺寸\videolist.txt", [1, Inf]);
output_videolist = import_videolist("D:\MATLAB\WORK\视频更改尺寸\output_videolist.txt", [1, Inf]);
for i = 1 : length(videolist.mp4)
str = strcat(".\视频材料\",videolist.mp4(i));
reader = VideoReader(str);%读取待修改的视频
writer = VideoWriter(output_videolist.mp4(i), ...
                        'MPEG-4');
writer.FrameRate = reader.FrameRate;
% writer.Path = strcat(".\输出视频\",output_videolist.mp4(i));    %设置输出路径 VideoWriter的path为只读属性，不能修改
open(writer);
while hasFrame(reader)
   img = readFrame(reader);
   img = imresize(img, [416,416]);%修改尺寸
   writeVideo(writer,img);
end

close(writer);
end

