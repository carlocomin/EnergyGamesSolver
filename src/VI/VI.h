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

#ifndef VI 
#define VI

#include "../mpg/mpg.h"
#include "../conf.h"

void VI_compute_energy(MeanPayoffGame *mpg, t_nrg* energy);
void VI_solve_decision(MeanPayoffGame *mpg, bool* decision);

#endif
