%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Graph Library for Metapost (c) 2010 - 2011
%
% Authors: Oliver Friedmann, University of Munich
%          Thomas D. Hansen, University of Aarhus
%
% Version: 06-19-11
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Interface
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Coordinates

% procedure coords_set_transform(x_transform: pair, y_transform: pair);
% procedure coords_reset_transform;
% procedure coords_enter_base(new_base: pair);
% procedure coords_enter_relative_base(new_relative_base: pair);
% procedure coords_leave_base;
% function  coords_register(x: numeric, y: numeric): coord_id;
% function  coords_get_abs(id: coord_id): pair;
% function  coords_get_rel(id: coord_id): pair;


% Groups

% const     group_root;
% procedure group_add_annot(id: group_id, str: string, col: color, angl: number);
% procedure group_enter(id: group_id);
% procedure group_leave;
% procedure group_set_style(id: group_id, style: path_style);
% function  group_add(parent: group_id): group_id;
% function  group_get_coord_ll: (coordx, coordy);
% function  group_get_coord_ur: (coordx, coordy);
% procedure group_separator_add(ida: group_id, idb: group_id, overlap: numeric);
% procedure group_include_coord(id: group_id, coordid: coord_id);
% const     group_current;



% Node Styles

% function node_style_add(prim: primitive_style, diameter: pair): node_style_id;


% Nodes

% function  node_register(coord: coord_id, style: node_style_id): node_id;
% function  node_get_coord(node: node_id): coord_id;
% procedure node_set_style(node: node_id, style: node_style_id);
% procedure node_set_visible(node: node_id, visibile: boolean);
% procedure node_add_text_line(node: node_id, strg: string, col: color);
% procedure node_set_group(node: node_is, group: group_id);


% Edges

% function  edge_register(source: coord_id, target: coord_id, style: style_id): edge_id;
% procedure edge_add_text_line(edge: edge_id, path: path_id, strng: string, col: color, scale: numeric, side: boolean);
% function  edge_register_coord(edge: edge_id; coord: coord_id): (path_id, path_id);
% procedure edge_register_coord_(edge: edge_id; coord: coord_id);
% procedure edge_set_visible(edge: edge_id, visible: boolean);
% procedure edge_set_style(edge: edge_id, style: style_id);
% procedure edge_set_arrow_style(edge: edge_id, path:path_id, arrow_style: arrow_style);
% procedure edge_path_curl(edge: edge_id; path: path_id; scale: numeric);
% procedure edge_path_loop(edge: edge_id; path: path_id; separation: numeric, diameter: numeric, rotation: numeric);


% Main

% procedure graph_draw;
% procedure graph_reset;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Coordinates
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pair _coords_x_transform, _coords_y_transform;
pair _coords_current_base, _coords_base_stack[];
numeric _coords_base_stack_length;
pair _coords_original[];
pair _coords[];
numeric _coords_length;

vardef coords_set_transform(expr x_tr, y_tr) =
	_coords_x_transform := x_tr;
	_coords_y_transform := y_tr;
enddef;

vardef coords_reset_transform =
	coords_set_transform((1cm, 0cm), (0cm, 1cm));
enddef;

vardef coords_enter_base(expr new_base) =
	_coords_base_stack[_coords_base_stack_length] := new_base;
	_coords_current_base := new_base;
	_coords_base_stack_length := _coords_base_stack_length + 1;
enddef;
	
vardef coords_enter_relative_base(expr new_relative_base) =
	coords_enter_base(_coords_current_base + new_relative_base);
enddef;

vardef coords_leave_base =
	if (_coords_base_stack_length > 0) :
		_coords_base_stack_length := _coords_base_stack_length - 1;
		_coords_current_base := (0,0);
		if (_coords_base_stack_length > 0) :
			_coords_current_base := _coords_base_stack[_coords_base_stack_length];
		fi;
	fi;
enddef;

vardef _coord_to_point(expr x,y) =
	numeric x_coord, y_coord;
	x_coord := (xpart _coords_x_transform) * x + (xpart _coords_y_transform) * y;
	y_coord := (ypart _coords_x_transform) * x + (ypart _coords_y_transform) * y;
	(x_coord, y_coord)
