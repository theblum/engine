const std = @import("std");
const log = std.log.scoped(.systemManager);

pub fn SystemManager(comptime S: type) type {
    return struct {
        const Self = @This();

        systems: *const Item,
        inited: bool = false,
        callDeinit: bool = true,

        pub const Item = struct {
            initFn: fn (*S) bool,
            deinitFn: fn (*S) void,
            tickFns: []const fn (*S) void,
        };

        pub fn init(systems: *const Item) Self {
            return .{
                .systems = systems,
            };
        }

        pub fn run(self: *Self, state: *S) void {
            if (!self.inited) {
                self.callDeinit = self.systems.initFn(state);
                self.inited = true;
            }

            for (self.systems.tickFns) |system| {
                system(state);
            }

            // @Todo: This is totally wrong. We don't want to deinit after every loop. Only when
            // switching to a different state or at the end of game loop.
            if (self.callDeinit) {
                self.systems.deinitFn(state);
                self.callDeinit = false;
                self.inited = false;
            }
        }
    };
}
