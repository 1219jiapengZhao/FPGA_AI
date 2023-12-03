#include "ov5640_sobel.h"
#include "hls_opencv.h"

int main(void)
{
	//��ȡͼ������
	IplImage* src = cvLoadImage(INPUT_IMAGE);
	IplImage* srcone = cvLoadImage(INPUT_IMAGE);
	IplImage* dst = cvCreateImage(cvGetSize(src),src->depth,src->nChannels);
	IplImage* one = cvCreateImage(cvGetSize(src),src->depth,src->nChannels);

	//ʹ��HLS����д���
	AXI_STREAM src_axi,srcone_axi,dst_axi,one_axi;
	IplImage2AXIvideo(src,src_axi);
	IplImage2AXIvideo(srcone,srcone_axi);
	ov5640_sobel(src_axi,srcone_axi,dst_axi,one_axi,src->height,src->width);
	AXIvideo2IplImage(dst_axi,dst);
	AXIvideo2IplImage(one_axi,one);

	//����ͼ��
	cvSaveImage(OUTPUT_IMAGE,dst);

	cvSaveImage(OUTSAVE_onepicture,one);		//	����img_1

	//��ʾͼ��
	cvShowImage(INPUT_IMAGE,src);
	cvShowImage(OUTPUT_IMAGE,dst);

	cvShowImage(OUTSAVE_onepicture,one);

	//�ȴ��û����¼����ϵ���һ����
	cv::waitKey(0);

}

