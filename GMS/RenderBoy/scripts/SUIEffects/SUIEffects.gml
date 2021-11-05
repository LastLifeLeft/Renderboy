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