enddef;

vardef coords_register(expr x,y) =
	numeric xx, yy;
	xx := x + xpart _coords_current_base;
	yy := y + ypart _coords_current_base;
	_coords[_coords_length] := _coord_to_point(xx,yy);
	_coords_original[_coords_length] := (xx,yy);
	_coords_length := _coords_length + 1;
	_coords_length - 1
enddef;

vardef coords_get_abs(expr id) =
	_coords_original[id]
enddef;

vardef coords_get_rel(expr id) =
	coords_get_abs(id) - _coords_current_base
enddef;

vardef _coords_reset =
	_coords_base_stack_length := 0;
	_coords_current_base := (0,0);
	_coords_length := 0;
	coords_reset_transform;
enddef;

_coords_reset;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Groups
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Groups
numeric _group_length;
numeric _group_subgroups[][]; numeric _group_subgroups_length[];
numeric _group_parent[];
pair _group_coord_ll[];
pair _group_coord_ur[];
numeric _group_included_coords[][]; numeric _group_included_coords_length[];
numeric group_root;
numeric group_current;
numeric _group_stack[]; numeric _group_stack_length;
numeric _group_style[];
% Group Annotations
numeric _group_annot_length[];
color _group_annot_text_color[][];
picture _group_annot_text[][];
numeric _group_annot_position[][];
% Group Separators
numeric _group_separators_length;
pair _group_separators[];
numeric _group_separators_style[];
numeric _group_separators_overlap[];

vardef _groups_reset =
	_group_length := 1;
	_group_subgroups_length[0] := 0;
	_group_parent[0] := -1;
	_group_included_coords_length[0] := 0;
	group_root := 0;
	group_current := 0;
	_group_stack_length := 0;
	_group_annot_length[0] := 0;
	_group_separators_length := 0;
enddef;

_groups_reset;

vardef group_add_annot(expr groupidx, strng, col, posi) =
	_group_annot_text[groupidx][_group_annot_length[groupidx]] := thelabel(strng, (0,0));
	_group_annot_text_color[groupidx][_group_annot_length[groupidx]] := col;
	_group_annot_position[groupidx][_group_annot_length[groupidx]] := posi;
	_group_annot_length[groupidx] := _group_annot_length[groupidx] + 1;
enddef;

vardef group_enter(expr groupid) =
	_group_stack[_group_stack_length] := groupid;
	_group_stack_length := _group_stack_length + 1;
	group_current := groupid;
enddef;

vardef group_leave =
	if (_group_stack_length > 0) :
		_group_stack_length := _group_stack_length - 1;
		if (_group_stack_length = 0):
			group_current := group_root;
		else:
			group_current := _group_stack[_group_stack_length-1];
		fi;
	fi;
enddef;

vardef group_set_style(expr groupid, value) =
	_group_style[groupid] := value;
enddef;

vardef group_add(expr parentid) =
	_group_annot_length[_group_length] := 0;
	_group_subgroups_length[_group_length] := 0;
	_group_subgroups[parentid][_group_subgroups_length[parentid]] := _group_length;
	_group_parent[_group_length] := parentid;
	_group_subgroups_length[parentid] := _group_subgroups_length[parentid] + 1;
	_group_included_coords_length[_group_length] := 0;
	_group_length := _group_length + 1;
	_group_length - 1
enddef;

vardef group_get_coord_ll(expr groupid) =
	_group_coord_ll[groupid]
enddef;

vardef group_get_coord_ur(expr groupid) =
	_group_coord_ur[groupid]
enddef;

