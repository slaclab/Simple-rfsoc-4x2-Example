# Define Firmware Version: v3.3.0.0
export PRJ_VERSION = 0x03030000

# Include .XSA in image dir
export GEN_XSA_IMAGE = 1

# Define release
ifndef RELEASE
export RELEASE = all
endif
