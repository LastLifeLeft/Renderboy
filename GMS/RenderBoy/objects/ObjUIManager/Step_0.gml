var _event = UI_tick();

while _event
{
	switch _event
	{
		case UI_EEvent.ReRender: #region
			var _layer = UI_count_layer();
			show_debug_message("---");
			
			layer_edit = -1;
			
			if global.cursor != cr_default
			{
				global.cursor = cr_default;
				window_set_cursor(cr_default);
			}
			
			layer_list_size = 0;
			ds_list_clear(layer_list);
			
			for (var i = 0; i < _layer; i++)
			{
				var _asset = UI_get_asset(i);
				
				if (_asset != "")
				{
					var _object = asset_map[? _asset]
					
					if is_undefined(_object)
					{
						switch UI_get_asset_type(_asset)
						{
							case  UI_EAssetType.Image :
								asset_map[? _asset] = new AssetImage(_asset);
								_object = asset_map[? _asset];
								break;
							case  UI_EAssetType.Video :
								
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
					
					layer_list_size ++;
					ds_list_add(layer_list, [_object, i, json_parse( UI_get_asset_state(i))]);
				}
			}
			
			break; #endregion
		case UI_EEvent.Edit: #region
			layer_edit = UI_get_edit_line();
			break; #endregion
		case UI_EEvent.Resize: #region
			screen_height = UI_get_height();
			screen_width = UI_get_width();
			
			if (screen_width / target_width) < (screen_height / target_height)
			{
				frame_draw_x = 0
				frame_draw_width = screen_width
				frame_draw_height = round((screen_width / target_width) * target_height)
				frame_draw_y = round((screen_height - frame_draw_height) * 0.5)
				
			}
			else
			{
				frame_draw_y = 0
				frame_draw_height = screen_height
				frame_draw_width = round((screen_height / target_height) * target_width)
				frame_draw_x = round((screen_width - frame_draw_width) * 0.5)
			}
			
			frame_scale = frame_draw_width / target_width;
			
			break; #endregion
		case UI_EEvent.End: #region
			game_end()
			break;
			#endregion
	}
	
	var _event = UI_tick();
}