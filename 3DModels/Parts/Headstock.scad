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

headstock_length = 5.375 * inch;
headstock_width = bed_ways_width + 1 * inch + gib_width;
headstock_base_thickness = 0.75 * inch;

headstock_spindle_support_thickness = 0.75 * inch;
headstock_spindle_support_bottom_width = headstock_width;
headstock_spindle_support_height = ((3 + (7/8)) - (1/4)) * inch;
headstock_spindle_front_radius = 6.5 * inch;

headstock_spindle_block_support_thickness = (5/8) * inch;
headstock_spindle_block_support_width = 3.65 * inch; // ?
headstock_spindle_block_support_height = headstock_spindle_support_height + headstock_base_thickness;

spindle_diameter = 0.75 * inch;
spindle_height = headstock_spindle_support_height;


clamp_thickness = 0.25 * inch;
back_clamp_width = rail_width + gib_width + 0.25*inch;
front_clamp_width = rail_width + 0.25*inch;


module headstock_spindle_support_block()
{
    spindle_height = headstock_spindle_support_height;
    color(aluminum) 
    difference()
    {
        union()
        {
            translate([0, 0, -headstock_base_thickness])
            // curved part
            cube([headstock_spindle_block_support_thickness, headstock_spindle_block_support_width, headstock_spindle_block_support_height]);
        }
        union()
        {
            // spindle hole
            translate([-eps, headstock_spindle_block_support_width/2, spindle_height]) rotate([0, 90, 0]) cylinder(d=spindle_diameter, h=headstock_spindle_support_thickness+2*eps);
        }
    }

}

module headstock_spindle_support()
{
    spindle_height = headstock_spindle_support_height;
    color(aluminum) 
    difference()
    {
        union()
        {
            intersection()
            {
                cube([headstock_spindle_support_thickness, headstock_spindle_support_bottom_width, headstock_spindle_support_height]);
                
                // curved part
                translate([eps, headstock_spindle_support_bottom_width-headstock_spindle_front_radius, -headstock_base_thickness]) rotate([0, 90, 0]) cylinder(r=headstock_spindle_front_radius, h=headstock_spindle_support_thickness+2*eps);
            }
            
        }
        union()
        {
            // spindle hole
            translate([-eps, headstock_spindle_block_support_width/2, spindle_height]) rotate([0, 90, 0]) cylinder(d=spindle_diameter, h=headstock_spindle_support_thickness+2*eps);
        }
    }
}

module headstock_base()
{
    color(aluminum) 
    difference()
    {
        {
            cube([headstock_length, headstock_width, headstock_base_thickness]);
        }

        union()
        {
            // holes
        }
    }

}

module headstock_back_rail_and_gib()
{
    // gib and back rail and clamp
    back_rail_length = headstock_length + headstock_spindle_block_support_thickness;
    translate([-headstock_spindle_block_support_thickness, 0, 0])
    {
        color(aluminum) translate([0, 0, -rail_thickness]) cube([back_rail_length, rail_width, rail_thickness]);
        translate([0, rail_width, -gib_thickness]) cube([back_rail_length, gib_width, gib_thickness]);
        color(steel) translate([0, 0, -rail_thickness-clamp_thickness]) cube([back_rail_length, back_clamp_width, clamp_thickness]);
    }

}

module headstock_front_rail_and_gib()
{
    // front rail
    color(aluminum) translate([0, bed_ways_width+rail_width+gib_width, -rail_thickness]) cube([headstock_length, rail_width, gib_thickness]);
    color(steel) translate([0, bed_ways_width+rail_width+gib_width-(front_clamp_width-rail_width), -rail_thickness-clamp_thickness]) cube([headstock_length, front_clamp_width, clamp_thickness]);
}

module headstock_spindle_supports()
{
    translate([-headstock_spindle_block_support_thickness, 0, headstock_base_thickness]) headstock_spindle_support_block();
    translate([0, 0, headstock_base_thickness]) headstock_spindle_support();
    translate([headstock_length-headstock_spindle_support_thickness, 0, headstock_base_thickness]) headstock_spindle_support();
}

module headstock()
{
    headstock_back_offset = rail_width + gib_width;
    translate([0, -bed_ways_width/2-headstock_back_offset, 0]) 
    {
        headstock_base();
        headstock_back_rail_and_gib();
        headstock_front_rail_and_gib();
        headstock_spindle_supports();
    }
}

// Main
// headstock();
