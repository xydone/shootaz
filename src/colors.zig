fn rgbaArray(r: f32, g: f32, b: f32, a: f32) [4]f32 {
    return .{ r, g, b, a };
}

pub const red = rgbaArray(1, 0, 0, 1);
pub const gray = rgbaArray(0.5, 0.5, 0.5, 1.0);
pub const green = rgbaArray(0.0, 1.0, 0.0, 1.0);
pub const blue = rgbaArray(0.0, 0.0, 1.0, 1.0);
pub const orange = rgbaArray(1.0, 0.5, 0.0, 1.0);
pub const cyan = rgbaArray(0.0, 0.5, 1.0, 1.0);
pub const pink = rgbaArray(1.0, 0.0, 0.5, 1.0);

const std = @import("std");
