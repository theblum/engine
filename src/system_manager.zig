const std = @import("std");
const log = std.log.scoped(.systemManager);

pub fn SystemManager(comptime S: type) type {
    return struct {
        const Self = @This();

        systems: *const Item,
        started: bool = false,
        callEnd: bool = false,

        pub const Item = struct {
            startFn: fn (*S) bool,
            endFn: fn (*S) void,
            tickFns: []const fn (*S) void,
        };

        pub fn init(systems: *const Item) Self {
            return .{
                .systems = systems,
            };
        }

        pub fn start(self: *Self, state: *S) void {
            if (!self.started) {
                self.callEnd = self.systems.startFn(state);
                self.started = true;
            }
        }

        pub fn end(self: *Self, state: *S) void {
            if (self.started and self.callEnd) {
                self.systems.endFn(state);
                self.started = false;
                self.callEnd = false;
            }
        }

        pub fn run(self: *Self, state: *S) void {
            for (self.systems.tickFns) |system| {
                system(state);
            }
        }
    };
}
