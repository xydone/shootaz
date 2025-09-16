const valid_keys: [4]Keycode = .{ .W, .S, .A, .D };

pub inline fn perFrame(dt: f32, state: *State) void {
    var direction = Vec3.zero();
    const forward = Vec3.norm(.{
        .x = @cos(state.camera.yaw) * @cos(state.camera.pitch),
        .y = 0,
        .z = @sin(state.camera.yaw) * @cos(state.camera.pitch),
    });
    const right = Vec3.cross(forward, state.camera.up);

    for (valid_keys) |key| {
        if (!state.input_state.isKeyPressed(key)) continue;

        switch (key) {
            .W => direction = Vec3.add(direction, forward),
            .S => direction = Vec3.sub(direction, forward),
            .A => direction = Vec3.sub(direction, right),
            .D => direction = Vec3.add(direction, right),
            else => unreachable,
        }
    }

    state.movement_direction = direction;

    if (Vec3.len(state.movement_direction) > 0) {
        const dir = Vec3.norm(state.movement_direction);
        state.velocity = Vec3.add(state.velocity, Vec3.mul(dir, state.movement_settings.accel * dt));
    } else {
        const speed = Vec3.len(state.velocity);
        if (speed > 0) {
            const drop = state.movement_settings.friction * dt;
            const new_speed = if (speed > drop) speed - drop else 0;
            state.velocity = Vec3.mul(Vec3.norm(state.velocity), new_speed);
        }
    }

    const vel_len = Vec3.len(state.velocity);
    if (vel_len > state.movement_settings.max_speed) {
        state.velocity = Vec3.mul(Vec3.norm(state.velocity), state.movement_settings.max_speed);
    }

    state.camera.pos = Vec3.add(state.camera.pos, Vec3.mul(state.velocity, dt));
}

const Vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;

const State = @import("state.zig");

const Keycode = sokol.app.Keycode;
const sokol = @import("sokol");
const std = @import("std");
