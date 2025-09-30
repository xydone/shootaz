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

        _ = lua.rawGetIndex(-1, 1);
        if (!lua.isNumber(-1)) {
            lua.pop(2);
            continue;
        }
        const x = lua.toNumber(-1) catch @panic("toNumber() failed");
        lua.pop(1);

        _ = lua.rawGetIndex(-1, 2);
        if (!lua.isNumber(-1)) {
            lua.pop(2);
            continue;
        }
        const y = lua.toNumber(-1) catch @panic("toNumber() failed");
        lua.pop(1);

        data.append(lua.allocator(), .{ .pos = .{ @floatCast(x * aspect), @floatCast(y) }, .color = .{ 1, 1, 1, 1 } }) catch @panic("OOM");

        lua.pop(1);
    }

    Crosshair.set(lua.allocator(), data.items) catch @panic("OOM");

    return 0;
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
