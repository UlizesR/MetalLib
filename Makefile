EXE = main
BUILD_DIR = bin

CC = clang
FLAGS = -Wno-nullability-completeness
LINKERS = -framework Cocoa -framework Metal -L$(BUILD_DIR) 
INCLUDES = -I./src
SRC_DIR = src

C_FILES = $(shell find $(SRC_DIR) -name "*.c")
OBJ_C_FILES = $(shell find $(SRC_DIR) -name "*.m")
O_FILES = $(patsubst src/%.c, $(BUILD_DIR)/%.o, $(C_FILES)) $(patsubst src/%.m, $(BUILD_DIR)/%.o, $(OBJ_C_FILES))

MAIN_C_FILE = $(EXE).c

all: compile 

compile: $(C_FILES) $(OBJ_C_FILES) $(MAIN_C_FILE)
	mkdir -p $(BUILD_DIR)
	echo "Building..."
	clang $(FLAGS) $(INCLUDES) $(LINKERS) $^ -o $(BUILD_DIR)/$(EXE)
	echo "Successfully built!"
	clear

run:
	./$(BUILD_DIR)/$(EXE)

clean:
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/$(EXE)