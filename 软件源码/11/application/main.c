// See LICENSE for license details.
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include "insn.h"
#define DECIDE  12
int main(void)
{
	unsigned char i;
	unsigned int cnn_result[3][3]={0};
	unsigned int pic[9][7] = {
	  {1, 50, 3, 21, 40, 47, 6},
	  {10, 55, 3, 89, 5, 27, 45},
	  {12, 56, 3, 14, 43, 28, 44},
	  {58, 62, 50, 75, 99, 108, 95},
	  {65, 126, 133, 126, 41, 6, 107},
	  {238, 237, 198, 94, 50, 6, 87},
	  {20, 125, 161, 107, 82, 109, 77},
	  {250, 201, 123, 96, 43, 6, 67},
	  {18, 72, 35, 27, 39, 26, 23}
	};//图像数组
 unsigned int conv_core_1[3][3]=
 {
		 {10,2,30},
         {2,33,40},
         {30,43,40}
 };

 unsigned int weight[4][5]=
 {
		 {10,20,30,6,21},
         {2,30,40,42,54},
		 {10,20,30,6,21},
		 {1,2,0,0,0}

 };
 unsigned int cnnres;//启动卷积并取出结果


//  custom_max(); //最大值池化
//  custom_allconnect();//全连接
//  result=custom_sresult();//


  jlsd((int)pic);//将图像数组加载到协处理器
  fconv((int)conv_core_1);//将卷积核加载到协处理器
  jlweight((int)weight);//将权重，偏执参数（最后两位）参数导入协处理器
  jact();//激活函数
  cnnres = jconv();

  if(cnnres>DECIDE)

     printf("the sound_pictrue is abnormal ");
  else
  	 printf("the sound_pictrue is normal ");


}
