pub inline fn handle(event: Event) void {
    switch (event.type) {
        .KEY_DOWN => State.instance.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), true),
        .KEY_UP => State.instance.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), false),
        .MOUSE_MOVE => {
            if (State.instance.settings.ui_settings.is_ui_open) return;
            const dx: f32 = event.mouse_dx * State.instance.camera.sensitivity;
            const dy: f32 = event.mouse_dy * State.instance.camera.sensitivity;

            State.instance.camera.yaw += dx;
            State.instance.camera.pitch -= dy;

            // clamp pitch so it doesn’t flip
            if (State.instance.camera.pitch > 1.5) State.instance.camera.pitch = 1.5;
            if (State.instance.camera.pitch < -1.5) State.instance.camera.pitch = -1.5;
        },
        .MOUSE_UP => State.instance.input_state.mouse_buttons.setValue(@intCast(@intFromEnum(event.mouse_button)), false),
        .MOUSE_DOWN => State.instance.input_state.mouse_buttons.setValue(@intCast(@intFromEnum(event.mouse_button)), true),
        else => {},
    }
}

pub const InputState = struct {
    const KeyBitSet = std.bit_set.IntegerBitSet(@as(u16, @intFromEnum(LAST_KEY_IN_KEYCODE_LIST)) + 1);
    const MouseBitSet = std.bit_set.IntegerBitSet(@as(u16, @intFromEnum(LAST_MOUSE_BUTTON_IN_LIST)) + 1);

    keys: KeyBitSet = .initEmpty(),
    mouse_buttons: MouseBitSet = .initEmpty(),

    pub inline fn isKeyPressed(input: InputState, key: Keycode) bool {
        return input.keys.isSet(@intCast(@intFromEnum(key)));
    }

    pub inline fn isKeyReleased(input: InputState, key: Keycode) bool {
        return !input.isKeyPressed(key);
    }

    pub inline fn isMouseButtonPressed(input: InputState, button: Mousebutton) bool {
        return input.mouse_buttons.isSet(@intCast(@intFromEnum(button)));
    }

    pub inline fn isMouseButtonReleased(input: InputState, button: Mousebutton) bool {
        return !input.isMouseButtonPressed(button);
    }
};

const LAST_KEY_IN_KEYCODE_LIST = Keycode.MENU;
const LAST_MOUSE_BUTTON_IN_LIST = Mousebutton.MIDDLE;

const Gun = @import("player/gun.zig");
const State = @import("state.zig");

const Event = sapp.Event;
const Mousebutton = sapp.Mousebutton;
const Keycode = sapp.Keycode;
const sapp = sokol.app;
const sokol = @import("sokol");

const std = @import("std");
