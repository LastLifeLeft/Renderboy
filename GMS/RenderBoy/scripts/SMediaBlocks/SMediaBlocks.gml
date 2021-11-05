#macro MEDIABLOCK_STATE \
	state = undefined;\
	submedia = ds_list_create()\
	\
	update = function()\
	{\
		state = json_parse(UI_get_asset_state(UUID));\
	}\


function MediaBlock2D(_UUID, _type) constructor
{
	UUID = _UUID;
	asset_UUID = UI_get_asset_uuid(UUID);
	asset = global.asset_map[? asset_UUID];
	type = _type;
	
	if is_undefined(asset)
	{
		if (type == UI_EAssetType.Image)
		{
			asset = new AssetImage(asset_UUID);
		}
		else
		{
			
		}
	}
	
	ds_map_add(global.mediablock_map, UUID, self)
	
	image_width = asset.width;
	image_height = asset.height;

	MEDIABLOCK_STATE
	
	render = function()
    {
		// Alooors... Il faudrait browser la liste de submedia
		
		asset.predraw(self, state);
		asset.draw(self, state);
		asset.postdraw(self, state);
		
    }
	
	edit = function()
    {
		//step ++;
		//step %= 16
		
		//var _angle = array_create(4);
		
		//var _half_width = floor(_state.width * 0.5)
		//var _half_height = floor(_state.height * 0.5)
		
		//_angle[0] = point_direction(0, 0, - _half_width, - _half_height);
		//_angle[2] = (_angle[0] + 180) % 360
		//_angle[1] = 360 - _angle[2]
		//_angle[3] = (_angle[1] + 180) % 360
		
		//var _image_len = point_distance(0,0, - _half_width, - _half_height);
		
		//var _cursor = cr_default
		
		//var x1 = _state.x + lengthdir_x(_image_len, _angle[0]);
		//var y1 = _state.y + lengthdir_y(_image_len, _angle[0]);
		
		//var x2 = _state.x + lengthdir_x(_image_len + 1, _angle[1]);
		//var y2 = _state.y + lengthdir_y(_image_len, _angle[1]);
		
		//var x3 = _state.x + lengthdir_x(_image_len + 1, _angle[2]);
		//var y3 = _state.y + lengthdir_y(_image_len + 1, _angle[2]);
		
		//var x4 = _state.x + lengthdir_x(_image_len, _angle[3]);
		//var y4 = _state.y + lengthdir_y(_image_len + 1, _angle[3]);
		
		//var _lengthdir_x = lengthdir_x(_half_width, 0);
		//var _lengthdir_y = lengthdir_y(_half_height, 0);
		
		//var x5 =  _state.x + _lengthdir_x
		//var y5 =  _state.y + _lengthdir_y
		
		//var x7 = _state.x - _lengthdir_x
		//var y7 = _state.y - _lengthdir_y
		
		//_lengthdir_x = lengthdir_x(_half_width, 90);
		//_lengthdir_y = lengthdir_y(_half_height, 90);
		
		//var x6 = _state.x + _lengthdir_x
		//var y6 = _state.y + _lengthdir_y
		
		//var x8 = _state.x - _lengthdir_x
		//var y8 = _state.y - _lengthdir_y
		
		//draw_selection_rectangle(x1, y1, x2, y2, x3, y3, x4, y4, 2, SprSelection, step / 16);
		
		//if (state_drag)
		//{
		//	_state.x += mouse_x - state_previous_mouse_x
		//	_state.y += mouse_y - state_previous_mouse_y
			
		//	state_previous_mouse_x = mouse_x
		//	state_previous_mouse_y = mouse_y
			
		//	_cursor = cr_size_all;
			
		//	if mouse_check_button_released(mb_left)
		//	{
		//		state_drag = false;
		//		UI_set_asset_state(ObjUIManager.layer_edit, json_stringify( _state))
		//	}
		//}
		//else if (state_rotation)
		//{
			
		//}
		//else if (state_scale)
		//{
		//	var _width = state_original_mouse_x - mouse_x;
		//	var _height =  state_original_mouse_y - mouse_y;
			
		//	switch state_scale
		//	{
		//		case 1: #region Top Left
		//			_state.height = State_origial_height + _height;
		//			_state.y = state_original_y - floor(_height * 0.5);
		//			_state.width = State_origial_width + _width
		//			_state.x = state_original_x - floor(_width * 0.5);
					
		//			break;
		//			#endregion
		//		case 2: #region bottom right
		//			_state.height = State_origial_height - _height;
		//			_state.y = state_original_y - floor(_height * 0.5);
		//			_state.width = State_origial_width - _width;
		//			_state.x = state_original_x - floor(_width * 0.5);
				
		//			break;
		//			#endregion
		//		case 3: #region Top right
		//			_state.height = State_origial_height + _height;
		//			_state.y = state_original_y - floor(_height * 0.5);
		//			_state.width = State_origial_width - _width;
		//			_state.x = state_original_x - floor(_width * 0.5);
				
		//			break;
		//			#endregion
		//		case 4: #region bottom left
		//			_state.height = State_origial_height - _height;
		//			_state.y = state_original_y - floor(_height * 0.5);
		//			_state.width = State_origial_width + _width;
		//			_state.x = state_original_x - floor(_width * 0.5);
				
		//			break;
		//			#endregion
		//		case 5: #region right
		//			_state.width = State_origial_width - _width;
		//			_state.x = state_original_x - floor(_width * 0.5);
					
		//			break;
		//			#endregion
		//		case 6: #region top
		//			_state.height = State_origial_height + _height;
		//			_state.y = state_original_y - floor(_height * 0.5);
					
		//			break;
		//			#endregion
		//		case 7: #region Left
		//			_state.width = State_origial_width + _width;
		//			_state.x = state_original_x - floor(_width * 0.5);
		//			break;
		//			#endregion
		//		case 8: #region bottom
		//			_state.height = State_origial_height - _height;
		//			_state.y = state_original_y - floor(_height * 0.5);
					
		//			break;
		//			#endregion
		//	}
			
		//	_cursor = global.cursor;
			
		//	if mouse_check_button_released(mb_left)
		//	{
		//		state_scale = false;
		//		UI_set_asset_state(ObjUIManager.layer_edit, json_stringify( _state))
		//	}
		//}
		//else
		//{
		//	if ((mouse_x >= x1 - 8) && (mouse_x <= x1 + 8) && (mouse_y >= y1 - 8) && (mouse_y <= y1 + 8))
		//	{
		//		_cursor = cr_size_nwse;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 1;
		//		}
		//	}
		//	else if ((mouse_x >= x2 - 8) && (mouse_x <= x2 + 8) && (mouse_y >= y2 - 8) && (mouse_y <= y2 + 8))
		//	{
		//		_cursor = cr_size_nesw;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 3;
		//		}
		//	}
		//	else if ((mouse_x >= x3 - 8) && (mouse_x <= x3 + 8) && (mouse_y >= y3 - 8) && (mouse_y <= y3 + 8))
		//	{
		//		_cursor = cr_size_nwse;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 2;
		//		}
		//	}
		//	else if ((mouse_x >= x4 - 8) && (mouse_x <= x4 + 8) && (mouse_y >= y4 - 8) && (mouse_y <= y4 + 8))
		//	{
		//		_cursor = cr_size_nesw;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 4;
		//		}
		//	}
		//	else if ((mouse_x >= x5 - 8) && (mouse_x <= x5 + 8) && (mouse_y >= y5 - 8) && (mouse_y <= y5 + 8))
		//	{
		//		_cursor = cr_size_we;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 5;
		//		}
		//	}
		//	else if ((mouse_x >= x6 - 8) && (mouse_x <= x6 + 8) && (mouse_y >= y6 - 8) && (mouse_y <= y6 + 8))
		//	{
		//		_cursor = cr_size_ns;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 6;
		//		}
		//	}
		//	else if ((mouse_x >= x7 - 8) && (mouse_x <= x7 + 8) && (mouse_y >= y7 - 8) && (mouse_y <= y7 + 8))
		//	{
		//		_cursor = cr_size_we;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 7;
		//		}
		//	}
		//	else if ((mouse_x >= x8 - 8) && (mouse_x <= x8 + 8) && (mouse_y >= y8 - 8) && (mouse_y <= y8 + 8))
		//	{
		//		_cursor = cr_size_ns;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_scale = 8;
		//			state_original_mouse_x = mouse_x;
		//			state_original_mouse_y = mouse_y;
		//		}
		//	}
		//	else
		//	{
		//		_cursor = cr_size_all;
		//		if mouse_check_button_pressed(mb_left)
		//		{
		//			state_drag = true
		//			state_previous_mouse_x = mouse_x;
		//			state_previous_mouse_y = mouse_y;
		//		}
		//	}
			
		//	if state_scale
		//	{
		//		state_original_mouse_x = mouse_x;
		//		state_original_mouse_y = mouse_y;
		//		State_origial_width = _state.width;
		//		State_origial_height = _state.height;
		//		state_original_x = _state.x;
		//		state_original_y = _state.y;
		//	}
			
		//}
		
		//draw_sprite(SprAnchor, 0, x1, y1);
		//draw_sprite(SprAnchor, 0, x2, y2);
		//draw_sprite(SprAnchor, 0, x3, y3);
		//draw_sprite(SprAnchor, 0, x4, y4);
		
		//draw_sprite(SprAnchor, 0, x5, y5);
		//draw_sprite(SprAnchor, 0, x6, y6);
		//draw_sprite(SprAnchor, 0, x7, y7);
		//draw_sprite(SprAnchor, 0, x8, y8);
		
		//if (global.cursor != _cursor)
		//{
		//	global.cursor = _cursor;
		//	window_set_cursor(_cursor);
		//}
	}
	
}