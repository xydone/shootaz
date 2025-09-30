/// Scales with aspect ratio automatically
pub fn lua_set_crosshair(lua: *Lua) c_int {
    const aspect = sapp.widthf() / sapp.heightf();
    const args = lua.getTop();
    if (args != 1 or !lua.isTable(1)) {
        return 0;
    }

    const len = lua.rawLen(1);
    var data = std.ArrayList(Crosshair.Data).empty;
    defer data.deinit(lua.allocator());

    var i: c_int = 1;
    while (i <= len) : (i += 1) {
        _ = lua.rawGetIndex(1, i);
        if (!lua.isTable(-1)) {
            lua.pop(1);
            continue;
        }

        const x = getNumberAt(lua, -1, 1);
        const y = getNumberAt(lua, -1, 2);

        _ = lua.rawGetIndex(-1, 3);
        if (!lua.isTable(-1)) {
            lua.pop(2);
            continue;
        }
        const r = getNumberAt(lua, -1, 1);
        const g = getNumberAt(lua, -1, 2);
        const b = getNumberAt(lua, -1, 3);
        const a = getNumberAt(lua, -1, 4);

        lua.pop(1);

        data.append(lua.allocator(), .{ .pos = .{ x, y * aspect }, .color = .{ r, g, b, a } }) catch @panic("OOM");

        lua.pop(1);
    }

    Crosshair.set(lua.allocator(), data.items) catch {};

    return 0;
}

inline fn getNumberAt(lua: *Lua, index: i32, field: i32) f32 {
    _ = lua.rawGetIndex(index, field);
    defer lua.pop(1);

    return @floatCast(lua.toNumber(-1) catch @panic("toNumber() failed"));
}

pub inline fn register(lua_instance: *Lua) void {
    lua_instance.newTable();

    lua_instance.pushFunction(zlua.wrap(lua_set_crosshair));
    lua_instance.setField(-2, "set_crosshair");

    lua_instance.setGlobal("Crosshair");
}

const Crosshair = @import("../components/crosshair.zig");

const State = @import("../state.zig");

const Lua = zlua.Lua;
const zlua = @import("zlua");

const sapp = @import("sokol").app;

const std = @import("std");
