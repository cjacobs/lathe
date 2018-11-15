// include <Basic2D.scad>
// include <Basic3D.scad>

include <Bed.scad>
include <SpindleBearing.scad>
include <Carriage.scad>

$fn = 100;

// Constants
eps = 0.125;
inch = 25.4;


module lathe()
{
    lathe_bed();
    
    translate([6*inch, 0, bed_support_height+bed_lid_thickness+bed_ways_thickness]) carriage();

    translate([2*inch, 0, bed_support_height+bed_lid_thickness+bed_ways_thickness]) rotate([0, 0, 90]) spindle_bearing();
}


// Main
lathe();
