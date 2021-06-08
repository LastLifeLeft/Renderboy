enum UI_EEvent
{
	None,
	End,
	Resize,
	ReRender,
	Edit
}

enum UI_EAssetType
{
	Image = 1,
	Video,
	Sound,
	Music,
	Voice,
	Character,
	Model
}

show_debug_overlay(true);
display_reset(0, true);
game_set_speed(30, gamespeed_fps);

layer_list = ds_list_create();
layer_list_size = 0;
layer_edit = -1;

asset_map= ds_map_create();

UI_init(window_get_caption());

//RenderTarget
target_width = 1280;
target_height = 720;

//frame_surface = surface_create(target_width, target_height);
surface_resize(application_surface, target_width, target_height);
frame_draw_x = 0
frame_draw_y = 0

frame_draw_width = target_width
frame_draw_height = target_height

frame_scale = 1

screen_width = 10;
screen_height = 10;

global.cursor = cr_default

application_surface_draw_enable(false);