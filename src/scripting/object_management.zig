pub fn lua_create_sphere(lua: *Lua) c_int {
    if (lua.getTop() != 3) {
        std.debug.print("createSphere: insufficient arguments.\n", .{});
        return 0;
    }

    const x = lua.toNumber(1) catch return 0;
    const y = lua.toNumber(2) catch return 0;
    const z = lua.toNumber(3) catch return 0;
    Sphere.insert(lua.allocator(), .{ .offset = .{ .x = @floatCast(x), .y = @floatCast(y), .z = @floatCast(z) } });
    return 1;
}

pub fn lua_get_spheres(lua: *Lua) c_int {
    const spheres = Sphere.getPositions();

    lua.newTable();

    for (spheres, 0..) |s, i| {
        lua.newTable(); // table for this sphere
        lua.pushNumber(@floatCast(s.offset.x));
        lua.setField(-2, "x");
        lua.pushNumber(@floatCast(s.offset.y));
        lua.setField(-2, "y");
        lua.pushNumber(@floatCast(s.offset.z));
        lua.setField(-2, "z");

        lua.setIndex(-2, @intCast(i + 1));
    }

    return 1;
}

const Lua = zlua.Lua;
const zlua = @import("zlua");

const Sphere = @import("../components/sphere.zig");

const std = @import("std");
