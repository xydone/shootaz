pub const Settings = struct {
    is_ui_open: bool = false,
    is_imgui_open: bool = false,
};
pub inline fn init(allocator: Allocator) void {
    simgui.setup(.{
        .logger = .{ .func = slog.func },
    });
    ScriptLauncher.init(allocator);
}

pub inline fn render() void {
    simgui.render();
}

pub inline fn handleInput(event: sapp.Event) void {
    _ = simgui.handleEvent(event);
}

pub inline fn shutdown(allocator: Allocator) void {
    simgui.shutdown();
    ScriptLauncher.deinit(allocator);
}

pub inline fn draw(allocator: Allocator) void {
    const settings = State.instance.settings.ui_settings;
    // call simgui.newFrame() before any ImGui calls
    simgui.newFrame(.{
        .width = sapp.width(),
        .height = sapp.height(),
        .delta_time = sapp.frameDuration(),
        .dpi_scale = sapp.dpiScale(),
    });
    FrameInfo.draw();
    Ammo.draw();
    Stats.draw();
    if (settings.is_imgui_open or settings.is_ui_open) {
        if (settings.is_imgui_open) {
            MovementInfo.draw();
            CameraInfo.draw();
        }
        if (settings.is_ui_open) {
            SettingsMenu.draw();
            ScriptLauncher.draw(allocator);
        }
    }
}

// UI Components
const CameraInfo = @import("camera_info.zig");
const MovementInfo = @import("movement_info.zig");
const ScriptLauncher = @import("script_launcher.zig");
const FrameInfo = @import("frame_info.zig");
const SettingsMenu = @import("settings_menu.zig");
const Ammo = @import("ammo.zig");
const Stats = @import("stats.zig");

const State = @import("../state.zig");

const simgui = sokol.imgui;
const slog = sokol.log;
const sapp = sokol.app;
const sokol = @import("sokol");
const ig = @import("cimgui");

const Allocator = std.mem.Allocator;
const std = @import("std");
