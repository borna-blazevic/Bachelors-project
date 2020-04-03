The project can be run with:
```
qemu-system-arm -machine lm3s811evb -serial stdio -kernel gcc/RTOSDemo.bin -s -S
```

and can be debbuged with 
```
arm-none-eabi-gdb -ex="target remote localhost:1234"
```

To start the execution once the emulator turns on it is necessary to continue the execution via gdb or GUI.