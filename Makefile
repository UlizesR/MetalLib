# Variables
CC = clang
CFLAGS = -framework Cocoa -framework Metal -ObjC
TARGET = main
OBJS = *.c *.m

# Default rule
all: $(TARGET)

# Rule to build the target
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET)

# Rule to clean the build
clean:
	rm -f $(TARGET)
