var instance: Cube.InstanceData = .{ .offset = .zero() };
var buf: [20]u8 = std.mem.zeroes([20]u8);

pub inline fn draw(allocator: Allocator, state: *State) void {
    defer ig.igEnd();
    if (ig.igBegin("Insert cube", &state.ui_settings.show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        _ = ig.igInputFloat("x:", &instance.offset.x);
        _ = ig.igInputFloat("y:", &instance.offset.y);
        _ = ig.igInputFloat("z:", &instance.offset.z);
        if (ig.igButton("Insert")) {
            Cube.insert(allocator, instance);
        }

        ig.igSeparatorText("Persistency");

        _ = ig.igInputText("File name", &buf, 20, 0);
        const name = std.mem.sliceTo(&buf, 0);
        if (ig.igButton("Save")) {
            Cube.save(allocator, name) catch @panic("Couldn't save!");
        }
        if (ig.igButton("Load")) {
            Cube.load(allocator, name) catch {};
        }
    }
}
const Cube = @import("../components/cube.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const ig = @import("cimgui");

const Allocator = std.mem.Allocator;
const std = @import("std");
