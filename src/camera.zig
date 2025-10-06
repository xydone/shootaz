pos: Vec3 = .{ .x = 0, .y = 1.5, .z = 6 },
target: Vec3 = Vec3.zero(),
up: Vec3 = Vec3.up(),
yaw: f32 = -pi / 2.0,
pitch: f32 = 0.0,
speed: f32 = 0.1,
render_distance: f32 = 1000,
view: Mat4 = Mat4.lookat(.{ .x = 0, .y = 1.5, .z = 6 }, Vec3.zero(), Vec3.up()),

const Vec3 = @import("math.zig").Vec3;
const Mat4 = @import("math.zig").Mat4;

pub fn getForward(self: @This()) Vec3 {
    return Vec3.norm(.{
        .x = @cos(self.yaw) * @cos(self.pitch),
        .y = @sin(self.pitch),
        .z = @sin(self.yaw) * @cos(self.pitch),
    });
}

pub fn updateView(self: *@This()) void {
    const forward = self.getForward();

    const view = Mat4.lookat(self.pos, Vec3.add(self.pos, forward), self.up);
    self.view = view;
}

const pi = std.math.pi;
const std = @import("std");
