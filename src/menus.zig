pub inline fn handle(event: Event, state: *State) void {
    const key: Keycode = if (event.type == .KEY_DOWN) event.key_code else return;
    switch (key) {
        .C => state.ui_settings.is_imgui_open = !state.ui_settings.is_imgui_open,
        .ESCAPE => {
            sapp.lockMouse(!sapp.mouseLocked());
            state.ui_settings.is_ui_open = !state.ui_settings.is_ui_open;
        },
        else => {},
    }
}

const Keycode = sapp.Keycode;
const Event = sapp.Event;
const sapp = sokol.app;
const sokol = @import("sokol");

const State = @import("state.zig");
