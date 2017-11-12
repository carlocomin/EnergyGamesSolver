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

#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <assert.h>
#include <algorithm>
#include "math.h"
#include "mpg.h"

using namespace std;

/*Constructor*/
MeanPayoffGame::MeanPayoffGame(const char* filename){
	load(filename);
	assert(is_well_defined());
}

/*Another Constructor*/
MeanPayoffGame::MeanPayoffGame(unsigned long n_0, unsigned long n_1){
	assert(n_0 + n_1 > 0);
	this->n_0 = n_0; // black nodes
	this->n_1 = n_1; // black nodes
	init_arcs();
}

/*Destructor*/
MeanPayoffGame::~MeanPayoffGame(){
//	if(VERBOSE_MODE) o_stream << "Destroying MPG... ";
	delete_arcs();
//	if(VERBOSE_MODE) o_stream << "done!"<< endl;
}

/* returns n_0 */
unsigned long MeanPayoffGame::get_n_0(){
	return this->n_0;
}

/* returns n_1 */
unsigned long MeanPayoffGame::get_n_1(){
	return this->n_1;
}

/* returns e */
unsigned long MeanPayoffGame::get_e(){
	return this->e;
}

/* computes and returns the max abs value of arc weights */
unsigned long MeanPayoffGame::get_Top(){
	unsigned long Top=0;
	unsigned long size = this->get_n_0() + this->get_n_1();
	for(unsigned long u=0; u < size; u++){
		list<t_w_arc>* arcs = this->get_arcs(u);
		list<t_w_arc>::iterator it = arcs->begin();
		long max_v = 0;
		for(it; it!=arcs->end(); it++){
			t_w_arc arc = *it;
			if(arc.weight<0 && -arc.weight > max_v) max_v = -arc.weight;
		}
		Top += max_v;
	}
	return Top;
}

/* returns arc list for tail index @tail_idx */
list<t_w_arc>* MeanPayoffGame::get_arcs(unsigned long tail_idx){
	return &this->arcs[tail_idx];
}

/* sets arcs @arc_list for tail @u */
void MeanPayoffGame::set_arcs(unsigned long u, list<t_w_arc>* arc_list){
	assert(arc_list->size()>0);
	this->e -= this->arcs[u].size();
	this->arcs[u] = *arc_list;
	this->e += this->arcs[u].size();
}

/**
* Initializes @this MPG by loading the input file @filename
* see "dat/mpg.dat" for an MPG file format example.
**/
void MeanPayoffGame::load(const char* filename){
	/*
	* init_steps:
	*	0: read number of vertices
	*	1: read number of arcs 
	* 	2: read arcs  
	*/
	long init_step = 0;
	/**/
//	if(VERBOSE_MODE) o_stream << endl << "Verbose mode on"<<endl; else o_stream << endl <<"Verbose mode off"<<endl;
//	if(VERBOSE_MODE) o_stream << "Loading Mean Payoff Game from input file: " << filename << "..." << endl;
	ifstream input(filename);
	string line;
	unsigned long arc_counter = 0;
	if(input.is_open()){
		unsigned long long num_line = 0;
		long num_white, num_black, num_arcs;
		while(getline(input, line)){
			num_line++;
			if(line.compare(0,1,"#")==0){ // skip comments
//				if(VERBOSE_MODE) o_stream << "   ... comment found at line #" << num_line << endl;
				continue;
			}
			istringstream iss(line);
			switch(init_step){
				case 0:
//					if(VERBOSE_MODE) o_stream 
//						<< "   ... reading vertex number at line #" << num_line;
					iss >> num_black >> num_white;
					assert(num_black >= 0);
					assert(num_white >= 0);
					this->n_0 = num_black;
					this->n_1 = num_white;
					init_arcs();
					init_step++;
//					if(VERBOSE_MODE) o_stream << ": black vertices " << num_black 
//							<< "; white vertices " << num_white << endl;
				break;
				case 1:
//					if(VERBOSE_MODE) o_stream 
//						<< "   ... reading arcs number at line #" << num_line;
					iss >> num_arcs;
					assert(num_arcs >= 0);
					init_step++;
//					if(VERBOSE_MODE) o_stream << ": number of arcs " << num_arcs << endl;
				break;
				case 2:
//					if(VERBOSE_MODE) o_stream << "   ... reading arc data at line #" << num_line;
					assert(arc_counter < num_arcs);
					long tail, head;
					long weight;
					iss >> tail >> head >> weight; // assume indexes are absolute 
					assert(tail >= 0 && tail < this->n_0 + this->n_1);
					assert(head >= 0 && head < this->n_0 + this->n_1);
					//assert(head != tail); // we assume no self loop  
					t_w_arc new_arc;
					new_arc.arc_idx = arc_counter;
					new_arc.tail_idx = tail;
					new_arc.head_idx = head;
					new_arc.weight = weight;
					push_arc(tail, new_arc);
					arc_counter++;
//					if(VERBOSE_MODE) o_stream << ": tail " << tail 
//					     << " head " << head 
//					     <<" weight " << weight << endl;
				break;
			}
		}
		input.close();
	}else throw "cannot open input file";
//	if(VERBOSE_MODE) o_stream << "... Mean Payoff Game load completed!" << endl<<endl;
}

