pub inline fn handle(event: Event) void {
    const key: Keycode = if (event.type == .KEY_DOWN) event.key_code else return;
    switch (key) {
        .C => State.instance.settings.ui_settings.is_imgui_open = !State.instance.settings.ui_settings.is_imgui_open,
        .ESCAPE => {
            sapp.lockMouse(!sapp.mouseLocked());
            State.instance.settings.ui_settings.is_ui_open = !State.instance.settings.ui_settings.is_ui_open;
        },
        else => {},
    }
}

const Keycode = sapp.Keycode;
const Event = sapp.Event;
const sapp = sokol.app;
const sokol = @import("sokol");

const State = @import("state.zig");
