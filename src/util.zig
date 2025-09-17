pub inline fn createVertex(pos: [3]f32, color: [4]f32) [7]f32 {
    return .{ pos[0], pos[1], pos[2], color[0], color[1], color[2], color[3] };
}
