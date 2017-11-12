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

#ifndef MPG 
#define MPG 

#include <list>
#include "../conf.h"

#define MAX 1 // player-1 is MAX
#define MIN 0 // player-0 is MIN
#define PRE_ARCS 0 // pre arcs 
#define POST_ARCS 1 // post arcs

typedef unsigned long t_nrg, t_idx;
typedef long t_weight;


/* MPG weighted arc data type definition */
struct t_w_arc{
	unsigned long arc_idx, tail_idx, head_idx;
	long weight;

	bool operator==(const t_w_arc& rhs) const{
        	return this->arc_idx == rhs.arc_idx && 
			this->tail_idx == rhs.tail_idx && 
			this->head_idx == rhs.head_idx && 
			this->weight == rhs.weight; 
    	}
};

struct t_rational{
	long long num;
	long long denom;
};

struct t_graph{
	unsigned long n;
	std::list<t_w_arc>* arcs;
};

/* MPG data type definition */
class MeanPayoffGame{
	private:
	unsigned long n_0; // number of V_0 black nodes
	unsigned long n_1; // number of V_1 white nodes
	unsigned long e; // number of arcs
	// we assume that Black=MIN nodes are numbered 0 to n_0-1
	// and that White=MAX nodes are numbered n_0 to n_0 + n_1 - 1
	std::list<t_w_arc>* arcs; // array of post adjacency lists  
		
	void load(const char* f);
	void init_arcs();
	void delete_arcs();

	public:
	// constructor/destructor
	MeanPayoffGame(const char* f);
	MeanPayoffGame(unsigned long n_0, unsigned long n_1);
	~MeanPayoffGame();

	//internal state methods
	std::list<t_w_arc>* get_arcs(unsigned long t);
	void set_arcs(unsigned long u, std::list<t_w_arc>* l);
	void push_arc(unsigned long t, t_w_arc e);
	unsigned long get_n_0();
	unsigned long get_n_1();
	unsigned long get_e();
	void remove_arc(unsigned long u);
	unsigned long get_Top();	
	bool is_well_defined();
	void print();	
};

class MPGProj{
	public:
	MPGProj(MeanPayoffGame *mpg);
	~MPGProj();
	void init_arbitrary(MeanPayoffGame *mpg, bool player);
	void init_reverse(MPGProj *pi);
	std::list<t_w_arc>* get_arcs(unsigned long u);
	void set_arc(unsigned long u, t_w_arc arc);

	private:
	unsigned long size;
	std::list<t_w_arc>* arcs; // array of list<t_w_arcs>
};

#endif
