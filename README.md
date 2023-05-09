# Simple-rfsoc-4x2-Example

<!--- ######################################################## -->

# Before you clone the GIT repository

https://confluence.slac.stanford.edu/x/vJmDFg

<!--- ######################################################## -->

# Clone the GIT repository

```bash
$ git clone --recursive git@github.com:slaclab/Simple-rfsoc-4x2-Example
```

<!--- ######################################################## -->

# How to generate the RFSoC .BIT and .XSA files

1) Setup Xilinx PATH and licensing (if on SLAC AFS network) else requires Vivado install and licensing on your local machine

```bash
$ source Simple-rfsoc-4x2-Example/firmware/vivado_setup.sh
```

2) Go to the target directory and make the firmware:

```bash
$ cd Simple-rfsoc-4x2-Example/firmware/targets/SimpleRfSoc4x2Example/
$ make
```

3) Optional: Review the results in GUI mode

```bash
$ make gui
```

The .bit and .XSA files are dumped into the SimpleRfSoc4x2Example/image directory:

```bash
$ ls -lath SimpleRfSoc4x2Example/images/
total 47M
drwxr-xr-x 5 ruckman re 2.0K Feb  7 07:13 ..
drwxr-xr-x 2 ruckman re 2.0K Feb  4 21:15 .
-rw-r--r-- 1 ruckman re  14M Feb  4 21:15 SimpleRfSoc4x2Example-0x01000000-20220204204648-ruckman-90df89c.xsa
-rw-r--r-- 1 ruckman re  33M Feb  4 21:14 SimpleRfSoc4x2Example-0x01000000-20220204204648-ruckman-90df89c.bit
```

<!--- ######################################################## -->

# How to build Petalinux images

1) Generate the .bit and .xsa files (refer to `How to generate the RFSoC .BIT and .XSA files` instructions).

2) Setup Xilinx licensing and petalinux software (if on SLAC AFS network) else requires Xilinx & petalinux install on your local machine

```bash
# These setup scripts assume that you are on SLAC network
$ source Simple-rfsoc-4x2-Example/firmware/vivado_setup.sh
$ source /path/to/petalinux/2022.2/settings.sh
```

3) Go to the target directory and run the `CreatePetalinuxProject.sh` script with arg pointing to path of .XSA file:

```bash
$ cd Simple-rfsoc-4x2-Example/firmware/targets/SimpleRfSoc4x2Example/
$ source CreatePetalinuxProject.sh images/SimpleRfSoc4x2Example-0x01000000-20220204204648-ruckman-90df89c.xsa
```

<!--- ######################################################## -->

# How to make the SD memory card for the first time

1) Creating Two Partitions.  Refer to URL below

https://xilinx-wiki.atlassian.net/wiki/x/EYMfAQ

2) Copy For the boot images, simply copy the files to the FAT partition.
This typically will include system.bit, BOOT.BIN, image.ub, and boot.scr.  Here's an example:

Note: Assumes SD memory FAT32 is `/dev/sde1` in instructions below

```bash
sudo mkdir -p boot
sudo mount /dev/sde1 boot
sudo cp Simple-rfsoc-4x2-Example/firmware/build/petalinux/SimpleRfSoc4x2Example/images/linux/system.bit boot/.
sudo cp Simple-rfsoc-4x2-Example/firmware/build/petalinux/SimpleRfSoc4x2Example/images/linux/BOOT.BIN   boot/.
sudo cp Simple-rfsoc-4x2-Example/firmware/build/petalinux/SimpleRfSoc4x2Example/images/linux/image.ub   boot/.
sudo cp Simple-rfsoc-4x2-Example/firmware/build/petalinux/SimpleRfSoc4x2Example/images/linux/boot.scr   boot/.
sudo sync boot/
sudo umount boot
```

3) Power down the RFSoC board

4) Confirm the Mode SW2 [4:1] = 1110 (Mode Pins [3:0]). Note: Switch OFF = 1 = High; ON = 0 = Low.

5) Power up the RFSoC board

6) Confirm that you can ping the boot after it boots up

<!--- ######################################################## -->

# How to remote update the firmware bitstream

- Assumes the DHCP assigned IP address is 10.0.0.10

1) Using "scp" to copy your .bit file to the SD memory card on the RFSoC.  Here's an example:

```bash
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "10.0.0.10" # https://jira.slac.stanford.edu/browse/ESRFOC-54
scp SimpleRfSoc4x2Example-0x01000000-20220204204648-ruckman-90df89c.bit root@10.0.0.10:/boot/system.bit
```

2) Send a "sync" and "reboot" command to the RFSoC to load new firmware:  Here's an example:

```bash
ssh root@10.0.0.10 '/bin/sync; /sbin/reboot'
```

<!--- ######################################################## -->

# How to install the Rogue With Anaconda

> https://slaclab.github.io/rogue/installing/anaconda.html

<!--- ######################################################## -->

# How to run the Rogue GUI

- Assumes the DHCP assigned IP address is 10.0.0.10

1) Setup the rogue environment (if on SLAC AFS network) else install rogue (recommend Anaconda method) on your local machine

```bash
$ source Simple-rfsoc-4x2-Example/software/setup_env_slac.sh
```

2) Lauch the GUI:

```bash
$ cd Simple-rfsoc-4x2-Example/software
$ python scripts/devGui.py --ip 10.0.0.10
```

<!--- ######################################################## -->
