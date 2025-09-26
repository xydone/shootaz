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

pub inline fn draw(allocator: Allocator, state: *State) void {
    const settings = state.ui_settings;
    if (settings.show_imgui) {
        // call simgui.newFrame() before any ImGui calls
        simgui.newFrame(.{
            .width = sapp.width(),
            .height = sapp.height(),
            .delta_time = sapp.frameDuration(),
            .dpi_scale = sapp.dpiScale(),
        });
        MovementInfo.draw(state);
        CameraInfo.draw(state);
        CubeInfo.draw(allocator, state);
    }
}

// UI Components
const CameraInfo = @import("camera_info.zig");
const MovementInfo = @import("movement_info.zig");
const CubeInfo = @import("cube_info.zig");

const State = @import("../state.zig");

const simgui = sokol.imgui;
const slog = sokol.log;
const sapp = sokol.app;
const sokol = @import("sokol");
const ig = @import("cimgui");

const Allocator = std.mem.Allocator;
const std = @import("std");
