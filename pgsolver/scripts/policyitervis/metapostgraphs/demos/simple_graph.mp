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
	node_style,
	edge_style;
	
numeric
	node_a,
	node_b,
	node_c,
	node_d;
	
	
numeric
	edge_a_b,
	edge_b_c,
	edge_c_d,
	edge_d_a;

node_style := node_style_add(primitive_style_add(white, path_style_default, primitive_circle), (1,1));
edge_style := path_style_add(black, path_shape_solid, 1);


vardef new_node(expr x, y, txt) =
	numeric n;
	n := node_register(coords_register(x,y), node_style);
	node_add_text_line(n, latex(txt), blue);
	n
enddef;

vardef new_edge(expr n, m) =
	edge_register(node_get_coord(n), node_get_coord(m), edge_style)
enddef;

beginfig(1);
	node_a := new_node(0, 0, "a");
	node_b := new_node(2, 0, "b");
	node_c := new_node(2, 2, "c");
	node_d := new_node(0, 2, "d");

	edge_a_b := new_edge(node_a, node_b);
	edge_b_c := new_edge(node_b, node_c);
	edge_c_d := new_edge(node_c, node_d);
	edge_d_a := new_edge(node_d, node_a);

 	graph_draw;
endfig;

end;

