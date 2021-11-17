function AssetImage(_UUID) constructor
{
	UUID = _UUID;
	width = UI_get_asset_width(UUID);
	height = UI_get_asset_height(UUID);
	
	path = UI_get_asset_path(UUID);
	
	sprite = sprite_add(path, 1, false, false, width * 0.5, height * 0.5);
	
	predraw = function(_parent, _state)
	{
		
	}
	
	draw = function(_parent, _state)
	{
		better_scaling_draw_sprite(sprite, 0,  _state.X, _state.Y, _state.Width / width,  _state.Height / height, _state.Angle, c_white, _state.Transparency, 1);
	}
	
	postdraw = function(_parent, _state)
	{
		
	}
	
	default_predraw = predraw;
	default_draw = draw;
	default_postdraw = postdraw;
	
}

function AssetVideo(_UUID) constructor
{
	UUID = _UUID;
	
	predraw = function(_parent, _state)
	{
	}
	
	draw = function(_parent, _state)
	{
	}
	
	postdraw = function(_parent, _state)
	{
	}
	
}

function AssetFXReapeat(_UUID) constructor
{
	predraw = function(_parent, _state)
	{
		_parent.draw = newdraw;
	}
	
	draw = function(_parent, _state)
	{
	}
	
	postdraw = function(_parent, _state)
	{
		_parent.draw = _parent.default_draw;
	}
	
	newdraw = function(_parent, _state)
	{
		
	}
	
}