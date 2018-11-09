//
// 2D
//
module rounded_rect(length, width, r, center=true)
{
    offset_x = center ? 0 : length;
    offset_y = center ? 0 : width;
    l2 = length - (2 * r);
    w2 = width - (2 * r);

    translate([offset_x, offset_y, 0]) hull()
    {
        translate([-l2/2, -w2/2, 0]) circle(r = r);
        translate([-l2/2,  w2/2, 0]) circle(r = r);
        translate([ l2/2, -w2/2, 0]) circle(r = r);
        translate([ l2/2,  w2/2, 0]) circle(r = r);
    }    
}
