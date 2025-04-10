# Define Firmware Version: v2.1.1.0
export PRJ_VERSION = 0x02010100

# Include .XSA in image dir
export GEN_XSA_IMAGE = 1

# Define release
ifndef RELEASE
export RELEASE = all
endif
