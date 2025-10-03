movement_settings: MovementSettings = .{},
player_settings: PlayerSettings = .{},
stats_settings: StatsSettings = .{},

const PlayerSettings = @import("player/player.zig").Settings;
const MovementSettings = @import("movement.zig").Settings;
const StatsSettings = @import("player/stats.zig").Settings;
