APP_NAME = ex1
BUILD_DIR = ./bin

LIB_NAME:= mkl
LIB_DEFINES:= -fvisibility=hidden -fPIC -O2 -Wno-nullability-completeness
LIB_INCLUDES:= -I./MKL/src 
LIB_LINKERS:= -dynamiclib -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore

LIB_C_FILES:= $(wildcard ./MKL/src/*.c) $(wildcard ./MKL/src/**/*.c)
LIB_OBJC_FILES:= $(wildcard ./MKL/src/*.m) $(wildcard ./MKL/src/**/*.m)
LIB_O_FILES:= $(patsubst ./MKL/src/%.c, $(BUILD_DIR)/%.o, $(LIB_C_FILES)) $(patsubst ./MKL/src/%.m, $(BUILD_DIR)/%.o, $(LIB_OBJC_FILES))

APP_DEFINES:= -O2 -Wno-nullability-completeness
APP_INCLUDES:= -I./App/ -I./MKL/src
APP_LINKERS:= -L$(BUILD_DIR) -lmkl -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore

APP_C_FILES:= ./App/main.c
APP_O_FILES:= $(patsubst ./App/%.c, $(BUILD_DIR)/%.o, $(APP_C_FILES))

all: buildLibrary buildApp 

buildLibrary: $(LIB_O_FILES)
	echo "Building Library..."
	mkdir -p $(BUILD_DIR)
	clang $(LIB_DEFINES) $(LIB_INCLUDES) $(LIB_LINKERS) $^ -o $(BUILD_DIR)/lib$(LIB_NAME).dylib

buildApp: $(APP_O_FILES)
	echo "Building App..."
	clang $(APP_DEFINES) $(APP_INCLUDES) $(APP_LINKERS) $^ -o $(BUILD_DIR)/$(APP_NAME)

run:
	echo "Running App..."
	./$(BUILD_DIR)/$(APP_NAME)

clean:
	rm -f $(LIB_O_FILES) $(APP_O_FILES)
	rm -f $(BUILD_DIR)/$(APP_NAME) $(BUILD_DIR)/lib$(LIB_NAME).dylib

$(BUILD_DIR)/%.o: ./MKL/src/%.c
	mkdir -p $(dir $@)
	clang -c $(LIB_DEFINES) $(LIB_INCLUDES) $< -o $@

$(BUILD_DIR)/%.o: ./MKL/src/%.m
	mkdir -p $(dir $@)
	clang -c $(LIB_DEFINES) $(LIB_INCLUDES) $< -o $@

$(BUILD_DIR)/%.o: ./App/%.c
	mkdir -p $(dir $@)
	clang -c $(APP_DEFINES) $(APP_INCLUDES) $< -o $@