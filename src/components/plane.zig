var bindings: sg.Bindings = undefined;
var location: Vec3 = .{ .x = 0, .y = -1, .z = 0 };
var pipeline: sg.Pipeline = undefined;

pub inline fn init() void {
    bindings.vertex_buffers[0] = sg.makeBuffer(.{
        .usage = .{},
        .data = sg.asRange(&initVertices()),
    });

    bindings.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{
            // each triplet represents a triangle
            0, 1, 2,
            0, 2, 3,
        }),
    });

    // create pipeline
    pipeline = sg.makePipeline(.{
        .shader = sg.makeShader(shader.planeShaderDesc(sg.queryBackend())),
        .index_type = .UINT16,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .cull_mode = .BACK,
    });
}

pub inline fn draw() void {
    sg.applyPipeline(State.instance.pip);
    sg.applyBindings(bindings);
    sg.applyUniforms(shader.UB_vs_params, sg.asRange(&computeParams(State.instance.*)));
    sg.draw(0, 6, 1);
}

pub fn move(move_vec: Vec3) void {
    location = location.add(move_vec);
}

fn computeParams() shader.VsParams {
    const model = Mat4.translate(location);

    const aspect_ratio = sapp.widthf() / sapp.heightf();

    const perspective_projection = Mat4.persp(60, aspect_ratio, 0.01, State.instance.camera.render_distance);

    // MVP = proj * view * model
    return shader.VsParams{ .mvp = Mat4.mul(Mat4.mul(perspective_projection, State.instance.camera.view), model) };
}

fn initVertices() [4][7]f32 {
    return .{
        createVertex(.{ -5, 0, -5 }, gray),
        createVertex(.{ 5, 0, -5 }, gray),
        createVertex(.{ 5, 0, 5 }, gray),
        createVertex(.{ -5, 0, 5 }, gray),
    };
}

const gray = @import("../colors.zig").gray;

const createVertex = @import("../util.zig").createVertex;

const shader = @import("../shaders/plane.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const Mat4 = @import("../math.zig").Mat4;

const sapp = sokol.app;
const sg = sokol.gfx;
const sokol = @import("sokol");

const std = @import("std");
