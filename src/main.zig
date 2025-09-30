var floor_bindings: sg.Bindings = undefined;

const allocator = std.heap.smp_allocator;
export fn init() void {
    State.instance.script_manager = ScriptManager.init(allocator);

    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });
    ui.init();

    sgl.setup(.{
        .logger = .{ .func = slog.func },
    });

    Cube.init(allocator, &State.instance);
    Sphere.init(allocator, &State.instance);

    State.instance.objects.cube_list = Cube.getListPtr();
    State.instance.objects.sphere_list = Sphere.getListPtr();

    Plane.init(&State.instance);

    Crosshair.init();

    // framebuffer clear color
    // state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0.25, .g = 0.5, .b = 0.75, .a = 1 } };
    State.instance.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 } };

    // lock mouse
    sapp.lockMouse(true);
}

export fn frame() void {
    State.instance.camera.updateView();

    ui.draw(allocator, &State.instance);

    const dt: f32 = @floatCast(sapp.frameDuration() * 60);

    State.instance.script_manager.update();

    Movement.perFrame(dt, &State.instance);

    sg.beginPass(.{ .action = State.instance.pass_action, .swapchain = sglue.swapchain() });

    Grid.draw(State.instance);
    Cube.draw(&State.instance);
    Sphere.draw(&State.instance);
    Crosshair.draw();

    // render simgui before the pass ends
    ui.render(State.instance);

    sg.endPass();
    sg.commit();
}

export fn input(ev: ?*const sapp.Event) void {
    const event = ev orelse return;
    // _ = simgui.handleEvent(event.*);
    ui.handleInput(event.*);

    Controls.handle(event.*, &State.instance);

    Menus.handle(event.*, &State.instance);
}

export fn cleanup() void {
    Cube.deinit(allocator);
    State.instance.script_manager.deinit();
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
        .fullscreen = true,
        .sample_count = 4,
        .icon = .{ .sokol_default = true },
        .window_title = "shapez",
        .logger = .{ .func = slog.func },
    });
}

const ScriptManager = @import("scripting/script_manager.zig");

const Object = @import("components/object.zig");
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
