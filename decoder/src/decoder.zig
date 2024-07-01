const std = @import("std");
const print = std.debug.print;

const c = @cImport({
    @cInclude("dmsdk/lua/lauxlib.h");
    @cInclude("dmsdk/extension/extension.h");
});

var g_ExtensionDesc: [256]u8 = undefined;

fn Decode(L: ?*c.lua_State) callconv(.C) i32 {
    var msglen: usize = 0;
    var msg: [*c]const u8 = c.luaL_checklstring(L, 1, &msglen);

    const t: []u8 = std.heap.c_allocator.alloc(u8, msglen) catch "";
    std.mem.copy(u8, t, msg[0..msglen]);

    var i: usize = 0;
    while (i < msglen) : (i += 1) {
        t[i] -= 1;
    }

    c.lua_pushstring(L, t.ptr);
    return 1;
}

const Module_methods = [_]c.luaL_Reg{ .{ .name = "decode", .func = &Decode }, .{ .name = 0, .func = null } };

fn RegisterModule(L: ?*c.lua_State) void {
    c.luaL_register(L, "decoder", &Module_methods[0]);
    c.lua_pop(L, 1);
}

fn Initialize(params: ?*c.ExtensionParams) callconv(.C) c_int {
    const L: ?*c.lua_State = params.?.m_L;
    RegisterModule(L);
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

// The "ExtensionZIG" in ext.manifest, makes the engine call this function upon starting the engine
export fn ExtensionZIG() callconv(.C) void {
    //@memset(&g_ExtensionDesc, 0);
    c.ExtensionRegister(@ptrCast(&g_ExtensionDesc), g_ExtensionDesc.len, "ExtensionZIG", null, null, Initialize, Finalize, Update, null);
}
