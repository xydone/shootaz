pub fn lua_get_player_position(lua: *Lua) c_int {
    const pos = State.instance.camera.pos;
    lua.pushNumber(pos.x);
    lua.pushNumber(pos.y);
    lua.pushNumber(pos.z);

    return 3;
}

const State = @import("../state.zig");

const Lua = zlua.Lua;
const zlua = @import("zlua");

const std = @import("std");
