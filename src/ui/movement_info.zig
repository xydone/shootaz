pub inline fn draw(state: *State) void {
    defer ig.igEnd();
    const clrs = state.pass_action.colors[0].clear_value;
    var cast: [4]f32 = .{ clrs.r, clrs.g, clrs.b, clrs.a };
    if (ig.igBegin("Movement settings", &state.ui_settings.show_window, ig.ImGuiWindowFlags_None)) {
        _ = ig.igText("Current speed: %f", Vec3.len(state.movement_settings.velocity));
        _ = ig.igInputFloat("Acceleration", &state.movement_settings.accel);
        _ = ig.igInputFloat("Friction", &state.movement_settings.friction);
        _ = ig.igInputFloat("Max speed", &state.movement_settings.max_speed);
        const is_color_changed = ig.igColorEdit4("Skybox color", &cast, 0);
        if (is_color_changed) {
            state.pass_action.colors[0].clear_value = .{
                .r = cast[0],
                .g = cast[1],
                .b = cast[2],
                .a = cast[3],
            };
        }
    }
}
const State = @import("../state.zig");
const Vec3 = @import("../math.zig").Vec3;

const ig = @import("cimgui");
