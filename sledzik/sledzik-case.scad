// Requires utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<../Lenbok_Utils/utils.scad>
// Requires bezier library from https://www.thingiverse.com/thing:2207518
use<../Lenbok_Utils/bezier.scad>

include <sledzik-layout.scad>
include <../keyboard-case.scad>

plate_thickness = 4;            // Fairly thick for strength, ideally print this section with high infill
top_case_raised_height = 2 ;    // Distance between plate and bottom of keycap plus a little extra, for raised top case
bottom_case_height = 10;        // Enough room to house electonics
wall_thickness = 4;             // Sides and bottom of case
depth_offset = 6;               // How much of side wall to include below top plate

// M5 bolt tenting
tent_bolt_rad = 5 / 2;
tent_nut_rad = 9.4 / 2;
tent_nut_height = 3.5;
tent_attachment_width = 40;

$fa = 1;
$fs = $preview ? 5 : 2;
bezier_precision = $preview ? 0.05 : 0.025;

x0 = 400;
y0 = -140;
x1 = -10;
y1 = 0;

// TODO:
sledzik_screw_holes = [
    [150, 100],
    [20, 20],
    [30, 30],
    [40, 40],
];

sledzik_tent_positions = [
    [[x1 + 20, y1], 90, plate_thickness + depth_offset], // top left
    [[x0/2,    y1], 90, plate_thickness + depth_offset], // top middle
    [[x0 - 20, y1], 90, plate_thickness + depth_offset], // top right
];

/*    CONTROL              POINT               CONTROL    */
bzVec = [
                           [x1, y1],           SHARP(),   // Top left
      SHARP(),             [x0, y1],           SHARP(),   // Top right
      SHARP(),             [x0, y0],           SHARP(),   // Bottom right2
      SHARP(),             [x1, y0],           SHARP(),
];

b1 = Bezier(bzVec, precision = bezier_precision);

module sledzik_outer_profile() {
    offset(r = 5, chamfer = false, $fn = 20) // Purposely slightly larger than the negative offset below
        offset(r = -4.5, chamfer = false, $fn = 20)
            polygon(b1);
}


module sledzik_top_case(raised = false) {
    difference() {
        top_case(keyboard_layout, sledzik_screw_holes,
                tent_positions = sledzik_tent_positions,
                standoffs = true,
                chamfer_height = raised ? 5 : 2.5,
                chamfer_width = 2.5,
                raised = raised)
            sledzik_outer_profile();

        translate([0, 0, - depth_offset * 1.0 ]) {

            // keyboard cable
            translate([153, 0, 0]) rotate([0, 0, 0]) {
                usb_c_breakout();
            }
        }
    }
    encoder(375, -25);
}

module encoder(enc_x, enc_y) {
    // add encoder cover over switch hole
    color(case_color) difference(){

        translate([enc_x, enc_y, 3])
            rotate([0,0,0])
                cube([unit, unit, 1]);

        translate([enc_x, enc_y, 0])
            rotate([0,0,0])
                translate([1+unit/2, 1+unit/2, 0])
                    cylinder(r=3, h=10, $fn=60);
    }
}


module sledzik_bottom_case() {
    difference() {
        bottom_case(sledzik_screw_holes) sledzik_outer_profile();

        translate([0, 0, wall_thickness + 0.01]) {
            // Case holes for connectors etc. The second version of each is just
            // For preview view

            // keyboard cable
            translate([180, 0, 0]) rotate([0, 0, 4]) {
                micro_usb_hole();
                %micro_usb_hole(hole = false);
            }
        }
    }
}


part = "top0b";
//part = "bottom0b";
//part = "hrw";
//part = "assembly";
//part = "keycaps+top";

explode = 1;
if (part == "outer") {
    //BezierVisualize(bzVec);
    offset(r = -2.5) // Where top of camber would come to
        sledzik_outer_profile();
    for (pos = sledzik_screw_holes) {
        translate(pos) {
            polyhole2d(r = 3.2 / 2);
        }
    }
#key_holes(keyboard_layout);

} else if (part == "top0") {
    rev0_top_case();

} else if (part == "bottom0") {
    rev0_bottom_case();

} else if (part == "top0b-raised") {
    sledzik_top_case(true);

} else if (part == "top0b") {
    sledzik_top_case(false);

} else if (part == "bottom0b") {
    sledzik_bottom_case();

} else if (part == "hrw") {
    sledzik_top_case(false);
    translate([0, 0, -bottom_case_height -30 * explode]) sledzik_bottom_case();
} else if (part == "keycaps+top") {
    %translate([0, 0, plate_thickness + 1 * explode]) key_holes(keyboard_layout, "keycap");
    sledzik_top_case();

} else if (part == "assembly") {
    %translate([0, 0, plate_thickness + 30 * explode]) key_holes(keyboard_layout, "keycap");
    %translate([0, 0, plate_thickness + 20 * explode]) key_holes(keyboard_layout, "switch");
    sledzik_top_case();
    translate([0, 0, -bottom_case_height -20 * explode]) sledzik_bottom_case();

} else if (part == "holetest") {
    * translate([-66.5, 20.25]) top_case([left_holes[0], left_holes[1], left_holes[7], left_holes[8]], [], raised = true)
        translate([66.5, -20.25]) square([46, 49], center = true);
    translate([-66.5, 20.25]) difference() {
        chamfer_extrude(height = plate_thickness + top_case_raised_height, chamfer = 5, width = 2.5, faces = [false, true]) translate([66.5, -20.25]) square([46, 49], center = true);
        translate([0, 0, 4])
            key_holes([left_holes[0], left_holes[1], left_holes[7], left_holes[8]]);
    }
}


// z https://github.com/aecepoglu/scad-keyboard-cases/commit/08f8f9e306ab0aa07d4f1b445c9bcf409a375086
module usb_c_breakout() {
    breakout_width = 20;
    breakout_height = 6.8;
    breakout_position = 0.5;

    hole_height = breakout_height / 2;
    hole_diameter = 1;

    usb_c_height = 4;
    usb_c_width = 9.5;
    usb_c_depth = 7.4;
    usb_c_overhang = 1.5;

    union() {
        translate([2, 0, breakout_position]) {
            union() {
                color("red")
                    translate([-2, -wall_thickness - 0, breakout_position - 0.5])
                    cube([breakout_width + 4, 2, breakout_height]);

                difference() {
                    color("grey")
                        translate([breakout_width / 2 + usb_c_width / 2,
                                -usb_c_depth + usb_c_overhang,
                                usb_c_height + breakout_position])
                            rotate(a=[0, 90, 90])
                                roundedcube([usb_c_height, usb_c_width, usb_c_depth],
                                        r=1.5,
                                        center=false,
                                        $fs=0.05);

                }
                difference() {
                    color("pink")
                        translate([breakout_width * 0.1, -4 * hole_height, breakout_height / 2.5])
                            rotate(a=[0, 90, 90])
                                cylinder(r = hole_diameter, h = 4 * wall_thickness, $fn=60);
                }
                difference() {
                    color("pink")
                        translate([breakout_width * 0.9, -4 * hole_height, breakout_height / 2.5])
                            rotate(a=[0, 90, 90])
                                cylinder(r = hole_diameter, h = 4 * wall_thickness, $fn=60);
                }
            }
        }
    }
}
