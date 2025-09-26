pub inline fn draw(state: *State) void {
    defer ig.igEnd();
    if (ig.igBegin("Camera", &state.ui_settings.show_window, ig.ImGuiWindowFlags_None)) {
        _ = ig.igText("Pitch: %f | Speed: %f | Yaw: %f", state.camera.pitch, state.camera.speed, state.camera.yaw);
        _ = ig.igText("(%f, %f, %f)", state.camera.pos.x, state.camera.pos.y, state.camera.pos.z);
        _ = ig.igText("up: (%f, %f, %f)", state.camera.up.x, state.camera.up.y, state.camera.up.z);
    }
}
const State = @import("../state.zig");

const ig = @import("cimgui");
