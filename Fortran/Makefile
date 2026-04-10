FC = gfortran
CC = gcc
FFLAGS = -O3
CFLAGS = -O3

OBJ = input_c.o sleep_c.o terminal_module.o types_module.o input_module.o sleep_module.o snake_module.o apple_module.o gui_module.o game_module.o main.o

all: ouroboros

ouroboros: $(OBJ)
	$(FC) $(FFLAGS) -o ouroboros $(OBJ)

input_c.o: input_c.c
	$(CC) $(CFLAGS) -c input_c.c

sleep_c.o: sleep_c.c
	$(CC) $(CFLAGS) -c sleep_c.c

terminal_module.o: terminal_module.f90
	$(FC) $(FFLAGS) -c terminal_module.f90

types_module.o: types_module.f90
	$(FC) $(FFLAGS) -c types_module.f90

input_module.o: input_module.f90 input_c.o
	$(FC) $(FFLAGS) -c input_module.f90

sleep_module.o: sleep_module.f90 sleep_c.o
	$(FC) $(FFLAGS) -c sleep_module.f90

snake_module.o: snake_module.f90 types_module.o
	$(FC) $(FFLAGS) -c snake_module.f90

apple_module.o: apple_module.f90 types_module.o
	$(FC) $(FFLAGS) -c apple_module.f90

gui_module.o: gui_module.f90 types_module.o terminal_module.o
	$(FC) $(FFLAGS) -c gui_module.f90

game_module.o: game_module.f90 types_module.o snake_module.o apple_module.o gui_module.o input_module.o sleep_module.o terminal_module.o
	$(FC) $(FFLAGS) -c game_module.f90

main.o: main.f90 types_module.o game_module.o input_module.o sleep_module.o terminal_module.o
	$(FC) $(FFLAGS) -c main.f90

clean:
	rm -f *.o *.mod ouroboros
