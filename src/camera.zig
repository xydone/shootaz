pos: Vec3 = .{ .x = 0, .y = 1.5, .z = 6 },
target: Vec3 = Vec3.zero(),
up: Vec3 = Vec3.up(),
yaw: f32 = -pi / 2.0,
pitch: f32 = 0.0,
speed: f32 = 0.1,
sensitivity: f32 = cm360ToSens(800, 30),

const Vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;

pub inline fn cm360ToSens(dpi: f32, cm: f32) f32 {
    return (2.0 * pi * 2.54) / (dpi * cm);
}

const pi = std.math.pi;
const std = @import("std");
