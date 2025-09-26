pub fn shoot(state: State, cube_positions: []Vec3) void {
    const origin = state.camera.pos;
    const direction = state.camera.getForward();

    for (cube_positions, 0..) |position, i| {
        const is_intercepted = doesIntercept(origin.toSlice(), direction.toSlice(), position.toSlice());

        if (is_intercepted) {
            Cube.removeIndex(@intCast(i));
            break;
        }
    }
}

inline fn doesIntercept(rayOrigin: [3]f32, rayDir: [3]f32, instanceOffset: [3]f32) bool {
    const cubeMin = [_]f32{
        instanceOffset[0] - 1.0,
        instanceOffset[1] - 1.0,
        instanceOffset[2] - 1.0,
    };
    const cubeMax = [_]f32{
        instanceOffset[0] + 1.0,
        instanceOffset[1] + 1.0,
        instanceOffset[2] + 1.0,
    };

    var tmin: f32 = -std.math.floatMin(f32);
    var tmax: f32 = std.math.floatMax(f32);

    for (0..3) |i| {
        if (rayDir[i] != 0.0) {
            var t1 = (cubeMin[i] - rayOrigin[i]) / rayDir[i];
            var t2 = (cubeMax[i] - rayOrigin[i]) / rayDir[i];
            if (t1 > t2) {
                const tmp = t1;
                t1 = t2;
                t2 = tmp;
            }
            if (t1 > tmin) tmin = t1;
            if (t2 < tmax) tmax = t2;
        } else {
            if (rayOrigin[i] < cubeMin[i] or rayOrigin[i] > cubeMax[i]) {
                return false;
            }
        }
    }

    return tmax >= tmin and tmax >= 0;
}

const Cube = @import("../components/cube.zig");

const State = @import("../state.zig");
const Vec3 = @import("../math.zig").Vec3;

const std = @import("std");
