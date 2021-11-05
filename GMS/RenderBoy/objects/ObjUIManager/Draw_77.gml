//if (live_call()) return live_result;

draw_clear(c_dkgrey);
better_scaling_draw_sprite(render_sprite, 0, frame_draw_x, frame_draw_y, frame_scale, frame_scale, 0, c_white, 1, 1);

if (editing_asset)
{
	editing_asset.edit()
}