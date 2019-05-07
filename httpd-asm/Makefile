TARGET ?= httpd

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src ./src/util
INC_DIRS ?= ./include

SRCS := $(shell find $(SRC_DIRS) -maxdepth 1 -name *.asm)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

INCS := $(shell find $(INC_DIRS) -name *.inc)

DEBUG ?= 1
RELEASE ?= 0
BUILDFLAGS := -DDEBUG=$(DEBUG) -DRELEASE=$(RELEASE)

ASFLAGS ?= -felf32 -O0 -g -I./src
LDFLAGS ?= -m32 -O0 -g

$(BUILD_DIR)/$(TARGET): $(OBJS)
	gcc $(BUILDFLAGS) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.asm.o: %.asm $(INCS)
	-mkdir -p $(dir $@)
	nasm $(BUILDFLAGS) $(ASFLAGS) -o $@ $<

.PHONY: run
run: $(BUILD_DIR)/$(TARGET)
	@$<

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
