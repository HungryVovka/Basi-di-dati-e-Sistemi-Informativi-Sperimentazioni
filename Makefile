# Compiler and compilation flags
CC = gcc
CFLAGS = -std=c99 -Wall -Wextra

# Output binary and source files
TARGET = bin/Rukavishnikov_app.exe
SRCS = main.c utils.c db_engine.c ai_dss.c
OBJS = $(SRCS:.c=.o)

# Default rule
all: create_bin $(TARGET)

create_bin:
	@if not exist bin mkdir bin

# Link object files into final executable
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) -lm

# Compile C source files into object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	cmd /c del /f /q *.o bin\Rukavishnikov_app.exe 2>NUL || exit 0

.PHONY: all clean create_bin

# gcc -std=c99 -Wall -Wextra main.c ai_dss.c db_engine.c utils.c -o Rukavishnikov_app -lm