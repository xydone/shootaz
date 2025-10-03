pub inline fn draw() void {
    defer ig.igEnd();

    const width = sapp.width();

    ig.igSetNextWindowPosEx(
        .{ .x = @floatFromInt(width), .y = 0 },
        ig.ImGuiCond_Once,
        .{ .x = 1, .y = 0 },
    );

    if (ig.igBegin("Stats", null, ig.ImGuiWindowFlags_AlwaysAutoResize | ig.ImGuiWindowFlags_NoInputs | ig.ImGuiWindowFlags_NoFocusOnAppearing | ig.ImGuiWindowFlags_NoTitleBar)) {
        const total_shots: f32 = @floatFromInt(State.instance.player.stats.total_shots);
        const accurate_shots: f32 = @floatFromInt(State.instance.player.stats.accurate_shots);
        const accuracy = if (total_shots == 0) 0 else (accurate_shots / total_shots) * 100;
        ig.igText("Time left: %.1f", State.instance.script_manager.timer.remaining());
        ig.igText("Targets hit: %d | Accuracy: %.1f%%", State.instance.player.stats.accurate_shots, accuracy);
        ig.igText("Reloads: %d", State.instance.player.stats.reload_count);
    }
}
const State = @import("../state.zig");

const sapp = sokol.app;
const sokol = @import("sokol");

const ig = @import("cimgui");