/* initializes arcs array list */
void MeanPayoffGame::init_arcs(){
	unsigned long size = this->n_0 + this->n_1;
	this->arcs = new list<t_w_arc>[size];
	this->e=0;
}

/* pushes #arc into tail with index tail_idx*/
void MeanPayoffGame::push_arc(unsigned long tail_idx, t_w_arc arc){
	assert(tail_idx < this->n_0 + this->n_1);
	get_arcs(tail_idx)->push_back(arc);
	this->e++;
}

/* deletes arcs from heap memory*/
void MeanPayoffGame::delete_arcs(){
	delete [] this->arcs;
}

/* checks whether @this is not empty and 
every vertex has at least one outgoing neighbour */
bool MeanPayoffGame::is_well_defined(){
	if(this->n_0 + this->n_1 == 0) return false; // do not consider empty games
	for(unsigned long i=0; i < this->n_0 + this->n_1; i++)
		if(get_arcs(i)->empty()) return false;
	return true; 	
}

/* decrements this->e */
void MeanPayoffGame::remove_arc(unsigned long u){
	get_arcs(u)->pop_front();
	this->e--;
}

/* prints to output */
void MeanPayoffGame::print(){
	o_stream << "## Mean Payoff Game definition: "<< endl;
	o_stream << this->n_0 << " " << this->n_1 << endl;
	o_stream << this->e << endl;
	for(unsigned long i=0; i < this->n_0 + this->n_1; i++){
		list<t_w_arc>* arc_list = get_arcs(i);
		list<t_w_arc>::iterator it = arc_list->begin();
		for (it; it != arc_list->end(); it++){
			t_w_arc arc = *it;
			o_stream << i << " " << arc.head_idx << " " << arc.weight << endl;
		}
	}	
	o_stream << "## End of MPG definition." << endl;
}

bool rational_equals(t_rational x, t_rational y){
	return x.num*y.denom == x.denom*y.num;
}

//Initialize an arbitrary strategy for Player-"pl" in MPG "mpg" 
MPGProj::MPGProj(MeanPayoffGame *mpg){
	this->size = mpg->get_n_0() + mpg->get_n_1();	
	this->arcs = new list<t_w_arc>[size];
}

void MPGProj::init_arbitrary(MeanPayoffGame *mpg, bool player){ 
	if(player){ // Max Strategy
		for(unsigned long u=0; u < this->size; u++){
			list<t_w_arc>* _arcs = mpg->get_arcs(u);
			if(u < mpg->get_n_0())
				this->arcs[u] = *_arcs;	
			else{
				t_w_arc arc = _arcs->front();
				this->arcs[u] = list<t_w_arc>(1,arc);
			}
		}
	}else{ // Min Strategy
		for(unsigned long u=0; u < this->size; u++){
			list<t_w_arc>* _arcs = mpg->get_arcs(u);
			if(u >= mpg->get_n_0())
				this->arcs[u] = *_arcs;	
			else{
				t_w_arc arc = _arcs->front();
				this->arcs[u] = list<t_w_arc>(1,arc);
			}
		}
	}
}

void MPGProj::init_reverse(MPGProj *pi){
	for(unsigned long u=0; u < this->size; u++){
		list<t_w_arc>* arcs_pi = pi->get_arcs(u); // u is tail
		list<t_w_arc>::iterator it = arcs_pi->begin();
		for(it; it!=arcs_pi->end(); it++){
			t_w_arc c_arc = *it;
			list<t_w_arc>* in_head_arcs = this->get_arcs(c_arc.head_idx);
			in_head_arcs->push_front(c_arc);
		}
	}
}

MPGProj::~MPGProj(){
	delete [] this->arcs;
}

list<t_w_arc>* MPGProj::get_arcs(unsigned long u){
	return &this->arcs[u];
}

void MPGProj::set_arc(unsigned long u, t_w_arc arc){
	this->arcs[u] = list<t_w_arc>(1,arc);
}
