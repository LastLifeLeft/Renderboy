#macro MEDIABLOCK_STATE \
	state = undefined;\
	submedia = ds_list_create()

enum MB_EEditState
{
	Hover,
	Rotate,
	Move,
	Resize
}

enum MB_EEffectType
{
	Blur,
	Tiled,
	FadeIn,
	FadeOut
}

function MediaBlock2D(_UUID, _type) constructor
{
	UUID = _UUID;
	asset_UUID = UI_get_asset_uuid(UUID);
	asset = global.asset_map[? asset_UUID];
	type = _type;
	parent = 0;
	
	edit_count = 0
	edit_corner = array_create(4);
	edit_state = MB_EEditState.Hover;
	edit_direction = 0;
	edit_angle = 0;
	edit_x = 0;
	edit_y = 0;
	mouse_previous_x = 0;
	mouse_previous_y = 0;
	
	backup_state = {
	    X : 0,
	    Y : 0,
		Width : 0,
		Height : 0,
		Angle : 0,
		Transparency : 1
	};
	
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

	MEDIABLOCK_STATE
	
	update = function(get_asset_state = true)
	{
		if get_asset_state
		{
			state = json_parse(UI_get_asset_state(UUID));
			
			ds_list_clear(submedia);
			if (UI_examine_submedia(UUID))
			{
				var _submedia_uuid = UI_next_submedia_uuid(UUID);
				
				while (_submedia_uuid != "")
				{
					var _submedia = global.mediablock_map[? _submedia_uuid];
				
					if (is_undefined(_submedia))
					{
						_submedia = mediablock_load(_submedia_uuid);
					}
				
					ds_list_add(submedia, _submedia);
					
					_submedia.update();
					_submedia.parent = self;
					
					var _submedia_uuid = UI_next_submedia_uuid(UUID);
				}
			}
		}
		
		var _half_width = floor(state.Width * 0.5 * ObjUIManager.frame_scale)
		var _half_height = floor(state.Height * 0.5 * ObjUIManager.frame_scale)
		
		edit_corner[0] = point_direction(0, 0, -_half_width, -_half_height) + state.Angle;
		edit_corner[1] = point_direction(0, 0, _half_width, -_half_height) + state.Angle;
		edit_corner[2] = point_direction(0, 0, _half_width, _half_height) + state.Angle;
		edit_corner[3] = point_direction(0, 0, -_half_width, _half_height) + state.Angle;
		
		var _image_len = point_distance(0,0, - _half_width, - _half_height);
		x = ObjUIManager.frame_draw_x + (state.X * ObjUIManager.frame_scale)
		y = ObjUIManager.frame_draw_y + (state.Y * ObjUIManager.frame_scale)
		
		x1 = x + lengthdir_x(_image_len, edit_corner[0]);
		y1 = y + lengthdir_y(_image_len, edit_corner[0]);
		
		x2 = x + lengthdir_x(_image_len + 1, edit_corner[1]);
		y2 = y + lengthdir_y(_image_len, edit_corner[1]);
		
		x3 = x + lengthdir_x(_image_len + 1, edit_corner[2]);
		y3 = y + lengthdir_y(_image_len + 1, edit_corner[2]);
		
		x4 = x + lengthdir_x(_image_len, edit_corner[3]);
		y4 = y + lengthdir_y(_image_len + 1, edit_corner[3]);
		
		x9 = x + lengthdir_x(_image_len + 20, edit_corner[0]);
		y9 = y + lengthdir_y(_image_len + 20, edit_corner[0]);
		
		x10 = x + lengthdir_x(_image_len + 21, edit_corner[1]);
		y10 = y + lengthdir_y(_image_len + 20, edit_corner[1]);
		
		x11 = x + lengthdir_x(_image_len + 21, edit_corner[2]);
		y11 = y + lengthdir_y(_image_len + 21, edit_corner[2]);
		
		x12 = x + lengthdir_x(_image_len + 20, edit_corner[3]);
		y12 = y + lengthdir_y(_image_len + 21, edit_corner[3]);
		
		
		//Right
		x5 = (x2 + x3) * 0.5
		y5 = (y2 + y3) * 0.5
		
		//top
		x6 = (x1 + x2) * 0.5
		y6 = (y1 + y2) * 0.5
		
		//Left
		x7 = (x1 + x4) * 0.5
		y7 = (y1 + y4) * 0.5
		
		// Bottom
		x8 = (x4 + x3) * 0.5
		y8 = (y4 + y3) * 0.5
	}
	
	pre_render = function()
	{
	}
	
	post_render = function()
	{
	}
	
	render = function()
    {
		var _listsize = ds_list_size(submedia);
		
		for (var i = 0; i < _listsize; i++)
		{
			submedia[| i].pre_render();
		}
		
		asset.draw(self, state);
		
		for (var i = 0; i < _listsize; i++)
		{
			submedia[| i].post_render();
		}
    }
	
	edit_step = function()
    {
		var _mouse_x = window_mouse_get_x();
		var _mouse_y = window_mouse_get_y();
		
		edit_count = ++ edit_count % 16;
		
		switch (edit_state)
		{
			case MB_EEditState.Hover: #region
				if point_in_rectangle(_mouse_x, _mouse_y, x1 - 7, y1 - 7, x1 + 7, y1 + 7) // Top left
				{
					ObjUIManager.target_cursor = SprCursorsSizeNWSE;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 7;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x2 - 7, y2 - 7, x2 + 7, y2 + 7) // Top right
				{
					ObjUIManager.target_cursor = SprCursorsSizeNESW;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 1;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x3 - 7, y3 - 7, x3 + 7, y3 + 7) // bottom right
				{
					ObjUIManager.target_cursor = SprCursorsSizeNWSE;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 3;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x4 - 7, y4 - 7, x4 + 7, y4 + 7) // bottom left
				{
					ObjUIManager.target_cursor = SprCursorsSizeNESW;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 5;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x5 - 7, y5 - 7, x5 + 7, y5 + 7) // right
				{
					ObjUIManager.target_cursor = SprCursorsSizeWE;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 2;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x6 - 7, y6 - 7, x6 + 7, y6 + 7) // top
				{
					ObjUIManager.target_cursor = SprCursorsSizeNS;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 0;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x7 - 7, y7 - 7, x7 + 7, y7 + 7) // left
				{
					ObjUIManager.target_cursor = SprCursorsSizeWE;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 6;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x8 - 7, y8 - 7, x8 + 7, y8 + 7) // bottom
				{
					ObjUIManager.target_cursor = SprCursorsSizeNS;
					
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Resize;
						edit_direction = 4;
					}
				}
				else if (PointInRotatedRectangle(_mouse_x, _mouse_y, x, y,
												 (state.Width * 0.5) * ObjUIManager.frame_scale,
												 (state.Height * 0.5) * ObjUIManager.frame_scale,
												 state.Width * ObjUIManager.frame_scale,
												 state.Height * ObjUIManager.frame_scale, state.Angle))
				{
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Move;
					}
					ObjUIManager.target_cursor = SprCursorSizeAll;
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x9 - 9, y9 - 9, x9 + 9, y9 + 9) // Rotate Top left
				{
					ObjUIManager.target_cursor = SprCursorsRotateNW;
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Rotate;
						edit_direction = ObjUIManager.target_cursor;
						edit_angle = point_direction(state.X * ObjUIManager.frame_scale + ObjUIManager.frame_draw_x, state.Y * ObjUIManager.frame_scale + ObjUIManager.frame_draw_y, x1, y1);
						mouse_previous_x = _mouse_x;
						mouse_previous_y = _mouse_y;
						
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x10 - 9, y10 - 9, x10 + 9, y10 + 9) // Rotate Top right
				{
					ObjUIManager.target_cursor = SprCursorsRotateNE;
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Rotate;
						edit_direction = ObjUIManager.target_cursor;
						edit_angle = point_direction(state.X * ObjUIManager.frame_scale + ObjUIManager.frame_draw_x, state.Y * ObjUIManager.frame_scale + ObjUIManager.frame_draw_y, x2, y2);
						mouse_previous_x = _mouse_x;
						mouse_previous_y = _mouse_y;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x11 - 9, y11 - 9, x11 + 9, y11 + 9) // Rotate bottom right
				{
					ObjUIManager.target_cursor = SprCursorsRotateSE;
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Rotate;
						edit_direction = ObjUIManager.target_cursor;
						edit_angle = point_direction(state.X * ObjUIManager.frame_scale + ObjUIManager.frame_draw_x, state.Y * ObjUIManager.frame_scale + ObjUIManager.frame_draw_y, x3, y3);
						mouse_previous_x = _mouse_x;
						mouse_previous_y = _mouse_y;
					}
				}
				else if point_in_rectangle(_mouse_x, _mouse_y, x12 - 9, y12 - 9, x12 + 9, y12 + 9) // Rotate bottom left
				{
					ObjUIManager.target_cursor = SprCursorsRotateSW;
					if (mouse_check_button_pressed(mb_left))
					{
						edit_state = MB_EEditState.Rotate;
						edit_direction = ObjUIManager.target_cursor;
						edit_angle = point_direction(state.X * ObjUIManager.frame_scale + ObjUIManager.frame_draw_x, state.Y * ObjUIManager.frame_scale + ObjUIManager.frame_draw_y, x4, y4);
						mouse_previous_x = _mouse_x;
						mouse_previous_y = _mouse_y;
					}
				}
				
				if (edit_state != MB_EEditState.Hover)
				{
						var _array = variable_struct_get_names(state);
						for (var i = 0; i < array_length(_array); i++;)
						{
							variable_struct_set(backup_state, _array[i], variable_struct_get(state, _array[i]))
						}
						
						edit_x = _mouse_x;
						edit_y = _mouse_y;
				}
				
				break;
				#endregion
			case MB_EEditState.Move: #region
				ObjUIManager._mouse_button = 0 // disable preview movement
				ObjUIManager.mouse_delta = 0 //disable preview zoom
				var _x = backup_state.X + round((_mouse_x - edit_x) / ObjUIManager.frame_scale);
				var _y = backup_state.Y + round((_mouse_y - edit_y) / ObjUIManager.frame_scale);
				
				
				ObjUIManager.target_cursor = SprCursorSizeAll;
				
				if (mouse_check_button_pressed(mb_right) or keyboard_check_pressed(vk_escape))
				{
					edit_state = MB_EEditState.Hover;
					var _array = variable_struct_get_names(state);
					for (var i = 0; i < array_length(_array); i++;)
					{
						variable_struct_set(state, _array[i], variable_struct_get(backup_state, _array[i]))
					}
					UI_set_properties(json_stringify(state));
					self.update(false);
					return true;
				}
				else if (!mouse_check_button(mb_left))
				{
					UI_set_mediablock_state(UUID, json_stringify(state));
					edit_state = MB_EEditState.Hover;
				}
				
				if (ObjUIManager.modifier_shift)
				{
					var _angle = point_direction(backup_state.X, backup_state.Y, _x, _y);
					
					if (_angle % 90 > 32 and _angle % 90 < 58) // we need to expend the cardinal zone and reduce the diagonals.
					{
						_angle = round(_angle / 45) * 45;
					}
					else
					{
						_angle = round(_angle / 90) * 90;
					}
					
					if (_angle % 90)
					{
						var _distance = min(abs(_x - backup_state.X), abs(_y - backup_state.Y)) * sqrt(2);
						
						_x = backup_state.X + lengthdir_x(_distance, _angle);
						_y = backup_state.Y + lengthdir_y(_distance, _angle);
					}
					else
					{
						_x = backup_state.X + abs(_x - backup_state.X) * lengthdir_x(1, _angle);
						_y = backup_state.Y + abs(_y - backup_state.Y) * lengthdir_y(1, _angle);
					}
				}
				
				if (_x != state.X) || (_y != state.Y)
				{
					state.X = _x;
					state.Y = _y;
					self.update(false);
					UI_set_properties(json_stringify(state));
					return true;
				}
				
				break;
				#endregion
			case MB_EEditState.Resize: #region
				ObjUIManager._mouse_button = 0 // disable preview movement
				ObjUIManager.mouse_delta = 0 //disable preview zoom
				
				var _offset_y = 0;
				var _offset_x = 0;
				var _height = state.Height;
				var _width = state.Width;
				var _x = state.X;
				var _y = state.Y;
				
				switch edit_direction
				{
					case 0: // Top
						_offset_y =  round((_mouse_y - edit_y) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							_offset_x = round((_offset_y / backup_state.Height) * backup_state.Width);
						}
						
						_y = round(backup_state.Y + _offset_y * 0.5);
						
						ObjUIManager.target_cursor = SprCursorsSizeNS;
						break;
					case 1: // Top right
						_offset_y =  round((_mouse_y - edit_y) / ObjUIManager.frame_scale);
						_offset_x =  round((edit_x - _mouse_x) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							if (_offset_y / backup_state.Height) > (_offset_x / backup_state.Width) 
							{
								_offset_x = round((_offset_y / backup_state.Height) * backup_state.Width);
							}
							else
							{
								_offset_y = round((_offset_x / backup_state.Width) * backup_state.Height);
							}
						}
						
						_x = round(backup_state.X - _offset_x * 0.5);
						_y = round(backup_state.Y + _offset_y * 0.5);
						ObjUIManager.target_cursor = SprCursorsSizeNESW;
						break;
					case 2: // Right
						_offset_x =  round((edit_x - _mouse_x) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							_offset_y = round((_offset_x / backup_state.Width) * backup_state.Height);
						}
						
						_x = round(backup_state.X - _offset_x * 0.5);
						
						ObjUIManager.target_cursor = SprCursorsSizeWE;
						break;
					case 3: // Bottom right
						_offset_x =  round((edit_x - _mouse_x) / ObjUIManager.frame_scale);
						_offset_y =  round((edit_y - _mouse_y) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							if (_offset_y / backup_state.Height) > (_offset_x / backup_state.Width) 
							{
								_offset_x = round((_offset_y / backup_state.Height) * backup_state.Width);
							}
							else
							{
								_offset_y = round((_offset_x / backup_state.Width) * backup_state.Height);
							}
						}
						
						_x = round(backup_state.X - _offset_x * 0.5);
						_y = round(backup_state.Y - _offset_y * 0.5);
						
						ObjUIManager.target_cursor = SprCursorsSizeNWSE;
						break;
					case 4: // Bottom
						_offset_y =  round((edit_y - _mouse_y) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							_offset_x = round((_offset_y / backup_state.Height) * backup_state.Width);
						}
						
						_y = round(backup_state.Y - _offset_y * 0.5);
						
						ObjUIManager.target_cursor = SprCursorsSizeNS;
						break;
					case 5: // Bottom left
						_offset_x =  round((_mouse_x - edit_x) / ObjUIManager.frame_scale);
						_offset_y =  round((edit_y - _mouse_y) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							if (_offset_y / backup_state.Height) > (_offset_x / backup_state.Width) 
							{
								_offset_x = round((_offset_y / backup_state.Height) * backup_state.Width);
							}
							else
							{
								_offset_y = round((_offset_x / backup_state.Width) * backup_state.Height);
							}
						}
						
						_x = round(backup_state.X + _offset_x * 0.5);
						_y = round(backup_state.Y - _offset_y * 0.5);
						
						ObjUIManager.target_cursor = SprCursorsSizeNESW;
						break;
					case 6: // left
						_offset_x =  round((_mouse_x - edit_x) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							_offset_y = round((_offset_x / backup_state.Width) * backup_state.Height);
						}
						
						_x = round(backup_state.X + _offset_x * 0.5);
						
						ObjUIManager.target_cursor = SprCursorsSizeWE;
						break;
					case 7: // top left
						_offset_y =  round((_mouse_y - edit_y) / ObjUIManager.frame_scale);
						_offset_x =  round((_mouse_x - edit_x) / ObjUIManager.frame_scale);
						
						if ObjUIManager.modifier_shift
						{
							if (_offset_y / backup_state.Height) > (_offset_x / backup_state.Width) 
							{
								_offset_x = round((_offset_y / backup_state.Height) * backup_state.Width);
							}
							else
							{
								_offset_y = round((_offset_x / backup_state.Width) * backup_state.Height);
							}
						}
						
						_x = round(backup_state.X + _offset_x * 0.5);
						_y = round(backup_state.Y + _offset_y * 0.5);
						ObjUIManager.target_cursor = SprCursorsSizeNWSE;
						break;
				}
				
				_width = backup_state.Width - _offset_x;
				_height = backup_state.Height - _offset_y;
				
				if (mouse_check_button_pressed(mb_right) or keyboard_check_pressed(vk_escape))
				{
					edit_state = MB_EEditState.Hover;
					var _array = variable_struct_get_names(state);
					for (var i = 0; i < array_length(_array); i++;)
					{
						variable_struct_set(state, _array[i], variable_struct_get(backup_state, _array[i]))
					}
					UI_set_properties(json_stringify(state));
					self.update(false);
					return true;
				}
				else if (!mouse_check_button(mb_left))
				{
					UI_set_mediablock_state(UUID, json_stringify(state));
					edit_state = MB_EEditState.Hover;
				}
				
				if (_width != state.Width) || (_height != state.Height) ||  (_x != state.X) ||  (_y != state.Y)
				{
					state.Width = _width;
					state.Height = _height;
					state.X = _x;
					state.Y = _y;
					UI_set_properties(json_stringify(state));
					self.update(false);
					return true;
				}
				
				break;
				#endregion
			case MB_EEditState.Rotate: #region
				ObjUIManager._mouse_button = 0 // disable preview movement
				ObjUIManager.mouse_delta = 0 //disable preview zoom
				
				ObjUIManager.target_cursor = edit_direction;
				var _angle = point_direction(state.X * ObjUIManager.frame_scale + ObjUIManager.frame_draw_x , state.Y * ObjUIManager.frame_scale + ObjUIManager.frame_draw_y, _mouse_x, _mouse_y);
				_angle = angle_difference(_angle, point_direction(state.X * ObjUIManager.frame_scale + ObjUIManager.frame_draw_x , state.Y * ObjUIManager.frame_scale + ObjUIManager.frame_draw_y, mouse_previous_x, mouse_previous_y));
				
				if (mouse_check_button_pressed(mb_right) or keyboard_check_pressed(vk_escape))
				{
					edit_state = MB_EEditState.Hover;
					state.Angle = backup_state.Angle;
					UI_set_properties(json_stringify(state));
					self.update(false);
					return true;
				}
				else if (!mouse_check_button(mb_left))
				{
					UI_set_mediablock_state(UUID, json_stringify(state));
					edit_state = MB_EEditState.Hover;
				}
				
				if (_angle != 0)
				{
					mouse_previous_x = _mouse_x;
					mouse_previous_y = _mouse_y;
					state.Angle += _angle
					UI_set_properties(json_stringify(state));
					self.update(false);
					return true;
				}
				
				break;
				#endregion
		}
		
		return false;
	}
	
	edit_draw = function()
    {
		draw_selection_rectangle(x1, y1, x2, y2, x3, y3, x4, y4, 1, SprSelection, edit_count / 16);
		
		draw_sprite(SprAnchor, 0, x1, y1);
		draw_sprite(SprAnchor, 0, x2, y2);
		draw_sprite(SprAnchor, 0, x3, y3);
		draw_sprite(SprAnchor, 0, x4, y4);
				
		draw_sprite(SprAnchor, 0, x5, y5);
		draw_sprite(SprAnchor, 0, x6, y6);
		draw_sprite(SprAnchor, 0, x7, y7);
		draw_sprite(SprAnchor, 0, x8, y8);
		
		switch (edit_state)
		{
			case MB_EEditState.Move: #region
				draw_set_alpha(0.4)
				draw_line_color(ObjUIManager.frame_draw_x + ObjUIManager.frame_scale * state.X,
								ObjUIManager.frame_draw_y + ObjUIManager.frame_scale * state.Y,
								ObjUIManager.frame_draw_x + ObjUIManager.frame_scale * backup_state.X,
								ObjUIManager.frame_draw_y + ObjUIManager.frame_scale * backup_state.Y,
								c_white, c_white);
				
				var _angle = point_direction(state.X, state.Y, backup_state.X, backup_state.Y);
				
				draw_set_halign(fa_center);
				draw_set_alpha(0.75);
				
				if (_angle > 90 and _angle < 270)
				{
					_angle += 180;
					draw_set_valign(fa_top);
				}
				else
				{
					draw_set_valign(fa_bottom);
				}
				
				draw_text_transformed(ObjUIManager.frame_draw_x + ObjUIManager.frame_scale * ((state.X + backup_state.X) * 0.5),
									  ObjUIManager.frame_draw_y + ObjUIManager.frame_scale * ((state.Y + backup_state.Y) * 0.5),
									  string(round(point_distance(state.X, state.Y, backup_state.X, backup_state.Y))) + " px",
									  1, 1, _angle);
									  
				draw_set_alpha(1)
				break;
				#endregion
			case MB_EEditState.Rotate : #region
				draw_set_alpha(0.4);
				var _distance = ObjUIManager.frame_scale * point_distance(0, 0, state.Width * 0.5, state.Height * 0.5) + 15
				
				draw_circle_curve(ObjUIManager.frame_draw_x + ObjUIManager.frame_scale * state.X,
								  ObjUIManager.frame_draw_y + ObjUIManager.frame_scale * state.Y,
								  _distance, 120, edit_angle, clamp(state.Angle - backup_state.Angle, -1440, 1440), 1, true);
								  
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				draw_set_alpha(0.85);
				
				var _angle =  edit_angle + (state.Angle - backup_state.Angle);
				if ((abs(_angle) % 360) > 90 and (abs(_angle) % 360) < 270)
				{
					_angle += 180;
				}
				
				draw_text_transformed(ObjUIManager.frame_draw_x + ObjUIManager.frame_scale * state.X + lengthdir_x(_distance + 25, edit_angle + (state.Angle - backup_state.Angle)),
									  ObjUIManager.frame_draw_y + ObjUIManager.frame_scale * state.Y + lengthdir_y(_distance + 25, edit_angle + (state.Angle - backup_state.Angle)),
									  string(round(state.Angle - backup_state.Angle))+ " deg",
									  1, 1, 0);
				
				draw_set_alpha(1);
				break;
				#endregion
		}
		
	}
	
}

