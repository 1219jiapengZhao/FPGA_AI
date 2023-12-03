#include "ov5640_sobel.h"

//#include "hls_opencv.h"		//编译头文件

void ov5640_sobel(AXI_STREAM &INPUT_STREAM,
		AXI_STREAM &INPUTCPOY_STREAM,
		            AXI_STREAM &OUTPUT_STREAM,
					AXI_STREAM &OUTSAVE_STREAM,
					int rows,
					int cols
					){
#pragma HLS INTERFACE axis port = INPUT_STREAM
#pragma HLS INTERFACE axis port = INPUTCPOY_STREAM
#pragma HLS INTERFACE axis port = OUTPUT_STREAM
#pragma HLS INTERFACE axis port = OUTSAVE_STREAM		//
#pragma HLS INTERFACE s_axilite port = rows
#pragma HLS INTERFACE s_axilite port = cols
#pragma HLS INTERFACE ap_ctrl_none port = return
#pragma HLS dataflow

	//hls::mat 格式变量
	RGB_IMAGE  img_0(rows,cols);
	RGB_IMAGE  imgcopy_0(rows,cols);
	GRAY_IMAGE img_1(rows,cols);
	GRAY_IMAGE imgone_1(rows,cols);
	GRAY_IMAGE img_2(rows,cols);
	RGB_IMAGE  img_3(rows,cols);
	RGB_IMAGE  imgcopy_1(rows,cols);

	//将AXI4 Stream数据转换成hls::mat格式
	hls::AXIvideo2Mat(INPUT_STREAM,img_0);
	hls::AXIvideo2Mat(INPUTCPOY_STREAM,imgcopy_0);

	//将RGB888格式的彩色数据转换成灰度数据
	hls::CvtColor<HLS_RGB2GRAY,HLS_8UC3,HLS_8UC1>(img_0,img_1);
	hls::CvtColor<HLS_RGB2GRAY,HLS_8UC3,HLS_8UC1>(imgcopy_0,imgone_1);

	hls::CvtColor<HLS_GRAY2RGB,HLS_8UC1,HLS_8UC3>(imgone_1,imgcopy_1);

	//将灰度数据与Sobel算子卷积SS
	hls::Sobel<1,0,3>(img_1,img_2);

	//将灰度数据转换成三个通道的灰度图像
	hls::CvtColor<HLS_GRAY2RGB,HLS_8UC1,HLS_8UC3>(img_2,img_3);


	//将hls::mat格式数据转换成AXI4 Stream格式
	hls::Mat2AXIvideo(img_3,OUTPUT_STREAM);
	hls::Mat2AXIvideo(imgcopy_1,OUTSAVE_STREAM);		//输出img_1
}
