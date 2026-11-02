/* ========================================================================
    CHARUCO BOARD
   1. SETTINGS
      - Setup your board parameter in Customizer -> Geometry settting -> Preview (F5)

   2. EXPORT:
      - Select 'White Base' in Customizer -> Render (F6) -> Export STL.
      - Select 'Black Pattern' in Customizer -> Render (F6) -> Export STL.
      - (Repeat for every Part Index required).

   3. IMPORT:
      - Drag BOTH files into the slicer window AT THE SAME TIME.
      - A dialog will appear: "Load as single object with multiple parts?"
      - Click YES (or "Multi-Part Object").

   4. COLOR ASSIGN:
      - You will see ONE object in the list with two sub-parts.
      - Assign Filament 1 (White) to the total part.
      - Assign Filament 1 (White) to the white sub-part.
      - Assign Filament 2 (Black) to the black sub-part.
    ======================================================================== */

// --- CUSTOMIZER PARAMETERS (MUST BE TOP LEVEL) --------------------------

/* [Export Settings] */
// Controls which component is shown/rendered.
export_mode = "Preview"; // [Preview, White Base, Black Pattern]

/* [Apple 1 Attachment] */
include_apple_post = true;
apple_post_file = "NDI_mounting_post.stl"; // Keep this STL beside this SCAD file, or provide its full path.
apple_offset_x = 5; // Additional X offset from the board's upper-right corner (mm).
apple_offset_y = 5; // Additional Y offset from the board's upper-right corner (mm).

/* [Geometry Settings] */
sq_size = 17;             // Grid square size (mm)
marker_size = 13;         // Marker size (mm) - leaves black border
board_cols = 8;          // Number of columns
board_rows = 6;          // Number of rows
border_size = 5;         // Border width (mm) around the chart

// Base thickness (mm).
thickness = 4;

// Depth of the black material flush surface (mm).
surface_layer = 0.6;

/* [Marker Dictionary] */
// DICT_4X4_250 supports marker IDs 0..249.
marker_dict_capacity = 250;
geom_eps = 0.02;          // Small overlap to avoid coplanar boolean artifacts

// --- LIBRARY IMPORT & VALIDATION ----------------------------------------

include <markers_lib.scad>
assert(markers_loaded, "CRITICAL ERROR: 'markers_lib.scad' is missing or outdated. Please run the Python marker generator to create/update the marker library.");

// --- 1. CALCULATIONS & LOGIC --------------------------------------------

effective_thickness = thickness;
inner_w = board_cols * sq_size;
inner_h = board_rows * sq_size;
total_board_w = inner_w + (2 * border_size);
total_board_h = inner_h + (2 * border_size);

label_text = str(board_rows, "x", board_cols , " Grid | ", sq_size, "mm Sq / ", marker_size, "mm Mrk | DICT_4X4_250");

max_marker_id = floor((board_rows * board_cols - 1) / 2);

// --- 2. ERROR CHECKING --------------------------------------------------

assert(board_cols > 0 && board_rows > 0, "CRITICAL ERROR: board_cols and board_rows must be greater than 0.");
assert(sq_size > 0 && marker_size > 0, "CRITICAL ERROR: sq_size and marker_size must be greater than 0.");
assert(marker_size <= sq_size, "CRITICAL ERROR: marker_size must be <= sq_size.");
assert(surface_layer > 0 && surface_layer < effective_thickness, "CRITICAL ERROR: surface_layer must be > 0 and < thickness.");
assert(max_marker_id < marker_dict_capacity, str("CRITICAL ERROR: Board needs marker ID ", max_marker_id, ", but dictionary supports max ", marker_dict_capacity - 1, ". Reduce board size or increase marker library."));

// --- 3. CONSOLE DEBUGGING -----------------------------------------------

