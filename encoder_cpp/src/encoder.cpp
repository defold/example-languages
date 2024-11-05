// include the Defold SDK
#include <dmsdk/sdk.h>
#include <dmsdk/dlib/configfile.h>
#include <dmsdk/dlib/time.h>
#include <assert.h>

static HConfigFile g_ConfigFile = 0;

static inline char tolower(char c)
{
    return c | 32; // adds
}

static char shift(char c)
{
    // Make sure it's lower case
    char l = tolower(c);
    if (l >= 'a' && l <= 'm') return c + 13;
    if (l >= 'n' && l <= 'z') return c - 13;
    return c;
}

static char* rot13(const char* input, size_t len, char* out)
{
    for (size_t i = 0; i < len; ++i)
    {
        out[i] = shift(input[i]);
    }
    return out;
}

static int g_CountRot13 = 0;
static int g_CountAdd = 0;
static uint64_t g_TimeRot13 = 0;
static uint64_t g_TimeAdd = 0;

static int Rot13(lua_State* L)
{
    // ++g_CountRot13;
    // uint64_t t_start = dmTime::GetTime();

    // The number of expected items to be on the Lua stack
    // once this struct goes out of scope
    int top = lua_gettop(L);

    // Check and get parameter string from stack
    size_t len;
    const char* original = (const char*)luaL_checklstring(L, 1, &len);
    char* mem = 0;
    char* out = 0;
    if (len > 1024)
    {
        mem = out = (char*)malloc(len+1);
    }
    else
    {
        out = (char*)alloca(len+1);
    }

    out[len] = 0;
    lua_pushstring(L, rot13(original, len, out));
    free(mem);

    assert((top + 1) == lua_gettop(L));

    // uint64_t t_end = dmTime::GetTime();
    // g_TimeRot13 += t_end - t_start;
    return 1; // Return 1 item
}

static int Add(lua_State* L)
{
    // ++g_CountAdd;
    // uint64_t t_start = dmTime::GetTime();

    int top = lua_gettop(L);
    double a = luaL_checknumber(L, 1);
    double b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);

    assert((top + 1) == lua_gettop(L));

    // uint64_t t_end = dmTime::GetTime();
    // g_TimeAdd += t_end - t_start;
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
    {"add", Add},
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
    // printf("MAWE: g_CountRot13: %d in %g s\n", g_CountRot13, g_TimeRot13 / 1000000.0 );
    // printf("MAWE: g_CountAdd: %d in %g s\n", g_CountAdd, g_TimeAdd / 1000000.0);
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
