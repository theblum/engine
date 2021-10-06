const std = @import("std");
const log = std.log.scoped(.gameStateManager);

pub fn GameStateManager(comptime S: type, comptime T: type) type {
    return struct {
        const Self = @This();

        array: Array,
        current: ?S = null,
        next: ?S,

        transitionFrom: ?TransitionFn = null,
        transitionTo: ?TransitionFn = null,

        const SystemManager = @import("system_manager.zig").SystemManager(T);
        const Array = std.EnumArray(S, Value);
        const TransitionFn = fn (*T) bool;
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

        // @Todo: This could probably use some cleanup...
        pub fn run(self: *Self, state: *T) void {
            var alreadyRun = false;

            if (self.transitionFrom) |transitionFrom| {
                self.array.getPtr(self.current.?).systemManager.run(state);
                alreadyRun = true;

                if (transitionFrom(state)) {
                    return;
                } else self.transitionFrom = null;
            }

            if (self.next) |next| {
                if (self.current) |current| {
                    self.array.getPtr(current).systemManager.end(state);
                }

                self.current = next;
                self.next = null;
                self.array.getPtr(self.current.?).systemManager.start(state);
            }

            if (self.transitionTo) |transitionTo| {
                if (!alreadyRun) {
                    self.array.getPtr(self.current.?).systemManager.run(state);
                    alreadyRun = true;
                }

                if (transitionTo(state)) {
                    return;
                } else self.transitionTo = null;
            }

            if (!alreadyRun) self.array.getPtr(self.current.?).systemManager.run(state);
        }

        pub fn setTo(self: *Self, next: S, transitionFrom: ?TransitionFn, transitionTo: ?TransitionFn) void {
            self.next = next;
            self.transitionFrom = transitionFrom;
            self.transitionTo = transitionTo;
        }
    };
}
