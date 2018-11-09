include <Basic2D.scad>

$fn = 100;

// Constants
inch = 25.4;

// Motor dimensions
motor_shell_diameter = 28.9;
motor_shell_length = 28.2;
motor_shell_offset = 10; // ???
motor_case_diameter = 27.5;
motor_case_length = 47.0;
motor_nubbin_diameter = 9.9;
motor_nubbin_length = 2.5;

motor_shaft_diameter = 2.0; // ???
bearing_diameter = 15.0;
bearing_thickness = 4.9;

mount_width = 45;
mount_height = 60;
step_width = 10;
step_height = 8;

base_width = mount_width + 2 * step_width;

pi_mounting_hole_diameter = 2;
pi_mounting_hole_x_dist = 58;
pi3_mounting_hole_y_dist = 49;
pi0_mounting_hole_y_dist = 23;
pi_mounting_hole_x_offset = 24;
pi_mounting_hole_y_offset = 85;

motor_mounting_hole_1_x = 5;
motor_mounting_hole_2_x = 23;
motor_mounting_hole_3_x = 61;

motor_mounting_hole_diameter = 2;
motor_mounting_holes = [[5,6], [23, 5], [61, 4], [5, 60], [23, 60], [61.5, 60]];

module pi_mount_holes()
{
    translate([pi_mounting_hole_x_offset, pi_mounting_hole_y_offset])
    {
        translate([0, 0]) circle(d=pi_mounting_hole_diameter);
        translate([pi_mounting_hole_x_dist, 0]) circle(d=pi_mounting_hole_diameter);

        translate([0, pi0_mounting_hole_y_dist]) circle(d=pi_mounting_hole_diameter);
        translate([pi_mounting_hole_x_dist, pi0_mounting_hole_y_dist]) circle(d=pi_mounting_hole_diameter);

        translate([0, pi3_mounting_hole_y_dist]) circle(d=pi_mounting_hole_diameter);
        translate([pi_mounting_hole_x_dist, pi3_mounting_hole_y_dist]) circle(d=pi_mounting_hole_diameter);
    }
}

module motor_mount_holes()
{
    translate(motor_mounting_holes[0]) circle(d=motor_mounting_hole_diameter);
    translate(motor_mounting_holes[1]) circle(d=motor_mounting_hole_diameter);
    translate(motor_mounting_holes[2]) circle(d=motor_mounting_hole_diameter);
    translate(motor_mounting_holes[3]) circle(d=motor_mounting_hole_diameter);
    translate(motor_mounting_holes[4]) circle(d=motor_mounting_hole_diameter);
    translate(motor_mounting_holes[5]) circle(d=motor_mounting_hole_diameter);
}

//
// Main
//

pi_mount_holes();
motor_mount_holes();