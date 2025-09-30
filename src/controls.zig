pub inline fn handle(event: Event) void {
    switch (event.type) {
        .KEY_DOWN => State.instance.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), true),
        .KEY_UP => State.instance.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), false),
        .MOUSE_MOVE => {
            if (State.instance.ui_settings.is_ui_open) return;
            const dx: f32 = event.mouse_dx * State.instance.camera.sensitivity;
            const dy: f32 = event.mouse_dy * State.instance.camera.sensitivity;

            State.instance.camera.yaw += dx;
            State.instance.camera.pitch -= dy;

            // clamp pitch so it doesn’t flip
            if (State.instance.camera.pitch > 1.5) State.instance.camera.pitch = 1.5;
            if (State.instance.camera.pitch < -1.5) State.instance.camera.pitch = -1.5;
        },
        .MOUSE_DOWN => {
            if (!State.instance.ui_settings.is_imgui_open and !State.instance.ui_settings.is_ui_open) {
                Gun.shoot();
            }
        },
        else => {},
    }
}

pub const InputState = struct {
    const KeyBitSet = std.bit_set.IntegerBitSet(@as(u16, @intFromEnum(LAST_KEY_IN_KEYCODE_LIST)) + 1);

    keys: KeyBitSet = KeyBitSet.initEmpty(),

    pub inline fn isKeyPressed(input: InputState, key: Keycode) bool {
        return input.keys.isSet(@intCast(@intFromEnum(key)));
    }

    pub inline fn isKeyReleased(input: InputState, key: Keycode) bool {
        return !input.isKeyPressed(key);
    }
};

const LAST_KEY_IN_KEYCODE_LIST = Keycode.MENU;

const Gun = @import("weapons/gun.zig");
const State = @import("state.zig");

const Event = sapp.Event;
const Keycode = sapp.Keycode;
const sapp = sokol.app;
const sokol = @import("sokol");

const std = @import("std");
