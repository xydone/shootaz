pub const Settings = struct {
    accel: f32 = 1,
    friction: f32 = 10,
    max_speed: f32 = 1.5,
    valid_keys: []const Keycode = &.{ .W, .S, .A, .D, .LEFT_SHIFT, .SPACE },
    direction: Vec3 = Vec3.zero(),
    velocity: Vec3 = Vec3.zero(),
};
pub inline fn perFrame(dt: f32, state: *State) void {
    const settings = state.movement_settings;
    if (state.camera.is_locked) return;
    var direction = Vec3.zero();
    const forward = Vec3.norm(.{
        .x = @cos(state.camera.yaw) * @cos(state.camera.pitch),
        .y = 0,
        .z = @sin(state.camera.yaw) * @cos(state.camera.pitch),
    });
    // const right = Vec3.cross(state.camera.up, forward);
    const right = Vec3.cross(forward, state.camera.up);

    for (settings.valid_keys) |key| {
        if (!state.input_state.isKeyPressed(key)) continue;

        switch (key) {
            .W => direction = Vec3.add(direction, forward),
            .S => direction = Vec3.sub(direction, forward),
            .A => direction = Vec3.sub(direction, right),
            .D => direction = Vec3.add(direction, right),
            .LEFT_SHIFT => direction = Vec3.sub(direction, state.camera.up),
            .SPACE => direction = Vec3.add(direction, state.camera.up),
            else => unreachable,
        }
    }

    state.movement_settings.direction = direction;

    if (Vec3.len(settings.direction) > 0) {
        const dir = Vec3.norm(settings.direction);
        state.movement_settings.velocity = Vec3.add(state.movement_settings.velocity, Vec3.mul(dir, settings.accel * dt));
    } else {
        const speed = Vec3.len(state.movement_settings.velocity);
        if (speed > 0) {
            const drop = settings.friction * dt;
            const new_speed = if (speed > drop) speed - drop else 0;
            state.movement_settings.velocity = Vec3.mul(Vec3.norm(state.movement_settings.velocity), new_speed);
        }
    }

    const vel_len = Vec3.len(state.movement_settings.velocity);
    if (vel_len > settings.max_speed) {
        state.movement_settings.velocity = Vec3.mul(Vec3.norm(state.movement_settings.velocity), settings.max_speed);
    }

    state.camera.pos = Vec3.add(state.camera.pos, Vec3.mul(state.movement_settings.velocity, dt));

    var front: Vec3 = .{
        .x = @cos(state.camera.yaw) * @cos(state.camera.pitch),
        .y = @sin(state.camera.pitch),
        .z = @sin(state.camera.yaw) * @cos(state.camera.pitch),
    };
    front = Vec3.norm(front);

    state.camera.target = Vec3.add(state.camera.pos, front);
    // state.camera.target = Vec3.sub(state.camera.pos, front);
}

const Vec3 = @import("math.zig").Vec3;
const Mat4 = @import("math.zig").Mat4;

const State = @import("state.zig");

const Keycode = sokol.app.Keycode;
const sokol = @import("sokol");
const std = @import("std");
