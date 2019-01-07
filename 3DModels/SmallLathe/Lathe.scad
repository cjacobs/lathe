include <../Parts/Bed.scad>
include <../Parts/Carriage.scad>
include <../Parts/Headstock.scad>
include <../Parts/SpindleBearing.scad>
include <../Parts/Tailstock.scad>

$fn = 40;

// Constants
eps = 0.125;
inch = 25.4;


module lathe()
{
    lathe_bed();

    translate([7*inch, 0, bed_support_height+bed_lid_thickness+bed_ways_thickness]) carriage();

    translate([bed_length-spindle_bearing_depth, 0, bed_support_height+bed_lid_thickness+bed_ways_thickness]) rotate([0, 0, -90]) spindle_bearing();

    translate([bed_length-spindle_bearing_depth-headstock_length, 0, bed_support_height+bed_lid_thickness+bed_ways_thickness]) headstock();
    translate([0, 0, bed_support_height+bed_lid_thickness+bed_ways_thickness]) tailstock();
}


// Main
translate([-bed_length/2, 0, 0]) lathe();
