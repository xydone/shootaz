movement_settings: MovementSettings = .{},
stats_settings: StatsSettings = .{},
ui_settings: UISettings = .{},

controls: Controls = .{},

const UISettings = @import("ui/ui.zig").Settings;
const MovementSettings = @import("movement.zig").Settings;
const StatsSettings = @import("player/stats.zig").Settings;

const Controls = @import("controls.zig").Settings;
