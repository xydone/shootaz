pub fn shoot(state: *State) void {
    const origin = state.camera.pos;
    const direction = state.camera.getForward();

    //TODO: this is ugly
    for (state.objects.getLists()) |list| {
        switch (list) {
            .cubes => |cubes| {
                for (cubes.items, 0..) |cube, i| {
                    const is_intercepted = Cube.intercept(origin.toSlice(), direction.toSlice(), cube.offset);

                    if (is_intercepted) {
                        Cube.removeIndex(@intCast(i));
                        break;
                    }
                }
            },
            .spheres => |spheres| {
                for (spheres.items, 0..) |sphere, i| {
                    const is_intercepted = Sphere.intercept(origin.toSlice(), direction.toSlice(), sphere.offset.toSlice(), sphere.radius);

                    if (is_intercepted) {
                        Sphere.removeIndex(@intCast(i));
                        break;
                    }
                }
            },
        }
    }
    std.debug.print("----------------------\n", .{});
}

const Sphere = @import("../components/sphere.zig");
const Cube = @import("../components/cube.zig");

const State = @import("../state.zig");
const Vec3 = @import("../math.zig").Vec3;

const std = @import("std");
