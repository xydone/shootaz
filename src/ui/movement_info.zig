var show_window = true;
pub inline fn draw() void {
    if (show_window == false) return;
    defer ig.igEnd();

    const clrs = State.instance.pass_action.colors[0].clear_value;
    var cast: [4]f32 = .{ clrs.r, clrs.g, clrs.b, clrs.a };
    if (ig.igBegin("Movement settings", &show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        _ = ig.igText("Current speed: %f", Vec3.len(State.instance.settings.movement_settings.velocity));
        _ = ig.igInputFloat("Acceleration", &State.instance.settings.movement_settings.accel);
        _ = ig.igInputFloat("Friction", &State.instance.settings.movement_settings.friction);
        _ = ig.igInputFloat("Max speed", &State.instance.settings.movement_settings.max_speed);
        const is_color_changed = ig.igColorEdit4("Skybox color", &cast, 0);
        if (is_color_changed) {
            State.instance.pass_action.colors[0].clear_value = .{
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
