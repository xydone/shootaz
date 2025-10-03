total_shots: u16 = 0,
accurate_shots: u16 = 0,
reload_count: u16 = 0,

const Stats = @This();

pub const Settings = struct {
    save_to_file: bool = false,
    pub fn init(allocator: Allocator) !Settings {
        return readZon(Settings, allocator, "config/stats.zon", 1024);
    }
};

const STATS_FOLDER = "stats";

pub fn save(stats: Stats, script_name: []const u8, allocator: Allocator) !void {
    if (State.instance.settings.stats_settings.save_to_file == false) return;
    const timestamp = std.time.timestamp();
    const file_name = std.fmt.allocPrint(allocator, "{s}_{}", .{ script_name, timestamp }) catch @panic("OOM");
    defer allocator.free(file_name);
    return saveToFile(Stats, allocator, STATS_FOLDER, file_name, stats);
}

const saveToFile = @import("../util/saveToFile.zig").saveToFile;
const readZon = @import("../util/readZon.zig").readZon;

const State = @import("../state.zig");

const Allocator = std.mem.Allocator;
const std = @import("std");
