$fn=64;             // smooth round things
motor_g = 22.625;   // distance between motor's center and origin
motor_d = 6+.10;    // motor diameter

dxf="./main.dxf";

// charger hole:
chw=4.75;           // width
chh=3.15;           // height
ckw=2.6;            // key width
ckh=1.75;           // key height

cam_z=5.7;          // camera mount vertical alignment
cam_x=-8.625;
cam_rect_o = 7.4;   // camera rectangular box outer width
cam_rect_i = 6.5;   // camera rectangular box inner width
cam_rect_h = 2.5;
cam_cyl_h = 1.25;   // camera cylinder height
cam_cyl_d = 7.1;    // ...and outer diameter
cam_cone_h = 1.2;
cam_cone_d = 6.5;


charger_hole_supports = true;
camera_mount_enable = true;     // maybe you need a case for CX-10(A)
camera_mount_support = true;

feet_enable = true;

led_holes_support = true;

main();

module charger_hole() {
    if(charger_hole_supports) {
        translate([0,10,6-chh/2]) {
            translate([0,0,-.1]) cube([chw,5,chh-.2], center=true);
            translate([0,0,-chh/2-ckh/2-.1]) cube([ckw,5,ckh-.2], center=true);
        }
    } else {
        translate([0,10,6-chh/2]) {
            cube([chw,5,chh], center=true);
            translate([0,0,-chh/2-ckh/2]) cube([ckw,5,ckh], center=true);
        }
    }
}

module camera_mount_subtractive() {
    wall_w = (cam_rect_o-cam_rect_i)/2;
    cube_h = cam_rect_h-wall_w;
    /* all that dancing around hull() is due to openSCAD glitchy behavior
     * when subtracting few stacked objects from other object */
    union() {
        translate([0,0,cube_h/2]) cube([cam_rect_i, cam_rect_i, cube_h], center = true);
        hull() {
            cylinder(h = cam_cyl_h+wall_w+cube_h, d = cam_cyl_d-wall_w*2);
            translate([0,0,cube_h+wall_w+cam_cyl_h+cam_cone_h*.9])
                cylinder(h = cam_cone_h*.1, d = cam_cone_d-wall_w*2);
        }
    }
}

module camera_mount_additive() {
    rotate([0,0,0]) union() {
        translate([0,0,cam_rect_h/2]) cube([cam_rect_o,cam_rect_o,cam_rect_h], center = true);
        translate([0,0,cam_rect_h]) {
            cylinder(h = cam_cyl_h, d=cam_cyl_d);
            translate([0,0,cam_cyl_h]) cylinder(h = cam_cone_h, d1=cam_cyl_d, d2=cam_cone_d);
        }
    }
}

module single_foot() {
    rotate([0,0,45]) {
        translate([0,motor_g,-5]) {
            difference() {
                cylinder(d1 = 7, d2=9, h=5);
                difference() {
                    cylinder(d1 = 5, d2=7, h=5);
                    translate([0,1,2.5]) cube([1,9,5], center=true);
                }
                translate([-4.5,-7,0]) cube([9,9,5]);
            }
        }
    }   
}

module main() {
    difference() {
        union() {
            difference() {
                union() {
                    main_body();
                    if(camera_mount_enable)
                        translate([cam_x,0,cam_z]) rotate([0,-90,0]) camera_mount_additive();
                    if(feet_enable)
                        for(a=[0:3]) rotate([0,0,a*90]) single_foot();
                }
                charger_hole();
                if(camera_mount_enable)
                    translate([cam_x,0,cam_z]) rotate([0,-90,0]) camera_mount_subtractive();
            }
            if(camera_mount_enable&&camera_mount_support) translate([-20.75/2-0,0,6-.05]) cube([3,7.1,.3],true);
        }
        // cutoff everything above 6mm
        translate([-50,-50,6]) cube([100,100,100]);
    }
}

module main_body() {
    difference() {
        union() {
            to_center = 16.3207;
            between = 5.63;
            for(a=[0:3]) {
                rotate([0,0,90*a])
                    difference() {
                        linear_extrude(height = 6, convexity = 1) import(dxf, layer="arm");
                        cylinder(r1=to_center+between/2, r2=to_center-between/2, h = 2);
                        
                    }
            }
            translate([0,0,2-1.2]) linear_extrude(height = 4+1.2, convexity = 1) import(dxf, layer="battery compartment");
            //linear_extrude(height = 6, convexity = 1) import("Untitled.dxf", layer="arm contour");
            translate([0,0,5.5]) linear_extrude(height = .5, convexity = 1) import(dxf, layer="screwholes");
            translate([0,0,0]) linear_extrude(height = .5, convexity = 1) import(dxf, layer="motor stoppers");
            translate([0,0,1]) linear_extrude(height = 5, convexity = 1) import(dxf, layer="motor bushings");
            
            sp = 26.43;
            
            translate([0,0,2-1.2]) difference () {
                intersection() {
                    union() {
                        translate([0,0,sp]) sphere(30);
                        translate([0,0,-2.5]) cube([19,19,5], center = true);
                    }
                    translate([0,0,-10]) linear_extrude(height = 10, convexity = 1) import(dxf, layer="contour mask");
                }
                
                intersection() {
                    union() {
                        translate([0,0,sp]) sphere(29);
                        translate([0,0,-2.5]) cube([18.2,18.2,5], center = true);
                    }
                    translate([0,0,-10]) linear_extrude(height = 10, convexity = 1) import(dxf, layer="inner contour mask");
                }
            }
            translate([0,0,-5+2-1.2]) for(a=[0:1])
            {
                rotate([0,0,90*a]) for(b=[0:1])
                {
                    translate([18/4*(b*2-1), 0, 0.2+a*0.1]) cube([2, 18.2, 0.4+a*0.2], center = true);
                }
            }
        }
        
        // led holes
        led=1;
        for(a=[0:3]) {
            rotate([0,0,a*90+45]) {
                translate([motor_g,0,.5+3]) cylinder(h=6, center=true, d=motor_d);
                if(led_holes_support) {
                    translate([0,75-4,6-led/2-.1]) cube([3,100,led-.2], center=true);
                } else {
                    translate([0,75-4,6-led/2]) cube([3,100,led], center=true);
                }
            }
        }
    }
}