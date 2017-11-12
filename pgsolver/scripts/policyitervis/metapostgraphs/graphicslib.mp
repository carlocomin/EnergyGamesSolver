%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Graphics Library for Metapost (c) 2010 - 2011
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


% Graphics Scaling

% procedure graphics_scale_set(scale: pair);


% Path and Arrow Drawing

% const     path_shape_solid, path_shape_dashed, path_shape_dotted;
% procedure path_draw(pth: path, shape: path_shape_const, col: color, thickness: numeric);
% procedure path_draw_arrow(pth: path, shape: path_shape_const, col: color, thickness: numeric);
% procedure path_draw_sep_arrow(pth: path, shape: path_shape_const, col: color, thickness: numeric);
% const     path_arrow_none, path_arrow_normal, path_arrow_sep;
% procedure path_draw_custom(pth: path, shape: path_shape_const, col: color, thickness: numeric, arrow: path_arrow_const);


% Path Styles

% const     path_style_default;
% function  path_style_add(col: color, shape: path_shape_const, thickness: numeric): path_style_id;
% procedure path_style_draw(pth: path, style: path_style_id);
% procedure path_style_draw_arrow(pth: path, style: path_style_id);
% procedure path_style_draw_sep_arrow(pth: path, style: path_style_id);
% procedure path_style_draw_custom(pth: path, style: path_style_id, arrow: path_arrow_const);


% Primitives

% function  primitive_build_circle(ll: pair, ur: pair): path;
% function  primitive_build_rectangle(ll: pair, ur: pair): path;
% function  primitive_build_diamond(ll: pair, ur: pair): path;
% function  primitive_build_hexagon(ll: pair, ur: pair): path;
% function  primitive_build_hard_chamfered_rectangle(ll: pair, ur: pair): path;
% function  primitive_build_soft_chamfered_rectangle(ll: pair, ur: pair): path;
% const     primitive_circle, primitive_rectangle, primitive_diamond, primitive_hexagon, primitive_hard_chamfered_rectangle, primitive_soft_chamfered_rectangle;
% function  primitive_build(ll: pair, ur: pair, prim: primitive_type): path;


% Primitive Styles

% function  primitive_style_add(bgcolor: color, pth_style: path_style, prim: primitive_type);
% function  primitive_style_get_path(style: primitive_style, ll: pair, ur: pair): path;
% function  primitive_style_get_path_mid(style: primitive_style, midpnt: pair, diameter: pair): path;
% procedure primitive_style_draw(style: primitive_style, ll: pair, ur: pair);
% procedure primitive_style_draw_mid(style: primitive_style, midpnt: pair, diameter: pair);


% Labels

% procedure label_by_angle(text: string, pos: pair, angle: numeric, col: color);
% procedure label_by_bbox(text: string, pict: picture, angle: numeric, col: color);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Graphics Scaling
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pair _graphics_scale;
_graphics_scale := (1cm, 1cm);

vardef graphics_scale_set(expr scale) =
	_graphics_scale := scale;
enddef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Path and Arrow Drawing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numeric path_shape_solid, path_shape_dashed, path_shape_dotted;
path_shape_solid := 0;
path_shape_dashed := 1;
path_shape_dotted := 2;

vardef path_draw(expr pth, shape, col, thickness) =
	if (shape = path_shape_solid) :
		draw pth withcolor col withpen pencircle scaled (thickness * 0.5);
	elseif (shape = path_shape_dashed) :
		draw pth withcolor col withpen pencircle scaled (thickness * 0.5) dashed evenly;
	elseif (shape = path_shape_dotted) :
		draw pth withcolor col withpen pencircle scaled (thickness * 0.5) dashed withdots;
	fi;
enddef;

vardef path_draw_arrow(expr pth, shape, col, thickness) =
	if (shape = path_shape_solid) :
		drawarrow pth withcolor col withpen pencircle scaled (thickness * 0.5);
	elseif (shape = path_shape_dashed) :
		drawarrow pth withcolor col withpen pencircle scaled (thickness * 0.5) dashed evenly;
	elseif (shape = path_shape_dotted) :
		drawarrow pth withcolor col withpen pencircle scaled (thickness * 0.5) dashed withdots;
	fi;
enddef;

vardef path_draw_sep_arrow(expr pth, shape, col, thickness) =
	pair p;
	p := point 0.9 * length pth of pth;
	path_draw_arrow(pth cutafter p, shape, col, thickness);
	path_draw(pth cutbefore p, shape, col, thickness);
enddef;

