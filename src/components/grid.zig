var location: Vec3 = .{ .x = 0, .y = -1, .z = 0 };
const AMOUNT_OF_LINES = 64;
const DISTANCE: f32 = 4;
const y = 0;

pub inline fn draw(state: State) void {
    const z_offset = (DISTANCE / 8);
    const camera = state.camera;
    const aspect = sapp.widthf() / sapp.heightf();

    sgl.defaults();

    sgl.matrixModeProjection();
    sgl.perspective(sgl.asRadians(60), aspect, 0.1, state.render_distance);

    sgl.matrixModeModelview();

    sgl.lookat(
        camera.pos.x,
        camera.pos.y,
        camera.pos.z,
        camera.target.x,
        camera.target.y,
        camera.target.z,
        camera.up.x,
        camera.up.y,
        camera.up.z,
    );

    sgl.beginLines();
    sgl.c3f(1.0, 1.0, 1.0);

    {
        var i: f32 = 0;
        while (i < AMOUNT_OF_LINES) : (i += 1) {
            const x = i * DISTANCE - AMOUNT_OF_LINES * DISTANCE * 0.5;
            sgl.v3f(x, y, -AMOUNT_OF_LINES * DISTANCE);
            sgl.v3f(x, y, 0.0);
        }
    }

    {
        var i: f32 = 0;
        while (i < AMOUNT_OF_LINES) : (i += 1) {
            const z = z_offset + i * DISTANCE - AMOUNT_OF_LINES * DISTANCE;
            sgl.v3f(-AMOUNT_OF_LINES * DISTANCE * 0.5, y, z);
            sgl.v3f(AMOUNT_OF_LINES * DISTANCE * 0.5, y, z);
        }
    }
    sgl.end();
    sgl.draw();
}

const createVertex = @import("../util.zig").createVertex;

const Vec3 = @import("../math.zig").Vec3;
const mat4 = @import("../math.zig").Mat4;

const State = @import("../state.zig");

const sapp = sokol.app;
const sg = sokol.gfx;
const sgl = sokol.gl;
const sokol = @import("sokol");

const std = @import("std");
