enum UI_EEvent
{
	None,
	End,
	Resize,
	ReRender
}

show_debug_overlay(true);
display_reset(0, true);
game_set_speed(30, gamespeed_fps);

frame_list = ds_list_create();
frame_list_size = 0;

asset_map= ds_map_create()

UI_init(window_get_caption());

