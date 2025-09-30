pub fn lua_get_player_position(lua: *Lua) c_int {
    const pos = State.instance.camera.pos;
    lua.pushNumber(pos.x);
    lua.pushNumber(pos.y);
    lua.pushNumber(pos.z);

    return 3;
}

pub inline fn register(lua_instance: *Lua) void {
    lua_instance.newTable();

    lua_instance.pushFunction(zlua.wrap(lua_get_player_position));
    lua_instance.setField(-2, "get_player_position");

    lua_instance.setGlobal("Player");
}

const State = @import("../state.zig");

const Lua = zlua.Lua;
const zlua = @import("zlua");

const std = @import("std");
