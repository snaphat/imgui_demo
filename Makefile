TARGET_EXEC ?= yobemag

BUILD_DIR ?= ./build
SRC_DIRS ?= ./src/imgui ./src/imgui/examples/libs/gl3w/GL

SRCS := main.cpp $(shell ls ./src/imgui/*.cpp) \
	./src/imgui/backends/imgui_impl_sdl.cpp \
	./src/imgui/backends/imgui_impl_opengl3.cpp \
	./src/imgui/examples/libs/gl3w/GL/gl3w.c
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d) include include/imgui
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS ?= $(INC_FLAGS) `sdl2-config --cflags` -MMD -MP -Wall -std=c++2a #-g -fsanitize=address -fsanitize=leak -fsanitize=undefined -fsanitize=pointer-compare -fsanitize=pointer-subtract -fstack-protector-all
LDFLAGS := `sdl2-config --libs` -lstdc++ -lSDL2 -ldl -lGL -lm #-fsanitize=address -fsanitize=leak -fsanitize=undefined -fsanitize=pointer-compare -fsanitize=pointer-subtract -fstack-protector-all


$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

# assembly
$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean

clean:
	$(RM) -r $(BUILD_DIR)

-include $(DEPS)

MKDIR_P ?= mkdir -p
