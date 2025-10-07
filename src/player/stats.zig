total_shots: u64 = 0,
accurate_shots: u64 = 0,
reload_count: u64 = 0,
seed: u64 = 123,
hit_timestamps: std.ArrayList(u64) = .empty,

const Stats = @This();

fn toFileFormat(self: Stats) StatsFile {
    return .{
        .total_shots = self.total_shots,
        .accurate_shots = self.accurate_shots,
        .reload_count = self.reload_count,
        .seed = self.seed,
        .hit_timestamps = self.hit_timestamps.items,
    };
}

const StatsFile = struct {
    total_shots: u64,
    accurate_shots: u64,
    reload_count: u64,
    seed: u64,
    hit_timestamps: []u64,
};

pub const Settings = struct {
    save_to_file: bool = false,
    time_hits: bool = false,
    pub fn init(allocator: Allocator) !Settings {
        return readZon(Settings, allocator, "config/stats.zon", 1024);
    }
};

const STATS_FOLDER = "stats";

pub fn save(stats: *Stats, script_name: []const u8, allocator: Allocator) !void {
    if (State.instance.settings.stats_settings.save_to_file == false) return;
    const timestamp = std.time.timestamp();
    const file_name = std.fmt.allocPrint(allocator, "{s}_{}", .{ script_name, timestamp }) catch @panic("OOM");
    defer allocator.free(file_name);
    const file = stats.toFileFormat();

    return saveToFile(StatsFile, allocator, STATS_FOLDER, file_name, file);
}

const saveToFile = @import("../util/saveToFile.zig").saveToFile;
const readZon = @import("../util/readZon.zig").readZon;

const State = @import("../state.zig");

const Allocator = std.mem.Allocator;
const std = @import("std");
