offset: Vec3,
color: [4]f32,
radius: f32,
pub const InstanceData = @This();

var bindings: sg.Bindings = .{};
var pipeline: sg.Pipeline = .{};
var element_range: sshape.ElementRange = undefined;
var is_buffer_dirty = false;

const MAXIMUM_SPHERE_COUNT = 1024;

var instance_data: std.ArrayList(InstanceData) = undefined;

pub inline fn init(allocator: Allocator) void {
    instance_data = std.ArrayList(InstanceData).initCapacity(allocator, MAXIMUM_SPHERE_COUNT) catch @panic("OOM");

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
            l.attrs[shader.ATTR_sphere_instance_color].format = .FLOAT4;
            l.attrs[shader.ATTR_sphere_instance_radius].buffer_index = 1;
            l.attrs[shader.ATTR_sphere_instance_radius].format = .FLOAT;

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
}

pub inline fn draw() void {
    flush();
    const vs_params = computeVsParams();
    sg.applyPipeline(pipeline);
    sg.applyBindings(bindings);
    sg.applyUniforms(shader.UB_vs_params, sg.asRange(&vs_params));
    sg.draw(element_range.base_element, element_range.num_elements, @intCast(instance_data.items.len));
}

fn computeVsParams() shader.VsParams {
    const aspect = sapp.widthf() / sapp.heightf();
    const proj = Mat4.persp(60, aspect, 0.1, State.instance.camera.render_distance);
    const vp = Mat4.mul(proj, State.instance.camera.view);

    return shader.VsParams{
        .mvp = vp,
    };
}

pub fn deinit(allocator: Allocator) void {
    instance_data.deinit(allocator);
}

pub fn getPositions() []InstanceData {
    return instance_data.items;
}

pub fn getListPtr() *std.ArrayList(InstanceData) {
    return &instance_data;
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
    is_buffer_dirty = true;
}

pub fn removeIndex(i: u16) void {
    _ = instance_data.swapRemove(i);
    if (instance_data.items.len > 0) {
        is_buffer_dirty = true;
    }
}

pub fn flush() void {
    if (is_buffer_dirty) {
        sg.updateBuffer(bindings.vertex_buffers[1], sg.asRange(instance_data.items));
        is_buffer_dirty = false;
    }
}

// https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html
pub fn intercept(ray_origin: [3]f32, ray_dir: [3]f32, center: [3]f32, radius: f32) bool {
    const L = [_]f32{
        ray_origin[0] - center[0],
        ray_origin[1] - center[1],
        ray_origin[2] - center[2],
    };

    const a = ray_dir[0] * ray_dir[0] + ray_dir[1] * ray_dir[1] + ray_dir[2] * ray_dir[2];
    const b = 2.0 * (ray_dir[0] * L[0] + ray_dir[1] * L[1] + ray_dir[2] * L[2]);
    const c = (L[0] * L[0] + L[1] * L[1] + L[2] * L[2]) - (radius * radius);

    const discriminant = b * b - 4.0 * a * c;

    if (discriminant < 0.0) {
        return false;
    }

    const sqrt_disc = std.math.sqrt(discriminant);
    const t1 = (-b - sqrt_disc) / (2.0 * a);
    const t2 = (-b + sqrt_disc) / (2.0 * a);

    return (t1 >= 0.0 or t2 >= 0.0);
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
