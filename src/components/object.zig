cube_list: *std.ArrayList(Cube),
sphere_list: *std.ArrayList(Sphere),

const ListRef = union(enum) {
    cubes: *std.ArrayList(Cube),
    spheres: *std.ArrayList(Sphere),
};

pub fn getLists(self: *@This()) [2]ListRef {
    return .{
        ListRef{ .cubes = self.cube_list },
        ListRef{ .spheres = self.sphere_list },
    };
}

const Cube = @import("cube.zig");
const Sphere = @import("sphere.zig");

const std = @import("std");
