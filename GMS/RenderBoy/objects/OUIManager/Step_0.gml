var _event = UI_tick();

while _event
{
	switch _event
	{
		case UI_EEvent.ReRender:
			var _layer = UI_count_layer();
			show_debug_message(_layer);
			break;
		case UI_EEvent.Resize:
			surface_resize(application_surface, UI_get_width(), UI_get_height());
			break;
		case UI_EEvent.End:
			game_end()
			break;
	}
	
	var _event = UI_tick();
}