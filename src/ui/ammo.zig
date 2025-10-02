pub inline fn draw() void {
    defer ig.igEnd();

    const height = sapp.height();

    ig.igSetNextWindowPosEx(
        .{ .x = 0, .y = @floatFromInt(height) },
        ig.ImGuiCond_Once,
        .{ .x = 0.0, .y = 1.0 },
    );

    if (ig.igBegin(" ", null, ig.ImGuiWindowFlags_AlwaysAutoResize | ig.ImGuiWindowFlags_NoInputs | ig.ImGuiWindowFlags_NoFocusOnAppearing)) {
        ig.igText("Ammo: %d | Time left: %.1f", State.instance.player.active_weapon.ammo, State.instance.script_manager.timer.remaining());
    }
}
const State = @import("../state.zig");

const sapp = sokol.app;
const sokol = @import("sokol");

const ig = @import("cimgui");