echo("=================================================");
echo("   CHARUCO GENERATOR - DEBUG OUTPUT (V42.0)      ");
echo("=================================================");
echo(str("[CONFIG] Grid (Cols x Rows): ", board_cols, " x ", board_rows));
echo(str("[CONFIG] Board Thick       : ", effective_thickness, " mm"));
echo(str("[CONFIG] Square Size       : ", sq_size, " mm"));
echo(str("[CONFIG] Marker Size       : ", marker_size, " mm"));
echo(str("[CONFIG] Border Size       : ", border_size, " mm"));
echo(str("[INFO]   Board Size (W x H): ", total_board_w, " x ", total_board_h, " mm"));
echo(str("[INFO]   Max Marker ID     : ", max_marker_id));
echo(str("[INFO]   Label Text        : ", label_text));
echo("=================================================");


// --- APPLE 1 POST ASSEMBLY ----------------------------------------------
// Original geometry from APPLE_1_post.scad. Its local origin is placed at
// the upper-right corner of the ChArUco board (see apple_anchor_x/y below).
module apple_1_post_geometry() {
//This is rigid body contains coordinates [-47.206 0.000], [0.345 44.316], [40.794 0.000], [-0.223 -28.594].

//body of DRF parameters
dx = 88; //total cross length
dx1 = 40.7941; // +x direction (in blue)
dx2 = 47.2059; //-x direction (in green)
dy = 72.912; //total cross length
dy1 = 44.3171; // +y direction (in red)
dy2 = 28.5949; //-y direction (in purple)
axy = 89.5536; //angle between cross lengths

//insert file location of the mounting post
post = apple_post_file;

//clearance holes parameters
oh = 10; //central clearance hole depth
or = 2.5; //central clearance hole radius
xh = dx+10; //x-body clearance hole 1 depth
xr = 2; //x-body clearance hole 1 radius
yh = dy+10; //x-body clearance hole 2 depth
yr = xr; //x-body clearance hole 2 radius
g = 5; //z-translation of x-body clearance holes

//DRF polygon points
dx1_points_o =[[(dx1+5),5],[(dx1+5),-5],[0,-5],[0,5]];
dx2_points_o =[[-(dx2+5),5],[-(dx2+5),-5],[0,-5],[0,5]];
dy1_points_o =[[(dy1+5),5],[(dy1+5), -5],[0,-5],[0,5]];
dy2_points_o =[[(dy2+5),5],[(dy2+5), -5],[0,-5],[0,5]];
dx1_points_i =[[(dx1-5),2],[(dx1-5),-2], [(5),-2], [(5), 2]];
dx2_points_i =[[-(dx2-5),2],[-(dx2-5),-2], [-(5),-2], [-(5), 2]];
dy1_points_i =[[(dy1-5),2], [(dy1-5),-2], [5,-2], [5,2]];
dy2_points_i =[[(dy2-5),2], [(dy2-5),-2], [5,-2], [5,2]];

difference(){
    //DRF without clearance holes
    union(){
        difference(){
            color("blue")
            linear_extrude (10)
            polygon(dx1_points_o);
            linear_extrude (10)
            polygon(dx1_points_i);
        }
        color("blue")
        translate([dx1, 0, 9.9999])
        import(post);

        difference(){
            color("green")
            linear_extrude (10)
            polygon(dx2_points_o);
            linear_extrude (10)
            polygon(dx2_points_i);
        }
        color("green")
        translate([-dx2, 0, 9.9999])
        import(post);

        difference(){
            color ("red")
            rotate ([0,0,axy])
            linear_extrude (10)
            polygon(dy1_points_o);
            rotate ([0,0,axy])
            linear_extrude (10)
            polygon(dy1_points_i);
        }
        color("red")
        translate ([(cos(axy)*dy1),(sin(axy)*dy1),9.9999])
        import(post);

        difference(){
            color ("purple")
            rotate ([0,0,-(180-axy)])
            linear_extrude (10)
            polygon(dy2_points_o);
            rotate ([0,0,-(180-axy)])
            linear_extrude (10)
            polygon(dy2_points_i);
        }
        color("purple")
        translate([-(cos(axy)*dy2),-(sin(axy)*dy2),9.9999])
        import(post);
    }

    //clearance holes
    union(){
        //central clearance hole
        cylinder(oh,or,or,$fn=25);
        //x-body clearance hole 1
        rotate([0,-90,0])
        translate([g,0,-(dx1+5)])
        cylinder(xh, xr, xr, $fn=25);
        //x-body clearance hole 2
        rotate([axy,-90,0])
        translate([g,0,-(dy1+5)])
        cylinder(yh, yr, yr, $fn=25);
    }
}

translate([-10,2.3, 8])
rotate([0,0,180])
linear_extrude(2)
{text("APPLE 1",5, font = "Liberation Sans:style=Bold");}

}

