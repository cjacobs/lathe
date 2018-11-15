include <Basic2D.scad>
include <Basic3D.scad>

$fn = 100;

// Constants
eps = 0.125;
inch = 25.4;

// Colors
black = [0, 0, 0];
silver = [0.8, 0.8, 0.8];

// Dimensions
bed_length = 24 * inch;

bed_ways_thickness = 0.25 * inch;
bed_ways_width = 3 * inch;

bed_support_width = 2 * inch;
bed_support_height = 2 * inch;

module bed_ways()
{
    color(silver) translate([0, -bed_ways_width/2, bed_support_height]) cube([bed_length, bed_ways_width, bed_ways_thickness]);
}

module bed_support()
{
    color(silver) translate([0, -bed_support_width/2, 0]) cube([bed_length, bed_support_width, bed_support_height]);
}

module lathe_bed()
{
    bed_ways();
    bed_support();
}

// Main
// lathe_bed();
