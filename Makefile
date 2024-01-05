APP_NAME = ex1
BUILD_DIR = ./bin

LIB_NAME:= mkl
LIB_DEFINES:= -dynamiclib -fvisibility=hidden -fPIC
LIB_INCLUDES:= -I./MKL/src 
LIB_LINKERS:= -framework Cocoa

LIB_C_FILES:= ./MKL/src/*.c
LIB_OBJC_FILES:= ./MKL/src/*.m

APP_DEFINES:=
APP_INCLUDES:= -I./examples/ -I./MKL/src
APP_LINKERS:= -L$(BUILD_DIR) -lmkl -framework Cocoa

APP_C_FILES:= ./examples/ex1.c

all: buildLibrary buildApp 

buildLibrary:
	echo "Building Library..."
	mkdir -p $(BUILD_DIR)
	clang $(LIB_DEFINES) $(LIB_INCLUDES) $(LIB_LINKERS) $(LIB_C_FILES) $(LIB_OBJC_FILES) -o $(BUILD_DIR)/lib$(LIB_NAME).dylib

buildApp:
	echo "Building App..."
	clang $(APP_DEFINES) $(APP_INCLUDES) $(APP_LINKERS) $(APP_C_FILES) -o $(BUILD_DIR)/$(APP_NAME)

run:
	echo "Running App..."
	./$(BUILD_DIR)/$(APP_NAME)