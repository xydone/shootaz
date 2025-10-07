lua: *Lua,
is_update_script_running: bool = false,
timer: Timer,
script_name: ?[]const u8 = null,
prng: std.Random.DefaultPrng,

const Timer = struct {
    is_active: bool = false,
    inner_timer: std.time.Timer,
    /// nanoseconds
    duration: u64,

    pub fn start(self: *@This(), duration: u64) void {
        self.inner_timer.reset();
        self.duration = duration;
        self.is_active = true;
    }

    pub fn check(self: *@This()) bool {
        const timer_ended = self.inner_timer.read() >= self.duration;

        if (timer_ended) self.is_active = false;

        return timer_ended;
    }

    /// returns seconds
    pub fn remaining(self: *@This()) f64 {
        if (self.is_active == false) return 0;
        const elapsed: f64 = @floatFromInt(self.inner_timer.read());
        const duration: f64 = @floatFromInt(self.duration);
        const remainder = duration - elapsed;
        return if (remainder < 0) 0 else remainder / 1_000_000_000;
    }
};

const LuaSetup = @This();

pub fn init(allocator: std.mem.Allocator) LuaSetup {
    const lua = Lua.init(allocator) catch @panic("Cannot init Lua");
    var seed: u64 = undefined;
    std.posix.getrandom(std.mem.asBytes(&seed)) catch @panic("Couldn't generate seed.");
    var script_manager: LuaSetup = .{
        .lua = lua,
        .timer = .{
            .inner_timer = std.time.Timer.start() catch @panic("Timer is not supported"),
            .duration = 0,
        },
        .prng = .init(seed),
    };
    script_manager.lua.openLibs();
    script_manager.registerFunctions();

    return script_manager;
}

pub fn deinit(self: LuaSetup) void {
    self.lua.deinit();
}

inline fn registerFunctions(self: *LuaSetup) void {
    Object.register(self.lua);
    Player.register(self.lua);
    Crosshair.register(self.lua);
}

pub fn doFile(self: *LuaSetup, allocator: Allocator, file_name: []const u8) error{FileNotFound}!void {
    State.instance.player.stats = .{};
    const path = std.fmt.allocPrintSentinel(allocator, "scripts/{s}.lua", .{file_name}, 0) catch @panic("OOM");
    self.lua.doFile(path) catch {
        const err = self.lua.toString(-1) catch return;
        std.debug.print("err: {s}\n", .{err});

        return error.FileNotFound;
    };

    self.script_name = file_name;

    _ = self.lua.getGlobal("MAX_RUNTIME") catch return;
    const has_update = blk: {
        _ = self.lua.getGlobal("update") catch break :blk false;
        self.lua.pop(1);
        break :blk true;
    };

    if (has_update) {
        self.is_update_script_running = true;
    }
    const duration: u64 = @intFromFloat(self.lua.toNumber(-1) catch return);

    self.timer.start(duration * std.time.ns_per_s);
    self.timer.is_active = true;
}

pub fn update(self: *LuaSetup) void {
    if (self.is_update_script_running == false) return;

    if (self.timer.check()) {
        self.is_update_script_running = false;
        State.instance.player.stats.save(self.script_name.?, self.lua.allocator()) catch @panic("Couldn't save stats.");
        self.timer.is_active = false;
        self.onTimerEnd();
        return;
    }

    _ = self.lua.getGlobal("update") catch return;
    self.lua.protectedCall(.{}) catch @panic("pcall failed");
}

pub fn startTimer(self: *LuaSetup, duration: f64) void {
    self.timer.start(duration);
}

pub fn onTimerEnd(self: *LuaSetup) void {
    _ = self.lua.getGlobal("onTimerEnd") catch return;
    self.lua.protectedCall(.{}) catch @panic("pcall failed");
}

const Crosshair = @import("crosshair.zig");
const Player = @import("player.zig");
const Object = @import("object.zig");

const State = @import("../state.zig");

const Lua = zlua.Lua;
const zlua = @import("zlua");

const Allocator = std.mem.Allocator;
const std = @import("std");
