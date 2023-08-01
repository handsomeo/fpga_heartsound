#include "oled.h"
#include "oledfont.h"
#include "hbird_sdk_hal.h"
/********printf 相关*******/
#include "stdio.h"
#define CMD_BUFFER_LEN 100
/*************************/
#define I2C_PRESCALER 0x1F //(soc_freq/(5*i2cfreq)) -1   i2cfreq = 100Khz
#define I2C_ID        I2C0
#define OLED_DATA 1
#define OLED_CMD 0
#define I2C_TARGET_ADDRESS (0x3c)

unsigned char gTxPacket[2] = {0};





void OLED_printf (unsigned char x, unsigned char y,char *fmt, ...)
{
    static char buffer[CMD_BUFFER_LEN+1];
    va_list arg_ptr;
//    va_start(arg_ptr, fmt);
    vsnprintf(buffer, CMD_BUFFER_LEN+1, fmt, arg_ptr);
    OLED_ShowString(x, y, (unsigned char *)buffer, 8);
//    va_end(arg_ptr);
}


void OLED_WR_Byte(unsigned char dat, unsigned char mode)
{
//    DL_I2C_transmitControllerData(I2C_0_INST, 0x78);
    /* Poll until the Controller writes all bytes */


//
//       while (DL_I2C_getControllerStatus(I2C_0_INST) &
//              DL_I2C_CONTROLLER_STATUS_BUSY_BUS);
	  if (mode)
	      {*(gTxPacket)=0x40;}

	  else
	  {*(gTxPacket)=0x00;}

	  *(gTxPacket+1)=dat;
	  i2c_send_data(I2C_ID, 0x3c);
	  i2c_send_command(I2C_ID, I2C_WRITE);
	  for (int i = 0; i < 2; i++) {
	      i2c_send_data(I2C_ID, *(gTxPacket+i));            //write i-th byte into fifo
	      i2c_send_command(I2C_ID, I2C_START_WRITE); //send data on the i2c bus                 //wait for ack
	    }
	  while(i2c_busy(I2C_ID));
//  /* Poll until the Controller writes all bytes */
//

 //do a start bit and send data



//  DL_I2C_transmitControllerData(I2C_0_INST, dat);
  /* Wait for I2C to be Idle */


  while(i2c_busy(I2C_ID));



}



void OLED_ColorTurn(unsigned char i)
{
  if (i == 0)
  {
    OLED_WR_Byte(0xA6, OLED_CMD);
  }
  if (i == 1)
  {
    OLED_WR_Byte(0xA7, OLED_CMD);
  }
}


void OLED_DisplayTurn(unsigned char i)
{
  if (i == 0)
  {
    OLED_WR_Byte(0xC8, OLED_CMD);
    OLED_WR_Byte(0xA1, OLED_CMD);
  }
  if (i == 1)
  {
    OLED_WR_Byte(0xC0, OLED_CMD);
    OLED_WR_Byte(0xA0, OLED_CMD);
  }
}


void OLED_Set_Pos(unsigned char x, unsigned char y)
{
  OLED_WR_Byte(0xb0 + y, OLED_CMD);
  OLED_WR_Byte(((x & 0xf0) >> 4) | 0x10, OLED_CMD);
  OLED_WR_Byte((x & 0x0f), OLED_CMD);
}

void OLED_Display_On(void)
{
  OLED_WR_Byte(0X8D, OLED_CMD); //SET DCDC
  OLED_WR_Byte(0X14, OLED_CMD); //DCDC ON
  OLED_WR_Byte(0XAF, OLED_CMD); //DISPLAY ON
}

void OLED_Display_Off(void)
{
  OLED_WR_Byte(0X8D, OLED_CMD);
  OLED_WR_Byte(0X10, OLED_CMD); //DCDC OFF
  OLED_WR_Byte(0XAE, OLED_CMD); //DISPLAY OFF
}

void OLED_Clear(void)
{
    unsigned char i, n;
  for (i = 0; i < 8 ; i++)
  {
    OLED_WR_Byte(0xb0 + i, OLED_CMD);
    OLED_WR_Byte(0x00, OLED_CMD);
    OLED_WR_Byte(0x10, OLED_CMD);
    for (n = 0; n < 128; n++)
      OLED_WR_Byte(0x0, OLED_DATA);
  } //鏇存柊鏄剧ず
}


void OLED_ShowChar(uint8_t x, uint8_t y, uint8_t chr, uint8_t sizey)
{
  uint8_t c = 0, sizex = sizey / 2;
  uint16_t i = 0, size1;
  if (sizey == 8)
    size1 = 6;
  else
    size1 = (sizey / 8 + ((sizey % 8) ? 1 : 0)) * (sizey / 2);
  c = chr - ' ';
  OLED_Set_Pos(x, y);
  for (i = 0; i < size1; i++)
  {
    if (i % sizex == 0 && sizey != 8)
      OLED_Set_Pos(x, y++);
    if (sizey == 8)
       OLED_WR_Byte(asc2_0806[c][i], OLED_DATA);
    else if (sizey == 16)
      OLED_WR_Byte(asc2_1608[c][i], OLED_DATA);
    //
    else
      return;
  }
}

