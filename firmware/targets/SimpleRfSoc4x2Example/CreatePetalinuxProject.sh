#!/bin/sh
####################################################

# Define the hardware type
# Note: Must match the axi-soc-ultra-plus-core/hardware directory name
hwType=RealDigitalRfSoC4x2

# Define number of DMA lanes
numLane=2

# Define number of DEST per DMA lane
numDest=32

# Define number of DMA TX/RX Buffers
rxBuffCnt=256
txBuffCnt=16

# Define DMA Buffer Size
buffSize=0x10000 # 64kB

####################################################

if [ $# -ne 1 ]
then
   echo "Usage: CreatePetalinuxProject.sh xsa"
   exit;
fi

# Define the target name
xsaPath=$(realpath "${1}")

# Define the target name
targetName=${PWD##*/}

# Make the build output
mkdir -p /u1/$USER
mkdir -p /u1/$USER/build
mkdir -p /u1/$USER/build/petalinux
buildPath=/u1/$USER/build/petalinux

# Execute the create petalinux script
../../submodules/axi-soc-ultra-plus-core/CreatePetalinuxProject.sh \
-p $buildPath -n $targetName -x $xsaPath -h $hwType \
-l $numLane -d $numDest -t $txBuffCnt -r $rxBuffCnt -s $buffSize
