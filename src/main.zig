var state: State = .{};

var floor_bindings: sg.Bindings = undefined;

export fn init() void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });
    simgui.setup(.{
        .logger = .{ .func = slog.func },
    });

    Cube.init(&state);
    Plane.init(&state);

    // shader and pipeline object
    state.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shaders.cubeShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.attrs[shaders.ATTR_cube_position].format = .FLOAT3;
            l.attrs[shaders.ATTR_cube_color0].format = .FLOAT4;
            break :init l;
        },
        .index_type = .UINT16,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .cull_mode = .BACK,
    });

    // framebuffer clear color
    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0.25, .g = 0.5, .b = 0.75, .a = 1 } };

    // lock mouse
    sapp.lockMouse(true);
}

export fn frame() void {
    updateCameraView();

    if (state.show_imgui) {
        // call simgui.newFrame() before any ImGui calls
        simgui.newFrame(.{
            .width = sapp.width(),
            .height = sapp.height(),
            .delta_time = sapp.frameDuration(),
            .dpi_scale = sapp.dpiScale(),
        });
        ig.igSetNextWindowPos(.{ .x = 10, .y = 10 }, ig.ImGuiCond_Once);
        ig.igSetNextWindowSize(.{ .x = 400, .y = 100 }, ig.ImGuiCond_Once);
        if (ig.igBegin("Movement settings", &state.show_window, ig.ImGuiWindowFlags_None)) {
            _ = ig.igText("Current speed: %f", Vec3.len(state.velocity));
            _ = ig.igInputFloat("Acceleration", &state.movement_settings.accel);
            _ = ig.igInputFloat("Friction", &state.movement_settings.friction);
            _ = ig.igInputFloat("Max speed", &state.movement_settings.max_speed);
        }
        ig.igEnd();
    }

    const dt: f32 = @floatCast(sapp.frameDuration() * 60);

    Movement.perFrame(dt, &state);

    // state.ry += 2 * dt;

    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });

    Plane.draw(&state);
    Cube.draw(&state);

    // render simgui before the pass ends
    if (state.show_imgui) simgui.render();
    sg.endPass();
    sg.commit();
}

export fn input(ev: ?*const sapp.Event) void {
    const event = ev orelse return;
    _ = simgui.handleEvent(event.*);

    Controls.handle(event.*, &state);

    Menus.handle(event.*, &state);
}

export fn cleanup() void {
    simgui.shutdown();
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

fn updateCameraView() void {
    // calculate forward vector from yaw/pitch
    const front = Vec3.norm(.{
        .x = @cos(state.camera.yaw) * @cos(state.camera.pitch),
        .y = @sin(state.camera.pitch),
        .z = @sin(state.camera.yaw) * @cos(state.camera.pitch),
    });

    const view = mat4.lookat(state.camera.pos, Vec3.add(state.camera.pos, front), state.camera.up);
    state.view = view;
}

fn rotateColors(direction: enum { left, right }, colors: [6][4]f32) [6][4]f32 {
    var result = colors;

    switch (direction) {
        .left => {
            const first = result[0];
            for (1..6) |i| {
                result[i - 1] = result[i];
            }
            result[5] = first;
        },
        .right => {
            const last = result[5];
            var i: usize = 5;
            while (i > 0) : (i -= 1) {
                result[i] = result[i - 1];
            }
            result[0] = last;
        },
    }

    return result;
}

fn createVertex(pos: [3]f32, color: [4]f32) [7]f32 {
    return .{ pos[0], pos[1], pos[2], color[0], color[1], color[2], color[3] };
}

const Plane = @import("components/plane.zig");
const Cube = @import("components/cube.zig");

const Menus = @import("menus.zig");
const Controls = @import("controls.zig");

const shaders = @import("shaders/cube.zig");

const Camera = @import("camera.zig");

const Movement = @import("movement.zig");

const Vec3 = @import("math.zig").Vec3;
const mat4 = @import("math.zig").Mat4;

const green = @import("colors.zig").green;
const red = @import("colors.zig").red;
const blue = @import("colors.zig").blue;
const orange = @import("colors.zig").orange;
const cyan = @import("colors.zig").cyan;
const pink = @import("colors.zig").pink;

const State = @import("state.zig");

const ig = @import("cimgui");
const simgui = sokol.imgui;
const slog = sokol.log;
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
