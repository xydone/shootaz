lua_instance: *Lua,
is_script_running: bool = false,

const LuaSetup = @This();

pub fn init(allocator: std.mem.Allocator) LuaSetup {
    const lua_instance = Lua.init(allocator) catch @panic("Cannot init Lua");
    var script_manager: LuaSetup = .{ .lua_instance = lua_instance };
    script_manager.lua_instance.openLibs();
    script_manager.registerFunctions();

    return script_manager;
}

pub fn deinit(self: LuaSetup) void {
    self.lua_instance.deinit();
}

inline fn registerFunctions(self: *LuaSetup) void {
    self.lua_instance.newTable();

    self.lua_instance.pushFunction(zlua.wrap(lua_create_sphere));
    self.lua_instance.setField(-2, "create_sphere");

    self.lua_instance.pushFunction(zlua.wrap(lua_get_spheres));
    self.lua_instance.setField(-2, "get_spheres");

    self.lua_instance.pushFunction(zlua.wrap(lua_get_player_position));
    self.lua_instance.setField(-2, "get_player_position");

    self.lua_instance.setGlobal("Game");
}

pub fn doFile(self: *LuaSetup, allocator: Allocator, file_name: []u8) void {
    self.is_script_running = true;
    const path = std.fmt.allocPrintSentinel(allocator, "scripts/{s}.lua", .{file_name}, 0) catch @panic("OOM");
    self.lua_instance.doFile(path) catch {
        const err = self.lua_instance.toString(-1) catch "failed";
        std.debug.print("err: {s}\n", .{err});
    };
}

pub fn update(self: *LuaSetup) void {
    if (self.is_script_running == false) return;
    _ = self.lua_instance.getGlobal("update") catch @panic("getGlobal failed");
    self.lua_instance.protectedCall(.{}) catch @panic("pcall failed");
}

const lua_get_player_position = @import("player.zig").lua_get_player_position;
const lua_create_sphere = @import("object_management.zig").lua_create_sphere;
const lua_get_spheres = @import("object_management.zig").lua_get_spheres;
const Lua = zlua.Lua;
const zlua = @import("zlua");

const Allocator = std.mem.Allocator;
const std = @import("std");
