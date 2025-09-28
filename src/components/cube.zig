var bindings: sg.Bindings = .{};
var pipeline: sg.Pipeline = .{};

const MAXIMUM_CUBE_COUNT = 1024;
const CUBE_GAP = 2;

var cube_positions: std.ArrayList(Vec3) = undefined;

pub inline fn init(allocator: Allocator, state: *State) void {
    cube_positions = std.ArrayList(Vec3).initCapacity(allocator, MAXIMUM_CUBE_COUNT) catch @panic("OOM");

    cube_positions.appendAssumeCapacity(.{
        .x = 0.0,
        .y = 0.0,
        .z = -50.0,
    });

    // cube vertex buffer
    bindings.vertex_buffers[0] = sg.makeBuffer(.{
        .usage = .{
            .dynamic_update = true,
        },
        .size = @sizeOf([24][7]f32),
    });
    sg.updateBuffer(bindings.vertex_buffers[0], sg.asRange(&initVertices(state.color_order)));

    // for instancing
    bindings.vertex_buffers[1] = sg.makeBuffer(.{
        .usage = .{ .dynamic_update = true },
        .size = @sizeOf([MAXIMUM_CUBE_COUNT]Vec3),
    });
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(cube_positions.items));

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

    // create pipeline
    pipeline = sg.makePipeline(.{
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
}

pub fn deinit(allocator: Allocator) void {
    cube_positions.deinit(allocator);
}

pub fn getPositions() []Vec3 {
    return cube_positions.items;
}

pub fn save(allocator: Allocator, file_name: []const u8) !void {
    saveToFile(Vec3, allocator, file_name, cube_positions.items) catch @panic("Save failed!");
}

pub fn load(allocator: Allocator, file_name: []const u8) !void {
    const path = try std.fmt.allocPrint(allocator, "config/{s}.zon", .{file_name});
    defer allocator.free(path);

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const string = try file.readToEndAllocOptions(
        allocator,
        1024,
        null,
        std.mem.Alignment.@"8",
        0,
    );
    defer allocator.free(string);

    const slice = try std.zon.parse.fromSlice([]Vec3, allocator, string, null, .{});

    cube_positions.clearRetainingCapacity();

    cube_positions.appendSliceAssumeCapacity(slice);
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(cube_positions.items));
}

pub fn insert(allocator: Allocator, location: Vec3) void {
    cube_positions.append(allocator, location) catch @panic("OOM");
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(cube_positions.items));
}

pub fn removeIndex(i: u16) void {
    _ = cube_positions.swapRemove(i);
    if (cube_positions.items.len > 0) {
        sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(cube_positions.items));
    }
}

pub fn pop() void {
    _ = cube_positions.pop();
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(cube_positions.items));
}

pub inline fn draw(state: *State) void {
    const vs_params = computeVsParams(state.*);
    sg.applyPipeline(pipeline);
    sg.applyBindings(bindings);
    sg.applyUniforms(shader.UB_vs_params, sg.asRange(&vs_params));
    sg.draw(0, 36, @intCast(cube_positions.items.len));
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

const saveToFile = @import("../util/saveToFile.zig").saveToFile;

const createVertex = @import("../util.zig").createVertex;

const shader = @import("../shaders/cube.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const Mat4 = @import("../math.zig").Mat4;

const sapp = sokol.app;
const asRadians = sokol.gl.asRadians;
const sg = sokol.gfx;
const sokol = @import("sokol");

const Allocator = std.mem.Allocator;
const std = @import("std");
