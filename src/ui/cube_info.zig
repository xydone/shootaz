var position: Vec3 = .zero();

pub inline fn draw(allocator: Allocator, state: *State) void {
    defer ig.igEnd();
    if (ig.igBegin("Insert cube", &state.ui_settings.show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        _ = ig.igInputFloat("x:", &position.x);
        _ = ig.igInputFloat("y:", &position.y);
        _ = ig.igInputFloat("z:", &position.z);
        if (ig.igButton("Insert!")) {
            Cube.insert(allocator, position);
        }
    }
}
const Cube = @import("../components/cube.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const ig = @import("cimgui");

const Allocator = std.mem.Allocator;
const std = @import("std");
