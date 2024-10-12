APP_NAME = ex1
BUILD_DIR = ./bin
APP_DIR = $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS

LIB_NAME:= mkl
LIB_DEFINES:= -fvisibility=hidden -fPIC -O2 -Wno-nullability-completeness
LIB_INCLUDES:= -I./MKL/src 
LIB_LINKERS:= -dynamiclib -install_name @rpath/lib$(LIB_NAME).dylib -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore -framework ModelIO

LIB_C_FILES:= $(shell find ./MKL/src -name "*.c")
LIB_OBJC_FILES:= $(shell find ./MKL/src -name "*.m")
LIB_O_FILES:= $(patsubst ./MKL/src/%.c, $(BUILD_DIR)/%.o, $(LIB_C_FILES)) $(patsubst ./MKL/src/%.m, $(BUILD_DIR)/%.o, $(LIB_OBJC_FILES))

APP_DEFINES:= -O2 -Wno-nullability-completeness
APP_INCLUDES:= -I./App/ -I./MKL/src
APP_LINKERS:= -L$(BUILD_DIR) -lmkl -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore -framework ModelIO

APP_C_FILES:= ./App/main.c
APP_O_FILES:= $(patsubst ./App/%.c, $(BUILD_DIR)/%.o, $(APP_C_FILES))

all: buildLib buildApp codesgn 

buildLib: $(LIB_O_FILES)
	echo "Building Library..."
	mkdir -p $(BUILD_DIR)
	clang $(LIB_DEFINES) $(LIB_INCLUDES) $(LIB_LINKERS) $^ -o $(BUILD_DIR)/lib$(LIB_NAME).dylib
	echo "Successfully built library!"
	clear

buildApp: $(APP_O_FILES)
	echo "Building App..."
	mkdir -p $(APP_DIR)
	mkdir -p $(APP_DIR)/../Resources
	clang $(APP_DEFINES) $(APP_INCLUDES) $(APP_LINKERS) $^ -o $(APP_DIR)/$(APP_NAME)
	install_name_tool -add_rpath @executable_path/ $(APP_DIR)/$(APP_NAME)
	cp $(BUILD_DIR)/lib$(LIB_NAME).dylib $(APP_DIR)/
	cp ./MKL/src/Graphics/Shaders/* $(APP_DIR)/../Resources/
	echo "Successfully built app!"
	clear

ENTITLEMENTS_PLIST = $(BUILD_DIR)/entitlements.plist

$(ENTITLEMENTS_PLIST):
	echo '<?xml version="1.0" encoding="UTF-8"?>' > $(ENTITLEMENTS_PLIST)
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $(ENTITLEMENTS_PLIST)
	echo '<plist version="1.0">' >> $(ENTITLEMENTS_PLIST)
	echo '    <dict>' >> $(ENTITLEMENTS_PLIST)
	echo '        <key>com.apple.security.get-task-allow</key>' >> $(ENTITLEMENTS_PLIST)
	echo '        <true/>' >> $(ENTITLEMENTS_PLIST)
	echo '    </dict>' >> $(ENTITLEMENTS_PLIST)
	echo '</plist>' >> $(ENTITLEMENTS_PLIST)

codesgn: $(ENTITLEMENTS_PLIST)
	codesign -s - -v -f --entitlements $(ENTITLEMENTS_PLIST) $(APP_DIR)/$(APP_NAME)

run:
	echo "Running App..."
	./$(APP_DIR)/$(APP_NAME)

clean:
	rm -f $(LIB_O_FILES) $(APP_O_FILES)
	rm -f $(APP_DIR)/$(APP_NAME) $(BUILD_DIR)/lib$(LIB_NAME).dylib

$(BUILD_DIR)/%.o: ./MKL/src/%.c
	mkdir -p $(dir $@)
	clang -c $(LIB_DEFINES) $(LIB_INCLUDES) $< -o $@

$(BUILD_DIR)/%.o: ./MKL/src/%.m
	mkdir -p $(dir $@)
	clang -c $(LIB_DEFINES) $(LIB_INCLUDES) $< -o $@

$(BUILD_DIR)/%.o: ./App/%.c
	mkdir -p $(dir $@)
	clang -c $(APP_DEFINES) $(APP_INCLUDES) $< -o $@