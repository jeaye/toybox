TARGET ?= httpd

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src ./src/util
INC_DIR ?= ./include

SRCS := $(shell find $(SRC_DIRS) -maxdepth 1 -name *.asm)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)

INCS := $(shell find $(INC_DIR) -name *.inc)

DEBUG ?= 1
ifeq ($(DEBUG),1)
	RELEASE ?= 0
else
	RELEASE ?= 1
endif
BUILDFLAGS := -DDEBUG=$(DEBUG) -DRELEASE=$(RELEASE)

CFLAGS = -Wall -pedantic
ASFLAGS ?= -felf32 -I$(INC_DIR) -w+all
LDFLAGS ?= -m32
ifeq ($(DEBUG),1)
	CLFAGS += -O0 -g
	ASFLAGS += -O0
else
	CFLAGS += -flto -Ofast
	ASFLAGS += -Ox
endif

$(BUILD_DIR)/$(TARGET): $(OBJS)
	gcc $(BUILDFLAGS) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)
ifeq ($(DEBUG),0)
	strip -s $@
endif

$(BUILD_DIR)/%.asm.o: %.asm $(INCS)
	-mkdir -p $(dir $@)
	nasm $(BUILDFLAGS) $(ASFLAGS) -o $@ $<

.PHONY: run
run: $(BUILD_DIR)/$(TARGET)
	@$<

.PHONY: clean
clean:
	rm -r $(BUILD_DIR)