vardef _group_recompute_bbox(expr groupid) =
	numeric llx, lly, urx, ury;
	vardef recompute(expr coordpair) =
		if(known(coordpair)) :
			numeric x, y;
			x := xpart coordpair;
			y := ypart coordpair;
			if (unknown(llx)) :
				llx := x;
				lly := y;
				urx := x;
				ury := y;
			else :
				llx := min(llx,x);
				lly := min(lly,y);
				urx := max(urx,x);
				ury := max(ury,y);
			fi;
		fi;
	enddef;
	for i = 0 upto (_group_included_coords_length[groupid] - 1) :
		recompute(_coords_original[_group_included_coords[groupid][i]]);
	endfor;
	for i = 0 upto _group_subgroups_length[groupid] - 1 :
		recompute(group_get_coord_ll(_group_subgroups[groupid][i]));
		recompute(group_get_coord_ur(_group_subgroups[groupid][i]));
	endfor;
	if(known(llx)):
		_group_coord_ll[groupid] := (llx, lly);
		_group_coord_ur[groupid] := (urx, ury);
%	else:
%		_group_coord_ll[groupid] := unknown;
%		_group_coord_ur[groupid] := unknown;
	fi;
	if (groupid <> group_root) :
		_group_recompute_bbox(_group_parent[groupid]);
	fi;
enddef;

vardef group_include_coord(expr groupid, coordid) =
	_group_included_coords[groupid][_group_included_coords_length[groupid]] := coordid;
	_group_included_coords_length[groupid] := _group_included_coords_length[groupid] + 1;
	_group_recompute_bbox(groupid);
enddef;

vardef _group_exclude_coord(expr groupid, coordid) =
	_group_included_coords_length[groupid] := _group_included_coords_length[groupid] - 1;
	for i = 0 to _group_included_coords_length[groupid] :
		if (_group_included_coords[groupid][i] = coordid) :
			_group_included_coords[groupid][i] := _group_included_coords[groupid][_group_included_coords_length[groupid]];
		fi;
	endfor;
	_group_recompute_bbox(groupid);
enddef;

vardef _group_draw_background(expr groupid, pict) =
	if (known(_group_style[groupid])):
		primitive_style_draw(_group_style[groupid], llcorner pict, urcorner pict);
	fi;
	for i = 0 upto _group_annot_length[groupid] - 1 :
		label_by_bbox(_group_annot_text[groupid][i], pict, _group_annot_position[groupid][i], _group_annot_text_color[groupid][i]);
	endfor;
enddef;

vardef group_separator_add(expr groupa, groupb, style, overlap) =
	_group_separators[_group_separators_length] := (groupa, groupb);
	_group_separators_style[_group_separators_length] := style;
	_group_separators_overlap[_group_separators_length] := overlap;
	_group_separators_length := _group_separators_length + 1;
enddef;

vardef _group_separator_draw(expr sepid) =
	numeric groupa, groupb, style;
	groupa := xpart _group_separators[sepid];
	groupb := ypart _group_separators[sepid];
	style := _group_separators_style[sepid];
	pair lla, ura, llb, urb;
	lla := group_get_coord_ll(groupa);
	ura := group_get_coord_ur(groupa);
	llb := group_get_coord_ll(groupb);
	urb := group_get_coord_ur(groupb);
	numeric xa, ya, xb, yb, xxa, yya, xxb, yyb;
	xa := xpart lla; ya := ypart lla;
	xb := xpart llb; yb := ypart llb;
	xxa := xpart ura; yya := ypart ura;
	xxb := xpart urb; yyb := ypart urb;
	
	numeric x,y,xx,yy, xadd, yadd;
	x := min(xa,xb); y := min(ya,yb);
	xx := max(xxa,xxb); yy := max(yya,yyb);
	
	xadd := _group_separators_overlap[sepid] * (xx-x);
	yadd := _group_separators_overlap[sepid] * (yy-y);
	
	numeric xmid, ymid, xdist, ydist;
	if (xxa < xb) :
		xmid := 0.5(xxa+xb);
		xdist := xb-xxa;
	else :
		xmid := 0.5(xa+xxb);
		xdist := xa-xxb;
	fi;
	if (yya < yb) :
		ymid := 0.5(yya+yb);
		ydist := yb-yya;
	else :
		ymid := 0.5(ya+yyb);
		ydist := ya-yyb;
	fi;
	
	path p;
	
	if (xdist > ydist) :
		p := _coord_to_point(xmid, y-yadd) -- _coord_to_point(xmid, yy+yadd);
	else :
		p := _coord_to_point(x-xadd, ymid) -- _coord_to_point(xx+xadd, ymid);
	fi;
	
	path_style_draw(p, style);
