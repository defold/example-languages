// include the Defold SDK
#include <dmsdk/sdk.h>
#include <dmsdk/dlib/configfile.h>
#include <assert.h>

static HConfigFile g_ConfigFile = 0;

static int isupper(char c)
{
    return (c >= 65 && c <= 90); // 65='A', 90='Z'
}

static int islower(char c)
{
    return (c >= 97 && c <= 122); // 97='a', 122='z'
}

static char* rot13(const char* input, size_t len, char* out)
{
    const char upper[] = "NOPQRSTUVWXYZABCDEFGHIJKLM"; // 65='A', 90='Z'
    const char lower[] = "nopqrstuvwxyzabcdefghijklm"; // 97='a', 122='z'

    for (size_t i = 0; i < len; ++i)
    {
        char c = input[i];
        if (isupper(c))
            c = upper[c - 65];
        else if (islower(c))
            c = lower[c - 97];
        out[i] = c;
    }
    return out;
}

static int Rot13(lua_State* L)
{
    // The number of expected items to be on the Lua stack
    // once this struct goes out of scope
    int top = lua_gettop(L);

    // Check and get parameter string from stack
    size_t len;
    const char* original = (const char*)luaL_checklstring(L, 1, &len);
    char* str = strdup(original);
    lua_pushstring(L, rot13(original, len, str));
    free((void*)str);

    assert((top + 1) == lua_gettop(L));
    return 1; // Return 1 item
}

static int GetInfo(lua_State* L)
{
    int top = lua_gettop(L);

    lua_newtable(L);

    const char* s = ConfigFileGetString(g_ConfigFile, "test.string", 0);
    if (s != 0)
    {
        lua_pushstring(L, s);
        lua_setfield(L, -2, "s");
    }

    float f = ConfigFileGetFloat(g_ConfigFile, "test.float", -1);
    if (f != -1)
    {
        lua_pushnumber(L, f);
        lua_setfield(L, -2, "f");
    }

    int i = ConfigFileGetInt(g_ConfigFile, "test.int", -1);
    if (i != -1)
    {
        lua_pushinteger(L, i);
        lua_setfield(L, -2, "i");
    }

    assert((top + 1) == lua_gettop(L));
    return 1; // Return 1 item
}

// Functions exposed to Lua
static const luaL_reg Module_methods[] =
{
    {"rot13", Rot13},
    {"get_info", GetInfo},
    {0, 0}
};

static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);

    // Register lua names
    luaL_register(L, "encoder_cpp", Module_methods);

    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

static dmExtension::Result AppInitializeMyExtension(dmExtension::AppParams* params)
{
    g_ConfigFile = params->m_ConfigFile;
    return dmExtension::RESULT_OK;
}

static dmExtension::Result InitializeMyExtension(dmExtension::Params* params)
{
    // Init Lua
    LuaInit(params->m_L);
    printf("Registered ExtensionCPP\n");
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
