const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cInclude("dmsdk/lua/lauxlib.h");
    @cInclude("dmsdk/extension/extension.h");
    @cInclude("dmsdk/dlib/configfile.h");
});

var g_ExtensionDesc: [256]u8 = undefined;
var g_ConfigFile: c.HConfigFile = undefined;

fn rot13_char(ch: u8) u8 {
    return switch (ch) {
        'a'...'m', 'A'...'M' => |_ch| _ch + 13,
        'n'...'z', 'N'...'Z' => |_ch| _ch - 13,
        else => |_ch| _ch,
    };
}

fn Rot13(L: ?*c.lua_State) callconv(.C) i32 {
    var msglen: usize = 0;
    var msg: [*c]const u8 = c.luaL_checklstring(L, 1, &msglen);

    const t: []u8 = std.heap.c_allocator.alloc(u8, msglen) catch "";
    std.mem.copy(u8, t, msg[0..msglen]);

    var i: usize = 0;
    while (i < t.len) : (i += 1) {
        t[i] = rot13_char(msg[i]);
    }

    c.lua_pushstring(L, t.ptr);
    return 1;
}

fn GetInfo(L: ?*c.lua_State) callconv(.C) i32 {

    c.lua_newtable(L);

    var s: [*c]const u8 = c.ConfigFileGetString(g_ConfigFile, "test.string", null);
    if (s != null)
    {
        c.lua_pushstring(L, s);
        c.lua_setfield(L, -2, "s");
    }

    var i: i32 = c.ConfigFileGetInt(g_ConfigFile, "test.int", -1);
    if (i != -1)
    {
        c.lua_pushinteger(L, i);
        c.lua_setfield(L, -2, "i");
    }

    var f: f32 = c.ConfigFileGetFloat(g_ConfigFile, "test.float", -1);
    if (f != -1)
    {
        c.lua_pushnumber(L, f);
        c.lua_setfield(L, -2, "f");
    }

    return 1;
}

const Module_methods = [_]c.luaL_Reg{
    .{ .name = "rot13", .func = &Rot13 },
    .{ .name = "get_info", .func = &GetInfo },
    .{ .name = 0, .func = null }
};

fn RegisterModule(L: ?*c.lua_State) void {
    c.luaL_register(L, "encoder_zig", &Module_methods[0]);
    c.lua_pop(L, 1);
}

fn Initialize(params: ?*c.ExtensionParams) callconv(.C) c_int {
    const L: ?*c.lua_State = params.?.m_L;
    RegisterModule(L);

    g_ConfigFile = params.?.m_ConfigFile;

    std.debug.print("Registered ExtensionZig", .{});
    return c.EXTENSION_RESULT_OK;
}

fn Finalize(params: ?*c.ExtensionParams) callconv(.C) c_int {
    _ = params; // unused
    return c.EXTENSION_RESULT_OK;
}

fn Update(params: ?*c.ExtensionParams) callconv(.C) c_int {
    _ = params; // unused
    return c.EXTENSION_RESULT_OK;
}

// The `name: "ExtensionZig"` in ext.manifest, makes the engine call this function upon starting the engine
export fn ExtensionZig() callconv(.C) void {
    c.ExtensionRegister(@ptrCast(&g_ExtensionDesc), g_ExtensionDesc.len, "ExtensionZig",
                        null, null, Initialize, Finalize, Update, null);
}
