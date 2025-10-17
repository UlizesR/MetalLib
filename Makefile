# Project Configuration
APP_NAME = ex1
BUILD_DIR = ./bin
LIB_NAME = mkl

# Compiler Flags
CC = clang
CFLAGS_COMMON = -Wall -Wextra -Wpedantic -O2 -std=c11
OBJCFLAGS_COMMON = -Wall -Wextra -O2 -fobjc-arc -fno-objc-exceptions

# Library Configuration
LIB_DEFINES = -fvisibility=hidden -fPIC $(CFLAGS_COMMON) -Wno-nullability-completeness
LIB_OBJC_DEFINES = -fvisibility=hidden -fPIC $(OBJCFLAGS_COMMON) -Wno-nullability-completeness
LIB_INCLUDES = -I./MKL/src
LIB_FRAMEWORKS = -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore -framework ModelIO
LIB_LINKERS = -dynamiclib -install_name @rpath/lib$(LIB_NAME).dylib $(LIB_FRAMEWORKS)

# Application Configuration  
APP_DEFINES = $(CFLAGS_COMMON) -Wno-nullability-completeness
APP_INCLUDES = -I./App/ -I./MKL/src
APP_LINKERS = -L$(BUILD_DIR) -lmkl -rpath @executable_path $(LIB_FRAMEWORKS)

# Source Files
LIB_C_FILES = $(shell find ./MKL/src -name "*.c")
LIB_OBJC_FILES = $(shell find ./MKL/src -name "*.m")
LIB_O_FILES = $(patsubst ./MKL/src/%.c, $(BUILD_DIR)/%.o, $(LIB_C_FILES)) \
              $(patsubst ./MKL/src/%.m, $(BUILD_DIR)/%.o, $(LIB_OBJC_FILES))

APP_C_FILES = ./examples/main.c
APP_O_FILES = $(patsubst ./examples/%.c, $(BUILD_DIR)/%.o, $(APP_C_FILES))

# Test programs
TEST_SHADERTOY_FILES = ./examples/test_shadertoy.c
TEST_SHADERTOY_O_FILES = $(patsubst ./examples/%.c, $(BUILD_DIR)/%.o, $(TEST_SHADERTOY_FILES))

TEST_SHAPES_FILES = ./examples/test_shapes.c
TEST_SHAPES_O_FILES = $(patsubst ./examples/%.c, $(BUILD_DIR)/%.o, $(TEST_SHAPES_FILES))

TEST_WAVING_FILES = ./examples/test_waving_cubes.c
TEST_WAVING_O_FILES = $(patsubst ./examples/%.c, $(BUILD_DIR)/%.o, $(TEST_WAVING_FILES))

TEST_OBJ_FILES = ./examples/test_obj_model.c
TEST_OBJ_O_FILES = $(patsubst ./examples/%.c, $(BUILD_DIR)/%.o, $(TEST_OBJ_FILES))

# Targets
.PHONY: all clean run buildLib buildApp shadertoy shapes waving obj

all: buildLib buildApp

# Build ShaderToy test
shadertoy: buildLib $(TEST_SHADERTOY_O_FILES)
	@echo "Building ShaderToy Test..."
	@mkdir -p $(BUILD_DIR)
	$(CC) $(APP_LINKERS) $(TEST_SHADERTOY_O_FILES) -o $(BUILD_DIR)/shadertoy
	@echo "✓ Successfully built ShaderToy test!"

# Build shapes test
shapes: buildLib $(TEST_SHAPES_O_FILES)
	@echo "Building Shapes Test..."
	@mkdir -p $(BUILD_DIR)
	$(CC) $(APP_LINKERS) $(TEST_SHAPES_O_FILES) -o $(BUILD_DIR)/shapes
	@echo "✓ Successfully built shapes test!"

# Build waving cubes test
waving: buildLib $(TEST_WAVING_O_FILES)
	@echo "Building Waving Cubes Test..."
	@mkdir -p $(BUILD_DIR)
	$(CC) $(APP_LINKERS) $(TEST_WAVING_O_FILES) -o $(BUILD_DIR)/waving
	@echo "✓ Successfully built waving cubes test!"

# Build OBJ model viewer
obj: buildLib $(TEST_OBJ_O_FILES)
	@echo "Building OBJ Model Viewer..."
	@mkdir -p $(BUILD_DIR)
	$(CC) $(APP_LINKERS) $(TEST_OBJ_O_FILES) -o $(BUILD_DIR)/obj_viewer
	@echo "✓ Successfully built OBJ model viewer!"

buildLib: $(LIB_O_FILES)
	@echo "Building Library..."
	@mkdir -p $(BUILD_DIR)
	$(CC) $(LIB_LINKERS) $^ -o $(BUILD_DIR)/lib$(LIB_NAME).dylib
	@echo "✓ Successfully built library!"

buildApp: buildLib $(APP_O_FILES)
	@echo "Building Executable..."
	@mkdir -p $(BUILD_DIR)
	$(CC) $(APP_LINKERS) $(APP_O_FILES) -o $(BUILD_DIR)/$(APP_NAME)
	@echo "✓ Successfully built executable!"

run:
	@echo "Running $(APP_NAME)..."
	@cd $(BUILD_DIR) && ./$(APP_NAME)

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@echo "✓ Clean complete!"

# Pattern rules for compilation
$(BUILD_DIR)/%.o: ./MKL/src/%.c
	@mkdir -p $(dir $@)
	@echo "Compiling C: $<"
	@$(CC) -c $(LIB_DEFINES) $(LIB_INCLUDES) $< -o $@

$(BUILD_DIR)/%.o: ./MKL/src/%.m
	@mkdir -p $(dir $@)
	@echo "Compiling ObjC: $<"
	@$(CC) -c $(LIB_OBJC_DEFINES) $(LIB_INCLUDES) $< -o $@

$(BUILD_DIR)/%.o: ./examples/%.c
	@mkdir -p $(dir $@)
	@echo "Compiling Example: $<"
	@$(CC) -c $(APP_DEFINES) $(APP_INCLUDES) $< -o $@

# Dependency tracking
-include $(LIB_O_FILES:.o=.d)
-include $(APP_O_FILES:.o=.d)
