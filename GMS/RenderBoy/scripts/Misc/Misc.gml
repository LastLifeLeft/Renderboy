function PointInRotatedRectangle(point_x, point_y, rect_x, rect_y, rect_offset_x, rect_offset_y, rect_width, rect_height, rect_angle)
{
    var rel_x = point_x - rect_x;
    var rel_y = point_y - rect_y;
    var angle = -rect_angle;
    var angleCos = cos(angle);
    var angleSin = sin(angle);
    var local_x = angleCos * rel_x - angleSin * rel_y;
    var local_y = angleSin * rel_x + angleCos * rel_y;
    return local_x >= -rect_offset_x && local_x <= rect_width - rect_offset_x && local_y >= -rect_offset_y && local_y <= rect_height - rect_offset_y;
}

function mediablock_load(UUID)
{
	var _result;
	switch (UI_get_mediablock_type(UUID))
	{
		case UI_EAssetType.Image:
			_result = new MediaBlock2D(UUID, UI_EAssetType.Image);
			break;
		case UI_EAssetType.Video :
			_result = new MediaBlock2D(UUID, UI_EAssetType.Video);
			break;
		case UI_EAssetType.Text:
			_result = new MediaBlocText(UUID)
			break;
		case UI_EAssetType.Effect2D :
			_result = new MediaBlock2DEffect(UUID);
			break;
	}
	
	return _result;
}