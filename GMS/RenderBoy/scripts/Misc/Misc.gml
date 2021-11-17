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