enddef;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Node Styles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numeric _node_styles_length;
numeric _node_styles_prim[];
pair _node_styles_dia[];
_node_styles_length := 0;

vardef node_style_add(expr prim, dia) =
	_node_styles_prim[_node_styles_length] := prim;
	_node_styles_dia[_node_styles_length] := dia;
	_node_styles_length := _node_styles_length + 1;
	_node_styles_length - 1
enddef;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Nodes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Nodes
numeric _nodes_length;
numeric _nodes_to_coords[];
numeric _nodes_coords_to[];
numeric _nodes_to_groups[];
numeric _nodes_groups_to[][]; numeric _nodes_groups_to_length[];
numeric _nodes_style[];
boolean _nodes_visible[];
color _nodes_text_color[][];
picture _nodes_text[][];
numeric _nodes_text_length[];

vardef _nodes_reset =
	for i = 0 upto _group_length - 1 :
		_nodes_groups_to_length[i] := _nodes_groups_to_length[_group_length];
	endfor;
	for i = 0 upto _coords_length - 1 :
		_nodes_coords_to[i] := _nodes_coords_to[_coords_length];
	endfor;
	_nodes_length := 0;
enddef;

_nodes_reset;	

vardef node_register(expr coordidx, styleid) =
	_nodes_to_coords[_nodes_length] := coordidx;
	_nodes_coords_to[coordidx] := _nodes_length;
	_nodes_to_groups[_nodes_length] := group_current;
	if not (known(_nodes_groups_to_length[group_current])) :
		_nodes_groups_to_length[group_current] := 0;
	fi;
	_nodes_groups_to[group_current][_nodes_groups_to_length[group_current]] := _nodes_length;
	_nodes_groups_to_length[group_current] := _nodes_groups_to_length[group_current] + 1;
	_nodes_visible[_nodes_length] := true;
	_nodes_style[_nodes_length] := styleid;
	_nodes_text_length[_nodes_length] := 0;	
	_nodes_length := _nodes_length+1;
	group_include_coord(group_current, coordidx);
	_nodes_length - 1
enddef;

vardef node_get_coord(expr nodeidx) =
	_nodes_to_coords[nodeidx]
enddef;

vardef node_set_style(expr nodeidx, styleid) =
	_nodes_style[nodeidx] := styleid;
enddef;

vardef node_set_visible(expr nodeidx, value) =
	_nodes_visible[nodeidx] := value;
enddef;

vardef node_add_text_line(expr nodeidx, strng, col) =
	_nodes_text[nodeidx][_nodes_text_length[nodeidx]] := thelabel(strng, (0,0));
	_nodes_text_color[nodeidx][_nodes_text_length[nodeidx]] := col;
	_nodes_text_length[nodeidx] := _nodes_text_length[nodeidx] + 1;
enddef;

vardef node_set_group(expr nodeid, groupid) =
	numeric old;
	old := _nodes_to_groups[nodeid];
	_nodes_groups_to_length[old] := _nodes_groups_to_length[old] - 1;
	for i=0 upto _nodes_groups_to_length[old] - 1 :
		if (_nodes_groups_to[old][i] = nodeid) :
			_nodes_groups_to[old][i] := _nodes_groups_to[old][_nodes_groups_to_length[old]];
		fi;
	endfor;
	_group_remove_coord(old, _nodes_to_coords[nodeid]);
	_nodes_to_groups[nodeid] := groupid;
	if not (known(_nodes_groups_to_length[groupid])) :
		_nodes_groups_to_length[groupid] := 0;
	fi;
	_nodes_groups_to[groupid][_nodes_groups_to_length[groupid]] := nodeid;
	_nodes_groups_to_length[groupid] := _nodes_groups_to_length[groupid] + 1;
	group_include_coord(groupid, _nodes_to_coords[nodeid]);
