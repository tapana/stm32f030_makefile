PROJECT = blink
TOOLCHAIN_PATH = ../gcc-arm-none-eabi-6-2017-q2/bin
STLINK_PATH = ../stlink/build/Release
#CUBE_PATH = ../STM32Cube_FW_F0_V1.8.0
CUBE_PATH = ./

AUTO_RESET = ../../util/cp210x_reset
SERIAL_FLASHER = python ../../util/stm32loader.py
SERIAL_PORT = /dev/ttyUSB0


CC = $(TOOLCHAIN_PATH)/arm-none-eabi-gcc
OBJCOPY = $(TOOLCHAIN_PATH)/arm-none-eabi-objcopy
OBJ_DIR = obj
OUTPUT_DIR = bin

ST_FLASH = $(STLINK_PATH)/st-flash

CFLAGS = -Wall -mcpu=cortex-m0 -mlittle-endian -mthumb -mthumb-interwork -Wl,--gc-sections

INC_DIRS = -IInc \
	-I$(CUBE_PATH)/Drivers/STM32F0xx_HAL_Driver/Inc/ \
	-I$(CUBE_PATH)/Drivers/CMSIS/Device/ST/STM32F0xx/Include/ \
	-I$(CUBE_PATH)/Drivers/CMSIS/Include/ \



DEFS = -DSTM32F030x8 

LDFLAGS = -Tdevice/STM32F030R8_FLASH.ld

HEADER_DEPS = $(wildcard inc/*.h)

#SOURCES=$(wildcard *.cpp)
SRCS = main.c \
	stm32f0xx_it.c \
	system_stm32f0xx.c 

SRCS += stm32f0xx_nucleo.c

SRCS += stm32f0xx_hal.c \
	stm32f0xx_hal_rcc.c \
	stm32f0xx_hal_gpio.c \
	stm32f0xx_hal_cortex.c \
	stm32f0xx_hal_dma.c \
	stm32f0xx_hal_tim.c \
#	stm32f0xx_hal_uart.c \
#	stm32f0xx_hal_spi.c \
#	stm32f0xx_hal_i2c.c \
#	stm32f0xx_hal_tim_ex.c \
#	stm32f0xx_hal_pwr.c \
#	stm32f0xx_hal_pwr_ex.c \
#	stm32f0xx_hal_rcc_ex.c \


vpath %.c Src
vpath %.c $(CUBE_PATH)/Drivers/STM32F0xx_HAL_Driver/Src


_OBJ = $(SRCS:.c=.o) startup_stm32f030x8.o
OBJS = $(addprefix $(OBJ_DIR)/,$(_OBJ))


all: $(OBJS) $(PROJECT)

$(PROJECT): $(OBJS)
	$(CC) -Og $(DEFS) $(CFLAGS) $(LDFLAGS) $(OBJS) -o $(OUTPUT_DIR)/$(PROJECT).elf
	$(OBJCOPY) -O binary $(OUTPUT_DIR)/$(PROJECT).elf $(OUTPUT_DIR)/$(PROJECT).bin
#$(OBJCOPY) -O ihex $(PROJECT).elf   $(PROJECT).hex

$(OBJ_DIR)/startup_stm32f030x8.o: device/startup_stm32f030x8.s
	$(CC) -O0 $(DEFS) $(CFLAGS) $(INC_DIRS) -c -o $@ $<

$(OBJ_DIR)/%.o: %.c $(HEADER_DEPS)	
	$(CC) -O0 $(DEFS) $(CFLAGS) $(INC_DIRS) -c -o $@ $<

.PHONY: clean

clean:
	rm -f $(OBJ_DIR)/*.o $(OUTPUT_DIR)/*

flash: all
	$(AUTO_RESET) $(SERIAL_PORT) b
	$(SERIAL_FLASHER) -p $(SERIAL_PORT) -evw $(OUTPUT_DIR)/$(PROJECT).bin	
	$(AUTO_RESET) $(SERIAL_PORT) l

fstlink: all
	$(ST_FLASH) write $(OUTPUT_DIR)/$(PROJECT).bin 0x8000000




#rm -f $(ODIR)/*.o *~ core $(INCDIR)/*~ 
