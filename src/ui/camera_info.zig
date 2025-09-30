pub inline fn draw() void {
    defer ig.igEnd();
    if (ig.igBegin("Camera", &State.instance.ui_settings.show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        _ = ig.igText("Pitch: %f | Speed: %f | Yaw: %f", State.instance.camera.pitch, State.instance.camera.speed, State.instance.camera.yaw);
        _ = ig.igText("(%f, %f, %f)", State.instance.camera.pos.x, State.instance.camera.pos.y, State.instance.camera.pos.z);
        _ = ig.igText("up: (%f, %f, %f)", State.instance.camera.up.x, State.instance.camera.up.y, State.instance.camera.up.z);
    }
}
const State = @import("../state.zig");

const ig = @import("cimgui");
