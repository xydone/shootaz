pub fn lua_create_sphere(lua: *Lua) c_int {
    if (lua.getTop() != 4) {
        std.debug.print("create_sphere: expected 4 arguments\n", .{});
        return 0;
    }

    const x = lua.toNumber(1) catch return 0;
    const y = lua.toNumber(2) catch return 0;
    const z = lua.toNumber(3) catch return 0;
    const radius: f32 = @floatCast(lua.toNumber(4) catch return 0);
    Sphere.insert(lua.allocator(), .{
        .offset = .{ .x = @floatCast(x), .y = @floatCast(y), .z = @floatCast(z) },
        .radius = radius,
        .color = red,
    });
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

pub inline fn register(lua_instance: *Lua) void {
    lua_instance.newTable();

    lua_instance.pushFunction(zlua.wrap(lua_create_sphere));
    lua_instance.setField(-2, "create_sphere");

    lua_instance.pushFunction(zlua.wrap(lua_get_spheres));
    lua_instance.setField(-2, "get_spheres");

    lua_instance.setGlobal("Object");
}

const red = @import("../colors.zig").red;

const Lua = zlua.Lua;
const zlua = @import("zlua");

const Sphere = @import("../components/sphere.zig");

const std = @import("std");
