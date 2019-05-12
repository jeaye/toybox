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
BUILDFLAGS := -DDEBUG=$(DEBUG) -DRELEASE=$(RELEASE)

CFLAGS = -static -nostdlib -nostartfiles -nodefaultlibs -Wall -pedantic
ASFLAGS ?= -felf32 -I$(INC_DIR) -Wall
LDFLAGS ?= -m32
ifeq ($(RELEASE),0)
	CLFAGS += -O0 -g
	ASFLAGS += -O0
else
	CFLAGS += -s -flto -Ofast
	ASFLAGS += -Ox
endif

$(BUILD_DIR)/$(TARGET): $(OBJS)
	gcc $(BUILDFLAGS) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.asm.o: %.asm $(INCS)
	-mkdir -p $(dir $@)
	nasm $(BUILDFLAGS) $(ASFLAGS) -o $@ $<

.PHONY: run
run: $(BUILD_DIR)/$(TARGET)
	@$<

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