unsigned int oled_pow(unsigned char m, unsigned char n)
{
    unsigned int result = 1;
  while (n--)
    result *= m;
  return result;
}

void OLED_ShowNum(unsigned char x, unsigned char y, unsigned int num, unsigned char len, unsigned char sizey)
{
    unsigned char t, temp, m = 0;
    unsigned char enshow = 0;
  if (sizey == 8)
    m = 2;
  for (t = 0; t < len; t++)
  {
    temp = (num / oled_pow(10, len - t - 1)) % 10;
    if (enshow == 0 && t < (len - 1))
    {
      if (temp == 0)
      {
        OLED_ShowChar(x + (sizey / 2 + m) * t, y, ' ', sizey);
        continue;
      }
      else
        enshow = 1;
    }
    OLED_ShowChar(x + (sizey / 2 + m) * t, y, temp + '0', sizey);
  }
}
//鏄剧ず涓�涓瓧绗﹀彿涓�
void OLED_ShowString(unsigned char x, unsigned char y, unsigned char *chr, unsigned char sizey)
{
  uint8_t j = 0;
  while (chr[j] != '\0')
  {
    OLED_ShowChar(x, y, chr[j++], sizey);
    if (sizey == 8)
      x += 6;
    else
      x += sizey / 2;
  }
}

void OLED_ShowChinese(uint8_t x, uint8_t y, uint8_t no, uint8_t sizey)
{
  uint16_t i, size1 = (sizey / 8 + ((sizey % 8) ? 1 : 0)) * sizey;
  for (i = 0; i < size1; i++)
  {
    if (i % sizey == 0)
      OLED_Set_Pos(x, y++);
    if (sizey == 16)
      OLED_WR_Byte(Hzk[no][i], OLED_DATA);

    else
      return;
  }
}


void OLED_DrawBMP(unsigned char x, uint8_t y, uint8_t sizex, uint8_t sizey, uint8_t BMP[])
{
  uint16_t j = 0;
  uint8_t i, m;
  sizey = sizey / 8 + ((sizey % 8) ? 1 : 0);
  for (i = 0; i < sizey; i++)
  {
    OLED_Set_Pos(x, i + y);
    for (m = 0; m < sizex; m++)
    {
      OLED_WR_Byte(BMP[j++], OLED_DATA);
    }
  }
}


void OLED_Init(void)
{



  OLED_WR_Byte(0xAE, OLED_CMD); //--turn off oled panel
  OLED_WR_Byte(0x00, OLED_CMD); //---set low column address
  OLED_WR_Byte(0x10, OLED_CMD); //---set high column address
  OLED_WR_Byte(0x40, OLED_CMD); //--set start line address  Set Mapping RAM Display Start Line (0x00~0x3F)
  OLED_WR_Byte(0x81, OLED_CMD); //--set contrast control register
  OLED_WR_Byte(0xCF, OLED_CMD); // Set SEG Output Current Brightness
  OLED_WR_Byte(0xA1, OLED_CMD); //--Set SEG/Column Mapping
  OLED_WR_Byte(0xC8, OLED_CMD); //Set COM/Row Scan Direction
  OLED_WR_Byte(0xA6, OLED_CMD); //--set normal display
  OLED_WR_Byte(0xA8, OLED_CMD); //--set multiplex ratio(1 to 64)
  OLED_WR_Byte(0x3f, OLED_CMD); //--1/64 duty
  OLED_WR_Byte(0xD3, OLED_CMD); //-set display offset	Shift Mapping RAM Counter (0x00~0x3F)
  OLED_WR_Byte(0x00, OLED_CMD); //-not offset
  OLED_WR_Byte(0xd5, OLED_CMD); //--set display clock divide ratio/oscillator frequency
  OLED_WR_Byte(0x80, OLED_CMD); //--set divide ratio, Set Clock as 100 Frames/Sec
  OLED_WR_Byte(0xD9, OLED_CMD); //--set pre-charge period
  OLED_WR_Byte(0xF1, OLED_CMD); //Set Pre-Charge as 15 Clocks & Discharge as 1 Clock
  OLED_WR_Byte(0xDA, OLED_CMD); //--set com pins hardware configuration
  OLED_WR_Byte(0x12, OLED_CMD);
  OLED_WR_Byte(0xDB, OLED_CMD); //--set vcomh
  OLED_WR_Byte(0x40, OLED_CMD); //Set VCOM Deselect Level
  OLED_WR_Byte(0x20, OLED_CMD); //-Set Page Addressing Mode (0x00/0x01/0x02)
  OLED_WR_Byte(0x02, OLED_CMD); //
  OLED_WR_Byte(0x8D, OLED_CMD); //--set Charge Pump enable/disable
  OLED_WR_Byte(0x14, OLED_CMD); //--set(0x10) disable
  OLED_WR_Byte(0xA4, OLED_CMD); // Disable Entire Display On (0xa4/0xa5)
  OLED_WR_Byte(0xA6, OLED_CMD); // Disable Inverse Display On (0xa6/a7)
  OLED_Clear();
  OLED_WR_Byte(0xAF, OLED_CMD); /*display ON*/

  OLED_ColorTurn(0);//0正常显示，1 反色显示
  OLED_DisplayTurn(0);//0正常显示 1 屏幕翻转显示
}
