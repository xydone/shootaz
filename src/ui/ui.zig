pub const Settings = struct {
    is_ui_open: bool = false,
    is_imgui_open: bool = false,
    show_window: bool = true,
};
pub inline fn init() void {
    simgui.setup(.{
        .logger = .{ .func = slog.func },
    });
}

pub inline fn render(state: State) void {
    if (state.ui_settings.is_imgui_open or state.ui_settings.is_ui_open) simgui.render();
}

pub inline fn handleInput(event: sapp.Event) void {
    _ = simgui.handleEvent(event);
}

pub inline fn shutdown() void {
    simgui.shutdown();
}

pub inline fn draw(allocator: Allocator, state: *State) void {
    const settings = state.ui_settings;
    if (settings.is_imgui_open or settings.is_ui_open) {
        // call simgui.newFrame() before any ImGui calls
        simgui.newFrame(.{
            .width = sapp.width(),
            .height = sapp.height(),
            .delta_time = sapp.frameDuration(),
            .dpi_scale = sapp.dpiScale(),
        });
        if (settings.is_imgui_open) {
            MovementInfo.draw(state);
            CameraInfo.draw(state);
            FrameInfo.draw(state);
            ObjectInfo.draw(allocator);
        }
        if (settings.is_ui_open) {
            SettingsMenu.draw(state);
        }
    }
}

// UI Components
const CameraInfo = @import("camera_info.zig");
const MovementInfo = @import("movement_info.zig");
const ObjectInfo = @import("object_info.zig");
const FrameInfo = @import("frame_info.zig");
const SettingsMenu = @import("settings_menu.zig");

const State = @import("../state.zig");

const simgui = sokol.imgui;
const slog = sokol.log;
const sapp = sokol.app;
const sokol = @import("sokol");
const ig = @import("cimgui");

const Allocator = std.mem.Allocator;
const std = @import("std");
