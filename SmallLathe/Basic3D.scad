//
// Simple shapes
//

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