pub inline fn draw(state: *State) void {
    defer ig.igEnd();
    if (ig.igBegin("Frames", &state.ui_settings.show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        const dt = sapp.frameDuration();
        const fps = 1 / dt;
        ig.igText("Time: %.3f | FPS: %.1f", dt, fps);
    }
}
const State = @import("../state.zig");

const sapp = sokol.app;
const sokol = @import("sokol");
const ig = @import("cimgui");