function MediaBlock2DEffect(_UUID) constructor
{
	UUID = _UUID;
	effect_type = real(UI_get_asset_uuid(UUID));
	type = UI_EAssetType.Effect2D;
	parent = 0;
	block_position = 0;
	block_duration = 0;
	
	ds_map_add(global.mediablock_map, UUID, self)
	
	update = function(get_asset_state = true)
	{
		switch effect_type
		{
			case MB_EEffectType.FadeIn :
			case MB_EEffectType.FadeOut :
				block_position = UI_get_mediablock_position(UUID);
				block_duration = UI_get_mediablock_duration(UUID);
				break;
			case MB_EEffectType.Blur :
				
				break;
		}
	}
	
	pre_render = function()
	{
		switch effect_type
		{
			case MB_EEffectType.FadeIn :
				transparency = parent.state.Transparency;
				parent.state.Transparency = ce_tween_cubic_in(ObjUIManager.player_position - block_position, 0, 1, block_duration);
				break;
			case MB_EEffectType.FadeOut :
				transparency = parent.state.Transparency;
				parent.state.Transparency = ce_tween_cubic_out(ObjUIManager.player_position - block_position, 1, 0, block_duration);
				
				break;
			case MB_EEffectType.Blur :
				
				break;
			case MB_EEffectType.Tiled :
				if (parent and parent.type = UI_EAssetType.Image)
				{
					parent.asset.draw = parent.asset.draw_tiled;
				}
				break;
		}
	}
	
	post_render = function()
	{
		switch effect_type
		{
			case MB_EEffectType.Tiled :
				parent.asset.draw = parent.asset.default_draw;
				break;
			case MB_EEffectType.FadeIn :
			case MB_EEffectType.FadeOut :
				parent.state.Transparency = transparency;
				break;
		}
	}
	
	render = function()
    {
		
    }
	
	edit_step = function()
    {
		return false;
    }
	
	edit_draw = function()
    {
    }
	
}