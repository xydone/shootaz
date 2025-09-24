rx: f32 = 0,
ry: f32 = 0,
pip: sg.Pipeline = .{},
pass_action: sg.PassAction = .{},
color_order: [6][4]f32 = .{ red, green, blue, orange, cyan, pink },
view: mat4 = mat4.lookat(.{ .x = 0, .y = 1.5, .z = 6 }, Vec3.zero(), Vec3.up()),
camera: Camera = .{},
render_distance: f32 = 1000,
show_imgui: bool = false,
show_window: bool = true,
velocity: Vec3 = Vec3.zero(),
movement_direction: Vec3 = Vec3.zero(),
movement_settings: struct {
    accel: f32 = 1,
    friction: f32 = 10,
    max_speed: f32 = 1.5,
} = .{},
is_camera_locked: bool = false,
input_state: InputState = .{},

const InputState = @import("controls.zig").InputState;

const Camera = @import("camera.zig");

const Vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;

const green = @import("colors.zig").green;
const red = @import("colors.zig").red;
const blue = @import("colors.zig").blue;
const orange = @import("colors.zig").orange;
const cyan = @import("colors.zig").cyan;
const pink = @import("colors.zig").pink;

const ig = @import("cimgui");
const simgui = sokol.imgui;
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const stm = sokol.time;
const sdtx = sokol.debugtext;
const sokol = @import("sokol");

// only needed when using std.fmt directly instead of sokol.debugtext.print()
const fmt = std.fmt;
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const std = @import("std");
