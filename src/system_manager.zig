const std = @import("std");
const log = std.log.scoped(.systemManager);

pub fn SystemManager(comptime S: type, comptime T: type) type {
    return struct {
        const Self = @This();

        systems: []const S,

        pub fn init(systems: []const S) Self {
            return .{
                .systems = systems,
            };
        }

        pub fn tick(self: Self, state: *T) void {
            for (self.systems) |system| {
                system.tickFn(state);
            }
        }
    };
}
