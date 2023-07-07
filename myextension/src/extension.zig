const std = @import("std");
const print = std.debug.print;


const c = @cImport({
    @cInclude("lua/lauxlib.h");
    @cInclude("dmsdk/extension/extension.h");
});

const ZigPluginContext = struct {
    some_value: i32,
};

fn Decode(L: ?*c.lua_State) callconv(.C) i32 {
    var msglen : usize = 0;
    var msg : [*c]const u8 = c.luaL_checklstring(L, 1, &msglen);

    const t : []u8 = std.heap.c_allocator.alloc(u8, msglen) catch "";
    std.mem.copy(u8, t, msg[0..msglen]);

    var i : usize = 0;
    while (i < msglen) : (i += 1) {
        t[i] -= 1;
    }

    c.lua_pushstring(L, t.ptr);
    return 1;
}

const Module_methods = [_]c.luaL_Reg{
    .{.name = "decode", .func = &Decode},
    .{.name = 0, .func = null}
};

fn RegisterModule(L: ?*c.lua_State) void {
    c.luaL_register(L, "pluginzig", &Module_methods[0]);
    c.lua_pop(L, 1);
}

fn PluginInit(name: [*c]const u8, L: ?*c.lua_State) callconv(.C) ?*anyopaque {
    print("    PluginZIG: PluginInit {s} {*}\n", .{name, L});
    const ctx : *ZigPluginContext = std.heap.c_allocator.create(ZigPluginContext) catch return null;
    ctx.some_value = 0;
    RegisterModule(L);
    return @ptrCast(ctx);
}

fn PluginFinalize(_plugin: ?*anyopaque) callconv(.C) void {
    const plugin : *ZigPluginContext = @ptrCast(@alignCast(_plugin));
    print("    PluginZIG: PluginFinalize {*}\n", .{plugin});
    std.heap.c_allocator.destroy(plugin);
}

fn PluginUpdate(_plugin: ?*anyopaque) callconv(.C) void {
    const plugin : *ZigPluginContext = @ptrCast(@alignCast(_plugin));
    plugin.some_value += 1;
    print("    PluginZIG: PluginUpdate {}\n", .{plugin.some_value});
}

// typedef dmExtensionResult (*FExtensionAppInit)(dmExtensionAppParams*);
// typedef dmExtensionResult (*FExtensionAppFinalize)(dmExtensionAppParams*);
// typedef dmExtensionResult (*FExtensionInitialize)(dmExtensionAppParams*);
// typedef dmExtensionResult (*FExtensionFinalize)(dmExtensionAppParams*);
// typedef dmExtensionResult (*FExtensionUpdate)(dmExtensionAppParams*);
// typedef void              (*FExtensionOnEvent)(dmExtensionParams*, const dmExtensionEvent*);

// typedef dmExtensionResult (*dmExtensionFCallback)(dmExtensionParams* params);

export fn PluginZIG() callconv(.C) void {
    const plugin : ?*c.dmExtensionDesc = std.heap.c_allocator.create(c.dmExtensionDesc) catch null;
    // void dmExtensionRegister(struct dmExtensionDesc* desc,
    // uint32_t desc_size,
    // const char *name,
    // FExtensionAppInit       app_init,
    // FExtensionAppFinalize   app_finalize,
    // FExtensionInitialize    initialize,
    // FExtensionFinalize      finalize,
    // FExtensionUpdate        update,
    // FExtensionOnEvent       on_event);

    //c.plugin_registerPlugin(plugin, "PluginZIG", PluginCreate, PluginDestroy, PluginUpdate);
    c.dmExtensionRegister(plugin, @bitSizeOf(c.dmExtensionDesc), "PluginZIG",
                null, null, PluginInit, PluginFinalize, PluginUpdate, null);
}

export const mod_init_func_ptr linksection("__DATA,__mod_init_func") = &PluginZIG; // note the & op
