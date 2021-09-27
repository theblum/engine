const std = @import("std");
const log = std.log.scoped(.renderer);
const c = @import("c.zig");
const m = @import("zlm");

const Window = @import("window.zig").Window;

pub const Renderer = struct {
    const Self = @This();

    window: *Window,
    circle: *c.sfCircleShape,
    rectangle: *c.sfRectangleShape,
    font: *c.sfFont,
    text: *c.sfText,

    pub fn init(window: *Window) !Self {
        var result: Self = .{
            .window = window,
            .circle = c.sfCircleShape_create() orelse return error.LoadingError,
            .rectangle = c.sfRectangleShape_create() orelse return error.LoadingError,
            .font = c.sfFont_createFromFile("resources/iosevka.ttf") orelse return error.LoadingError,
            .text = c.sfText_create() orelse return error.LoadingError,
        };

        return result;
    }

    pub fn deinit(self: Self) void {
        c.sfCircleShape_destroy(self.circle);
        c.sfRectangleShape_destroy(self.rectangle);
        c.sfFont_destroy(self.font);
        c.sfText_destroy(self.text);
    }

    pub fn clearWindow(self: Self, color: m.Vec4) void {
        c.sfRenderWindow_clear(self.window.handle, vec4ToSFMLColor(color));
    }

    pub fn displayWindow(self: Self) void {
        c.sfRenderWindow_display(self.window.handle);
    }

    const CircleOptions = struct {
        color: m.Vec4 = m.vec4(1.0, 1.0, 1.0, 1.0),
        outlineColor: ?m.Vec4 = null,
        outlineThickness: f32 = 1.0,
        rotation: f32 = 0.0,
    };

    pub fn drawCircle(self: Self, position: m.Vec2, radius: f32, options: CircleOptions) void {
        c.sfCircleShape_setOrigin(self.circle, .{ .x = radius, .y = radius });
        c.sfCircleShape_setPosition(self.circle, .{ .x = position.x, .y = position.y });
        c.sfCircleShape_setRadius(self.circle, radius);
        c.sfCircleShape_setRotation(self.circle, options.rotation);
        c.sfCircleShape_setFillColor(self.circle, vec4ToSFMLColor(options.color));

        if (options.outlineColor) |outlineColor| {
            c.sfCircleShape_setOutlineColor(self.circle, vec4ToSFMLColor(outlineColor));
            c.sfCircleShape_setOutlineThickness(self.circle, options.outlineThickness);
        }

        c.sfRenderWindow_drawCircleShape(self.window.handle, self.circle, null);
    }

    const RectangleOptions = struct {
        color: m.Vec4 = m.vec4(1.0, 1.0, 1.0, 1.0),
        outlineColor: ?m.Vec4 = null,
        outlineThickness: f32 = 1.0,
        rotation: f32 = 0.0,
    };

    pub fn drawRectangle(self: Self, position: m.Vec2, size: m.Vec2, options: RectangleOptions) void {
        c.sfRectangleShape_setOrigin(self.rectangle, .{ .x = size.x * 0.5, .y = size.y * 0.5 });
        c.sfRectangleShape_setPosition(self.rectangle, .{ .x = position.x, .y = position.y });
        c.sfRectangleShape_setSize(self.rectangle, .{ .x = size.x, .y = size.y });
        c.sfRectangleShape_setRotation(self.rectangle, options.rotation);
        c.sfRectangleShape_setFillColor(self.rectangle, vec4ToSFMLColor(options.color));

        if (options.outlineColor) |outlineColor| {
            c.sfRectangleShape_setOutlineColor(self.rectangle, vec4ToSFMLColor(outlineColor));
            c.sfRectangleShape_setOutlineThickness(self.rectangle, options.outlineThickness);
        }

        c.sfRenderWindow_drawRectangleShape(self.window.handle, self.rectangle, null);
    }

    const TextOptions = struct {
        color: m.Vec4 = m.vec4(0.0, 0.0, 0.0, 1.0),
        size: u32 = 12,
    };

    // @Todo: Deal with getting the text width when needed.
    pub fn drawText(self: Self, text: [:0]const u8, position: m.Vec2, options: TextOptions) void {
        c.sfText_setString(self.text, text);
        c.sfText_setFont(self.text, self.font);
        c.sfText_setCharacterSize(self.text, options.size);
        c.sfText_setFillColor(self.text, vec4ToSFMLColor(options.color));

        c.sfText_setPosition(self.text, .{ .x = position.x, .y = position.y });
        c.sfRenderWindow_drawText(self.window.handle, self.text, null);
    }

    fn vec4ToSFMLColor(vec: m.Vec4) c.sfColor {
        return .{
            .r = @floatToInt(u8, vec.x * 255.0),
            .g = @floatToInt(u8, vec.y * 255.0),
            .b = @floatToInt(u8, vec.z * 255.0),
            .a = @floatToInt(u8, vec.w * 255.0),
        };
    }
};