// --- MAIN RENDER MODULE -------------------------------------------------

module render_board() {
    // --- COMPONENT 1: WHITE BASE ---
    if (export_mode == "White Base" || export_mode == "Preview") {
        color("white") union() {
          difference() {
            // A. Base plate with full border
            translate([-border_size, -border_size, 0])
                cube([total_board_w, total_board_h, effective_thickness]);

            // B. Subtract all black features from white base
            for (x = [0 : board_cols - 1]) {
                for (y = [0 : board_rows - 1]) {
                    global_x = x;
                    global_y = y;

                    if ((global_x + global_y) % 2 == 0) { // Solid black square
                        translate([x * sq_size, y * sq_size, effective_thickness - surface_layer])
                            cube([sq_size, sq_size, surface_layer + 0.1]);
                    }

                    if ((global_x + global_y) % 2 == 1) { // Marker square
                        row_from_top = (board_rows - 1) - global_y;
                        index = row_from_top * board_cols + global_x;
                        id = floor(index / 2);
                        offset = (sq_size - marker_size) / 2;

                        translate([x * sq_size + offset, y * sq_size + offset, effective_thickness - surface_layer]) {
                            translate([0, 0, -geom_eps])
                                draw_marker_black_3d(id, cell = marker_size / 6, height = surface_layer + 2 * geom_eps);
                        }
                    }
                }
            }

            // C. Label (back side / underside engraving)
            translate([inner_w / 2, -border_size / 2, -0.01])
                linear_extrude(0.8)
                mirror([1, 0, 0])
                text(label_text, size = 3.5, font = "Arial:style=Bold", halign = "center", valign = "center");
          } // end white-base difference()

          // Apple 1 assembly is included ONLY in the white-base export.
          // Its local origin is anchored at the board's upper-right corner.
          if (include_apple_post) {
              translate([inner_w + border_size + apple_offset_x,
                         inner_h + border_size + apple_offset_y, 0])
                  apple_1_post_geometry();
          }
        } // end white-base union()
    }

    // --- COMPONENT 2: BLACK PATTERN ---
    if (export_mode == "Black Pattern" || export_mode == "Preview") {
        color("black") union() {
            for (x = [0 : board_cols - 1]) {
                for (y = [0 : board_rows - 1]) {
                    global_x = x;
                    global_y = y;

                    if ((global_x + global_y) % 2 == 0) { // Solid black square
                        translate([x * sq_size, y * sq_size, effective_thickness - surface_layer])
                            cube([sq_size, sq_size, surface_layer]);
                    }

                    if ((global_x + global_y) % 2 == 1) { // Marker square
                        row_from_top = (board_rows - 1) - global_y;
                        index = row_from_top * board_cols + global_x;
                        id = floor(index / 2);
                        offset = (sq_size - marker_size) / 2;

                        translate([x * sq_size + offset, y * sq_size + offset, effective_thickness - surface_layer]) {
                            draw_marker_black_3d(id, cell = marker_size / 6, height = surface_layer);
                        }
                    }
                }
            }
        }
    }
}

render_board();

