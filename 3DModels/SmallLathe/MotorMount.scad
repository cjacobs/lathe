include <Basic2D.scad>

$fn = 100;

// Constants
inch = 25.4;

// Motor dimensions
motor_diameter = 3.5 * inch;

motor_shaft_diameter = (5/16) * inch;

mount_width = 5 * inch;
mount_height = 9 * inch;

base_width = mount_width;

stepx = 0.75 * inch;
stepy = 0.5 * inch;

bearing_diameter = 22;

r = 2;

module mount_body(use_step=true)
{
    stepx_value = use_step ? stepx : mount_width/2;
    eps = 0.0125;
    translate([-mount_width/2, 0]) union()
    {
        square([mount_width, mount_height-stepy-r]);
        translate([(mount_width/2)-stepx_value, mount_height-stepy-r]) square([(mount_width/2+stepx_value), stepy]);
    }
}

module hole_mount(hole_diameter)
{
    difference()
    {
        union()
        {
            mount_body();
        }
        union()
        {
            translate([0, mount_height-(mount_width/2)])
            {
                gap = 2;
                circle(d=hole_diameter);       
                translate([-1, 0]) square([gap, mount_width/2]);
            }
        }
    }
}

module motor_body_mount()
{
    hole_mount(motor_diameter);
}

module motor_front_mount()
{
    difference()
    {
        motor_body_mount();
        
        translate([0, mount_height-(mount_width/2)]) union()
        {
            rotate([0, 0, 180]) translate([0, motor_diameter/2 + (9/16)*inch]) circle(2);
            rotate([0, 0, 60]) translate([0, motor_diameter/2 + (9/16)*inch]) circle(2);
            rotate([0, 0, -60]) translate([0, motor_diameter/2 + (9/16)*inch]) circle(2);
        }
    }
}

module motor_front_mount2()
{
    difference()
    {
        motor_body_mount();
        
        translate([0, mount_height-(mount_width/2)]) union()
        {
            slop = 2;
            rotate([0, 0, 180]) translate([0, motor_diameter/2]) translate([-0.25*inch, -slop]) square([0.5*inch, 0.75*inch+slop]);
            rotate([0, 0, 60]) translate([0, motor_diameter/2]) translate([-0.25*inch, -slop]) square([0.5*inch, 0.75*inch+slop]);
            rotate([0, 0, -60]) translate([0, motor_diameter/2]) translate([-0.25*inch, -slop]) square([0.5*inch, 0.75*inch+slop]);
        }
    }
}

module cutout_with_center()
{
    difference()
    {
        union()
        {
            translate([0, mount_height-(mount_width/2)])
            {
                gap = 2;
                circle(d=motor_diameter);       
                // translate([-1, 0]) square([gap, mount_width/2]);
            }

            translate([0, mount_height-(mount_width/2)]) union()
            {
                slop = 2;
                rotate([0, 0, 180]) translate([0, motor_diameter/2]) translate([-0.25*inch, -slop]) square([0.5*inch, 0.75*inch+slop]);
                rotate([0, 0, 60]) translate([0, motor_diameter/2]) translate([-0.25*inch, -slop]) square([0.5*inch, 0.75*inch+slop]);
                rotate([0, 0, -60]) translate([0, motor_diameter/2]) translate([-0.25*inch, -slop]) square([0.5*inch, 0.75*inch+slop]);
            }
        }

        union()
        {
            translate([0, mount_height-(mount_width/2)])
            {
                circle(d=1);       
            }
        }
    }
}

module motor_back_mount()
{
    difference()
    {
        union()
        {
            mount_body(false);
            translate([0, 0.5*inch]) mount_body(false);
        }
        
        translate([0, mount_height-(mount_width/2)]) union()
        {
            translate([0, 0])
            {
                gap = mount_width/2;
                circle(d=motor_diameter);       
                translate([-gap/2, 0]) square([gap, mount_width/2 + inch]);
            }

            rotate([0, 0, 180]) translate([0, motor_diameter/2 + (9/16)*inch]) circle(2);
            rotate([0, 0, 60]) translate([0, motor_diameter/2 + (9/16)*inch]) circle(2);
            rotate([0, 0, -60]) translate([0, motor_diameter/2 + (9/16)*inch]) circle(2);
        }
    }
}

module motor_bearing_mount()
{
    hole_mount(bearing_diameter);
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

eps = 0.0125;
x_spacing = mount_width + eps;
y_spacing = mount_height + eps;
// motor_body_mount();

// translate([0*x_spacing, 0]) motor_bearing_mount();
// translate([1*x_spacing, 0]) motor_bearing_mount();
// translate([2*x_spacing, 0]) motor_bearing_mount();

// translate([0*x_spacing, y_spacing]) motor_front_mount();
// translate([1*x_spacing, y_spacing]) motor_front_mount2();
// translate([2*x_spacing, y_spacing]) motor_back_mount();

// cutout_with_center();
circle(d=motor_diameter);