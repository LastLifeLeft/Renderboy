//if (live_call()) return live_result;

var _mouse_delta/*:int*/ = mouse_wheel_down() * -1 + mouse_wheel_up();
var _modifier_control/*:int*/ = keyboard_check(vk_control);
var _modifier_shift/*:int*/ = keyboard_check(vk_shift);
var _modifier_alt/*:int*/ = keyboard_check(vk_alt);
var _target_cursor = cr_default;
var _resize = false;

if (_mouse_delta != 0)
{
	if (_modifier_control)
	{
		var _new_scale = clamp(frame_scale + (_mouse_delta * 0.05), 0.25, 3);
		var _scale_change = frame_scale - _new_scale
		frame_scale = _new_scale;
		
		frame_draw_x += (_scale_change * target_width * 0.5);
		frame_draw_y += (_scale_change * target_height * 0.5);
		
	}
}

if (mouse_check_button(mb_middle))
{
	var _mouse_delta_x = mouse_previous_x - mouse_x;
	var _mouse_delta_y = mouse_previous_y - mouse_y;
	
	frame_draw_x -= _mouse_delta_x;
	frame_draw_y -= _mouse_delta_y;
	
	_target_cursor = cr_size_all;
}

mouse_previous_x = mouse_x;
mouse_previous_y = mouse_y;

var _event = UI_tick();

while _event
{
	switch _event
	{
		case UI_EEvent.Edit: #region
			editing_asset =  global.mediablock_map[? UI_get_event_mediablock()];
			break;
			#endregion
		case UI_EEvent.ReRender: #region
			ds_list_clear(render_list);
			
			var _keep_edit = false;
			
			for (var _loop/*:int*/ = layer_count - 1; _loop > -1; _loop--)
			{
				if (UI_examine_layer(_loop))
				{
					var _mediablock_uuid = UI_next_mediablock_uuid(_loop);
					
					while  (_mediablock_uuid != "")
					{
						var _mediablock = global.mediablock_map[? _mediablock_uuid];
						
						if (is_undefined(_mediablock))
						{
							switch (UI_get_mediablock_type(_mediablock_uuid))
							{
								case  UI_EAssetType.Image:
									_mediablock = new MediaBlock2D(_mediablock_uuid, UI_EAssetType.Image);
									break;
								case  UI_EAssetType.Video :
									_mediablock = new MediaBlock2D(_mediablock_uuid, UI_EAssetType.Video);
									break;
								case  UI_EAssetType.Sound :
								
									break;
								case  UI_EAssetType.Music :
								
									break;
								case  UI_EAssetType.Voice :
								
									break;
								case  UI_EAssetType.Character :
								
									break;
								case  UI_EAssetType.Model :
								
									break;
							}
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

if (_resize)
{
	var _new_width = UI_get_width();
	var _new_height = UI_get_height();
	//show_debug_message(UI_get_height());
	
	frame_draw_x += (_new_width - window_width) * 0.5
	frame_draw_y += (_new_height - window_height) * 0.5
	
	window_width = _new_width;
	window_height = _new_height;
	
	window_set_size(window_width, window_height);
}

if (_target_cursor != mouse_cursor)
{
	mouse_cursor = _target_cursor;
	window_set_cursor(mouse_cursor);
}