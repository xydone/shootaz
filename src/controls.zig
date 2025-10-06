pub const Settings = struct {
    reload: Keycode = .R,
    shoot: Mousebutton = .LEFT,
    move_forward: Keycode = .W,
    move_back: Keycode = .S,
    move_left: Keycode = .A,
    move_right: Keycode = .D,
    move_up: Keycode = .SPACE,
    move_down: Keycode = .LEFT_SHIFT,
    sensitivity: f32 = cm360ToSens(800, 30),

    pub fn init(allocator: Allocator) !Settings {
        return readZon(Settings, allocator, "config/controls.zon", 1024);
    }
};

pub inline fn handle(event: Event) void {
    switch (event.type) {
        .KEY_DOWN => State.instance.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), true),
        .KEY_UP => State.instance.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), false),
        .MOUSE_MOVE => {
            if (State.instance.settings.ui_settings.is_ui_open) return;
            const dx: f32 = event.mouse_dx * State.instance.settings.controls.sensitivity;
            const dy: f32 = event.mouse_dy * State.instance.settings.controls.sensitivity;

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

inline fn cm360ToSens(dpi: f32, cm: f32) f32 {
    return (2.0 * pi * 2.54) / (dpi * cm);
}

const LAST_KEY_IN_KEYCODE_LIST = Keycode.MENU;
const LAST_MOUSE_BUTTON_IN_LIST = Mousebutton.MIDDLE;

const readZon = @import("util/readZon.zig").readZon;

const Gun = @import("player/gun.zig");
const State = @import("state.zig");

const Event = sapp.Event;
const Mousebutton = sapp.Mousebutton;
const Keycode = sapp.Keycode;
const sapp = sokol.app;
const sokol = @import("sokol");

const pi = std.math.pi;

const Allocator = std.mem.Allocator;
const std = @import("std");
