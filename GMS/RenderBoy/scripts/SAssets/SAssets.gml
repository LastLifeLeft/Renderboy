function AssetImage(_UUID) constructor
{
	UUID = _UUID;
	width = UI_get_asset_width(UUID);
	height = UI_get_asset_height(UUID);
	
	path = UI_get_asset_path(UUID);
	
	sprite = sprite_add(path, 1, false, false, width * 0.5, height * 0.5);

	draw = function(_parent, _state)
	{
		draw_sprite_ext(sprite, 0,  _state.X, _state.Y, _state.Width / width,  _state.Height / height, _state.Angle, c_white, _state.Transparency)
	}

	draw_tiled = function(_parent, _state)
	{
		var _tex_repeat = gpu_get_tex_repeat();
		gpu_set_tex_repeat(true);
		
		draw_primitive_begin_texture(pr_trianglelist, sprite_get_texture(sprite, 0));
		var _x1 = (_state.X - _state.Width)
		var _y1 = (_state.Y - _state.Height)
		
		var _x3 = (_state.X + _state.Width)
		var _y3 = (_state.Y + _state.Height)
		
		var xtex = (_x3 - _x1) / width;
		var ytex = (_y3 - _y1) / height;
		
		draw_vertex_texture(_x1, _y1, 0, 0);
		draw_vertex_texture(_x3, _y1, xtex, 0);
		draw_vertex_texture(_x3, _y3, xtex, ytex);

		draw_vertex_texture(_x3, _y3, xtex, ytex);
		draw_vertex_texture(_x1, _y3, 0, ytex);
		draw_vertex_texture(_x1, _y1, 0, 0);

		draw_primitive_end();
		gpu_set_tex_repeat(_tex_repeat);
	}
	
	default_draw = draw;
}

function AssetVideo(_UUID) constructor
{
	UUID = _UUID;
	
	draw = function(_parent, _state)
	{
		
	}
}


enum RB_EEffect
{
	Blur,
	Tile,
	Mask,
	SomethingElse,
    SIZE
}





//tex_array[0] = 0.5;
//tex_array[1] = 0.1;
//tex_array[2] = 0.25;




