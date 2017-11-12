/*  
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/**********************************************
**    Source Code - KASI Algorithm           **
**    Author: Carlo Comin, 8 November 2017   **
***********************************************/

#include <iostream>
#include <sys/time.h>
#include <math.h>
#include "conf.h"
#include "mpg/mpg.h"
#include "VI/VI.h"
#include "kasi/kasi.h"

using namespace std;

//const char* OUTPUT_FILE = "data/output.dat";
//const bool VERBOSE_MODE = false;
const string INPUT_FILE_MPG = "data/pg_mpg.dat";
const unsigned int NUM_TESTS = 5;
ofstream o_stream;

/*********************************************
* Prototypes
********************************************/
void test();
double start_KASI(MeanPayoffGame* mpg);
timespec time_diff(timespec start, timespec end);

/********************************************
** KASI Algorithm Implementation main()
*******************************************/
int main(int argc, char** argv){
	//o_stream.open(OUTPUT_FILE, ofstream::app);
	test();
	//o_stream.close();
	return 0;
} 

/*****************
** default test
*****************/
void print_energy(unsigned long *energy, MeanPayoffGame *mpg){
	unsigned long size = mpg->get_n_0() + mpg->get_n_1();
	cout << "ENERGY e[v]:" << endl;
	for(unsigned long v=0; v<size; v++){
		string e_v = (energy[v] == ULONG_MAX) ? "T" : to_string(energy[v]);
		cout << "e[" << v << "]=" << e_v << "; ";
	} cout << endl;
}

void assert_energies_are_equal(unsigned long *energy, unsigned long *energy2, unsigned long size){
	for(unsigned long u=0; u<size; u++){
		if(energy[u]!=energy2[u]){
			cout << "FATAL ERROR!!" << endl;
			throw "ERROR";		
		}
	}
	cout << "OK! KASI and VI compute the same set of energies!"  << endl;
}

double start_algorithms(MeanPayoffGame *mpg){
	uint64_t diff_sec, diff_nsec;
	struct timespec start, end;
	pair<double, string> p; 
	clock_gettime(CLOCK_MONOTONIC, &start);	
	cout << "invoking KASI procedure..." << endl;
	unsigned long size = mpg->get_n_0() + mpg->get_n_1();
	unsigned long energy[size];	
	KASI_lowerWeakUpperBound(mpg, mpg->get_Top()+1, energy);
	unsigned long energy2[size];
	VI_compute_energy(mpg, energy2);
	assert_energies_are_equal(energy, energy2, size);
	print_energy(energy, mpg);
	clock_gettime(CLOCK_MONOTONIC, &end); /* mark the end time */
	diff_sec = time_diff(start, end).tv_sec;
	diff_nsec = time_diff(start, end).tv_nsec;
	double time = ((double) diff_sec + (diff_nsec / 1000000000.0));
	return time;
}
/*****************************************************************************************/

/***********************
** test procedure 
**********************/
/*
 TEST : 
  1. load an MPG G
  2. compute G's energies with KASI algorithm
*/
void test(){
	MeanPayoffGame* mpg = new MeanPayoffGame(INPUT_FILE_MPG.c_str());
	double tot_time=0, tot_time_squared=0, avg_time=0, std_dev=0, max_time=0, min_time=1000000;
	double time;
	for(unsigned int j=0; j < NUM_TESTS; j++){
		time = start_algorithms(mpg);
		cout << "instance #" << j << " : " << time << endl;
		tot_time += time;
		tot_time_squared += time*time;	
		if(time > max_time) max_time = time;
		if(time < min_time) min_time = time;
	}
	avg_time = tot_time / NUM_TESTS;	
	std_dev = sqrt((tot_time_squared / NUM_TESTS) - avg_time*avg_time);
	double semi_disp_max = (max_time - min_time) / 2;
	double err_perc = (semi_disp_max / avg_time)*100;
	cout << "max: " << max_time << "sec" << endl;
	cout << "min: " << min_time << "sec" << endl;
	cout << "avg: " << avg_time << "sec" << endl;
	cout << "std_dev: " << std_dev << "sec" << endl;
	cout << "semi_disp_max: " << semi_disp_max << " err_perc: " << err_perc << endl;
	delete mpg;
}

timespec time_diff(timespec start, timespec end){
	timespec temp;
	if ((end.tv_nsec-start.tv_nsec)<0) {
		temp.tv_sec = end.tv_sec-start.tv_sec-1; // borrow 1 sec
		temp.tv_nsec = 1000000000L+end.tv_nsec-start.tv_nsec;
	} else {
		temp.tv_sec = end.tv_sec-start.tv_sec;
		temp.tv_nsec = end.tv_nsec-start.tv_nsec;
	}
	return temp;
}

