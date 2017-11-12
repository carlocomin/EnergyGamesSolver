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
#include <queue>
#include <vector>    
#include <functional> 
#include "string.h"
#include "stdlib.h"
#include "math.h"
#include "../conf.h"
#include "../mpg/mpg.h"
#include "../kasi/kasi.h"

using namespace std;

typedef unsigned long t_key;

class rev_paircomparison{
	public:
  	bool operator() (const pair<t_idx, t_key>& lhs, const pair<t_idx, t_key>& rhs){
		return lhs.second > rhs.second;	
  	}
};

void evaluateStrategy(MeanPayoffGame *mpg, t_nrg B, MPGProj* pi, MPGProj* rev_pi, t_nrg* energy, bool *Bz, bool *S);
void KASI_Dijkstra(MeanPayoffGame *mpg, t_nrg B, MPGProj* pi, t_nrg *energy, bool* Bz, bool *S);
t_nrg circle_op(t_nrg Top, t_nrg energy, t_weight w);

void refresh_revprj(MPGProj *rev_pi, t_w_arc old_arc, t_w_arc new_arc){
	list<t_w_arc>* old_head_inarcs = rev_pi->get_arcs(old_arc.head_idx);
	old_head_inarcs->remove(old_arc);
	list<t_w_arc>* new_head_inarcs = rev_pi->get_arcs(new_arc.head_idx);
	new_head_inarcs->push_front(new_arc);
}

bool positive_Bz_Max(MeanPayoffGame *mpg, t_idx v, MPGProj *pi, t_nrg* energy){	
	t_idx size = mpg->get_n_0() + mpg->get_n_1();
	if(v < mpg->get_n_0()){	// u is Min's node 
		t_w_arc arc = pi->get_arcs(v)->front();
		t_idx u = arc.head_idx;
		if(energy[v] < circle_op(mpg->get_Top(), energy[u], arc.weight))	
			return false;
		else return true;
	}else{ // u is Max's node 
		list<t_w_arc>* arcs = mpg->get_arcs(v);	
		list<t_w_arc>::iterator it = arcs->begin();
		for(it; it!=arcs->end(); it++){
			t_w_arc arc = *it;
			t_idx u = arc.head_idx;
			if(energy[v] >= circle_op(mpg->get_Top(),energy[u],arc.weight))	
				return true;
		}
		return false;
	}
}

bool update_Bz(MeanPayoffGame *mpg, MPGProj *pi, t_nrg* energy, bool* Bz){
	t_idx size = mpg->get_n_0() + mpg->get_n_1();
	bool change = false;
	for(t_idx v=0; v < size; v++)
		if(Bz[v] && (energy[v] > 0 || !positive_Bz_Max(mpg, v, pi, energy))){
			Bz[v]=false;	
			change=true;
		}
	return change; // no change
}

void KASI_lowerWeakUpperBound(MeanPayoffGame *mpg, t_nrg B, t_nrg *energy){
	MPGProj pi = MPGProj(mpg);
	pi.init_arbitrary(mpg, MIN);
	MPGProj rev_pi = MPGProj(mpg);
	rev_pi.init_reverse(&pi);
	t_idx size = mpg->get_n_0() + mpg->get_n_1();
	fill_n(energy, size, 0);
	bool Bz[size];
	fill_n(Bz, size, true);
	update_Bz(mpg, &pi, energy, Bz);
	bool S[size];
	fill_n(S, size, false);
	bool improvement = true; 
	while(improvement){
		evaluateStrategy(mpg, B, &pi, &rev_pi, energy, Bz, S);
		improvement = false;		
		for(t_idx v=0; v < mpg->get_n_0(); v++){ // O(m)
			if(energy[v] < ULONG_MAX){ // v is the tail
				list<t_w_arc> *arcs = mpg->get_arcs(v);
				list<t_w_arc>::iterator it = arcs->begin();
				for(it; it!=arcs->end();it++){
					t_w_arc	arc = *it;
					t_idx u = arc.head_idx;
					if(energy[v] < circle_op(mpg->get_Top(),energy[u],arc.weight)){
						t_w_arc old_arc = pi.get_arcs(v)->front();
						pi.set_arc(v,arc);
						refresh_revprj(&rev_pi, old_arc, arc);
						improvement = true;	
					}
				} 
			}
		}
	}
}

void evaluateStrategy(MeanPayoffGame *mpg, t_nrg B, MPGProj* pi, MPGProj* rev_pi, t_nrg* energy, bool *Bz, bool *S){	
	bool Bz_changing = true;
	while(Bz_changing){
		KASI_Dijkstra(mpg, B, rev_pi, energy, Bz, S);
		Bz_changing = update_Bz(mpg, pi, energy, Bz);
	}
}

void KASI_Dijkstra(MeanPayoffGame *mpg, t_nrg B, MPGProj* rev_pi, t_nrg *energy, bool* Bz, bool *S){
	priority_queue<pair<t_idx, t_key>, 
		std::vector<pair<t_idx, t_key> >, rev_paircomparison> Q; // min priority queue
	t_idx size = mpg->get_n_0() + mpg->get_n_1();
	bool enqueued[size];
	fill_n(enqueued, size, false);
	t_key key[size];
	fill_n(key, size, ULONG_MAX);
	for(t_idx v=0; v<size; v++){
		if(energy[v]<ULONG_MAX)
			S[v] = true;
		if(Bz[v]){
			key[v] = 0;
			pair<t_idx, t_key> v_key(v, key[v]);
			Q.push(v_key);
			enqueued[v] = true;
		}
	}
	while(!Q.empty()){
		pair<t_idx, t_key> top_u_key = Q.top();	
		t_idx u = top_u_key.first;
		Q.pop(); enqueued[u] = false;
		list<t_w_arc> *arcs = rev_pi->get_arcs(u);
		list<t_w_arc>::iterator it = arcs->begin();
		for(it; it!=arcs->end(); it++){
			t_w_arc arc = *it;
			t_idx v = arc.tail_idx;
			if(S[v] && !Bz[v]){
				t_key tmp = key[u] - arc.weight - energy[v] + energy[u];
				if(tmp<key[v]){
					key[v] = tmp;	
					if(!enqueued[v]){
						pair<t_idx, t_key> v_key(v, key[v]);	
						Q.push(v_key);
						enqueued[v]=true;
					}
				}
			}
		}
	}
	for(t_idx v=0; v<size; v++){
		if(S[v] && key[v]<ULONG_MAX && (energy[v]+key[v])<=B)
			energy[v] += key[v];
		else{
			energy[v] = ULONG_MAX;
			S[v] = false;
		}
	}
}

/* circle_op() computes the circle-minus operator, see [Brim2011], we assumee ULONG_MAX=\top */
t_nrg circle_op(t_nrg Top, t_nrg energy, t_weight w){
	t_weight abs_w = labs(w);
	if(energy == ULONG_MAX || (w<0 && energy+abs_w>Top) 
			|| (w>=0 && energy > abs_w && energy-abs_w > Top)) 
		return ULONG_MAX;
	if(w<0) return energy+abs_w;
	if(w>=0 && energy > abs_w) return energy-abs_w;
	else return 0;
}
