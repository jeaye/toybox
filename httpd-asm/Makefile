TARGET ?= httpd

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src ./src/util

SRCS := $(shell find $(SRC_DIRS) -maxdepth 1 -name *.asm)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

DEBUG ?= 1
RELEASE ?= 0
BUILDFLAGS := -DDEBUG=$(DEBUG) -DRELEASE=$(RELEASE)

ASFLAGS ?= -felf32 -O0 -g -I./src
LDFLAGS ?= -m32 -O0 -g

$(BUILD_DIR)/$(TARGET): $(OBJS)
	gcc $(BUILDFLAGS) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.asm.o: %.asm
	-mkdir -p $(dir $@)
	nasm $(BUILDFLAGS) $(ASFLAGS) -o $@ $<

.PHONY: run
run: $(BUILD_DIR)/$(TARGET)
	@$<

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
