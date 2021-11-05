if (rerender)
{
	draw_clear(c_black);
	rerender = false;
	
	var _item_count/*int*/ = ds_list_size(render_list);
	
	for (var i/*int*/= 0; i < _item_count; i++)
	{
		render_list[| i].render();
	}
	
	sprite_delete(render_sprite);
	render_sprite = sprite_create_from_surface(application_surface, 0, 0, target_width, target_height, false, false, 0, 0);
}