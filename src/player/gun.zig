ammo: u16,
cooldown: f32 = 0,
/// amount of ammo that will be replenished on hit or on reload
replenish_ammo: u16,
firing_mode: FiringModeData,
/// seconds between shots
fire_rate: f32,

pub const FiringMode = enum { automatic, semi };

pub const FiringModeData = union(FiringMode) {
    automatic: void,
    semi: struct {
        has_fired_this_click: bool = false,
    },
};

pub fn canShoot(self: @This()) bool {
    return self.ammo != 0;
}

/// Returns if shot is a hit
/// Asserts that there is enough ammo
pub fn shoot(self: *@This()) bool {
    std.debug.assert(self.ammo != 0);

    self.cooldown = self.fire_rate;

    const origin = State.instance.camera.pos;
    const direction = State.instance.camera.getForward();

    self.ammo -|= 1;

    //TODO: this is ugly
    const is_hit = blk: {
        for (State.instance.objects.getLists()) |list| {
            switch (list) {
                .cubes => |cubes| {
                    for (cubes.items, 0..) |cube, i| {
                        const is_intercepted = Cube.intercept(origin.toSlice(), direction.toSlice(), cube.offset);

                        if (is_intercepted) {
                            self.ammo = self.replenish_ammo;
                            Cube.removeIndex(@intCast(i));
                            break :blk true;
                        }
                    }
                },
                .spheres => |spheres| {
                    for (spheres.items, 0..) |sphere, i| {
                        const is_intercepted = Sphere.intercept(origin.toSlice(), direction.toSlice(), sphere.offset.toSlice(), sphere.radius);

                        if (is_intercepted) {
                            self.ammo = self.replenish_ammo;
                            Sphere.removeIndex(@intCast(i));
                            break :blk true;
                        }
                    }
                },
            }
        }
        break :blk false;
    };

    return is_hit;
}

pub fn reload(self: *@This()) void {
    self.ammo = self.replenish_ammo;
}

const Sphere = @import("../components/sphere.zig");
const Cube = @import("../components/cube.zig");

const State = @import("../state.zig");
const Vec3 = @import("../math.zig").Vec3;

const std = @import("std");