numeric path_arrow_none, path_arrow_normal, path_arrow_sep;
path_arrow_none := 0;
path_arrow_normal := 1;
path_arrow_sep := 2;

vardef path_draw_custom(expr pth, shape, col, thickness, arr) =
	if (arr = path_arrow_none) :
		path_draw(pth, shape, col, thickness);
	elseif (arr = path_arrow_normal) :
		path_draw_arrow(pth, shape, col, thickness);
	elseif (arr = path_arrow_sep) :
		path_draw_sep_arrow(pth, shape, col, thickness);
	fi;
enddef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Path Styles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numeric _path_style_length, path_style_default;
color _path_style_color[];
numeric _path_style_shape[];
numeric _path_style_thickness[];

vardef path_style_add(expr col, shape, thickness) =
	_path_style_color[_path_style_length] := col;
	_path_style_shape[_path_style_length] := shape;
	_path_style_thickness[_path_style_length] := thickness;
	_path_style_length := _path_style_length + 1;
	_path_style_length - 1
enddef;

vardef path_style_draw(expr pth, style) =
	path_draw(pth, _path_style_shape[style], _path_style_color[style], _path_style_thickness[style]);
enddef;

vardef path_style_draw_arrow(expr pth, style) =
	path_draw_arrow(pth, _path_style_shape[style], _path_style_color[style], _path_style_thickness[style]);
enddef;

vardef path_style_draw_sep_arrow(expr pth, style) =
	path_draw_sep_arrow(pth, _path_style_shape[style], _path_style_color[style], _path_style_thickness[style]);
enddef;

vardef path_style_draw_custom(expr pth, style, arr) =
	path_draw_custom(pth, _path_style_shape[style], _path_style_color[style], _path_style_thickness[style], arr);
enddef;

