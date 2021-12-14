# dragino lora testing
# Single lora testing app

CC=g++
CFLAGS=-c -Wall
LIBS=-lwiringPi -lgps

all: dragino_lora_app

dragino_lora_app: main.o gps_api.o
	$(CC) main.o  gps_api.o $(LIBS) -o lora_workbench

main.o: main.c gps_api.c
	$(CC) $(CFLAGS) main.c gps_api.c

clean:
	rm *.o lora_workbench
