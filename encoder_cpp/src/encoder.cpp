// include the Defold SDK
#include <dmsdk/sdk.h>

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

        // if ((input[i] > 64 && input[i] < 91) || (input[i] > 96 && input[i] < 123))
        // {
        //     input[i] = (input[i] - 65 > 25) ? lower[input[i] - 97] : upper[input[i] - 65];
        // }
        // else {
        //     out[i] = input[i];
        // }
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
    return 1; // Return 1 item
}

// Functions exposed to Lua
static const luaL_reg Module_methods[] =
{
    {"rot13", Rot13},
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
