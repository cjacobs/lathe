include <../Common/Basic2D.scad>
include <../Common/Basic3D.scad>

include <Bed.scad>

$fn = 40;

// Constants
eps = 0.125;
inch = 25.4;

// Colors
black = [0, 0, 0];
aluminum = [0.9, 0.9, 0.9];
steel = [0.5, 0.5, 0.54];

// Dimensions
gib_width = bed_ways_thickness;
gib_thickness = bed_ways_thickness;
rail_width = 0.5*inch;
rail_thickness = bed_ways_thickness;

tailstock_length = 3.375 * inch;
tailstock_width = bed_ways_width + 1 * inch + gib_width;
tailstock_base_thickness = 0.75 * inch;

tailstock_spindle_support_thickness = 0.75 * inch;
tailstock_spindle_support_bottom_width = tailstock_width;
tailstock_spindle_support_height = ((3 + (7/8)) - (1/4))* inch;
tailstock_spindle_front_radius = 6.5 * inch;

tailstock_spindle_block_support_thickness = (5/8) * inch;
tailstock_spindle_block_support_width = 3.65 * inch; // ?
tailstock_spindle_block_support_height = tailstock_spindle_support_height + tailstock_base_thickness;

spindle_diameter = 0.75 * inch;
spindle_height = tailstock_spindle_support_height;


clamp_thickness = 0.25 * inch;
back_clamp_width = rail_width + gib_width + 0.25*inch;
front_clamp_width = rail_width + 0.25*inch;


module tailstock_spindle_support()
{
    spindle_height = tailstock_spindle_support_height;
    color(aluminum) 
    difference()
    {
        union()
        {
            intersection()
            {
                cube([tailstock_spindle_support_thickness, tailstock_spindle_support_bottom_width, tailstock_spindle_support_height]);
                
                // curved part
                translate([eps, tailstock_spindle_support_bottom_width-tailstock_spindle_front_radius, -tailstock_base_thickness]) rotate([0, 90, 0]) cylinder(r=tailstock_spindle_front_radius, h=tailstock_spindle_support_thickness+2*eps);
            }
            
        }
        union()
        {
            // spindle hole
            translate([-eps, tailstock_spindle_block_support_width/2, spindle_height]) rotate([0, 90, 0]) cylinder(d=spindle_diameter, h=tailstock_spindle_support_thickness+2*eps);
        }
    }
}

module tailstock_base()
{
    color(aluminum) 
    difference()
    {
        {
            cube([tailstock_length, tailstock_width, tailstock_base_thickness]);
        }

        union()
        {
            // holes
        }
    }

}

module tailstock_back_rail_and_gib()
{
    // gib and back rail and clamp
    back_rail_length = tailstock_length;
    color(aluminum) translate([0, 0, -rail_thickness]) cube([back_rail_length, rail_width, rail_thickness]);
    translate([0, rail_width, -gib_thickness]) cube([back_rail_length, gib_width, gib_thickness]);
    color(steel) translate([0, 0, -rail_thickness-clamp_thickness]) cube([back_rail_length, back_clamp_width, clamp_thickness]);
}

module tailstock_front_rail_and_gib()
{
    // front rail
    color(aluminum) translate([0, bed_ways_width+rail_width+gib_width, -rail_thickness]) cube([tailstock_length, rail_width, gib_thickness]);
    color(steel) translate([0, bed_ways_width+rail_width+gib_width-(front_clamp_width-rail_width), -rail_thickness-clamp_thickness]) cube([tailstock_length, front_clamp_width, clamp_thickness]);
}

module tailstock_spindle_supports()
{
    translate([0, 0, tailstock_base_thickness]) tailstock_spindle_support();
    translate([tailstock_length-tailstock_spindle_support_thickness, 0, tailstock_base_thickness]) tailstock_spindle_support();
}

module tailstock()
{
    tailstock_back_offset = rail_width + gib_width;
    translate([0, -bed_ways_width/2-tailstock_back_offset, 0]) 
    {
        tailstock_base();
        tailstock_back_rail_and_gib();
        tailstock_front_rail_and_gib();
        tailstock_spindle_supports();
    }
}

// Main
// tailstock();
