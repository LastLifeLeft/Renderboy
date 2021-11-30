function draw_selection_rectangle(x1, y1, x2, y2, x3, y3, x4, y4, thickness, texture, _tex_roll){
	var _tex_repeat = gpu_get_tex_repeat();
	gpu_set_tex_repeat(true);
	draw_primitive_begin_texture(pr_trianglelist, sprite_get_texture(texture, 0));

	var width =  point_distance(x1, y1, x2, y2);
	var height = point_distance(x2, y2, x3, y3);
	var _ytex = thickness / sprite_get_height(texture);
	
	var _xtex = width / sprite_get_width(texture) - _tex_roll;
	var _dir = point_direction(x1, y1, x2, y2);
	var _lenghtdir_x = lengthdir_x(thickness, _dir);
	var _lenghtdir_y = lengthdir_y(thickness, _dir);

	draw_vertex_texture(x1, y1, -_tex_roll, 0);
	draw_vertex_texture(x2, y2, _xtex, 0);
	draw_vertex_texture(x2 - _lenghtdir_y, y2 + _lenghtdir_x, _xtex, _ytex);

	draw_vertex_texture(x2 - _lenghtdir_y, y2 + _lenghtdir_x, _xtex, _ytex);
	draw_vertex_texture(x1 - _lenghtdir_y, y1 + _lenghtdir_x, -_tex_roll, _ytex);
	draw_vertex_texture(x1, y1, -_tex_roll, 0);
	
	_tex_roll = frac(_xtex)
	_xtex = height / sprite_get_width(texture) + _tex_roll;
	_dir -= 90;
	_lenghtdir_x = lengthdir_x(thickness, _dir);
	_lenghtdir_y = lengthdir_y(thickness, _dir);
	
	draw_vertex_texture(x2, y2, _tex_roll, 0);
	draw_vertex_texture(x3, y3, _xtex, 0);
	draw_vertex_texture(x3 - _lenghtdir_y, y3 + _lenghtdir_x, _xtex, _ytex);

	draw_vertex_texture(x3 - _lenghtdir_y, y3 + _lenghtdir_x, _xtex, _ytex);
	draw_vertex_texture(x2 - _lenghtdir_y, y2 + _lenghtdir_x, _tex_roll, _ytex);
	draw_vertex_texture(x2, y2, _tex_roll, 0);
	
	_tex_roll = frac(_xtex)
	_xtex = width / sprite_get_width(texture) + _tex_roll;
	_dir -= 90;
	_lenghtdir_x = lengthdir_x(thickness, _dir);
	_lenghtdir_y = lengthdir_y(thickness, _dir);
	
	draw_vertex_texture(x3, y3, _tex_roll, 0);
	draw_vertex_texture(x4, y4, _xtex, 0);
	draw_vertex_texture(x4 - _lenghtdir_y, y4 + _lenghtdir_x, _xtex, _ytex);

	draw_vertex_texture(x4 - _lenghtdir_y, y4 + _lenghtdir_x, _xtex, _ytex);
	draw_vertex_texture(x3 - _lenghtdir_y, y3 + _lenghtdir_x, _tex_roll, _ytex);
	draw_vertex_texture(x3, y3, _tex_roll, 0);
	
	_tex_roll = frac(_xtex)
	_xtex = height / sprite_get_width(texture) + _tex_roll;
	_dir -= 90;
	_lenghtdir_x = lengthdir_x(thickness, _dir);
	_lenghtdir_y = lengthdir_y(thickness, _dir);
	
	draw_vertex_texture(x4, y4, _tex_roll, 0);
	draw_vertex_texture(x1, y1, _xtex, 0);
	draw_vertex_texture(x1 - _lenghtdir_y, y1 + _lenghtdir_x, _xtex, _ytex);

	draw_vertex_texture(x1 - _lenghtdir_y, y1 + _lenghtdir_x, _xtex, _ytex);
	draw_vertex_texture(x4 - _lenghtdir_y, y4 + _lenghtdir_x, _tex_roll, _ytex);
	draw_vertex_texture(x4, y4, _tex_roll, 0);
	
	draw_primitive_end();
	gpu_set_tex_repeat(_tex_repeat);
}

/// @description draw_circle_curve(x,y,r,bones,ang,angadd,width,outline)
/// @param x
/// @param y
/// @param r
/// @param bones
/// @param ang
/// @param angadd
/// @param width
/// @param outline
function draw_circle_curve(_x, _y, radius, bones, angle, angle_add, width, outline) {

	/*
	x,y — Center of circle.
	r — Radius.
	bones — Amount of bones. More bones = more quality, but less speed. Minimum — 3.
	ang — Angle of first circle's point.
	angadd — Angle of last circle's point (relative to ang). 
	width — Width of circle (may be positive or negative).
	outline — 0 = curve, 1 = sector. 
	*/

	var xx,yy,R,B,A,Aa,W,a,lp,lm,dp,dm,AAa,Wh,Out;
	xx=_x
	yy=_y
	R=radius
	B=max(3,bones)
	A=angle
	Aa=angle_add
	W=width
	Out=outline

	a=Aa/B
	Wh=W/2
	lp=R+Wh
	lm=R-Wh
	AAa=A+Aa
	if Out
	{
		//OUTLINE
		draw_primitive_begin(pr_trianglestrip) //Change to pr_linestrip, to see how it works.
		draw_vertex(xx+lengthdir_x(lm,A),yy+lengthdir_y(lm,A)) //First point.
		for(i=1; i<=B; i+=1)
		{
			dp=A+a*i
			dm=dp-a
			draw_vertex(xx+lengthdir_x(lp,dm),yy+lengthdir_y(lp,dm))
			draw_vertex(xx+lengthdir_x(lm,dp),yy+lengthdir_y(lm,dp))
		}
		draw_vertex(xx+lengthdir_x(lp,AAa),yy+lengthdir_y(lp,AAa))
		draw_vertex(xx+lengthdir_x(lm,AAa),yy+lengthdir_y(lm,AAa)) //Last two points to make circle look right.
		//OUTLINE
	}
	else
	{
		//SECTOR
		draw_primitive_begin(pr_trianglefan) //Change to pr_linestrip, to see how it works.
		draw_vertex(xx,yy) //First point in the circle's center.
		for(i=1; i<=B; i+=1)
		{
			dp=A+a*i
			dm=dp-a
			draw_vertex(xx+lengthdir_x(lp,dm),yy+lengthdir_y(lp,dm))
		}
		draw_vertex(xx+lengthdir_x(lp,AAa),yy+lengthdir_y(lp,AAa)) //Last point.
		//SECTOR
	}
	draw_primitive_end()


}