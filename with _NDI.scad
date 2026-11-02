// White Charuco (pure SCAD) + arm + imported APPLE
// Requires markers_lib.scad in the same folder

include <markers_lib.scad>

// ========== Charuco parameters ==========
sq_size = 15;
marker_size = 11;
board_cols = 7;
board_rows = 5;
border_size = 10;
thickness = 6;
surface_layer = 0.6;
geom_eps = 0.05;

// ========== Connector parameters ==========
connector_width  = 12;
connector_height = 8;
horiz_length     = 80;
vert_length      = 30;

// ========== White Charuco base ==========
module white_charuco_base() {
    effective_thickness = thickness;
    inner_w = board_cols * sq_size;
    inner_h = board_rows * sq_size;
    total_board_w = inner_w + (2 * border_size);
    total_board_h = inner_h + (2 * border_size);

    color("white") difference() {
        translate([-border_size, -border_size, 0])
            cube([total_board_w, total_board_h, effective_thickness]);

        for (x = [0 : board_cols - 1]) {
            for (y = [0 : board_rows - 1]) {
                if ((x + y) % 2 == 0) {
                    translate([x * sq_size, y * sq_size, effective_thickness - surface_layer])
                        cube([sq_size, sq_size, surface_layer + 0.2]);
                }
                if ((x + y) % 2 == 1) {
                    row_from_top = (board_rows - 1) - y;
                    index = row_from_top * board_cols + x;
                    id = floor(index / 2);
                    offset = (sq_size - marker_size) / 2;
                    translate([x * sq_size + offset, y * sq_size + offset, effective_thickness - surface_layer])
                        translate([0, 0, -geom_eps])
                            draw_marker_black_3d(id, cell = marker_size / 6, height = surface_layer + 2 * geom_eps);
                }
            }
        }
    }
}

// ========== Assembly ==========
board_w = board_cols * sq_size + 2 * border_size;   // 125
board_h = board_rows * sq_size + 2 * border_size;   // 95

// 1. White board (pure SCAD)
white_charuco_base();

// 2. Right-angle arm (bottom flush at z = 0)
translate([board_w - border_size, board_h/2 - connector_width/2, 0])
    cube([horiz_length, connector_width, connector_height]);

translate([board_w - border_size + horiz_length - connector_height,
           board_h/2 - connector_width/2,
           0])
    cube([connector_height, connector_width, vert_length + connector_height]);

// 3. APPLE (only imported STL)
translate([board_w - border_size + horiz_length - 3,
           board_h/2,
           vert_length + connector_height + 42])
    rotate([0, 0, 90])
    rotate([0, -90, 0])
    rotate([0, 0, -270])
    import("APPLE_1_post.stl", convexity=10);