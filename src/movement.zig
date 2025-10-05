pub const Settings = struct {
    accel: f32 = 1,
    friction: f32 = 10,
    max_speed: f32 = 1.5,
    direction: Vec3 = Vec3.zero(),
    velocity: Vec3 = Vec3.zero(),
};
pub inline fn perFrame(dt: f32) void {
    const settings = State.instance.settings.movement_settings;
    if (State.instance.settings.ui_settings.is_ui_open) return;

    const controls = State.instance.settings.controls;
    const direction = blk: {
        const forward = Vec3.norm(.{
            .x = @cos(State.instance.camera.yaw) * @cos(State.instance.camera.pitch),
            .y = 0,
            .z = @sin(State.instance.camera.yaw) * @cos(State.instance.camera.pitch),
        });
        const right = Vec3.cross(forward, State.instance.camera.up);

        var dir = Vec3.zero();
        if (State.instance.input_state.isKeyPressed(controls.move_forward)) dir = Vec3.add(dir, forward);
        if (State.instance.input_state.isKeyPressed(controls.move_back)) dir = Vec3.sub(dir, forward);
        if (State.instance.input_state.isKeyPressed(controls.move_left)) dir = Vec3.sub(dir, right);
        if (State.instance.input_state.isKeyPressed(controls.move_right)) dir = Vec3.add(dir, right);
        if (State.instance.input_state.isKeyPressed(controls.move_down)) dir = Vec3.sub(dir, State.instance.camera.up);
        if (State.instance.input_state.isKeyPressed(controls.move_up)) dir = Vec3.add(dir, State.instance.camera.up);

        break :blk dir;
    };

    State.instance.settings.movement_settings.direction = direction;

    if (Vec3.len(settings.direction) > 0) {
        const dir = Vec3.norm(settings.direction);
        State.instance.settings.movement_settings.velocity = Vec3.add(State.instance.settings.movement_settings.velocity, Vec3.mul(dir, settings.accel * dt));
    } else {
        const speed = Vec3.len(State.instance.settings.movement_settings.velocity);
        if (speed > 0) {
            const drop = settings.friction * dt;
            const new_speed = if (speed > drop) speed - drop else 0;
            State.instance.settings.movement_settings.velocity = Vec3.mul(Vec3.norm(State.instance.settings.movement_settings.velocity), new_speed);
        }
    }

    const vel_len = Vec3.len(State.instance.settings.movement_settings.velocity);
    if (vel_len > settings.max_speed) {
        State.instance.settings.movement_settings.velocity = Vec3.mul(Vec3.norm(State.instance.settings.movement_settings.velocity), settings.max_speed);
    }

    State.instance.camera.pos = Vec3.add(State.instance.camera.pos, Vec3.mul(State.instance.settings.movement_settings.velocity, dt));

    var front: Vec3 = .{
        .x = @cos(State.instance.camera.yaw) * @cos(State.instance.camera.pitch),
        .y = @sin(State.instance.camera.pitch),
        .z = @sin(State.instance.camera.yaw) * @cos(State.instance.camera.pitch),
    };
    front = Vec3.norm(front);

    State.instance.camera.target = Vec3.add(State.instance.camera.pos, front);
}

const Vec3 = @import("math.zig").Vec3;
const Mat4 = @import("math.zig").Mat4;

const State = @import("state.zig");

const Keycode = sokol.app.Keycode;
const sokol = @import("sokol");
const std = @import("std");
