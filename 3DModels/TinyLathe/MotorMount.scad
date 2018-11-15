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

r = 2;

module mount_body()
{
    union()
    {
        rounded_rect(mount_width, mount_height, r);
        translate([0, -(mount_height - step_height)/2, 0]) rounded_rect(mount_width + 2*step_width, step_height, r=r, center=true);
        translate([0, -(mount_height - step_height/2)/2, 0]) square([mount_width + 2*step_width, step_height/2], center=true);
    }
}

module motor_body_mount()
{
    difference()
    {
        union()
        {
            mount_body();
        }
        union()
        {
            translate([0, (mount_height-mount_width)/2]) 
            {
                circle(d=motor_shell_diameter);            
                translate([-1, 0]) square([2,mount_width/2]);
            }
        }
    }
}

module motor_front_mount()
{
    difference()
    {
        union()
        {
            mount_body();
        }
        union()
        {
            translate([0, step_height]) 
            {
                circle(d=motor_nubbin_diameter);            
                translate([-1, 0]) square([2,mount_width/2]);
            }
        }
    }
}

module motor_bearing_mount()
{
    difference()
    {
        union()
        {
            mount_body();
        }
        union()
        {
            translate([0, step_height]) 
            {
                circle(d=bearing_diameter);            
                translate([-1, 0]) square([2,mount_width/2]);
            }
        }
    }
}

module tailpiece_mount()
{
    difference()
    {
        union()
        {
            mount_body();
        }
        union()
        {
            translate([0, step_height]) 
            {
                circle(d=motor_shaft_diameter);            
            }
        }
    }
}

//
// Main
//

slop = 2;

// translate([0, 0]) motor_body_mount();
// rotate([0, 0, 180]) translate([0, mount_width + step_height + slop]) motor_front_mount();
// translate([mount_width+slop, -(mount_width + 2 * step_height+slop)]) motor_bearing_mount();
// rotate([0, 0, 180]) translate([-(mount_width + step_height+slop), step_height]) tailpiece_mount();

translate([-((mount_width + step_width + slop) * 1.5), 0]) motor_body_mount();
// translate([-((mount_width + step_width + slop) * 0.5), 0]) rotate([0, 0, 180]) motor_front_mount();
// translate([(mount_width + step_width + slop) * 0.5, 0]) motor_bearing_mount();
// translate([(mount_width + step_width + slop) * 1.5, 0]) rotate([0, 0, 180]) tailpiece_mount();