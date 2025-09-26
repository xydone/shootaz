pos: Vec3 = .{ .x = 0, .y = 1.5, .z = 6 },
target: Vec3 = Vec3.zero(),
up: Vec3 = Vec3.up(),
yaw: f32 = -pi / 2.0,
pitch: f32 = 0.0,
speed: f32 = 0.1,
sensitivity: f32 = cm360ToSens(800, 30),
render_distance: f32 = 1000,
is_locked: bool = false,
view: Mat4 = Mat4.lookat(.{ .x = 0, .y = 1.5, .z = 6 }, Vec3.zero(), Vec3.up()),

const Vec3 = @import("math.zig").Vec3;
const Mat4 = @import("math.zig").Mat4;

pub inline fn cm360ToSens(dpi: f32, cm: f32) f32 {
    return (2.0 * pi * 2.54) / (dpi * cm);
}

pub fn updateView(self: *@This(), params: struct { yaw: f32, pitch: f32, pos: Vec3, up: Vec3 }) void {
    // calculate forward vector from yaw/pitch
    const front = Vec3.norm(.{
        .x = @cos(params.yaw) * @cos(params.pitch),
        .y = @sin(params.pitch),
        .z = @sin(params.yaw) * @cos(params.pitch),
    });

    const view = Mat4.lookat(params.pos, Vec3.add(params.pos, front), params.up);
    self.view = view;
}

const pi = std.math.pi;
const std = @import("std");
