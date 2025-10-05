active_weapon: Gun = .{
    .ammo = 3,
    .replenish_ammo = 3,
    .firing_mode = Gun.FiringModeData{ .semi = .{} },
    .fire_rate = 0.1,
},
stats: Stats = .{},

pub fn perFrame(dt: f32) void {
    if (State.instance.settings.ui_settings.is_ui_open) return;
    const controls = State.instance.settings.controls;

    if (State.instance.player.active_weapon.cooldown > 0.0) {
        State.instance.player.active_weapon.cooldown -= dt;
        return;
    }

    const is_shooting = State.instance.input_state.isMouseButtonPressed(controls.shoot);

    switch (State.instance.player.active_weapon.firing_mode) {
        .semi => |*semi| {
            if (is_shooting) {
                if (semi.has_fired_this_click == false) {
                    shoot();
                    semi.has_fired_this_click = true;
                }
            } else semi.has_fired_this_click = false;
        },
        .automatic => if (is_shooting) shoot(),
    }

    if (State.instance.input_state.isKeyPressed(controls.reload)) {
        reload();
    }
}

pub fn shoot() void {
    State.instance.player.stats.total_shots += 1;
    const can_shoot = State.instance.player.active_weapon.canShoot();
    if (can_shoot == false) return;
    const is_hit = State.instance.player.active_weapon.shoot();
    if (is_hit) State.instance.player.stats.accurate_shots += 1;
}

pub fn reload() void {
    if (State.instance.player.active_weapon.ammo == State.instance.player.active_weapon.replenish_ammo) return;
    State.instance.player.active_weapon.reload();
    State.instance.player.stats.reload_count += 1;
}

const Stats = @import("stats.zig");

const State = @import("../state.zig");

const Mousebutton = @import("sokol").app.Mousebutton;
const Keycode = @import("sokol").app.Keycode;

const Gun = @import("gun.zig");
