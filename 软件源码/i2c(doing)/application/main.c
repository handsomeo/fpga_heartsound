// See LICENSE for license details.
#include <stdio.h>
#include "hbird_sdk_hal.h"
#include "oled.h"

void gpio_config();
//int i2c_eeprom_wr_test();

int main(void)
{
    printf("123");
    gpio_config();
    /* I2C Config */
    i2c_setup(I2C_ID, I2C_PRESCALER, I2C_CTR_EN);
    printf("123");
    /* GPIO Config */


    OLED_Init();
    OLED_ShowString(1, 1, "hello", 8);

    return 0;
}

/**
    \brief      configure the GPIO ports
    \param[in]  none
    \param[out] none
    \retval     none
*/
void gpio_config()
{
    // GPIO Init
    // Set GPIOA[14] as I2C SCL, GPIOA[15] as I2C SDA
    gpio_iof_config(GPIOA, IOF_I2C_MASK);
}



