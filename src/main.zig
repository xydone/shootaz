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
    sgl.setup(.{
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
    // state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0.25, .g = 0.5, .b = 0.75, .a = 1 } };
    state.pass_action.colors[0] = .{ .load_action = .CLEAR, .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 } };

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
        const clrs = state.pass_action.colors[0].clear_value;
        var cast: [4]f32 = .{ clrs.r, clrs.g, clrs.b, clrs.a };
        if (ig.igBegin("Movement settings", &state.show_window, ig.ImGuiWindowFlags_None)) {
            _ = ig.igText("Current speed: %f", Vec3.len(state.velocity));
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

            ig.igEnd();
        }
        if (ig.igBegin("Camera", &state.show_window, ig.ImGuiWindowFlags_None)) {
            _ = ig.igText("Pitch: %f | Speed: %f | Yaw: %f", state.camera.pitch, state.camera.speed, state.camera.yaw);
            _ = ig.igText("(%f, %f, %f)", state.camera.pos.x, state.camera.pos.y, state.camera.pos.z);
            _ = ig.igText("up: (%f, %f, %f)", state.camera.up.x, state.camera.up.y, state.camera.up.z);

            ig.igEnd();
        }
    }

    const dt: f32 = @floatCast(sapp.frameDuration() * 60);

    Movement.perFrame(dt, &state);

    // state.ry += 2 * dt;

    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });

    // Plane.draw(&state);
    // Cube.draw(&state);
    Grid.draw(state);

    // render simgui before the pass ends
    if (state.show_imgui) simgui.render();
    sg.endPass();
    sg.commit();
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

export fn input(ev: ?*const sapp.Event) void {
    const event = ev orelse return;
    _ = simgui.handleEvent(event.*);

    Controls.handle(event.*, &state);

    Menus.handle(event.*, &state);
}

export fn cleanup() void {
    simgui.shutdown();
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
