# TODO: Different target for debug/release
TARGET ?= httpd

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src ./src/util
INC_DIR ?= ./include

SRCS := $(shell find $(SRC_DIRS) -maxdepth 1 -name *.asm)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

INCS := $(shell find $(INC_DIR) -name *.inc)

RELEASE ?= 0
ifeq ($(RELEASE),1)
	DEBUG ?= 0
else
	DEBUG ?= 1
endif

## Customizable features.
LOGGING ?= 1
##

BUILDFLAGS := -DDEBUG=$(DEBUG) -DRELEASE=$(RELEASE) -DLOGGING=$(LOGGING)

LDFLAGS = -melf_i386 --static -nostdlib
ASFLAGS ?= -felf32 -I$(INC_DIR) -Wall
ifeq ($(RELEASE),0)
	LDLFAGS += -O0 -g
	ASFLAGS += -O0 -g
else
	LDFLAGS += -s -O3
	ASFLAGS += -Ox
endif

$(BUILD_DIR)/$(TARGET): $(OBJS)
	ld -o $@ $(LDFLAGS) $(OBJS)

$(BUILD_DIR)/%.asm.o: %.asm $(INCS)
	@mkdir -p $(dir $@)
	nasm $(BUILDFLAGS) $(ASFLAGS) -o $@ $<

.PHONY: run
run: $(BUILD_DIR)/$(TARGET)
	@$<

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
