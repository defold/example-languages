using System.Runtime.InteropServices;
using System.Reflection.Emit;

using dmSDK.Dlib;
using dmSDK.Extension;
using dmSDK.Lua;

// naming conventions: https://stackoverflow.com/a/1618325/468516

public unsafe partial class CS
{
    private static ConfigFile.Config* g_ConfigFile = null;

    // From Rosetta: https://rosettacode.org/wiki/Rot-13#C#
    private static char shift(char c) {
        return c.ToString().ToLower().First() switch {
            >= 'a' and <= 'm' => (char)(c + 13),
            >= 'n' and <= 'z' => (char)(c - 13),
            var _ => c
        };
    }

    private static int Rot13(Lua.State* L)
    {
        String s = LuaL.checkstring(L, 1);
        String encoded = new string(s.Select(c => shift(c)).ToArray());
        Lua.pushstring(L, encoded);
        return 1;
    }

    private static int GetInfo(Lua.State* L)
    {
        Lua.newtable(L);

        string s = ConfigFile.GetString(g_ConfigFile, "test.string", null);
        if (s != null)
        {
            Lua.pushstring(L, s);
            Lua.setfield(L, -2, "s");
        }
        int i = ConfigFile.GetInt(g_ConfigFile, "test.int", -1);
        if (i != -1)
        {
            Lua.pushinteger(L, i);
            Lua.setfield(L, -2, "i");
        }
        float f = ConfigFile.GetFloat(g_ConfigFile, "test.float", -1);
        if (f != -1)
        {
            Lua.pushnumber(L, f);
            Lua.setfield(L, -2, "f");
        }
        return 1;
    }

    static private int CSExtensionAppInitialize(ref Extension.AppParams parameters)
    {
        g_ConfigFile = parameters.ConfigFile;
        return 0; // TODO: Return dmsdk ExtensionResult enum
    }

    static private int CSExtensionAppFinalize(ref Extension.AppParams parameters)
    {
        return 0;
    }

    static private int CSExtensionInitialize(ref Extension.Params parameters)
    {
        // Register a new Lua module
        LuaL.RegHelper[] functions = {
            new() {name = "rot13", func = Extension.GetFunctionPointer(Rot13)},
            new() {name = "get_info", func = Extension.GetFunctionPointer(GetInfo)},
            new() {name = null, func = 0}
        };

        LuaL.Register(parameters.L, "encoder_cs", functions);
        Lua.pop(parameters.L, 1);

        Console.WriteLine("Registered ExtensionCSharp");
        return 0;
    }

    static private int CSExtensionFinalize(ref Extension.Params parameters)
    {
        Console.WriteLine(String.Format("    CS: Extension Finalize!"));
        return 0;
    }

    static private int CSExtensionUpdate(ref Extension.Params updateParams)
    {
        return 0;
    }

    // ************************************************************

    private static System.Runtime.InteropServices.GCHandle g_ExtensionBlob;

    private static void CsRegisterExtensionInternal()
    {
        IntPtr app_initialize = Extension.GetFunctionPointer(CSExtensionAppInitialize);
        IntPtr app_finalize = Extension.GetFunctionPointer(CSExtensionAppFinalize);;
        IntPtr initialize = Extension.GetFunctionPointer(CSExtensionInitialize);;
        IntPtr finalize = Extension.GetFunctionPointer(CSExtensionFinalize);;
        IntPtr update = Extension.GetFunctionPointer(CSExtensionUpdate);;
        IntPtr on_event = 0;//Extension.GetFunctionPointer(CSExtensionOnEvent);;

        g_ExtensionBlob = GCHandle.Alloc(new byte[256], GCHandleType.Pinned);

        Extension.Register((void*)g_ExtensionBlob.AddrOfPinnedObject(), 256,
                            "ExtensionCSharp",
                            app_initialize,
                            app_finalize,
                            initialize,
                            finalize,
                            update,
                            on_event);
    }

    [UnmanagedCallersOnly(EntryPoint = "ExtensionCSharp")]
    public static void ExtensionCSharp()
    {
        CsRegisterExtensionInternal();
    }
}
