var instance: Sphere.InstanceData = .{
    .offset = .zero(),
    .color = red,
    .radius = 1,
};
var buf: [20]u8 = std.mem.zeroes([20]u8);

var show_window = true;
var file_name_list: std.ArrayList([]u8) = .empty;
var dir: ?std.fs.Dir = null;

pub inline fn init(allocator: Allocator) void {
    fetchFiles(allocator) catch std.debug.print("Could not fetch files.", .{});
}

pub inline fn deinit(allocator: Allocator) void {
    file_name_list.deinit(allocator);
}

pub inline fn draw(allocator: Allocator) void {
    if (show_window == false) return;
    defer ig.igEnd();

    if (ig.igBegin("Scripts", &show_window, ig.ImGuiWindowFlags_AlwaysAutoResize)) {
        for (file_name_list.items) |file_name| {
            if (ig.igButton(file_name.ptr)) {
                State.instance.script_manager.doFile(allocator, file_name) catch {};
            }
        }
    }

    ig.igSeparator();
    if (ig.igButton("Refetch scripts")) {
        fetchFiles(allocator) catch {};
    }
}

pub fn fetchFiles(allocator: Allocator) error{CannotOpenDir}!void {
    if (dir) |_| {
        // clear previous files
        file_name_list.clearRetainingCapacity();
    } else {
        dir = std.fs.cwd().openDir("scripts", .{ .iterate = true }) catch return error.CannotOpenDir;
    }
    var it = dir.?.iterate();

    while (it.next() catch return error.CannotOpenDir) |entry| {
        const idx = std.mem.lastIndexOfScalar(u8, entry.name, '.') orelse continue;
        file_name_list.append(allocator, allocator.dupe(u8, entry.name[0..idx]) catch @panic("OOM")) catch @panic("OOM");
    }
}

const red = @import("../colors.zig").red;
const Sphere = @import("../components/sphere.zig");
const State = @import("../state.zig");

const Vec3 = @import("../math.zig").Vec3;
const ig = @import("cimgui");

const Allocator = std.mem.Allocator;
const std = @import("std");
