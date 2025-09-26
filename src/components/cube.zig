bindings: sg.Bindings,
pipeline: sg.Pipeline,
count: u8,

const MAXIMUM_CUBE_COUNT = 1024;
const CUBE_GAP = 10;

const Cube = @This();

pub inline fn init(state: *State) Cube {
    var cube: Cube = .{
        .bindings = .{},
        .pipeline = .{},
        .count = 20,
    };
    //cube positions
    var instance_positions: [20]Vec3 = undefined;
    for (0..20) |i| {
        const offset: f32 = @floatFromInt(i * CUBE_GAP);
        instance_positions[i] = .{
            .x = 0.0,
            .y = 0.0,
            .z = -50.0 - offset,
        };
    }

    // cube vertex buffer
    cube.bindings.vertex_buffers[0] = sg.makeBuffer(.{
        .usage = .{
            .dynamic_update = true,
        },
        .size = @sizeOf([24][7]f32),
    });
    sg.updateBuffer(cube.bindings.vertex_buffers[0], sg.asRange(&initVertices(state.color_order)));

    // for instancing
    cube.bindings.vertex_buffers[1] = sg.makeBuffer(.{
        .usage = .{ .dynamic_update = true },
        .size = @sizeOf([MAXIMUM_CUBE_COUNT]Vec3),
    });
    sg.updateBuffer(cube.bindings.vertex_buffers[1], sg.asRange(&instance_positions));

    // cube index buffer
    cube.bindings.index_buffer = sg.makeBuffer(.{
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

    // create pipeline
    cube.pipeline = sg.makePipeline(.{
        .shader = sg.makeShader(shader.cubeShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            // vertex buffer 0 = cube geometry
            l.buffers[0].stride = @sizeOf([7]f32);
            l.attrs[shader.ATTR_cube_position].format = .FLOAT3;
            l.attrs[shader.ATTR_cube_color0].format = .FLOAT4;

            // vertex buffer 1 = instance data
            l.buffers[1].stride = @sizeOf(Vec3);
            l.buffers[1].step_func = .PER_INSTANCE;
            l.attrs[shader.ATTR_cube_instance_offset].buffer_index = 1;
            l.attrs[shader.ATTR_cube_instance_offset].format = .FLOAT3;

            break :init l;
        },
        .index_type = .UINT16,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
        .cull_mode = .BACK,
    });

    return cube;
}

pub inline fn draw(self: Cube, state: *State) void {
    const vs_params = computeVsParams(state.*);
    sg.applyPipeline(self.pipeline);
    sg.applyBindings(self.bindings);
    sg.applyUniforms(shader.UB_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 36, self.count);
}

fn computeVsParams(state: State) shader.VsParams {
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = Mat4.persp(60, aspect, 0.1, state.camera.render_distance);
    const vp = Mat4.mul(proj, state.camera.view);

    return shader.VsParams{
        .mvp = vp,
    };
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
const Mat4 = @import("../math.zig").Mat4;

const sapp = sokol.app;
const asRadians = sokol.gl.asRadians;
const sg = sokol.gfx;
const sokol = @import("sokol");

const std = @import("std");
