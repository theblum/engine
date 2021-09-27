const std = @import("std");
const log = std.log.scoped(.clock);
const c = @import("c.zig");

pub const Clock = struct {
    const Self = @This();

    handle: *c.sfClock,

    pub fn init() !Self {
        var result = .{
            .handle = c.sfClock_create() orelse return error.LoadingError,
        };

        return result;
    }

    pub fn deinit(self: Self) void {
        c.sfClock_destroy(self.handle);
    }

    pub fn getSecondsAndRestart(self: Self) f32 {
        return c.sfTime_asSeconds(c.sfClock_restart(self.handle));
    }
};
