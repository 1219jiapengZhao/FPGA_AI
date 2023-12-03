#ifndef _OV5640_SOBEL_H
#define _OV5640_SOBEL_H

#include "hls_video.h"

#define MAX_HEIGHT 800        //图像最大高度
#define MAX_WIDTH  1280       //图像最大宽度

#define INPUT_IMAGE   "lena.jpg"
//#define INPUT_IMAGE   "road.jpg"
#define OUTPUT_IMAGE  "lena_sobel.jpg"
//#define OUTPUT_IMAGE  "road_sobel.jpg"


#define OUTSAVE_onepicture  "huidutu.jpg"

typedef hls::stream<ap_axiu<24,1,1,1> > AXI_STREAM;
typedef hls::Mat<MAX_HEIGHT,MAX_WIDTH,HLS_8UC3> RGB_IMAGE;
typedef hls::Mat<MAX_HEIGHT,MAX_WIDTH,HLS_8UC1> GRAY_IMAGE;

void ov5640_sobel(AXI_STREAM &INPUT_STREAM,
		AXI_STREAM &INPUTCPOY_STREAM,
		            AXI_STREAM &OUTPUT_STREAM,
					AXI_STREAM &OUTSAVE_STREAM,
					int rows,
					int cols
					);

#endif
