include <Endpiece.scad>
include <BrassNut.scad>

inch = 25.4;

off_white = [0.96, 0.95, 0.875];
steel = [0.96, 0.95, 0.98];
bearing_color = [0.25, 0.35, 0.75];

endpiece_thickness = 0.385 * inch;
screw_width = 8;

translate([0, 0, 1*inch]) brass_nut();

color(off_white) translate([-endpiece_width/2, -endpiece_height + 0.5*inch]) linear_extrude(height = endpiece_thickness, center = false) 
{
    endpiece();
}

color(off_white) translate([-carriage_width/2, -carriage_height + 0.5*inch, 2*inch]) linear_extrude(height = endpiece_thickness, center = false) 
{
    carriage();
}

color(steel)
{
    translate([0, 0, -1*inch]) cylinder(d=screw_width, h=6*inch);
}

color(bearing_color)
{
    bearing();
}