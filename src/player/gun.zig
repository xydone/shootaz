ammo: u16,
cooldown: f32 = 0,
/// amount of ammo that will be replenished on hit or on reload
replenish_ammo: u16,
firing_mode: FiringMode,
/// seconds between shots
fire_rate: f32,

pub const FiringMode = union(enum) {
    automatic: void,
    semi: struct {
        has_fired_this_click: bool = false,
    },
};

pub fn shoot(self: *@This()) void {
    // dont allow shooting if we dont have ammo
    if (self.ammo == 0) return;

    self.cooldown = self.fire_rate;

    const origin = State.instance.camera.pos;
    const direction = State.instance.camera.getForward();

    self.ammo -|= 1;

    //TODO: this is ugly
    for (State.instance.objects.getLists()) |list| {
        switch (list) {
            .cubes => |cubes| {
                for (cubes.items, 0..) |cube, i| {
                    const is_intercepted = Cube.intercept(origin.toSlice(), direction.toSlice(), cube.offset);

                    if (is_intercepted) {
                        self.ammo = self.replenish_ammo;
                        Cube.removeIndex(@intCast(i));
                        break;
                    }
                }
            },
            .spheres => |spheres| {
                for (spheres.items, 0..) |sphere, i| {
                    const is_intercepted = Sphere.intercept(origin.toSlice(), direction.toSlice(), sphere.offset.toSlice(), sphere.radius);

                    if (is_intercepted) {
                        self.ammo = self.replenish_ammo;
                        Sphere.removeIndex(@intCast(i));
                        break;
                    }
                }
            },
        }
    }
}

pub fn reload(self: *@This()) void {
    self.ammo = self.replenish_ammo;
}

const Sphere = @import("../components/sphere.zig");
const Cube = @import("../components/cube.zig");

const State = @import("../state.zig");
const Vec3 = @import("../math.zig").Vec3;

const std = @import("std");
