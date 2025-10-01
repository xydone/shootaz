active_weapon: Gun = .{
    .ammo = 3,
    .replenish_ammo = 3,
    .firing_mode = Gun.FiringModeData{ .semi = .{} },
    .fire_rate = 0.1,
},

pub const Settings = struct {
    reload_key: Keycode = .R,
    shoot_button: Mousebutton = .LEFT,
};

pub fn perFrame(dt: f32) void {
    if (State.instance.ui_settings.is_ui_open) return;
    const settings = State.instance.settings.player_settings;

    if (State.instance.player.active_weapon.cooldown > 0.0) {
        State.instance.player.active_weapon.cooldown -= dt;
        return;
    }

    const is_shooting = State.instance.input_state.isMouseButtonPressed(settings.shoot_button);

    switch (State.instance.player.active_weapon.firing_mode) {
        .semi => |*semi| {
            if (is_shooting) {
                if (semi.has_fired_this_click == false) {
                    State.instance.player.active_weapon.shoot();
                    semi.has_fired_this_click = true;
                }
            } else semi.has_fired_this_click = false;
        },
        .automatic => if (is_shooting) State.instance.player.active_weapon.shoot(),
    }

    if (State.instance.input_state.isKeyPressed(settings.reload_key)) {
        State.instance.player.active_weapon.reload();
    }
}

const State = @import("../state.zig");

const Mousebutton = @import("sokol").app.Mousebutton;
const Keycode = @import("sokol").app.Keycode;

const Gun = @import("gun.zig");
