var vbuf: sg.Buffer = undefined;
var pip: sg.Pipeline = .{};
var bind: sg.Bindings = .{};

pub const Data = struct {
    pos: [2]f32,
    color: [4]f32,
};

const MAXIMUM_AMOUNT_OF_VERTICES = 1024;

const CROSSHAIR_SIZE = 0.02;

var crosshair_data = std.ArrayList(Data).empty;
var is_buffer_dirty = true;

pub fn init(allocator: Allocator) void {
    State.instance.script_manager.doFile(allocator, "crosshair") catch {
        // default crosshair if file is missing
        crosshair_data.appendSlice(allocator, &.{
            .{ .pos = .{ -CROSSHAIR_SIZE, 0.0 }, .color = .{ 1, 1, 1, 1 } },
            .{ .pos = .{ CROSSHAIR_SIZE, 0.0 }, .color = .{ 1, 1, 1, 1 } },
            // vertical
            .{ .pos = .{ 0.0, -CROSSHAIR_SIZE }, .color = .{ 1, 1, 1, 1 } },
            .{ .pos = .{ 0.0, CROSSHAIR_SIZE }, .color = .{ 1, 1, 1, 1 } },
        }) catch @panic("OOM");
    };

    vbuf = sg.makeBuffer(.{
        .usage = .{ .dynamic_update = true },
        .size = @sizeOf([MAXIMUM_AMOUNT_OF_VERTICES]Data),
    });

    pip = sg.makePipeline(.{
        .shader = sg.makeShader(shader.crosshairShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.attrs[shader.ATTR_crosshair_position].format = .FLOAT2;
            l.attrs[shader.ATTR_crosshair_color0].format = .FLOAT4;

            break :init l;
        },
        .primitive_type = .LINES,
    });

    bind.vertex_buffers[0] = vbuf;
}

pub fn deinit(allocator: Allocator) void {
    crosshair_data.deinit(allocator);
}

pub inline fn draw() void {
    flush();
    sg.applyPipeline(pip);
    sg.applyBindings(bind);
    sg.draw(0, @intCast(crosshair_data.items.len), 1);
}

pub fn set(allocator: Allocator, crosshair_vertices: []Data) error{OddVertexCount}!void {
    if (crosshair_vertices.len % 2 != 0) return error.OddVertexCount;
    is_buffer_dirty = true;
    crosshair_data.clearAndFree(allocator);
    crosshair_data.appendSlice(allocator, crosshair_vertices) catch @panic("OOM");
}

pub fn flush() void {
    if (is_buffer_dirty) {
        sg.updateBuffer(vbuf, sg.asRange(crosshair_data.items));
        is_buffer_dirty = false;
    }
}

const State = @import("../state.zig");

const shader = @import("../shaders/crosshair.zig");

const sg = @import("sokol").gfx;

const Allocator = std.mem.Allocator;
const std = @import("std");