enddef;

vardef _node_draw(expr nodeidx) =
	if (_nodes_visible[nodeidx] = true) :
		pair p;
		numeric style;
		numeric x,y;
		style := _nodes_style[nodeidx];
		p := _coords[_nodes_to_coords[nodeidx]];
		primitive_style_draw_mid(_node_styles_prim[style], p, _node_styles_dia[style]);
		for i = 0 upto _nodes_text_length[nodeidx]-1:
			label(_nodes_text[nodeidx][i], p + (0cm,0.2cm * (_nodes_text_length[nodeidx]-1) - i * 0.4cm)) withcolor _nodes_text_color[nodeidx][i];
		endfor;
	fi;
enddef;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Edges
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numeric _edges_length;
numeric _edges_to_coords[][];
numeric _edges_to_coords_length[];
boolean _edges_visible[];
numeric _edges_style[];
path _edges_paths[][];
numeric _edges_paths_arrow_style[][];
% Annotations
numeric _edges_annot_length[][];
picture _edges_annot_text[][][];
color _edges_annot_text_color[][][];
boolean _edges_annot_text_side[][][];
numeric _edges_annot_text_scale[][][];

vardef _edges_reset =
	_edges_length := 0;
enddef;

_edges_reset;	

vardef edge_register(expr sourcecoord, targetcoord, style) =
	_edges_to_coords[_edges_length][0] := sourcecoord;
	_edges_to_coords[_edges_length][1] := targetcoord;
	_edges_to_coords_length[_edges_length] := 2;
	_edges_visible[_edges_length] := true;
	_edges_style[_edges_length] := style;
	_edges_paths[_edges_length][0] := _coords[sourcecoord] -- _coords[targetcoord];
	_edges_paths_arrow_style[_edges_length][0] := path_arrow_normal;
	_edges_annot_length[_edges_length][0] := 0;
	_edges_length := _edges_length+1;
	_edges_length - 1
enddef;

vardef edge_add_text_line(expr edgeidx, pathidx, strng, col, scale, side) =
	numeric annotidx;
	annotidx := _edges_annot_length[edgeidx][pathidx];
	_edges_annot_length[edgeidx][pathidx] := annotidx + 1;
	_edges_annot_text[edgeidx][pathidx][annotidx] := thelabel(strng, (0,0));
	_edges_annot_text_color[edgeidx][pathidx][annotidx] := col;
	_edges_annot_text_scale[edgeidx][pathidx][annotidx] := scale;
	_edges_annot_text_side[edgeidx][pathidx][annotidx] := side;
enddef;

vardef edge_register_coord(expr edgeidx, coordidx) =
	numeric n;
	n := _edges_to_coords_length[edgeidx];
	_edges_annot_length[edgeidx][n-1] := 0;
	_edges_to_coords[edgeidx][n] := _edges_to_coords[edgeidx][n-1];
	_edges_to_coords[edgeidx][n-1] := coordidx;
	_edges_paths_arrow_style[edgeidx][n-1] := _edges_paths_arrow_style[edgeidx][n-2];
	_edges_paths_arrow_style[edgeidx][n-2] := path_arrow_none;
	_edges_paths[edgeidx][n-2] := _coords[_edges_to_coords[edgeidx][n-2]] -- _coords[_edges_to_coords[edgeidx][n-1]];
	_edges_paths[edgeidx][n-1] := _coords[_edges_to_coords[edgeidx][n-1]] -- _coords[_edges_to_coords[edgeidx][n]];
	_edges_to_coords_length[edgeidx] := n + 1;
	(n-2,n-1)
enddef;

vardef edge_register_coord_(expr edgeidx, coordidx) =
	pair tmp;
	tmp := edge_register_coord(edgeidx, coordidx);
enddef;

vardef edge_set_visible(expr edgeidx, value) =
	_edges_visible[edgeidx] := value;
enddef;

vardef edge_set_style(expr edgeidx, value) =
	if edgeidx >= 0 :
		_edges_style[edgeidx] := value;
	fi;
