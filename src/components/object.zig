cube_list: *std.ArrayList(Cube),
sphere_list: *std.ArrayList(Sphere),

pub const ValidObject = enum { cube, sphere };

const ListRef = union(ValidObject) {
    cube: *std.ArrayList(Cube),
    sphere: *std.ArrayList(Sphere),
};

pub fn getLists(self: *@This()) [2]ListRef {
    return .{
        ListRef{ .cube = self.cube_list },
        ListRef{ .sphere = self.sphere_list },
    };
}

pub fn deinit(self: *@This(), allocator: Allocator) void {
    self.cube_list.deinit(allocator);
    self.sphere_list.deinit(allocator);
}

const Cube = @import("cube.zig");
const Sphere = @import("sphere.zig");

const Allocator = std.mem.Allocator;
const std = @import("std");
