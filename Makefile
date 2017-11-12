###########################################			  
##  Simple Makefile for 2017 KASI Code   ##
##  Author: Carlo Comin	  		 ##
###########################################

SHELL = /bin/sh
CC = g++ -g -O -std=c++0x 

objects = obj/main.o obj/mpg.o obj/VI.o obj/kasi.o 
objectss = obj/mpg.o obj/pg2mpg.o
binaryname = bin/main
binarynamee = bin/pg2mpg

all: maketest
maketest : main.o mpg.o VI.o kasi.o pg2mpg.o 
	mkdir -p bin
	$(CC) -o $(binaryname) $(objects)
	$(CC) -o $(binarynamee) $(objectss)
	rm -rf obj 	
main.o :  
	mkdir -p obj
	$(CC) -o obj/main.o -c src/main.cc
mpg.o :
	mkdir -p obj
	$(CC) -o obj/mpg.o -c src/mpg/mpg.cc
VI.o:
	mkdir -p obj
	$(CC) -o obj/VI.o -c src/VI/VI.cc
kasi.o :
	mkdir -p obj
	$(CC) -o obj/kasi.o -c src/kasi/kasi.cc
pg2mpg.o :
	mkdir -p obj
	$(CC) -o obj/pg2mpg.o -c src/mpg/pg2mpg.cc
clean : 
	rm -rf bin obj
