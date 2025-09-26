pub const Settings = struct {
    show_imgui: bool = false,
    show_window: bool = true,
};
pub inline fn init() void {
    simgui.setup(.{
        .logger = .{ .func = slog.func },
    });
}

pub inline fn render(state: State) void {
    if (state.ui_settings.show_imgui) simgui.render();
}

pub inline fn handleInput(event: sapp.Event) void {
    _ = simgui.handleEvent(event);
}

pub inline fn shutdown() void {
    simgui.shutdown();
}

pub inline fn draw(state: *State) void {
    const settings = state.ui_settings;
    if (settings.show_imgui) {
        // call simgui.newFrame() before any ImGui calls
        simgui.newFrame(.{
            .width = sapp.width(),
            .height = sapp.height(),
            .delta_time = sapp.frameDuration(),
            .dpi_scale = sapp.dpiScale(),
        });
        ig.igSetNextWindowPos(.{ .x = 10, .y = 10 }, ig.ImGuiCond_Once);
        ig.igSetNextWindowSize(.{ .x = 400, .y = 100 }, ig.ImGuiCond_Once);

        MovementInfo.draw(state);
        CameraInfo.draw(state);
    }
}

// UI Components
const CameraInfo = @import("camera_info.zig");
const MovementInfo = @import("movement_info.zig");

const State = @import("../state.zig");

const simgui = sokol.imgui;
const slog = sokol.log;
const sapp = sokol.app;
const sokol = @import("sokol");
const ig = @import("cimgui");
const std = @import("std");
