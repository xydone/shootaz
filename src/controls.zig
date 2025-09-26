pub inline fn handle(event: Event, state: *State) void {
    switch (event.type) {
        .KEY_DOWN => state.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), true),
        .KEY_UP => state.input_state.keys.setValue(@intCast(@intFromEnum(event.key_code)), false),
        .MOUSE_MOVE => {
            if (state.camera.is_locked) return;
            const dx: f32 = event.mouse_dx * state.camera.sensitivity;
            const dy: f32 = event.mouse_dy * state.camera.sensitivity;

            state.camera.yaw += dx;
            state.camera.pitch -= dy;

            // clamp pitch so it doesn’t flip
            if (state.camera.pitch > 1.5) state.camera.pitch = 1.5;
            if (state.camera.pitch < -1.5) state.camera.pitch = -1.5;
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

const State = @import("state.zig");

const Event = sapp.Event;
const Keycode = sapp.Keycode;
const sapp = sokol.app;
const sokol = @import("sokol");

const std = @import("std");
