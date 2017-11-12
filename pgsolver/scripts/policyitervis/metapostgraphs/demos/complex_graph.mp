verbatimtex
%&latex
\documentclass{article}
\usepackage{amsmath,amssymb}
\begin{document}
etex

input "latex";

input "../graphicslib";
input "../graphlib";


numeric
	node_style_even,
	node_style_odd,
	node_style_prio,
	node_style_reward,
	node_style_plain,
	edge_style_default,
	edge_style_strategy,
	multiplicity_style,
	style_separator;
	
	

numeric % Groups
	group_source,
	group_sink,
	group_layers[],
	group_skipped_layers[],
	group_multiplicity[];
	
numeric % Nodes
	node_B[],
	node_b[],
	node_a[],
	node_w[],
	node_u[],
	node_d[],
	node_y[],
	node_x[],
	node_b_s_rew[],
	node_b_u_rew[],
	node_s,
	node_t,
	node_intermediate[];
	
	
numeric % Edges
	edge_B_b[],
	edge_B_y[],
	edge_b_B[],
	edge_b_u[],
	edge_b_u_rew[],
	edge_b_s[],
	edge_b_s_rew[],
	edge_a_d[],
	edge_a_x[],
	edge_w_a[],
	edge_w_w[],
	edge_w_t[],
	edge_u_d[],
	edge_u_u[],
	edge_u_t[],
	edge_d_B[],
	edge_y_w[],
	edge_x_u[],
	edge_s_d,
	edge_t_t,
	edge_coord_b_s_s[],
	% edge_w_coord_w_y[],
	edge_y_coord_w_y[],
	edge_b_coord_b_u[],
	edge_x_coord_x_u[],
	edge_coord_b_u_coord_x_u[],
	edge_coord_x_u_coord_b_u[],
	edge_coord_u_coord_uu;

numeric % Coords
	coord_w_y[],
	coord_b_s[],
	coord_b_u[],
	coord_x_u[],
	coord_u,
	coord_uu;
	
node_style_even := node_style_add(primitive_style_add(white, path_style_default, primitive_circle), (1,1));
node_style_odd := node_style_add(primitive_style_add(white, path_style_default, primitive_rectangle), (1,1));
node_style_prio := node_style_add(primitive_style_add(white, path_style_default, primitive_hexagon), (1,1));
node_style_reward := node_style_add(primitive_style_add(white, path_style_default, primitive_diamond), (0.75,0.75));
node_style_plain := node_style_add(primitive_style_add(white, path_style_add(white, path_shape_solid, 0), primitive_circle), (1,1));
multiplicity_style := primitive_style_add(0.7white, path_style_add(black, path_shape_dotted, 0.75), primitive_soft_chamfered_rectangle);
edge_style_default := path_style_add(black, path_shape_solid, 1);
edge_style_strategy := path_style_add(blue, path_shape_solid, 3.5);
style_separator := path_style_add(black, path_shape_dashed, 0.75);


