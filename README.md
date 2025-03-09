# Trendnet
Notes for TrendNet AP


# Locating UART
I found an area on the board that looked like UART, with a multimeter I found what I think is ground, Send and Recieve

# Testing UART
I hooked up my flipper zero and connect like normal, after playing around with different baud rates it seems like to 57600.
```
U-boot Ver:1.0.1.30 2009/10/12


Board: Ralink APSoC DRAM:  32 MB  1*32 MB
============================================ 
ASIC 3052_MP2 (Port5<->None)
Product Name: EAP9550
SDRAM CAS = 3(d1835272) 
============================================ 

Please choose the operation: 
   1: Load system code to SDRAM via TFTP. 

LINUX started...
init started: BusyBox v1.7.5 (2011-06-30 16:53:57 CST)
starting pid 131, tty '/dev/console': '/sbin/config_init'
Config Init version: 1.2.2.98 date: 2011/06/30
starting pid 174, tty '/dev/ttyS1': '/sbin/config_term'
************************************************************************
*                                TEW-653AP                             *
************************************************************************

KernelApp/Ramdisk Ver:1.2.2.98                   Date:2011/06/30
console> cat: can't open '/apps/lib/modules/2.6.21/modulesApp.dep': No such file or directory
ln: /sbin/./apps_init: File exists
sh: cannot create /proc/senao/ip_conntrack_interface: nonexistent directory

```

# TODO
