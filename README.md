This project is done for my bachelor's thesis **Control Subsystem of Embedded Computer for Data Processing in CubeSat Nanosatellite**.

It consists of three submodules:
1. task -> a basic control subsystem which emulates firmware upgrade and handles errors coupled with the bootloader submodule.
2. bootloader submodule -> a bootloader which keeps the original image burned to the flash and allows booting of the newly upgraded firmware through the task submodule.
3. test -> a basic testing environment which executes 4 firmware upgrades under different environments. Test submodule comes with 4 different firmware versions for testing.

The project can be run with after building:
```
make burn
```

To generate own firmware upgrades simply copy the task directory, alter this line in main.c:
```
	NVIC_SetVectorTable(NVIC_VectTab_FLASH, 0x20000);
```
with this:
```
	NVIC_SetVectorTable(NVIC_VectTab_FLASH, 0x40000);
```
and replace the contents of the STM32F407VGTx_FLASH.ld file with this:
```
/*
*****************************************************************************
**

**  File        : LinkerScript.ld
**
**  Abstract    : Linker script for STM32F407VGTx Device with
**                1024KByte FLASH, 128KByte RAM
**
**                Set heap size, stack size and stack location according
**                to application requirements.
**
**                Set memory bank area and size if external memory is used.
**
**  Target      : STMicroelectronics STM32
**
**
**  Distribution: The file is distributed as is, without any warranty
**                of any kind.
**
**  (c)Copyright Ac6.
**  You may use this file as-is or modify it according to the needs of your
**  project. Distribution of this file (unmodified or modified) is not
**  permitted. Ac6 permit registered System Workbench for MCU users the
**  rights to distribute the assembled, compiled & linked contents of this
**  file as part of an application binary file, provided that it is built
**  using the System Workbench for MCU toolchain.
**
*****************************************************************************
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Highest address of the user mode stack */
_estack = 0x20020000;    /* end of RAM */
/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x200;;      /* required amount of heap  */
_Min_Stack_Size = 0x400;; /* required amount of stack */

/* Specify the memory areas */
MEMORY
{
BOOTLOADER (rx)      : ORIGIN = 0x8000000, LENGTH = 128K
RECOVERY_IMAGE (rx) : ORIGIN = 0x8020000, LENGTH = 128K
NEW_IMAGE (rx) : ORIGIN = 0x8040000, LENGTH = 768K
SHARED (rwx) : ORIGIN = 0x20000000, LENGTH = 1K
RAM (xrw)      : ORIGIN = 0x20000400, LENGTH = 127K
FIRMWARE_UPGRADE (xrw) : ORIGIN = 0x10000000, LENGTH = 64K
}


_recovery_image = ORIGIN(RECOVERY_IMAGE);
_new_image = ORIGIN(NEW_IMAGE);
_shared = ORIGIN(SHARED);
_firmware_upgrade = ORIGIN(FIRMWARE_UPGRADE);

/* Define output sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >NEW_IMAGE

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >NEW_IMAGE

  /* Constant data goes into FLASH */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >NEW_IMAGE

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >NEW_IMAGE
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >NEW_IMAGE

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >NEW_IMAGE
  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >NEW_IMAGE
  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >NEW_IMAGE

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM AT> NEW_IMAGE
  
  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM

  /* User_heap_stack section, used to check that there is enough RAM left */
  ._user_heap_stack :
  {
    . = ALIGN(4);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(4);
  } >RAM

  

  /* Remove information from the standard libraries */
  /DISCARD/ :
  {
    libc.a ( * )
    libm.a ( * )
    libgcc.a ( * )
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
```
Add additional changes, make the project and export it to a srec file.

To start the execution the computer has to be connected to an STM32F407 Discovery board.

Useful tips discovered while working on the project:

1. STM32F407 Discovery board's hardware CRC uses this format:
    ```
    class CrcSTM(CrcBase):
    """CRC-STM"""
    _width = 32
    _poly = 0x4C11DB7
    _initvalue = 0xFFFFFFFF
    _reflect_input = False
    _reflect_output = False
    _xor_output = 0x0
    _check_result = 0x376e6e7
    ```
    which is written for the crccheck Python module.

2. QEMU does not support FLASH writing for the lm3s6965 board, QEMU emulates the FLASH as read-only.