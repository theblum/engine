const std = @import("std");
const log = std.log.scoped(.window);
const c = @import("c.zig");
const m = @import("zlm");

const Input = @import("input.zig").Input;

pub const Window = struct {
    const Self = @This();

    handle: *c.sfRenderWindow,
    input: Input = undefined,

    // @Note: These store the size of the game window, not the actual window size (they may be different if the
    // window has been resized). You can get the actual window size by calling `getActualSize()`. Storing these as
    // f32s makes calculations easier, but should we instead store as u32s and cast to f32s whenever needed?
    size: m.Vec2,

    const WindowOptions = struct {
        vsync: bool = false,
        targetFPS: u32 = 0,
        scale: u32 = 1,
        keyRepeat: bool = true,
        mouseVisible: bool = true,
        mouseGrabbed: bool = false,
    };

    pub fn init(programName: [:0]const u8, width: u32, height: u32, options: WindowOptions) !Self {
        var result: Window = undefined;
        result.size = m.vec2(@intToFloat(f32, width), @intToFloat(f32, height));

        // @Note: These are all just the default settings except for `antialiasingLevel`.
        // Also, as per the documentation: All these settings with the exception of the compatibility
        // flag and anti-aliasing level have no impact on the regular SFML rendering (graphics module),
        // so you may need to use this structure only if you're using SFML as a windowing system for
        // custom OpenGL rendering.
        const settings = .{
            .depthBits = 0,
            .stencilBits = 0,
            .antialiasingLevel = 8,
            .majorVersion = 1,
            .minorVersion = 1,
            .attributeFlags = c.sfContextDefault,
            .sRgbCapable = c.sfFalse,
        };

        result.handle = c.sfRenderWindow_create(
            .{ .width = width, .height = height, .bitsPerPixel = 32 },
            programName,
            c.sfDefaultStyle,
            &settings,
        ) orelse return error.WindowCreationFailed;

        c.sfRenderWindow_setVerticalSyncEnabled(result.handle, if (options.vsync) c.sfTrue else c.sfFalse);
        c.sfRenderWindow_setFramerateLimit(result.handle, options.targetFPS);
        c.sfRenderWindow_setSize(result.handle, .{ .x = width * options.scale, .y = height * options.scale });
        c.sfRenderWindow_setKeyRepeatEnabled(result.handle, if (options.keyRepeat) c.sfTrue else c.sfFalse);
        c.sfRenderWindow_setMouseCursorVisible(result.handle, if (options.mouseVisible) c.sfTrue else c.sfFalse);
        c.sfRenderWindow_setMouseCursorGrabbed(result.handle, if (options.mouseGrabbed) c.sfTrue else c.sfFalse);

        return result;
    }

    pub fn deinit(self: Self) void {
        c.sfRenderWindow_destroy(self.handle);
    }

    pub fn addInput(self: *Self) void {
        self.input = Input.init(self);
    }

    pub fn isOpen(self: Self) bool {
        return c.sfRenderWindow_isOpen(self.handle) == c.sfTrue;
    }

    pub fn getActualSize(self: Self) m.Vec2 {
        var size = c.sfRenderWindow_getSize(self.handle);
        return .{ .x = @intToFloat(f32, size.x), .y = @intToFloat(f32, size.y) };
    }

    pub fn pollEvents(self: *Self) void {
        for (self.input.mouseButtons) |*button|
            button.wasDown = button.isDown;

        for (self.input.keys) |*key|
            key.wasDown = key.isDown;

        var event: c.sfEvent = undefined;
        while (c.sfRenderWindow_pollEvent(self.handle, &event) == c.sfTrue) {
            switch (event.type) {
                c.sfEvtClosed => c.sfRenderWindow_close(self.handle),

                c.sfEvtMouseButtonPressed, c.sfEvtMouseButtonReleased => {
                    const pressed = if (event.type == c.sfEvtMouseButtonPressed) true else false;

                    switch (event.mouseButton.button) {
                        c.sfMouseLeft => self.input.setMouseButton(.left, pressed),
                        c.sfMouseRight => self.input.setMouseButton(.right, pressed),
                        c.sfMouseMiddle => self.input.setMouseButton(.middle, pressed),
                        else => {},
                    }
                },

                c.sfEvtKeyPressed, c.sfEvtKeyReleased => {
                    if (event.key.code == c.sfKeyEscape)
                        c.sfRenderWindow_close(self.handle);

                    const pressed = if (event.type == c.sfEvtKeyPressed) true else false;
                    _ = pressed;

                    switch (event.key.code) {
                        c.sfKeyA => self.input.setKey(.a, pressed),
                        c.sfKeyB => self.input.setKey(.b, pressed),
                        c.sfKeyC => self.input.setKey(.c, pressed),
                        c.sfKeyD => self.input.setKey(.d, pressed),
                        c.sfKeyE => self.input.setKey(.e, pressed),
                        c.sfKeyF => self.input.setKey(.f, pressed),
                        c.sfKeyG => self.input.setKey(.g, pressed),
                        c.sfKeyH => self.input.setKey(.h, pressed),
                        c.sfKeyI => self.input.setKey(.i, pressed),
                        c.sfKeyJ => self.input.setKey(.j, pressed),
                        c.sfKeyK => self.input.setKey(.k, pressed),
                        c.sfKeyL => self.input.setKey(.l, pressed),
                        c.sfKeyM => self.input.setKey(.m, pressed),
                        c.sfKeyN => self.input.setKey(.n, pressed),
                        c.sfKeyO => self.input.setKey(.o, pressed),
                        c.sfKeyP => self.input.setKey(.p, pressed),
                        c.sfKeyQ => self.input.setKey(.q, pressed),
                        c.sfKeyR => self.input.setKey(.r, pressed),
                        c.sfKeyS => self.input.setKey(.s, pressed),
                        c.sfKeyT => self.input.setKey(.t, pressed),
                        c.sfKeyU => self.input.setKey(.u, pressed),
                        c.sfKeyV => self.input.setKey(.v, pressed),
                        c.sfKeyW => self.input.setKey(.w, pressed),
                        c.sfKeyX => self.input.setKey(.x, pressed),
                        c.sfKeyY => self.input.setKey(.y, pressed),
                        c.sfKeyZ => self.input.setKey(.z, pressed),
                        else => {},
                    }
                },

                else => {},
            }
        }
    }
};
