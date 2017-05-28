CC=gcc
CFLAGS=-Wall -Wextra
APPNAME=bitbash

SRCS=$(shell ls *.c)
OBJS=$(patsubst %.c,%.o,$(SRCS))

all: $(APPNAME)

$(APPNAME): $(OBJS)
	$(CC) $(CFLAGS) -o $(APPNAME) $(OBJS)

clean:
	rm $(APPNAME) $(OBJS)
