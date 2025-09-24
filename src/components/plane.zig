var bindings: sg.Bindings = undefined;
var location: Vec3 = .{ .x = 0, .y = -1, .z = 0 };
pub inline fn init(state: *State) void {
    _ = state; // autofix
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
}

pub inline fn draw(state: *State) void {
    sg.applyPipeline(state.pip);
    sg.applyBindings(bindings);
    sg.applyUniforms(shader.UB_vs_params, sg.asRange(&computeParams(state.*)));
    sg.draw(0, 6, 1);
}

pub fn move(move_vec: Vec3) void {
    location = location.add(move_vec);
}

fn computeParams(state: State) shader.VsParams {
    const model = mat4.translate(location);

    const aspect_ratio = sapp.widthf() / sapp.heightf();

    const perspective_projection = mat4.persp(60, aspect_ratio, 0.01, state.render_distance);

    // MVP = proj * view * model
    return shader.VsParams{ .mvp = mat4.mul(mat4.mul(perspective_projection, state.view), model) };
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
const mat4 = @import("../math.zig").Mat4;

const sapp = sokol.app;
const sg = sokol.gfx;
const sokol = @import("sokol");

const std = @import("std");
