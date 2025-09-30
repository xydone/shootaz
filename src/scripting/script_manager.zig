lua_instance: *Lua,
is_update_script_running: bool = false,

const LuaSetup = @This();

pub fn init(allocator: std.mem.Allocator) LuaSetup {
    const lua_instance = Lua.init(allocator) catch @panic("Cannot init Lua");
    var script_manager: LuaSetup = .{ .lua_instance = lua_instance };
    script_manager.lua_instance.openLibs();
    script_manager.registerFunctions();

    script_manager.doFile(allocator, "crosshair") catch {};

    return script_manager;
}

pub fn deinit(self: LuaSetup) void {
    self.lua_instance.deinit();
}

inline fn registerFunctions(self: *LuaSetup) void {
    Object.register(self.lua_instance);
    Player.register(self.lua_instance);
    Crosshair.register(self.lua_instance);
}

pub fn doFile(self: *LuaSetup, allocator: Allocator, file_name: []const u8) error{FileNotFound}!void {
    const path = std.fmt.allocPrintSentinel(allocator, "scripts/{s}.lua", .{file_name}, 0) catch @panic("OOM");
    self.lua_instance.doFile(path) catch {
        const err = self.lua_instance.toString(-1) catch return;
        std.debug.print("err: {s}\n", .{err});

        return error.FileNotFound;
    };
}

pub fn update(self: *LuaSetup) void {
    if (self.is_update_script_running == false) return;
    _ = self.lua_instance.getGlobal("update") catch @panic("getGlobal failed");
    self.lua_instance.protectedCall(.{}) catch @panic("pcall failed");
}

const Crosshair = @import("crosshair.zig");
const Player = @import("player.zig");
const Object = @import("object.zig");

const Lua = zlua.Lua;
const zlua = @import("zlua");

const Allocator = std.mem.Allocator;
const std = @import("std");
