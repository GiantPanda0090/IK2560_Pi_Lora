CC=g++
CFLAGS=-c -Wall
LIBS=-lwiringPi -lgps -lm

all: lora_test

lora_test: main.o gps_api.o geo.o
	$(CC) main.o  gps_api.o $(LIBS) -o lora_test

main.o: main.c gps_api.c geo.c
	$(CC) $(CFLAGS) main.c gps_api.c geo.c

clean:
	rm *.o lora_test
