const std = @import("std");
const log = std.log.scoped(.entityManager);

pub const MAX_ENTITIES = 4096;

pub fn EntityManager(comptime S: type, comptime T: type) type {
    return struct {
        const Self = @This();

        entities: []Item,
        entityCount: usize = 0,
        allocator: *std.mem.Allocator,

        const Handle = struct {
            index: usize,
            generation: u32,
        };

        const Item = struct {
            handle: Handle,
            entity: ?S = null,
        };

        pub fn init(allocator: *std.mem.Allocator) !Self {
            var entities = try allocator.alloc(Item, MAX_ENTITIES);
            for (entities) |*e, i| {
                e.* = Item{ .handle = .{ .index = i, .generation = 0 } };
            }

            var result = .{
                .entities = entities,
                .allocator = allocator,
            };

            return result;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.entities);
        }

        pub fn createEntity(self: *Self, entity: S) !Handle {
            var result: Handle = undefined;

            if (self.entityCount >= self.entities.len) return error.ExceededMaxEntries;

            for (self.entities) |*item| {
                if (item.entity) |_| {} else {
                    item.handle.generation += 1;
                    item.entity = entity;

                    result = item.handle;

                    self.entityCount += 1;

                    break;
                }
            } else return error.ExceededMaxEntities;

            return result;
        }

        pub fn deleteEntity(self: *Self, handle: Handle) void {
            var item = &self.entities[handle.index];

            // @Note: This silently fails if the generations don't match.  Should this be the case?
            // Or should we return an error? Or not even check the generation?
            if (handle.generation == item.handle.generation) {
                item.entity = null;
                self.entityCount -= 1;
            }
        }

        pub fn getEntityPtr(self: Self, handle: Handle) !*S {
            var item = &self.entities[handle.index];

            if (handle.generation != item.handle.generation) return error.GenerationMismatch;
            return if (item.entity) |*entity| entity else error.InvalidHandle;
        }

        pub fn iterator(self: *Self) Iterator {
            return .{
                .entityManager = self,
            };
        }

        const Iterator = struct {
            entityManager: *Self,
            currentIndex: usize = 0,
            entitiesSeen: usize = 0,

            pub fn next(self: *@This(), flags: []const T) ?*Item {
                var manager = self.entityManager;
                var result = for (manager.entities[self.currentIndex..]) |*item| {
                    self.currentIndex += 1;
                    if (self.entitiesSeen >= manager.entityCount)
                        break null;

                    if (item.entity) |entity| {
                        self.entitiesSeen += 1;
                        if (entity.hasFlags(flags))
                            break item;
                    }
                } else null;

                return if (result) |r| r else blk: {
                    self.reset();
                    break :blk null;
                };
            }

            pub fn reset(self: *@This()) void {
                self.currentIndex = 0;
                self.entitiesSeen = 0;
            }
        };
    };
}
