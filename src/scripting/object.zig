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
        lua.newTable();
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

pub fn lua_generate_random_sphere(lua: *Lua) c_int {
    var seed: u64 = undefined;
    std.posix.getrandom(std.mem.asBytes(&seed)) catch @panic("Couldn't generate seed.");

    State.instance.player.stats.seed = seed;
    var prng = std.Random.DefaultPrng.init(seed);

    const x_range = getRange(lua, "X") catch @panic("X is not a variable");
    const y_range = getRange(lua, "Y") catch @panic("Y is not a variable");
    const z_range = getRange(lua, "Z") catch @panic("Z is not a variable");
    const radius = blk: {
        _ = lua.getGlobal("RADIUS") catch @panic("getGlobal() failed");
        const radius: f32 = lua.toNumeric(f32, -1) catch @panic("toNumeric() failed");

        break :blk radius;
    };

    const ranges: [3]Range = .{ x_range, y_range, z_range };

    var offset = Vec3.zero();
    for (std.enums.values(Axis)) |axis| {
        const range = ranges[@intFromEnum(axis)];
        const value = switch (range) {
            .single_value => |value| value,
            .range => |value| prng.random().intRangeAtMost(i16, value.min, value.max),
        };

        switch (axis) {
            .x => offset.x = @floatFromInt(value),
            .y => offset.y = @floatFromInt(value),
            .z => offset.z = @floatFromInt(value),
        }
    }

    Sphere.insert(lua.allocator(), .{
        .offset = offset,
        .radius = radius,
        .color = red,
    });
    return 0;
}

const Axis = enum { x, y, z };

const Range = union(enum) {
    single_value: i16,
    range: struct { min: i16, max: i16 },
};
fn getRange(lua: *Lua, variable: [:0]const u8) error{NoVariable}!Range {
    const lua_variable = lua.getGlobal(variable) catch return error.NoVariable;
    defer lua.pop(1);
    return switch (lua_variable) {
        .number => Range{ .single_value = @intCast(lua.toInteger(-1) catch @panic("toInteger() failed")) },
        .table => {
            _ = lua.getField(-1, "min");
            const min: i16 = @intCast(lua.toInteger(-1) catch @panic("toInteger() failed"));
            lua.pop(1);
            _ = lua.getField(-1, "max");
            const max: i16 = @intCast(lua.toInteger(-1) catch @panic("toInteger() failed"));
            lua.pop(1);

            return Range{ .range = .{ .min = min, .max = max } };
        },
        else => return error.NoVariable,
    };
}

pub fn lua_clear_spheres(lua: *Lua) c_int {
    _ = lua; // autofix
    Sphere.clear();

    return 0;
}

pub inline fn register(lua: *Lua) void {
    lua.newTable();

    lua.pushFunction(zlua.wrap(lua_generate_random_sphere));
    lua.setField(-2, "generate_random_sphere");

    lua.pushFunction(zlua.wrap(lua_create_sphere));
    lua.setField(-2, "create_sphere");

    lua.pushFunction(zlua.wrap(lua_clear_spheres));
    lua.setField(-2, "clear_spheres");

    lua.pushFunction(zlua.wrap(lua_get_spheres));
    lua.setField(-2, "get_spheres");

    lua.setGlobal("Object");
}

const red = @import("../colors.zig").red;

const Lua = zlua.Lua;
const zlua = @import("zlua");

const Vec3 = @import("../math.zig").Vec3;

const State = @import("../state.zig");

const Sphere = @import("../components/sphere.zig");

const std = @import("std");
