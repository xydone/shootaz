var instance: Sphere.InstanceData = .{
    .offset = .zero(),
    .color = red,
    .radius = 1,
};
var buf: [20]u8 = std.mem.zeroes([20]u8);

pub inline fn draw(allocator: Allocator) void {
    defer ig.igEnd();
    if (ig.igBegin("Object Info", &State.instance.ui_settings.show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        _ = ig.igInputText("Name", &buf, 20, 0);
        const name = std.mem.sliceTo(&buf, 0);

        if (ig.igButton("Launch script")) {
            State.instance.script_manager.is_update_script_running = true;
            State.instance.script_manager.doFile(allocator, name) catch {};
        }
    }
}

const red = @import("../colors.zig").red;
const Sphere = @import("../components/sphere.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const ig = @import("cimgui");

const Allocator = std.mem.Allocator;
const std = @import("std");
