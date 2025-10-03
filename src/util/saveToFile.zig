pub fn saveToFile(T: type, allocator: Allocator, folder_name: []const u8, file_name: []const u8, data: T) !void {
    const path = try std.fmt.allocPrint(allocator, "{s}/{s}.zon", .{ folder_name, file_name });
    defer allocator.free(path);
    const file = std.fs.cwd().createFile(path, .{}) catch |err| file: {
        switch (err) {
            // if the parent folder is not found, FileNotFound is thrown.
            error.FileNotFound => {
                // fs.path.dirname() returns null if the path is the root dir
                const dirname = std.fs.path.dirname(path) orelse return err;
                // create the dir
                try std.fs.cwd().makeDir(dirname);
                // retry creating the file
                break :file try std.fs.cwd().createFile(path, .{});
            },
            else => return err,
        }
    };
    defer file.close();

    var writer = std.Io.Writer.Allocating.init(allocator);
    try std.zon.stringify.serialize(data, .{ .whitespace = false }, &writer.writer);

    const string = try writer.toOwnedSlice();
    defer allocator.free(string);

    _ = try file.writeAll(string);
}

const Allocator = std.mem.Allocator;
const std = @import("std");
