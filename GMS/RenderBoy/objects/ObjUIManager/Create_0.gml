enum UI_EEvent
{
	None,
	End,
	Resize,
	ReRender,
	Edit,
	AddLayer,
	RemoveLayer
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


enum ECursor
{
	HandPoint,
	HandHover,
	HandGrab,
	MoveAll,
	MoveWE,
	MoveNS,
	MoveDiagWE,
	MoveDiagEW,
	RotateNW,
	RotateNE,
	RotateSE,
	RotateSW
}

show_debug_overlay(false);

display_reset(0, true);
game_set_speed(60, gamespeed_fps);

target_width = 1280;
target_height = 720;

window_width = 1318;
window_height = 718;

room_set_height(Room1, target_height);
room_set_width(Room1, target_width);

window_set_size(window_width, window_height);

surface_resize(application_surface, target_width, target_height);

frame_draw_x = (window_width - target_width) * 0.5
frame_draw_y = (window_height - target_height) * 0.5
frame_scale = 1

mouse_previous_x = 0;
mouse_previous_y = 0;
mouse_cursor = cr_default;

layer_count = 0;

rerender = true;
render_sprite = sprite_create_from_surface(application_surface, 0, 0, target_width, target_height, false, false, 0, 0);

global.asset_map = ds_map_create();
global.mediablock_map = ds_map_create();
render_list = ds_list_create();

editing_asset = 0;

UI_init(window_get_caption());

application_surface_draw_enable(false);
show_debug_overlay(true);

