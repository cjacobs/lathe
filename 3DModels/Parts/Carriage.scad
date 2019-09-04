include <../Common/Basic2D.scad>
include <../Common/Basic3D.scad>
include <../Common/Colors.scad>

include <Bed.scad>

$fn = 100;

// Constants
eps = 0.125;
inch = 25.4;

// Dimensions
carriage_length = 8 * inch;
carriage_width = 4 * inch;
carriage_bed_thickness = 0.375 * inch;

cross_slide_length = 4 * inch;
cross_slide_width = 4 * inch;
cross_slide_thickness = 0.25 * inch;

gib_width = bed_ways_thickness;
gib_thickness = bed_ways_thickness;

rail_width = bed_ways_thickness;
rail_thickness = bed_ways_thickness;

clamp_thickness = 0.25 * inch;
back_clamp_width = rail_width + gib_width + 0.25*inch;
front_clamp_width = rail_width + 0.25*inch;

module carriage_bed()
{
    color(aluminum) 
    difference()
    {
        {
            cube([carriage_width, carriage_length, carriage_bed_thickness]);
        }

        union()
        {
            // holes
        }
    }

    translate([0, 0, carriage_bed_thickness])
    union()
    {
        color(aluminum) 
        {
            cube([rail_width, carriage_length, rail_thickness]);

            translate([carriage_width-rail_width, 0, 0])
            cube([rail_width, carriage_length, rail_thickness]);
        }

        translate([0, 0, carriage_bed_thickness])
        color(steel) 
        {
            cube([front_clamp_width, carriage_length, clamp_thickness]);

            translate([carriage_width-front_clamp_width, 0, 0])
            cube([front_clamp_width, carriage_length, clamp_thickness]);
        }
    }
}

module cross_slide()
{
    color(aluminum)
    cube([cross_slide_width, cross_slide_length, cross_slide_thickness]);
}

module carriage()
{
    carriage_back_offset = rail_width + gib_width;
    translate([0, -bed_ways_width/2-carriage_back_offset, 0]) 
    {
        carriage_bed();

        translate([0, 0, carriage_bed_thickness+carriage_bed_thickness+clamp_thickness])
        cross_slide();

        // gib and back rail and clamp
        color(aluminum) translate([0, 0, -rail_thickness]) cube([carriage_width, rail_width, rail_thickness]);
        translate([0, rail_width, -gib_thickness]) cube([carriage_width, gib_width, gib_thickness]);
        color(steel) translate([0, 0, -rail_thickness-clamp_thickness]) cube([carriage_width, back_clamp_width, clamp_thickness]);

        // front rail
        carriage_front_extra = carriage_length - (bed_ways_width+rail_width+gib_width);
        color(aluminum) translate([0, bed_ways_width+rail_width+gib_width, -rail_thickness]) cube([carriage_width, carriage_front_extra, gib_thickness]);
        color(steel) translate([0, bed_ways_width+rail_width+gib_width-(front_clamp_width-rail_width), -rail_thickness-clamp_thickness]) cube([carriage_width, front_clamp_width, clamp_thickness]);
    }
}

// Main
// carriage();
