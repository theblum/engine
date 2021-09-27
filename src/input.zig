const std = @import("std");
const log = std.log.scoped(.input);
const c = @import("c.zig");
const m = @import("zlm");

const Window = @import("window.zig").Window;

pub const Input = struct {
    const Self = @This();

    mouseButtons: [MouseButtons.len]MouseItem = .{MouseItem{}} ** MouseButtons.len,
    keys: [Keys.len]KeyItem = .{KeyItem{}} ** Keys.len,
    window: *Window,

    // @Note: Should these structs just be one `Item` struct?
    const MouseItem = struct {
        isDown: bool = false,
        wasDown: bool = false,
    };

    const KeyItem = struct {
        isDown: bool = false,
        wasDown: bool = false,
    };

    pub fn init(window: *Window) Self {
        return .{ .window = window };
    }

    pub fn getMouseButton(self: Self, button: MouseButtons) MouseItem {
        return self.mouseButtons[@enumToInt(button)];
    }

    pub fn setMouseButton(self: *Self, button: MouseButtons, pressed: bool) void {
        self.mouseButtons[@enumToInt(button)].isDown = pressed;
    }

    pub fn getMousePosition(self: Self) m.Vec2 {
        const position = c.sfMouse_getPositionRenderWindow(self.window.handle);
        const adjustedPosition = c.sfRenderWindow_mapPixelToCoords(self.window.handle, position, null);
        return .{ .x = adjustedPosition.x, .y = adjustedPosition.y };
    }

    pub fn getKey(self: Self, key: Keys) KeyItem {
        return self.keys[@enumToInt(key)];
    }

    pub fn setKey(self: *Self, key: Keys, pressed: bool) void {
        self.keys[@enumToInt(key)].isDown = pressed;
    }

    pub const MouseButtons = enum {
        const len = @typeInfo(@This()).Enum.fields.len;

        left,
        right,
        middle,
    };

    pub const Keys = enum {
        const len = @typeInfo(@This()).Enum.fields.len;

        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        j,
        k,
        l,
        m,
        n,
        o,
        p,
        q,
        r,
        s,
        t,
        u,
        v,
        w,
        x,
        y,
        z,
    };
};
