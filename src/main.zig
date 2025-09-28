var state: State = .{};

var floor_bindings: sg.Bindings = undefined;

const allocator = std.heap.smp_allocator;

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });
    ui.init();

    sgl.setup(.{
        .logger = .{ .func = slog.func },
    });

    Cube.init(allocator, &state);
    Sphere.init(allocator, &state);

    Plane.init(&state);

    Crosshair.init();

    // framebuffer clear color
    // state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0.25, .g = 0.5, .b = 0.75, .a = 1 } };
    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 } };

    // lock mouse
    sapp.lockMouse(true);
}

export fn frame() void {
    state.camera.updateView();

    ui.draw(allocator, &state);

    const dt: f32 = @floatCast(sapp.frameDuration() * 60);

    Movement.perFrame(dt, &state);

    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });

    Grid.draw(state);
    // Cube.draw(&state);
    Sphere.draw(&state);
    Crosshair.draw();

    // render simgui before the pass ends
    ui.render(state);

    sg.endPass();
    sg.commit();
}

export fn input(ev: ?*const sapp.Event) void {
    const event = ev orelse return;
    // _ = simgui.handleEvent(event.*);
    ui.handleInput(event.*);

    Controls.handle(event.*, &state, Cube.getPositions());

    Menus.handle(event.*, &state);
}

export fn cleanup() void {
    Cube.deinit(allocator);
    ui.shutdown();
    sgl.shutdown();
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .width = 800,
        .height = 600,
        .sample_count = 4,
        .icon = .{ .sokol_default = true },
        .window_title = "cube.zig",
        .logger = .{ .func = slog.func },
    });
}

const Grid = @import("components/grid.zig");
const Plane = @import("components/plane.zig");
const Cube = @import("components/cube.zig");
const Sphere = @import("components/sphere.zig");

const Crosshair = @import("components/crosshair.zig");
const Menus = @import("menus.zig");
const Controls = @import("controls.zig");

const Camera = @import("camera.zig");

const Movement = @import("movement.zig");

const Vec3 = @import("math.zig").Vec3;
const Mat4 = @import("math.zig").Mat4;

const State = @import("state.zig");

const ui = @import("ui/ui.zig");
const slog = sokol.log;
const sgl = sokol.gl;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const stm = sokol.time;
const sdtx = sokol.debugtext;
const sokol = @import("sokol");

// only needed when using std.fmt directly instead of sokol.debugtext.print()
const fmt = std.fmt;
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const std = @import("std");

const builtin = @import("builtin");
