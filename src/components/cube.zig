var bindings: sg.Bindings = undefined;
var location: Vec3 = .{ .x = 0, .y = 0, .z = -50 };

pub inline fn init(state: *State) void {
    // cube vertex buffer
    bindings.vertex_buffers[0] = sg.makeBuffer(.{
        .usage = .{
            .dynamic_update = true,
        },
        .size = @sizeOf([24][7]f32),
    });
    sg.updateBuffer(bindings.vertex_buffers[0], sg.asRange(&initVertices(state.color_order)));

    // cube index buffer
    bindings.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },

        .data = sg.asRange(&[_]u16{
            // each triplet represents a triangle
            0,  1,  2,  0,  2,  3,
            6,  5,  4,  7,  6,  4,
            8,  9,  10, 8,  10, 11,
            14, 13, 12, 15, 14, 12,
            16, 17, 18, 16, 18, 19,
            22, 21, 20, 23, 22, 20,
        }),
    });
}

pub inline fn draw(state: *State) void {
    const vs_params = computeVsParams(state.*);
    sg.applyPipeline(state.pip);
    sg.applyBindings(bindings);
    sg.applyUniforms(shader.UB_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 36, 1);
}

fn computeVsParams(state: State) shader.VsParams {
    const rxm = mat4.rotate(state.rx, .{ .x = 1, .y = 0, .z = 0 });
    const rym = mat4.rotate(state.ry, .{ .x = 0, .y = 1, .z = 0 });
    const rotation = mat4.mul(rxm, rym);

    const translation = mat4.translate(location);
    const model = mat4.mul(translation, rotation);

    const aspect = sapp.widthf() / sapp.heightf();
    const proj = mat4.persp(60, aspect, 0.1, state.render_distance);
    return shader.VsParams{ .mvp = mat4.mul(mat4.mul(proj, state.view), model) };
}
fn initVertices(color_list: [6][4]f32) [24][7]f32 {
    return .{
        createVertex(.{ -1, -1, -1 }, color_list[0]),
        createVertex(.{ 1, -1, -1 }, color_list[0]),
        createVertex(.{ 1, 1, -1 }, color_list[0]),
        createVertex(.{ -1, 1, -1 }, color_list[0]),
        createVertex(.{ -1, -1, 1 }, color_list[1]),
        createVertex(.{ 1, -1, 1 }, color_list[1]),
        createVertex(.{ 1, 1, 1 }, color_list[1]),
        createVertex(.{ -1, 1, 1 }, color_list[1]),
        createVertex(.{ -1, -1, -1 }, color_list[2]),
        createVertex(.{ -1, 1, -1 }, color_list[2]),
        createVertex(.{ -1, 1, 1 }, color_list[2]),
        createVertex(.{ -1, -1, 1 }, color_list[2]),
        createVertex(.{ 1, -1, -1 }, color_list[3]),
        createVertex(.{ 1, 1, -1 }, color_list[3]),
        createVertex(.{ 1, 1, 1 }, color_list[3]),
        createVertex(.{ 1, -1, 1 }, color_list[3]),
        createVertex(.{ -1, -1, -1 }, color_list[4]),
        createVertex(.{ -1, -1, 1 }, color_list[4]),
        createVertex(.{ 1, -1, 1 }, color_list[4]),
        createVertex(.{ 1, -1, -1 }, color_list[4]),
        createVertex(.{ -1, 1, -1 }, color_list[5]),
        createVertex(.{ -1, 1, 1 }, color_list[5]),
        createVertex(.{ 1, 1, 1 }, color_list[5]),
        createVertex(.{ 1, 1, -1 }, color_list[5]),
    };
}

const createVertex = @import("../util.zig").createVertex;

const shader = @import("../shaders/cube.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const mat4 = @import("../math.zig").Mat4;

const sapp = sokol.app;
const asRadians = sokol.gl.asRadians;
const sg = sokol.gfx;
const sokol = @import("sokol");

const std = @import("std");
