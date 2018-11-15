include <Basic2D.scad>
include <Basic3D.scad>

include <BrassNut.scad>

$fn = 100;

// Constants
eps = 0.125;
inch = 25.4;

// Colors
black = [0, 0, 0];
aluminum = [0.9, 0.9, 0.9];
steel = [0.5, 0.5, 0.54];
stainless = [0.85, 0.85, 0.85];

// Dimensions
bed_length = 24 * inch;

bed_ways_thickness = 0.375 * inch;
bed_ways_width = 4 * inch;

bed_support_thickness = 0.5 * inch;
bed_support_width = 3 * inch;
bed_support_height = 2 * inch;
bed_lid_thickness = 0.25 * inch;

bed_ways_screw_diameter = 0.25*inch;
bed_support_screw_diameter = 0.125*inch;

// lead screw
leadscrew_diameter = 8;
leadscrew_length = 500;
leadscrew_height = bed_support_height/2;
leadscrew_offset = brass_nut_ring_diameter/2 + 0.125*inch;

module bed_ways()
{
    hollow_length = ((bed_length - 4*bed_support_thickness) / 3);
    rib_offset = bed_support_thickness + hollow_length;

    color(steel) 
    translate([0, 0, bed_support_height+bed_lid_thickness])
    difference()
    {
        {
            translate([0, -bed_ways_width/2, 0]) cube([bed_length, bed_ways_width, bed_ways_thickness]);
        }

        union()
        {
            // translate([0*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([0*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([1*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([1*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([2*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([2*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([3*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([3*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);

            translate([0*rib_offset + bed_support_thickness/2, 0, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([1*rib_offset + bed_support_thickness/2, 0, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([2*rib_offset + bed_support_thickness/2, 0, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([3*rib_offset + bed_support_thickness/2, 0, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);

            translate([hollow_length/2 + 0*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 0*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 1*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 1*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 2*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 2*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, -eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
        }
    }

}

module bed_support()
{
    color(aluminum) 
    difference()
    {
        hollow_length = ((bed_length - 4*bed_support_thickness) / 3);
        rib_offset = bed_support_thickness + hollow_length;
        rib_width = bed_support_width - (2*bed_support_thickness);
        union()
        {
            // sides
            translate([0, bed_support_width/2 - bed_support_thickness, 0]) cube([bed_length, bed_support_thickness, bed_support_height]);
            translate([0, -bed_support_width/2, 0]) cube([bed_length, bed_support_thickness, bed_support_height]);
            
            // ribs
            translate([0*rib_offset, -bed_support_width/2 + bed_support_thickness, 0]) cube([bed_support_thickness, rib_width, bed_support_height]);
            translate([1*rib_offset, -bed_support_width/2 + bed_support_thickness, 0]) cube([bed_support_thickness, rib_width, bed_support_height]);
            translate([2*rib_offset, -bed_support_width/2 + bed_support_thickness, 0]) cube([bed_support_thickness, rib_width, bed_support_height]);
            translate([3*rib_offset, -bed_support_width/2 + bed_support_thickness, 0]) cube([bed_support_thickness, rib_width, bed_support_height]);

            // lid
            translate([0, -bed_support_width/2, bed_support_height]) cube([bed_length, bed_support_width, bed_lid_thickness]);
        }

        union()
        {
            // lid screw holes
            // translate([0*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([0*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([1*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([1*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([2*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([2*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([3*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            // translate([3*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);

            translate([0*rib_offset + bed_support_thickness/2, 0, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([1*rib_offset + bed_support_thickness/2, 0, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([2*rib_offset + bed_support_thickness/2, 0, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([3*rib_offset + bed_support_thickness/2, 0, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);

            translate([hollow_length/2 + 0*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 0*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 1*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 1*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 2*rib_offset + bed_support_thickness/2, bed_support_width/2 - bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);
            translate([hollow_length/2 + 2*rib_offset + bed_support_thickness/2, -bed_support_width/2 + bed_support_thickness/2, bed_support_height-eps]) cylinder(d=bed_ways_screw_diameter, h=bed_ways_thickness+2*eps);

            // support screw holes
            translate([0*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([0*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([0*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([0*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([1*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([1*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([1*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([1*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([2*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([2*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([2*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([2*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([3*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([3*rib_offset + bed_support_thickness/2, bed_support_width/2+eps, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([3*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            translate([3*rib_offset + bed_support_thickness/2, -bed_support_width/2+bed_support_thickness, bed_support_height - bed_support_thickness]) rotate([90, 0, 0]) cylinder(d=bed_support_screw_diameter, h=bed_support_thickness+2*eps);
            
        }
    }
}

module leadscrew_assembly()
{
    length_diff = bed_length - leadscrew_length;
    color(stainless) 
    translate([length_diff/2, bed_support_width/2 + leadscrew_offset, leadscrew_height]) rotate([0, 90, 0]) 
    {
        cylinder(d=leadscrew_diameter, h=leadscrew_length);
        brass_nut();
    }

}

module lathe_bed()
{
    bed_ways();
    bed_support();
    leadscrew_assembly();

}

// Main
// lathe_bed();
