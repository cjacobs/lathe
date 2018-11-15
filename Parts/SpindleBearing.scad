include <Basic2D.scad>
include <Basic3D.scad>

$fn = 100;

// Constants
eps = 0.125;
inch = 25.4;

// Colors
black = [0, 0, 0];
body_color = [0.85, 0.85, 0.65];
silver = [0.8, 0.8, 0.8];
screw_color = [0.25, 0.35, 0.75];

// Dimensions
spindle_bearing_width = 4 * inch;
spindle_bearing_height = 3.25 * inch;
spindle_bearing_depth = 3.125 * inch;
spindle_bearing_overhang_height = 0.125 * inch;
spindle_bearing_overhang_offset = 2 * inch;

spindle_bearing_mounting_screw_radius = 0.125*inch;
spindle_bearing_mounting_screw_depth = 1.5*inch;
spindle_bearing_mounting_screw_x_offset = 0.25*inch;
spindle_bearing_mounting_screw_y_offset = 0.25*inch;

spindle_radius = (.375 * inch) / 2;
spindle_center_height = 1.5*inch;
spindle_center_x = 2*inch;
spindle_length = 4.75 * inch;
spindle_front_offset = 0.5*inch;

spindle_bearing_retention_ring_outer_radius = (3*inch) / 2;
spindle_bearing_retention_ring_inner_radius = (1.25*inch) / 2;
spindle_bearing_retention_ring_thickness = (3/16)*inch;

spindle_bearing_pulley_radius = ((3 + (7/8)) * inch) / 2;
spindle_bearing_pulley_thickness = (5/8)*inch;
spindle_bearing_pulley_edge_thickness = (1/16)*inch;
spindle_bearing_pulley_offset = 0.25 * inch;
spindle_bearing_pulley_inner_radius = ((3 + (7/8)) * inch) / 2 - 0.125*inch;

spindle_bearing_pulley_inset_radius = ((2 + (7/8)) * inch) / 2;
spindle_bearing_pulley_inset_thickness = (3/16) * inch;
// pulley face inset diameter = 2 7/8"
// pulley face inset depth = 3/16"

module spindle_bearing_body()
{
    color(body_color) translate([-spindle_bearing_width/2, 0, 0]) difference()
    {
        union()
        {
            cube([spindle_bearing_width, spindle_bearing_depth, spindle_bearing_depth]);
        }

        union()
        {
            translate([-eps, spindle_bearing_overhang_offset, -eps]) cube([spindle_bearing_width + 2*eps, (spindle_bearing_depth-spindle_bearing_overhang_offset)+eps, spindle_bearing_overhang_height + eps]);
            translate([spindle_center_x, -eps, spindle_center_height]) rotate([-90, 0, 0]) cylinder(r=spindle_radius, h=spindle_bearing_depth + 2*eps);
        
            // Screw holes
            color(black) translate([spindle_bearing_mounting_screw_x_offset, spindle_bearing_mounting_screw_y_offset, -eps]) cylinder(r=spindle_bearing_mounting_screw_radius, h=spindle_bearing_mounting_screw_depth);
            color(black) translate([spindle_bearing_width - spindle_bearing_mounting_screw_x_offset, spindle_bearing_mounting_screw_y_offset, -eps]) cylinder(r=spindle_bearing_mounting_screw_radius, h=spindle_bearing_mounting_screw_depth);
            color(black) translate([spindle_bearing_mounting_screw_x_offset, spindle_bearing_overhang_offset-spindle_bearing_mounting_screw_y_offset, -eps]) cylinder(r=spindle_bearing_mounting_screw_radius, h=spindle_bearing_mounting_screw_depth);
            color(black) translate([spindle_bearing_width - spindle_bearing_mounting_screw_x_offset, spindle_bearing_overhang_offset-spindle_bearing_mounting_screw_y_offset, -eps]) cylinder(r=spindle_bearing_mounting_screw_radius, h=spindle_bearing_mounting_screw_depth);
        }
    }
}

module spindle_bearing_retention_ring()
{
    color(silver) translate([0, -spindle_bearing_retention_ring_thickness-eps, spindle_center_height]) rotate([-90, 0, 0]) difference()
    {
        union()
        {
            cylinder(r=spindle_bearing_retention_ring_outer_radius, h=spindle_bearing_retention_ring_thickness);
        }

        union()
        {
            translate([0, 0, -eps]) cylinder(r=spindle_bearing_retention_ring_inner_radius, h=spindle_bearing_retention_ring_thickness + 3*eps);
        }
    }
}

module spindle_bearing_pulley()
{
    color(silver) translate([0, spindle_bearing_depth + spindle_bearing_pulley_offset, spindle_center_height]) rotate([-90, 0, 0]) difference()
    difference()
    {
        union()
        {
            cylinder(r=spindle_bearing_pulley_inner_radius, h=spindle_bearing_pulley_thickness, $fn=90);
            cylinder(r=spindle_bearing_pulley_radius, h=spindle_bearing_pulley_edge_thickness);
            translate([0, 0, spindle_bearing_pulley_thickness-spindle_bearing_pulley_edge_thickness]) cylinder(r=spindle_bearing_pulley_radius, h=spindle_bearing_pulley_edge_thickness);
        }
        union()
        {
            translate([0, 0, spindle_bearing_pulley_thickness-spindle_bearing_pulley_inset_thickness]) cylinder(r=spindle_bearing_pulley_inset_radius, h=spindle_bearing_pulley_inset_thickness+eps);
        }
    }
}

module spindle()
{
    color(silver) translate([0, -spindle_front_offset, spindle_center_height]) rotate([-90, 0, 0]) difference()
    {
        cylinder(r=spindle_radius, h=spindle_length);
    }
}

module spindle_bearing()
{
    spindle_bearing_body();
    spindle_bearing_retention_ring();
    spindle_bearing_pulley();
    spindle();
}

// Main

// spindle_bearing();