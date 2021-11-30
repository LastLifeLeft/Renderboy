//if (live_call()) return live_result;

mouse_delta = mouse_wheel_down() * -1 + mouse_wheel_up();
_mouse_button = mouse_check_button(mb_middle);
modifier_control = UI_get_modifier_ctrl();
modifier_shift = UI_get_modifier_shift();

target_cursor = -1;
var _resize = false;

var _event = UI_tick();

while _event
{
	switch _event
	{
		case UI_EEvent.Edit: #region
			editing_asset =  global.mediablock_map[? UI_get_event_mediablock()];
			editing_asset.update();
			break;
			#endregion
		case UI_EEvent.ReRender: #region
			ds_list_clear(render_list);
			player_position = UI_get_player_position();
			var _keep_edit = false;
			
			for (var _loop/*:int*/ = layer_count - 1; _loop > -1; _loop--)
			{
				if (UI_examine_layer(_loop))
				{
					var _mediablock_uuid = UI_next_mediablock_uuid(_loop);
					
					while (_mediablock_uuid != "")
					{
						var _mediablock = global.mediablock_map[? _mediablock_uuid];
						
						if (is_undefined(_mediablock))
						{
							_mediablock = mediablock_load(_mediablock_uuid);
						}
						
						_mediablock.update();
						ds_list_add(render_list, _mediablock);
						
						_mediablock_uuid = UI_next_mediablock_uuid(_loop);
						
						if (_mediablock == editing_asset)
						{
							_keep_edit = true;
						}
					}
				}
			}
			
			if (_keep_edit == false)
			{
				editing_asset = false;
			}
			
			rerender = true;
			
			break;
			#endregion
		case UI_EEvent.Resize: #region
			_resize = true
			break;
			#endregion
		case UI_EEvent.End: #region
			game_end();
			break;
			#endregion
		case UI_EEvent.AddLayer: #region
			layer_count ++;
			break;
			#endregion
		case UI_EEvent.RemoveLayer: #region
			layer_count --;
			break;
			#endregion
	}
	var _event = UI_tick();
}

if (_resize) // Window resized
{
	var _new_width = UI_get_width();
	var _new_height = UI_get_height();
	//show_debug_message(UI_get_height());
	
	frame_draw_x += (_new_width - window_width) * 0.5
	frame_draw_y += (_new_height - window_height) * 0.5
	
	window_width = _new_width;
	window_height = _new_height;
	
	frame_draw_x = clamp(frame_draw_x, (frame_scale * target_width) * - 0.9, window_width - (frame_scale * target_width) * 0.1)
	frame_draw_y = clamp(frame_draw_y, (frame_scale * target_height) * - 0.9, window_height - (frame_scale * target_height) * 0.1)
	
	if (editing_asset)
	{
		editing_asset.update(false);
	}
	
	window_set_size(window_width, window_height);
	alarm_set(0,10);
}

if (editing_asset)
{
	rerender += editing_asset.edit_step();
}

if (mouse_delta != 0) // Scalling the preview
{
	if (modifier_control)
	{
		var _new_scale = clamp(frame_scale + (mouse_delta * 0.05), 0.25, 3);
		var _scale_change = frame_scale - _new_scale
		frame_scale = _new_scale;
		
		frame_draw_x += (_scale_change * target_width * 0.5);
		frame_draw_y += (_scale_change * target_height * 0.5);
		
		frame_draw_x = clamp(frame_draw_x, (frame_scale * target_width) * - 0.9, window_width - (frame_scale * target_width) * 0.1)
		frame_draw_y = clamp(frame_draw_y, (frame_scale * target_height) * - 0.9, window_height - (frame_scale * target_height) * 0.1)
		
		if (editing_asset)
		{
			editing_asset.update(false);
		}
	}
}

if (_mouse_button) // Moving the preview
{
	var mouse_delta_x = mouse_previous_x - mouse_x;
	var mouse_delta_y = mouse_previous_y - mouse_y;
	
	frame_draw_x -= mouse_delta_x;
	frame_draw_y -= mouse_delta_y;
	
	frame_draw_x = clamp(frame_draw_x, (frame_scale * target_width) * - 0.9, window_width - (frame_scale * target_width) * 0.1)
	frame_draw_y = clamp(frame_draw_y, (frame_scale * target_height) * - 0.9, window_height - (frame_scale * target_height) * 0.1)
	
	if (editing_asset)
	{
		editing_asset.update(false);
	}
	
	target_cursor = SprCursorsHandGrab;
	
}

mouse_previous_x = mouse_x;
mouse_previous_y = mouse_y;

if (target_cursor != mouse_cursor)
{
	mouse_cursor = target_cursor;
	if (mouse_cursor == -1)
	{
		window_set_cursor(cr_default);
		cursor_sprite = -1;
	}
	else
	{
		window_set_cursor(cr_none);
		cursor_sprite = target_cursor;
	}
	
}


