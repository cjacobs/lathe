$fn = 100;

brass_nut_ring_diameter = 22.18;
brass_nut_ring_thickness = 3.5;
brass_nut_shaft_diameter = 9.9;

module brass_nut()
{
    ring_diameter = brass_nut_ring_diameter;
    ring_thickness = brass_nut_ring_thickness;
    shaft_diameter = brass_nut_shaft_diameter;
    shaft_inner_diameter = 7;
    shaft_extent_short = 2.1;
    shaft_extent_long = 9.9;

    eps = 0.0125;
    difference()
    {
        union()
        {
            translate([0, 0, -shaft_extent_short]) cylinder(d=shaft_diameter, h=shaft_extent_short + shaft_extent_long + ring_thickness);
            cylinder(d=ring_diameter, h=ring_thickness);
        }

        union()
        {
            translate([0, 0, -shaft_extent_short-eps]) cylinder(d=shaft_inner_diameter, h=shaft_extent_short + shaft_extent_long + ring_thickness + 2*eps);
        }
    }
}

