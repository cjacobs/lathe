include <../Common/ScrewHoles.scad>
include <Basic2D.scad>
include <../Parts/BrassNut.scad>

$fn = 100;

// Constants
inch = 25.4;

endpiece_width = 2 * inch;
endpiece_height = 1.5 * inch;
carriage_width = 2 * inch;
carriage_height = 1 * inch;
rail_diameter = 6;
bearing_outer_diameter = 22.08;
bearing_inner_diameter = 8;
bearing_thickness = 7;

screw_diameter = number_4_screw_tap_diameter;

module endpiece()
{
    difference()
    {
        union()
        {
            square([endpiece_width, endpiece_height]);
        }

        union()
        {
            translate([endpiece_width/2, 1*inch]) circle(d=bearing_outer_diameter);
            translate([(3/8) * inch, 1*inch]) circle(d=rail_diameter);
            translate([(2-(3/8)) * inch, 1*inch]) circle(d=rail_diameter);

            translate([(1/8)*inch, (1/8)*inch]) circle(d=screw_diameter);
            translate([(2-(1/8))*inch, (1/8)*inch]) circle(d=screw_diameter);
        }
    }
}

module carriage()
{
    eps = 0.0125;
    difference()
    {
        union()
        {
            square([carriage_width, carriage_height]);
        }

        union()
        {
            translate([carriage_width/2, carriage_height/2])
            {
                circle(d=brass_nut_shaft_diameter);
                translate([-(5/8) * inch, 0]) circle(d=rail_diameter+eps);
                translate([(5/8) * inch, 0]) circle(d=rail_diameter+eps);
            }
        }
    }
}


module bearing()
{
    eps = 0.0125;
    difference()
    {
        union()
        {
            cylinder(d=bearing_outer_diameter, h=bearing_thickness);
        }

        union()
        {
            translate([0, 0, -eps]) cylinder(d=bearing_inner_diameter, h=bearing_thickness+2*eps);
        }
    }
}

