TARGET ?= httpd

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src

SRCS := $(shell find $(SRC_DIRS) -name *.asm)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

ASFLAGS ?= -felf32 -O0 -g
LDFLAGS ?= -m32 -O0 -g

$(BUILD_DIR)/$(TARGET): $(OBJS)
	gcc $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.asm.o: %.asm
	-mkdir -p $(dir $@)
	nasm $(ASFLAGS) -o $@ $<

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
