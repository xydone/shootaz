pub fn lua_get_player_position(lua: *Lua) c_int {
    const pos = State.instance.camera.pos;
    lua.pushNumber(pos.x);
    lua.pushNumber(pos.y);
    lua.pushNumber(pos.z);

    return 3;
}

pub fn lua_set_weapon(lua: *Lua) c_int {
    if (lua.getTop() != 4) {
        std.debug.print("set_weapon: expected 4 arguments\n", .{});
        return 0;
    }

    const ammo: u16 = @intFromFloat(lua.toNumber(1) catch return 0);
    const replenish_ammo: u16 = @intFromFloat(lua.toNumber(2) catch return 0);
    const firing_mode_value: u8 = @intFromFloat(lua.toNumber(3) catch return 0);
    const fire_rate: f32 = @floatCast(lua.toNumber(4) catch return 0);

    const firing_mode: Gun.FiringMode = @enumFromInt(firing_mode_value);

    State.instance.player.active_weapon = .{
        .ammo = ammo,
        .replenish_ammo = replenish_ammo,
        .firing_mode = switch (firing_mode) {
            .semi => .{ .semi = .{} },
            .automatic => .{ .automatic = {} },
        },
        .fire_rate = fire_rate,
    };

    return 0;
}

pub inline fn register(lua: *Lua) void {
    lua.newTable();

    lua.pushFunction(zlua.wrap(lua_get_player_position));
    lua.setField(-2, "get_player_position");

    lua.pushFunction(zlua.wrap(lua_set_weapon));
    lua.setField(-2, "set_weapon");

    lua.setGlobal("Player");

    lua.pushInteger(@intFromEnum(Gun.FiringMode.semi));
    lua.setGlobal("FIRING_MODE_SEMI");

    lua.pushInteger(@intFromEnum(Gun.FiringMode.automatic));
    lua.setGlobal("FIRING_MODE_AUTOMATIC");
}

const Gun = @import("../player/gun.zig");

const State = @import("../state.zig");

const Lua = zlua.Lua;
const zlua = @import("zlua");

const std = @import("std");
