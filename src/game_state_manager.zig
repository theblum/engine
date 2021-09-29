const std = @import("std");
const log = std.log.scoped(.gameStateManager);

pub fn GameStateManager(comptime S: type, comptime T: type) type {
    return struct {
        const Self = @This();

        array: Array,
        current: ?S = null,
        next: ?S,

        const SystemManager = @import("system_manager.zig").SystemManager(T);
        const Array = std.EnumArray(S, Value);
        const Value = struct {
            systemManager: SystemManager,
        };

        pub fn indexOf(gameState: S) usize {
            return Array.Indexer.indexOf(gameState);
        }

        pub fn keyForIndex(index: usize) S {
            return Array.Indexer.keyForIndex(index);
        }

        pub fn init(start: S) Self {
            return .{
                .array = Array.initUndefined(),
                .next = start,
            };
        }

        pub fn deinit(self: *Self, state: *T) void {
            if (self.current) |current| {
                self.array.getPtr(current).systemManager.end(state);
                self.current = null;
            }
        }

        pub fn register(self: *Self, gameState: S, systems: *const SystemManager.Item) void {
            self.array.set(gameState, .{ .systemManager = SystemManager.init(systems) });
        }

        pub fn run(self: *Self, state: *T) void {
            if (self.next) |next| {
                if (self.current) |current|
                    self.array.getPtr(current).systemManager.end(state);

                self.current = next;
                self.next = null;
                self.array.getPtr(self.current.?).systemManager.start(state);
            }

            self.array.getPtr(self.current.?).systemManager.run(state);
        }

        pub fn setTo(self: *Self, next: S) void {
            self.next = next;
        }
    };
}
