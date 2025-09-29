pub inline fn draw(state: *State) void {
    defer ig.igEnd();
    if (ig.igBegin("Settings", &state.ui_settings.show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        if (ig.igButton("Quit")) {
            sapp.requestQuit();
        }
    }
}
const State = @import("../state.zig");

const sapp = sokol.app;
const sokol = @import("sokol");

const ig = @import("cimgui");
