################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_UPPER_SRCS += \
../hbird_sdk/SoC/hbirdv2/Common/Source/GCC/intexc_hbirdv2.S \
../hbird_sdk/SoC/hbirdv2/Common/Source/GCC/startup_hbirdv2.S 

OBJS += \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/intexc_hbirdv2.o \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/startup_hbirdv2.o 

S_UPPER_DEPS += \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/intexc_hbirdv2.d \
./hbird_sdk/SoC/hbirdv2/Common/Source/GCC/startup_hbirdv2.d 


# Each subdirectory must supply rules for building sources it contributes
hbird_sdk/SoC/hbirdv2/Common/Source/GCC/%.o: ../hbird_sdk/SoC/hbirdv2/Common/Source/GCC/%.S
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	riscv-nuclei-elf-gcc -march=rv32imac -mabi=ilp32 -mcmodel=medany -mno-save-restore -funroll-all-loops -finline-limit=600 -ftree-dominator-opts -fno-if-conversion2 -fselective-scheduling -fno-code-hoisting -funroll-loops -finline-functions -falign-functions=4 -falign-jumps=4 -falign-loops=4 -O2 -ffunction-sections -fdata-sections -fno-common --specs=nano.specs --specs=nosys.specs -u _printf_float  -g -x assembler-with-cpp -D__IDE_RV_CORE=e203 -DSOC_HBIRDV2 -DDOWNLOAD_MODE=DOWNLOAD_MODE_ILM -DDOWNLOAD_MODE_STRING=\"ILM\" -DBOARD_MCU200T -I"C:\Users\ming\Desktop\i2c\hbird_sdk\NMSIS\Core\Include" -I"C:\Users\ming\Desktop\i2c\hbird_sdk\SoC\hbirdv2\Common\Include" -I"C:\Users\ming\Desktop\i2c\hbird_sdk\SoC\hbirdv2\Board\mcu200t\Include" -I"C:\Users\ming\Desktop\i2c\application" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


