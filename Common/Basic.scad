//
// Simple shapes
//

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

// Cantilever snap-fit thing
//
// parameters:
// height
// base_thickness
// tip_thickness
// shift (0 == "tooth" side vertical)
// overhang
// tip height
// overhang point pos (0 = 0 degree release angle)
module snap_fit_thing_cross_section(base_height, base_thickness, tip_thickness, shift, overhang, tip_height, overhang_pos)
{
    thickness_diff = base_thickness - tip_thickness;
    front_extent = thickness_diff * shift;
    bottom_tip_x = (tip_height / (base_height+tip_height)) * front_extent;
    polygon(points=[ [front_extent, 0], 
                     [bottom_tip_x, base_height], 
                     [overhang, base_height + overhang_pos*tip_height], 
                     [0, base_height + tip_height], 
                     [-tip_thickness, base_height + tip_height],
                     [-base_thickness+front_extent, 0] ]);


}

module snap_fit_thing(width, base_height, base_thickness, tip_thickness, shift, overhang, tip_height, overhang_pos)
{
    // Cantilever snap-fit thing
    //
    // parameters:
    // width
    // height
    // base_thickness
    // tip_thickness
    // shift (0 == "tooth" side vertical)
    // overhang
    // tip height
    // overhang point pos (0 = 0 degree release angle)
    linear_extrude(height = width, center = false) 
    {
        snap_fit_thing_cross_section(base_height, base_thickness, tip_thickness, shift, overhang, tip_height, overhang_pos);
    }

}
//
// 3D
//
module wedge(length, width, height)
{
    wedge_points =[[0, 0], [width, 0], [0, height]];
    wedge_paths =[[0, 1, 2]];

    linear_extrude(height = length, center = false) 
    {
        polygon(wedge_points, wedge_paths);
    }
}

// rectilinear slab with rounded edges along z axis, centered
module rounded_slab(length, width, height, r, center=true)
{
    translate([0, 0, height/2]) linear_extrude(height=height, center = true, convexity = 10, twist = 0) rounded_rect(length, width, r, center = center);
}

module rounded_shell(length, width, height, r, thickness, center=true)
{
    eps = 1;
    offset_y = center ? 0: thickness/2;
    offset_x = center ? 0: thickness/2;

    difference()
    {
        rounded_slab(length, width, height, r, center=center);
        translate([offset_x, offset_y, -eps]) rounded_slab(length-2*thickness, width-2*thickness, height+2*eps, r-thickness, center=center);
    }
}