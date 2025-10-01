pass_action: sg.PassAction = .{},
camera: Camera = .{},
input_state: InputState = .{},
settings: Settings = .{},
ui_settings: UISettings = .{},
objects: Object,
script_manager: ScriptManager,
player: Player = .{},

pub var instance: @This() = .{
    .objects = undefined,
    .script_manager = undefined,
};

const UISettings = @import("ui/ui.zig").Settings;
const MovementSettings = @import("movement.zig").Settings;
const Settings = @import("settings.zig");

const InputState = @import("controls.zig").InputState;

const Object = @import("components/object.zig");
const Camera = @import("camera.zig");

const Player = @import("player/player.zig");

const ScriptManager = @import("scripting/script_manager.zig");

const Vec3 = @import("math.zig").Vec3;
const Mat4 = @import("math.zig").Mat4;

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