vardef build_graph(expr paritygame) =
	vardef new_even_node(expr x, y, txt, prio) =
		numeric n;
		n := node_register(coords_register(x,y), node_style_even);
		node_add_text_line(n, latex(txt), black);
		if (paritygame = true) :
			node_add_text_line(n, latex(prio), blue);
		fi;
		n
	enddef;

	vardef new_odd_node(expr x, y, txt, prio) =
		numeric n;
		n := node_register(coords_register(x,y), node_style_odd);
		node_add_text_line(n, latex(txt), black);
		if (paritygame = true) :
			node_add_text_line(n, latex(prio), blue);
		fi;
		n
	enddef;

	vardef new_prio_node(expr x, y, prio) =
		numeric n;
		n := node_register(coords_register(x,y), node_style_prio);
		node_add_text_line(n, latex(prio), blue);
		n
	enddef;

	vardef new_rew_node(expr x, y, rew) =
		numeric n;
		n := node_register(coords_register(x,y), node_style_reward);
		node_add_text_line(n, latex(rew), blue);
		n
	enddef;

	vardef new_default_edge(expr n, m) =
		edge_register(node_get_coord(n), node_get_coord(m), edge_style_default)
	enddef;

	vardef new_edge_to_coord(expr node, coord) =
		numeric e;
		e := edge_register(node_get_coord(node), coord, edge_style_default);
		edge_set_arrow_style(e, 0, path_arrow_sep);
		e
	enddef;

	vardef new_coord_to_edge(expr coord, node) =
		edge_register(coord, node_get_coord(node), edge_style_default)
	enddef;

	vardef new_coord_to_coord(expr coords, coord) =
		numeric e;
		e := edge_register(coords, coord, edge_style_default);
		edge_set_arrow_style(e, 0, path_arrow_none);
		e
	enddef;

	vardef i_string(expr times_i, add_const) =
		string tmp;
		if(times_i > 0):
			if (times_i > 1):
				if (add_const > 0):
					tmp := "{" & decimal(times_i) & "i{+}" & decimal(add_const) & "}";
				else:
					tmp := "{" & decimal(times_i) & "i}";
				fi;
			else:
				if (add_const > 0):
					tmp := "{i{+}" & decimal(add_const) & "}";
				else:
					tmp := "{i}";
				fi;
			fi;
		else:
			tmp := "{" & decimal(add_const) & "}";
		fi;
		tmp
	enddef;
	vardef build_group_layer(expr basey, index, times_i, add_const) =
		group_layers[index] := group_add(group_root);
		group_enter(group_layers[index]);	
		coords_enter_base((0,basey));
		
		string indexstr;
		indexstr := i_string(times_i, add_const);	
		
		node_w[index] := new_even_node(0,0, "$w_" & indexstr & "$", "3");
		node_a[index] := new_even_node(2,0, "$a_" & indexstr & "$", "5");
		node_x[index] := new_prio_node(6,0, i_string(4 * times_i, 5 + 4 * add_const));
		node_d[index] := new_prio_node(2,2, i_string(4 * times_i, 7 + 4 * add_const));
		node_u[index] := new_even_node(8,2, "$u_" & indexstr & "$", "3");
		node_B[index] := new_odd_node (2,4, "$B_" & indexstr & "$", "6");
		node_y[index] := new_prio_node(2,6.5, i_string(4 * times_i, 8 + 4 * add_const));

		coord_w_y[index] := coords_register(0,6.5);
		coord_b_s[index] := coords_register(-1,5.5);
		coord_b_u[index] := coords_register(9,4);
		coord_x_u[index] := coords_register(9,0);
		
		group_multiplicity[index] := group_add(group_layers[index]);
		group_set_style(group_multiplicity[index], multiplicity_style);
		group_add_annot(group_multiplicity[index], latex("$" & indexstr & "$"), red, 180-45);
		group_enter(group_multiplicity[index]);
		node_b[index] := new_even_node(5,4, "$b_" & indexstr & "$", "5");
		if (paritygame = false) :
			node_b_u_rew[index] := new_rew_node(6.5,4, "$j\varepsilon$");
			node_b_s_rew[index] := new_rew_node(5,5.5, "$j\varepsilon$");
		fi;
		group_leave;
			
		edge_w_a[index] := new_default_edge(node_w[index], node_a[index]);
		edge_a_x[index] := new_default_edge(node_a[index], node_x[index]);
		edge_a_d[index] := new_default_edge(node_a[index], node_d[index]);
		edge_u_d[index] := new_default_edge(node_u[index], node_d[index]);
		edge_d_B[index] := new_default_edge(node_d[index], node_B[index]);
		edge_B_b[index] := new_default_edge(node_B[index], node_b[index]);
						   edge_path_curl(edge_B_b[index], 0, 0.35);
		edge_b_B[index] := new_default_edge(node_b[index], node_B[index]);
						   edge_path_curl(edge_b_B[index], 0, 0.35);
		edge_B_y[index] := new_default_edge(node_B[index], node_y[index]);
		
		if (paritygame = true) :
			edge_b_s[index] := new_edge_to_coord(node_b[index], coord_b_s[index]);
							   edge_register_coord_(edge_b_s[index], coords_register(5,5.5));
			edge_b_coord_b_u[index] := new_edge_to_coord(node_b[index], coord_b_u[index]);
		else :
			edge_b_s_rew[index] := new_edge_to_coord(node_b_s_rew[index], coord_b_s[index]);
			edge_b_s[index] := new_default_edge(node_b[index], node_b_s_rew[index]);
			edge_b_coord_b_u[index] := new_default_edge(node_b[index], node_b_u_rew[index]);
			edge_b_u_rew[index] := new_edge_to_coord(node_b_u_rew[index], coord_b_u[index]);
		fi;
		
		if (paritygame = false) :
			edge_add_text_line(edge_B_b[index], 0, latex("$1{-}\varepsilon$"), blue, 0.5, true);
			edge_add_text_line(edge_B_y[index], 0, latex("$\varepsilon$"), blue, 0.25, true);
		fi;

		% edge_w_coord_w_y[index] := new_edge_to_coord(node_w[index], coord_w_y[index]);
		edge_y_coord_w_y[index] := new_edge_to_coord(node_y[index], coord_w_y[index]);
		edge_x_coord_x_u[index] := new_edge_to_coord(node_x[index], coord_x_u[index]);
		edge_coord_b_u_coord_x_u[index] := new_coord_to_coord(coord_b_u[index], coord_x_u[index]);
		
		coords_leave_base;
		group_leave;
	enddef;
		
	vardef build_skipped_layer(expr basey, index) =
		group_skipped_layers[index] := group_add(group_root);
		group_enter(group_skipped_layers[index]);	
		coords_enter_base((0,basey));
		
		node_intermediate[index] := node_register(coords_register(4,0), node_style_plain);
		node_add_text_line(node_intermediate[index], latex("$\vdots$"), black);
			
		coords_leave_base;
		group_leave;
	enddef;
		
	vardef build_source(expr basey) =
		group_source := group_add(group_root);
		group_enter(group_source);	
		coords_enter_base((0,basey));
		
		coord_b_s[-1] := coords_register(-1,0);
		node_s        := new_prio_node(1,0, "8");
		coord_u		  := coords_register(9,0);
		coord_uu      := coords_register(8,0);
		edge_coord_b_s_s[-1] := new_coord_to_edge(coord_b_s[-1], node_s);
		edge_coord_u_coord_uu := new_coord_to_coord(coord_u, coord_uu);
		
		coords_leave_base;
		group_leave;
	enddef;

	vardef build_sink(expr basey,index) =
		group_sink := group_add(group_root);
		group_enter(group_sink);	
		coords_enter_base((0,basey));
		
		node_w[index] := new_even_node(0,0, "$w_{n{+}1}$", "3");
		node_u[index] := new_even_node(8,0, "$u_{n{+}1}$", "3");
		node_t        := new_even_node(4,0, "$t$", "1");
		
		edge_w_t      := new_default_edge(node_w[index], node_t);
		edge_u_t      := new_default_edge(node_u[index], node_t);
		if (paritygame = true):
			edge_t_t      := new_default_edge(node_t, node_t);
							 edge_path_loop(edge_t_t, 0, 0.75, 0.75, 0);
		fi;
						 
		coords_leave_base;
		group_leave;
	enddef;

	vardef connect_source_with_group_layer_one =
		edge_s_d := new_default_edge(node_s, node_d[0]);
					edge_register_coord_(edge_s_d, coords_register(xpart (coords_get_abs(node_get_coord(node_s))),
																   ypart (coords_get_abs(node_get_coord(node_d[0])))));
		edge_coord_b_s_s[0] := new_coord_to_coord(coord_b_s[0], coord_b_s[-1]);
		edge_u_u[-1] := new_coord_to_edge(coord_uu, node_u[0]);
		edge_coord_x_u_coord_b_u[-1] := new_coord_to_coord(coord_x_u[0], coord_u);
	enddef;

	vardef connect_group_layer_with_next(expr layer) =
		edge_w_w[layer] := new_default_edge(node_w[layer], node_w[layer+1]);
		edge_coord_x_u_coord_b_u[layer] := new_coord_to_coord(coord_x_u[layer+1], coord_b_u[layer]);
		edge_u_u[layer] := new_default_edge(node_u[layer], node_u[layer+1]);
		edge_coord_b_s_s[layer] := new_coord_to_coord(coord_b_s[layer+1], coord_b_s[layer]);
	enddef;

	vardef connect_sink_with_last_layer(expr layer) =
		edge_w_w[layer] := new_default_edge(node_w[layer], node_w[layer+1]);
		edge_u_u[layer] := new_default_edge(node_u[layer], node_u[layer+1]);
	enddef;
	
	graph_reset;
	build_source(0);
	build_group_layer(ypart group_get_coord_ur(group_source) + 1.75,0,0,1);
	build_skipped_layer(ypart group_get_coord_ur(group_layers[0]) + 1.75, 0);
	build_group_layer(ypart group_get_coord_ur(group_skipped_layers[0]) + 1.75,1,1,0);
	build_group_layer(ypart group_get_coord_ur(group_layers[1]) + 1.75,2,1,1);
	build_skipped_layer(ypart group_get_coord_ur(group_layers[2]) + 1.75, 1);
	build_sink(ypart group_get_coord_ur(group_skipped_layers[1]) + 1.75, 3);
	group_separator_add(group_source, group_layers[0], style_separator, 0.25);
	group_separator_add(group_layers[0], group_skipped_layers[0], style_separator, 0.25);
	group_separator_add(group_skipped_layers[0], group_layers[1], style_separator, 0.25);
	group_separator_add(group_layers[1], group_layers[2], style_separator, 0.25);
	group_separator_add(group_layers[2], group_skipped_layers[1], style_separator, 0.25);
	group_separator_add(group_skipped_layers[1], group_sink, style_separator, 0.25);
	connect_source_with_group_layer_one;
	connect_group_layer_with_next(0);
	connect_group_layer_with_next(1);
	connect_sink_with_last_layer(2);
enddef;
		
beginfig(1);
	build_graph(true);
 	graph_draw;
endfig;

beginfig(2);
	build_graph(false);
 	graph_draw;
endfig;

% Animation

build_graph(true);

edge_set_style(edge_s_d, edge_style_strategy);

beginfig(3);
	graph_draw;
endfig;

edge_set_style(edge_t_t, edge_style_strategy);

beginfig(4);
	graph_draw;
endfig;

end;

