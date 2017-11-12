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

/* 
    This code is an implementation of the Value Iteration Algorithm for Mean Payoff Energy Games 
     see [Brim2011]: 
       L. Brim et. al,  Journal Formal Methods in System Design, Volume 38 Issue 2, April 2011, Pages 97-118 
                        Kluwer Academic Publishers Hingham, MA, USA 
*/

#include <iostream>
#include <list>
#include <utility>
#include <climits>
#include <assert.h>
#include "math.h"
#include "VI.h"

using namespace std;

unsigned long circle_op(MeanPayoffGame *mpg, long a, long b);
void lift_op(MeanPayoffGame *mpg, t_nrg* e, t_idx v);
list<pair<unsigned long, long> >* compute_pre_arcs(MeanPayoffGame *mpg);
long get_count(MeanPayoffGame *mpg, t_nrg* e, t_idx v);

// compute decision boolean vector
void VI_solve_decision(MeanPayoffGame *mpg, bool *decision){
	t_idx size = mpg->get_n_0() + mpg->get_n_1();
	t_nrg energy[size]; 
	VI_compute_energy(mpg, energy);
	for(t_idx u=0; u < size; u++){
		if(energy[u]==ULONG_MAX) decision[u]=false;
		else decision[u]=true;
	}
}

// computes a pre-arcs list
list<pair<t_idx, t_weight> >* compute_pre_arcs(MeanPayoffGame *mpg){
	t_idx size = mpg->get_n_0() + mpg->get_n_1();
	list<pair<t_idx, t_weight> >* pre_arcs = new list<pair<t_idx, t_weight> >[size];
	for(t_idx u=0; u < size; u++){
		list<t_w_arc>* arc_list = mpg->get_arcs(u);
		list<t_w_arc>::iterator it = arc_list->begin();
		for(it; it != arc_list->end(); it++){
			t_w_arc arc = *it;
			t_idx head_idx = arc.head_idx;
			t_weight weight = arc.weight;
			pair<t_idx, t_weight> p(u, weight);
			pre_arcs[head_idx].push_front(p);
		}
	}
	return pre_arcs;
}

// computes the circle-minus operator, see [Brim2011], we assumee ULONG_MAX=\top
t_nrg circle_op(MeanPayoffGame *mpg, long a, long b){
	if(a == ULONG_MAX || (a>b && a - b > mpg->get_Top())) return ULONG_MAX;
	return a>b ? a-b : 0;
}

// computes updated value for the count(f,v) function
// pre-condition: u is a Max node
long get_count(MeanPayoffGame *mpg, t_nrg* energy, t_idx u){
	if(u < mpg->get_n_0()) throw "u is a Min node, count() is undefined";
	unsigned long count = 0;
	list<t_w_arc>* arc_list = mpg->get_arcs(u);
	list<t_w_arc>::iterator it = arc_list->begin();
	for(it; it!=arc_list->end(); it++){
		t_w_arc arc = *it;
		t_idx v = arc.head_idx;
		t_weight weight = arc.weight;
		t_nrg rhs = circle_op(mpg, energy[v], weight);
		if(energy[u] >= rhs) count++;
	}
	return count;
}

// computes the lift operator delta(f,v), see [Brim2011]
void lift_op(MeanPayoffGame *mpg, t_nrg* energy, t_idx u){
	t_idx n_0 = mpg->get_n_0();
	t_nrg lifted_val = u<n_0 ? 0 : ULONG_MAX;
	list<t_w_arc>* arc_list = mpg->get_arcs(u);
	list<t_w_arc>::iterator it = arc_list->begin();
	for(it; it!=arc_list->end(); it++){
		t_w_arc arc = *it;
		t_idx v = arc.head_idx;
		t_weight weight = arc.weight;
		t_nrg candidate = circle_op(mpg, energy[v], weight);
		if((u < n_0 && candidate > lifted_val) || 
			(u >= n_0 && candidate < lifted_val))
			lifted_val = candidate;
	}
	if(lifted_val > mpg->get_Top()) energy[u] = ULONG_MAX;
	else energy[u] = lifted_val;
}

// Value Iteration Algorithm for Energy Games, main loop, see [Brim2011].
void VI_compute_energy(MeanPayoffGame *mpg, t_nrg *energy){
	t_idx n_0 = mpg->get_n_0();
	t_idx n_1 = mpg->get_n_1();
	t_idx size = n_0 + n_1;
	fill_n(energy, size, 0);
	long* count = new long[size];
	// compute pre arc lists
	list<pair<t_idx, t_weight> >* pre_arcs = compute_pre_arcs(mpg);
	// init list L
	list<t_idx> L;
	bool contains[size];
	for(t_idx u=0; u < size; u++){
		list<t_w_arc>* arc_list = mpg->get_arcs(u);
		list<t_w_arc>::iterator it = arc_list->begin();
		bool insert = u < n_0 ? false : true;
		for(it; it!=arc_list->end(); it++){
			t_w_arc arc = *it;
			if(u < n_0 && arc.weight < 0){ 
				insert = true;
				break;
			}else if(u >= n_0 && arc.weight >= 0){
				insert = false;
				break;
			}
		}
		if(insert){
			L.push_front(u); // LIFO 
		//	L.push_back(u); //FIFO
			contains[u]=true;
		}else contains[u]=false;
	}
	// init energy and counter
	for(t_idx u=0; u < size; u++) energy[u] = 0;
	for(t_idx u=0; u < size; u++){
		count[u] = 0;
		if(u >= n_0 && !contains[u]) count[u] = get_count(mpg, energy, u);	
	}

	//iterate until L goes empty
	while(!L.empty()){
		t_idx v = L.front(); // LIFO/FIFO
		L.pop_front(); contains[v]=false; // LIFO/FIFO
		t_nrg old = energy[v];
		lift_op(mpg, energy, v);
		//if(energy[v]==ULONG_MAX) break; // STOP CRITERION at first Min Node
		if(v>=n_0) count[v] = get_count(mpg, energy, v);
		list<pair<t_idx, t_weight> >::iterator it = pre_arcs[v].begin();
		for(it; it!=pre_arcs[v].end(); it++){
			pair<t_idx, t_weight> p = *it;
			t_idx tail = p.first;
			t_weight weight = p.second;
			if(energy[tail] < circle_op(mpg, energy[v], weight)){
				if(tail < n_0 && contains[tail]==false){ // check Min
					L.push_front(tail); // add Min node LIFO
					//L.push_back(tail); // FIFO
					contains[tail]=true;
				}else if(tail >= n_0){ // check Max
					if(energy[tail] >= circle_op(mpg, old, weight)) 
						count[tail]--;
					if(count[tail]<=0 && contains[tail]==false){
						L.push_front(tail); // LIFO
						//L.push_back(tail); // FIFO
						contains[tail]=true;
					}
				}
			}
		}
	}
	delete [] pre_arcs;
	delete [] count;  
}
