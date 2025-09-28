var bindings: sg.Bindings = .{};
var pipeline: sg.Pipeline = .{};
var element_range: sshape.ElementRange = undefined;

const MAXIMUM_SPHERE_COUNT = 1024;

pub const InstanceData = struct {
    offset: Vec3,
    color: [4]f32,
};
var instance_data: std.ArrayList(InstanceData) = undefined;

pub inline fn init(allocator: Allocator, state: *State) void {
    _ = state; // autofix
    instance_data = std.ArrayList(InstanceData).initCapacity(allocator, MAXIMUM_SPHERE_COUNT) catch @panic("OOM");

    instance_data.appendAssumeCapacity(.{
        .offset = .{
            .x = 0.0,
            .y = 0.0,
            .z = -50.0,
        },
        .color = red,
    });

    pipeline = sg.makePipeline(.{
        .shader = sg.makeShader(shader.sphereShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.buffers[0] = sshape.vertexBufferLayoutState();
            l.attrs[shader.ATTR_sphere_position] = sshape.positionVertexAttrState();

            l.buffers[1].stride = @sizeOf(InstanceData);
            l.buffers[1].step_func = .PER_INSTANCE;
            l.attrs[shader.ATTR_sphere_instance_offset].buffer_index = 1;
            l.attrs[shader.ATTR_sphere_instance_offset].format = .FLOAT3;
            l.attrs[shader.ATTR_sphere_instance_color].buffer_index = 1;
            l.attrs[shader.ATTR_sphere_instance_color].format = .FLOAT3;

            break :init l;
        },
        .index_type = .UINT16,
        .cull_mode = .NONE,
        .depth = .{
            .compare = .LESS_EQUAL,
            .write_enabled = true,
        },
    });

    var vertices: [6 * 1024]sshape.Vertex = undefined;
    var indices: [16 * 1024]u16 = undefined;
    var buf: sshape.Buffer = .{
        .vertices = .{ .buffer = sshape.asRange(&vertices) },
        .indices = .{ .buffer = sshape.asRange(&indices) },
    };
    buf = sshape.buildSphere(buf, .{
        .radius = 1,
        .slices = 36,
        .stacks = 20,
    });
    element_range = sshape.elementRange(buf);

    bindings.vertex_buffers[0] = sg.makeBuffer(sshape.vertexBufferDesc(buf));
    bindings.index_buffer = sg.makeBuffer(sshape.indexBufferDesc(buf));

    // for instancing
    bindings.vertex_buffers[1] = sg.makeBuffer(.{
        .usage = .{ .dynamic_update = true },
        .size = @sizeOf([MAXIMUM_SPHERE_COUNT]InstanceData),
    });
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(instance_data.items));
}

pub inline fn draw(state: *State) void {
    const vs_params = computeVsParams(state.*);
    sg.applyPipeline(pipeline);
    sg.applyBindings(bindings);
    sg.applyUniforms(shader.UB_vs_params, sg.asRange(&vs_params));
    sg.draw(element_range.base_element, element_range.num_elements, @intCast(instance_data.items.len));
}

fn computeVsParams(state: State) shader.VsParams {
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = Mat4.persp(60, aspect, 0.1, state.camera.render_distance);
    const vp = Mat4.mul(proj, state.camera.view);

    return shader.VsParams{
        .mvp = vp,
    };
}

pub fn deinit(allocator: Allocator) void {
    instance_data.deinit(allocator);
}

pub fn getPositions() []Vec3 {
    return instance_data.items;
}

pub fn save(allocator: Allocator, file_name: []const u8) !void {
    saveToFile(InstanceData, allocator, file_name, instance_data.items) catch @panic("Save failed!");
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

    const slice = try std.zon.parse.fromSlice([]InstanceData, allocator, string, null, .{});

    instance_data.clearRetainingCapacity();

    instance_data.appendSliceAssumeCapacity(slice);
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(instance_data.items));
}

pub fn insert(allocator: Allocator, instance: InstanceData) void {
    instance_data.append(allocator, instance) catch @panic("OOM");
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(instance_data.items));
}

pub fn removeIndex(i: u16) void {
    _ = instance_data.swapRemove(i);
    if (instance_data.items.len > 0) {
        sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(instance_data.items));
    }
}

pub fn pop() void {
    _ = instance_data.pop();
    sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(instance_data.items));
}

const saveToFile = @import("../util/saveToFile.zig").saveToFile;

const red = @import("../colors.zig").red;

const shader = @import("../shaders/sphere.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const Mat4 = @import("../math.zig").Mat4;

const sshape = sokol.shape;
const sapp = sokol.app;
const asRadians = sokol.gl.asRadians;
const sg = sokol.gfx;
const sokol = @import("sokol");

const Allocator = std.mem.Allocator;
const std = @import("std");
