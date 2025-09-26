var vbuf: sg.Buffer = undefined;
var pip: sg.Pipeline = .{};
var bind: sg.Bindings = .{};

const CROSSHAIR_SIZE = 0.02;

var vertices = [_]Vertex{
    // horizontal
    .{ .pos = .{ -CROSSHAIR_SIZE, 0.0 }, .color = .{ 1, 1, 1, 1 } },
    .{ .pos = .{ CROSSHAIR_SIZE, 0.0 }, .color = .{ 1, 1, 1, 1 } },
    // vertical
    .{ .pos = .{ 0.0, -CROSSHAIR_SIZE }, .color = .{ 1, 1, 1, 1 } },
    .{ .pos = .{ 0.0, CROSSHAIR_SIZE }, .color = .{ 1, 1, 1, 1 } },
};

pub fn init() void {
    vbuf = sg.makeBuffer(.{
        .data = sg.asRange(&vertices),
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

pub inline fn draw() void {
    sg.applyPipeline(pip);
    sg.applyBindings(bind);
    sg.draw(0, 4, 1);
}

const Vertex = extern struct {
    pos: [2]f32,
    color: [4]f32,
};

const shader = @import("../shaders/crosshair.zig");

const std = @import("std");
const sg = @import("sokol").gfx;
