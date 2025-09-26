pass_action: sg.PassAction = .{},
color_order: [6][4]f32 = .{ red, green, blue, orange, cyan, pink },
camera: Camera = .{},
input_state: InputState = .{},
movement_settings: MovementSettings = .{},
ui_settings: UISettings = .{},

const UISettings = @import("ui/ui.zig").Settings;
const MovementSettings = @import("movement.zig").Settings;

const InputState = @import("controls.zig").InputState;

const Camera = @import("camera.zig");

const Vec3 = @import("math.zig").Vec3;
const Mat4 = @import("math.zig").Mat4;

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