enddef;

vardef edge_set_arrow_style(expr edgeidx, pathidx, value) =
	_edges_paths_arrow_style[edgeidx][pathidx] := value;
enddef;

vardef edge_path_curl(expr edgeidx, pathidx, scale) =
	pair startpnt, endpnt, midpnt, scalepnt, finalpnt;
	startpnt := _coords[_edges_to_coords[edgeidx][pathidx]];
	endpnt := _coords[_edges_to_coords[edgeidx][pathidx+1]];
	midpnt := (startpnt + endpnt) * 0.5;
	scalepnt := scale * endpnt + (1-scale) * midpnt;
	finalpnt := scalepnt rotatedaround(midpnt, 90);
	_edges_paths[edgeidx][pathidx] := startpnt .. finalpnt .. endpnt;
enddef;

vardef edge_path_loop(expr edgeidx, pathidx, separation, diameter, rotation) =
	pair circlepnt;
	path pth;
	circlepnt := _coords[_edges_to_coords[edgeidx][pathidx]] + (0, separation * 1cm) rotated (-rotation);
	pth := reverse ((fullcircle scaled (diameter * 1cm) rotated (270-rotation)) shifted circlepnt);
	_edges_paths[edgeidx][pathidx] := pth;
enddef;

vardef _edge_draw(expr edgeidx) =
	if (_edges_visible[edgeidx] = true) :
		for i=0 upto _edges_to_coords_length[edgeidx]-2:
			path pth;
			pth := _edges_paths[edgeidx][i];
			numeric startpnt, endpnt;
			startpnt := _edges_to_coords[edgeidx][i];
			endpnt := _edges_to_coords[edgeidx][i+1];
			pair startcoord, endcoord;
			startcoord := _coords[startpnt];
			endcoord := _coords[endpnt];
			if (known(_nodes_coords_to[startpnt])):
				numeric style, source;
				source := _nodes_coords_to[startpnt];
				style := _nodes_style[source];
				pth := pth cutbefore primitive_style_get_path_mid(_node_styles_prim[style], startcoord, _node_styles_dia[style]);
			fi;
			if (known(_nodes_coords_to[endpnt])):
				numeric style, target;
				target := _nodes_coords_to[endpnt];
				style := _nodes_style[target];
				pth := pth cutafter primitive_style_get_path_mid(_node_styles_prim[style], endcoord, _node_styles_dia[style]);
			fi;
			path_style_draw_custom(pth, _edges_style[edgeidx], _edges_paths_arrow_style[edgeidx][i]);
			for j=0 upto _edges_annot_length[edgeidx][i]-1:
				pair midpnt;
				numeric angl;
				midpnt := point _edges_annot_text_scale[edgeidx][i][j] * length pth of pth;
				angl := (angle (endcoord - startcoord) + 360 + 90) mod 360;
				if (_edges_annot_text_side[edgeidx][i][j] = false) :
					angl := (angl + 180) mod 360;
				fi;
				label_by_angle(_edges_annot_text[edgeidx][i][j], midpnt, angl, _edges_annot_text_color[edgeidx][i][j]);
			endfor;
		endfor;
	fi;
enddef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vardef graph_draw =
	vardef draw_group(expr g) =
		picture pict;
		pict := image(
			if (known(_nodes_groups_to_length[g])):
				for i = 0 upto _nodes_groups_to_length[g] - 1:
					_node_draw(_nodes_groups_to[g][i]);
				endfor;
			fi;
			for i = 0 upto _group_subgroups_length[g] - 1:
				draw_group(_group_subgroups[g][i]);
			endfor;
		);
		_group_draw_background(g, pict);
		draw pict;
	enddef;
	draw_group(0);
	for i = 0 upto _group_separators_length - 1 :
		_group_separator_draw(i);
	endfor;
	for i = 0 upto _edges_length - 1:
		_edge_draw(i);
	endfor;
enddef;

vardef graph_reset =
	_nodes_reset;
	_edges_reset;
	_groups_reset;
	_coords_reset;
enddef;