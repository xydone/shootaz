pub inline fn handle(event: Event, state: *State) void {
    const key: Keycode = if (event.type == .KEY_DOWN) event.key_code else return;
    switch (key) {
        .C => state.show_imgui = !state.show_imgui,
        .ESCAPE => {
            sapp.lockMouse(!sapp.mouseLocked());
            state.is_camera_locked = !state.is_camera_locked;
        },
        else => {},
    }
}

const Keycode = sapp.Keycode;
const Event = sapp.Event;
const sapp = sokol.app;
const sokol = @import("sokol");

const State = @import("state.zig");
