// include the Defold SDK
#include <dmsdk/sdk.h>

static int Encode(lua_State* L)
{
    // The number of expected items to be on the Lua stack
    // once this struct goes out of scope
    int top = lua_gettop(L);

    // Check and get parameter string from stack
    size_t len;
    const char* original = (const char*)luaL_checklstring(L, 1, &len);

    char* str = strdup(original);

    for(int i = 0; i < len; ++i) {
        str[i] = str[i]+1;
    }
    lua_pushstring(L, str);
    free((void*)str);
    return 1; // Return 1 item
}

// Functions exposed to Lua
static const luaL_reg Module_methods[] =
{
    {"encode", Encode},
    {0, 0}
};

static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);

    // Register lua names
    luaL_register(L, "encoder", Module_methods);

    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

static dmExtension::Result AppInitializeMyExtension(dmExtension::AppParams* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result InitializeMyExtension(dmExtension::Params* params)
{
    // Init Lua
    LuaInit(params->m_L);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeMyExtension(dmExtension::AppParams* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result FinalizeMyExtension(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

static dmExtension::Result OnUpdateMyExtension(dmExtension::Params* params)
{
    return dmExtension::RESULT_OK;
}

DM_DECLARE_EXTENSION(ExtensionCPP, "ExtensionCPP", AppInitializeMyExtension, AppFinalizeMyExtension, InitializeMyExtension, OnUpdateMyExtension, 0, FinalizeMyExtension)
