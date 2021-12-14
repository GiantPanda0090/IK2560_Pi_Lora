CC=g++
CFLAGS=-c -Wall
LIBS=-lwiringPi -lgps -lm

all: lora_test

lora_test: main.o gps_api.o
	$(CC) main.o  gps_api.o $(LIBS) -o lora_test

main.o: main.c gps_api.c
	$(CC) $(CFLAGS) main.c gps_api.c

clean:
	rm *.o lora_test
