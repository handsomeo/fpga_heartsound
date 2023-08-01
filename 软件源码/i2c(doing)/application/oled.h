/*
 * oled.h
 *
 *  Created on: 2023年5月31日
 *      Author: xy
 */

#ifndef APPLICATION_OLED_H_
#define APPLICATION_OLED_H_




#define CMD_BUFFER_LEN 100
/*************************/
#define I2C_PRESCALER 0x1F //(soc_freq/(5*i2cfreq)) -1   i2cfreq = 100Khz
#define I2C_ID        I2C0
#define OLED_DATA 1
#define OLED_CMD 0
#define I2C_TARGET_ADDRESS (0x3c)




extern void OLED_printf (unsigned char poX, unsigned char poY,char *fmt, ...);
extern void OLED_ColorTurn(unsigned char i);
extern void OLED_DisplayTurn(unsigned char i);
extern void OLED_WR_Byte(unsigned char dat, unsigned char cmd);
extern void OLED_Set_Pos(unsigned char x, unsigned char y);
extern void OLED_Display_On(void);
extern void OLED_Display_Off(void);
extern void OLED_Clear(void);
extern void OLED_ShowChar(unsigned char x, unsigned char y, unsigned char chr, unsigned char sizey);
extern unsigned int oled_pow(unsigned char m, unsigned char n);
extern void OLED_ShowNum(unsigned char x, unsigned char y, unsigned int num, unsigned char len, unsigned char sizey);
extern void OLED_ShowString(unsigned char x, unsigned char y, unsigned char *chr, unsigned char sizey);
extern void OLED_ShowChinese(unsigned char x, unsigned char y, unsigned char no, unsigned char sizey);
extern void OLED_DrawBMP(unsigned char x, unsigned char y, unsigned char sizex, unsigned char sizey, unsigned char BMP[]);
extern void OLED_Init(void);






#endif /* APPLICATION_OLED_H_ */