_path_style_length := 0;
path_style_default := path_style_add(black, path_shape_solid, 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Primitives
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vardef primitive_build_circle(expr ll, ur) =
	fullcircle xscaled (xpart ur - xpart ll) yscaled (ypart ur - ypart ll) shifted (0.5*(ll+ur))
enddef;

vardef primitive_build_rectangle(expr ll, ur) =
	(ll -- (xpart ll, ypart ur) -- ur -- (xpart ur, ypart ll) -- cycle)
enddef;

vardef primitive_build_diamond(expr ll, ur) =
	(xpart ll, 0.5(ypart ur + ypart ll)) --
	(0.5(xpart ur + xpart ll), ypart ur) --
	(xpart ur, 0.5(ypart ur + ypart ll)) --
	(0.5(xpart ur + xpart ll), ypart ll) --
	cycle
enddef;

vardef primitive_build_hexagon(expr ll, ur) =
	numeric llx,lly,urx,ury;
	llx := xpart ll; lly := ypart ll;
	urx := xpart ur; ury := ypart ur;
	((llx,0.5(lly+ury)) --
	 (0.75*llx+0.25*urx,ury) --
	 (0.25*llx+0.75*urx,ury) --
	 (urx,0.5(lly+ury)) --
	 (0.25*llx+0.75*urx,lly) --
	 (0.75*llx+0.25*urx,lly)
	 -- cycle)
enddef;

vardef primitive_build_hard_chamfered_rectangle(expr ll, ur) =
	numeric llx,lly,urx,ury,bx,by;
	bx := 0.1 * xpart _graphics_scale;
	by := 0.1 * ypart _graphics_scale;
	llx := xpart ll; lly := ypart ll;
	urx := xpart ur; ury := ypart ur;
	ll+(bx,-by) -- ll+(-bx,by) -- (llx,ury)+(-bx,-by) -- (llx,ury)+(bx,by) --
	ur+(-bx,by) -- ur+(bx,-by) -- (urx,lly)+(bx,by) -- (urx,lly)+(-bx,-by) -- cycle
enddef;

vardef primitive_build_soft_chamfered_rectangle(expr ll, ur) =
	numeric llx,lly,urx,ury,bx,by;
	bx := 0.1 * xpart _graphics_scale;
	by := 0.1 * ypart _graphics_scale;
	llx := xpart ll; lly := ypart ll;
	urx := xpart ur; ury := ypart ur;
	ll+(bx,-by) .. ll+(-bx,-by)/sqrt(2)/2 .. ll+(-bx,by) --
	(llx,ury)+(-bx,-by) .. (llx,ury)+(-bx,by)/sqrt(2)/2 .. (llx,ury)+(bx,by) --
	ur+(-bx,by) .. ur+(bx,by)/sqrt(2)/2 .. ur+(bx,-by) --
	(urx,lly)+(bx,by) .. (urx,lly)+(bx,-by)/sqrt(2)/2 .. (urx,lly)+(-bx,-by) -- cycle
enddef;

numeric primitive_circle, primitive_rectangle, primitive_diamond, primitive_hexagon, primitive_hard_chamfered_rectangle, primitive_soft_chamfered_rectangle;
primitive_circle := 0;
primitive_rectangle := 1;
primitive_diamond := 2;
primitive_hexagon := 3;
primitive_hard_chamfered_rectangle := 4;
primitive_soft_chamfered_rectangle := 5;

vardef primitive_build(expr ll, ur, prim) =
	if (prim = primitive_circle) :
		primitive_build_circle(ll, ur)
	elseif (prim = primitive_rectangle) :
		primitive_build_rectangle(ll, ur)
	elseif (prim = primitive_diamond) :
		primitive_build_diamond(ll, ur)
	elseif (prim = primitive_hexagon) :
		primitive_build_hexagon(ll, ur)
	elseif (prim = primitive_hard_chamfered_rectangle) :
		primitive_build_hard_chamfered_rectangle(ll, ur)
	elseif (prim = primitive_soft_chamfered_rectangle) :
		primitive_build_soft_chamfered_rectangle(ll, ur)
	fi
enddef;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Primitive Styles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numeric _primitive_styles_length;
color _primitive_styles_bgcolor[];
numeric _primitive_styles_type[], _primitive_styles_path[];
_primitive_styles_length := 0;

vardef primitive_style_add(expr bgcolor, pth_style, prim) =
	_primitive_styles_bgcolor[_primitive_styles_length] := bgcolor;
	_primitive_styles_type[_primitive_styles_length] := pth_style;
	_primitive_styles_path[_primitive_styles_length] := prim;
	_primitive_styles_length := _primitive_styles_length + 1;
	_primitive_styles_length - 1
enddef;

vardef primitive_style_get_path(expr style_id, ll, ur) =
	primitive_build(ll, ur, _primitive_styles_path[style_id])
enddef;

vardef primitive_style_get_path_mid(expr style_id, midpnt, diameter) =
	path shape;
	numeric x,y;
	x := 0.5 * xpart diameter * xpart _graphics_scale;
	y := 0.5 * ypart diameter * ypart _graphics_scale;
	primitive_build(midpnt - (x,y), midpnt + (x,y), style_id)
enddef;

vardef primitive_style_draw(expr style_id, ll, ur) =
	path shape;
	shape := primitive_style_get_path(style_id, ll, ur);
	fill shape withcolor _primitive_styles_bgcolor[style_id];
	path_style_draw(shape, _primitive_styles_type[style_id]);
enddef;

vardef primitive_style_draw_mid(expr style_id, midpnt, diameter) =
	numeric x,y;
	x := 0.5 * xpart diameter * xpart _graphics_scale;
	y := 0.5 * ypart diameter * ypart _graphics_scale;
	primitive_style_draw(style_id, midpnt - (x,y), midpnt + (x,y));
enddef;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Labels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vardef label_by_angle(expr strng, pnt, angl, col) =
	numeric ang;
	ang := (angl + 22.5) mod 360;
	if (ang < 45) :
		label.lft(strng, pnt) withcolor col;
	elseif (ang < 90) :
		label.ulft(strng, pnt) withcolor col;
	elseif (ang < 135) :
		label.top(strng, pnt) withcolor col;
	elseif (ang < 180) :
		label.urt(strng, pnt) withcolor col;
	elseif (ang < 225) :
		label.rt(strng, pnt) withcolor col;
	elseif (ang < 270) :
		label.lrt(strng, pnt) withcolor col;
	elseif (ang < 315) :
		label.bot(strng, pnt) withcolor col;
	elseif (ang < 360) :
		label.llft(strng, pnt) withcolor col;
	fi;
enddef;

vardef _bounding_rect_point_by_angle(expr pict, angl) =
	pair midpnt, endpnt, anglpnt;
	midpnt := 0.5 * (llcorner pict + urcorner pict);
	endpnt := 2 * (urcorner pict) - midpnt;
	anglpnt := endpnt rotatedaround (midpnt, -angl + 45);
	(bbox pict) intersectionpoint (midpnt -- anglpnt)
enddef;

vardef label_by_bbox(expr strng, pict, angl, col) =
	label_by_angle(strng, _bounding_rect_point_by_angle(pict, angl), angl + 90, col);
enddef;

