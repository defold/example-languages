using System.Runtime.InteropServices;
using System.Reflection.Emit;

using dmSDK.Dlib;
using dmSDK.Extension;
using dmSDK.Lua;

// naming conventions: https://stackoverflow.com/a/1618325/468516

public unsafe partial class CS
{
    private static ConfigFile.Config* g_ConfigFile = null;

    // ***************************************************************************

    // From https://x.com/Meetem4
    private static char shift(char c) {
        return char.ToLower(c) switch {
            >= 'a' and <= 'm' => (char)(c + 13),
            >= 'n' and <= 'z' => (char)(c - 13),
            var _ => c
        };
    }

    // From https://x.com/Meetem4
    [UnmanagedCallersOnly]
    private static int Rot13(Lua.State* L)
    {
        String s = LuaL.checkstring(L, 1);
        Span<char> newStringChars = stackalloc char[s.Length];
        for (int i = 0; i < s.Length; i++)
            newStringChars[i] = shift(s[i]);

        String encoded = new string(newStringChars);
        Lua.pushstring(L, encoded);
        return 1;
    }

    [UnmanagedCallersOnly]
    private static int TestGC(Lua.State* L)
    {
        Console.WriteLine("Calling System.GC.Collect()");
        System.GC.Collect();
        return 0;
    }

    // ***************************************************************************

    [UnmanagedCallersOnly]
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

    [UnmanagedCallersOnly]
    static private int CSExtensionAppInitialize(Extension.AppParams* parameters)
    {
        g_ConfigFile = parameters->ConfigFile;
        return 0; // TODO: Return dmsdk ExtensionResult enum
    }

    [UnmanagedCallersOnly]
    static private int CSExtensionAppFinalize(Extension.AppParams* parameters)
    {
        return 0;
    }

    [UnmanagedCallersOnly]
    static private int CSExtensionInitialize(Extension.Params* parameters)
    {
        // Register a new Lua module
        LuaL.RegHelper[] functions = {
            new() {name = "rot13", func = (IntPtr)(delegate* unmanaged<Lua.State*,int>)&Rot13},
            new() {name = "get_info", func = (IntPtr)(delegate* unmanaged<Lua.State*,int>)&GetInfo},
            new() {name = "test_gc", func = (IntPtr)(delegate* unmanaged<Lua.State*,int>)&TestGC},
            new() {name = null, func = 0}
        };

        LuaL.Register(parameters->L, "encoder_cs", functions);
        Lua.pop(parameters->L, 1);

        Console.WriteLine("Registered ExtensionCSharp");
        return 0;
    }

    [UnmanagedCallersOnly]
    static private int CSExtensionFinalize(Extension.Params* parameters)
    {
        Console.WriteLine(String.Format("    CS: Extension Finalize!"));
        return 0;
    }

    [UnmanagedCallersOnly]
    static private int CSExtensionUpdate(Extension.Params* updateParams)
    {
        System.GC.Collect();
        return 0;
    }

    // ************************************************************

    private static System.Runtime.InteropServices.GCHandle g_ExtensionBlob;

    private static void CsRegisterExtensionInternal()
    {
        Console.WriteLine("Register internal");

        String s = new String("Hello");
        Console.WriteLine(s);
        s = null;

        Console.WriteLine("Calling System.GC.Collect()");
        System.GC.Collect();


        IntPtr app_initialize = (IntPtr)(delegate* unmanaged<Extension.AppParams*,int>)&CSExtensionAppInitialize;
        IntPtr app_finalize = (IntPtr)(delegate* unmanaged<Extension.AppParams*,int>)&CSExtensionAppFinalize;
        IntPtr initialize = (IntPtr)(delegate* unmanaged<Extension.Params*,int>)&CSExtensionInitialize;
        IntPtr finalize = (IntPtr)(delegate* unmanaged<Extension.Params*,int>)&CSExtensionFinalize;
        IntPtr update = (IntPtr)(delegate* unmanaged<Extension.Params*,int>)&CSExtensionUpdate;
        IntPtr on_event = 0;//(IntPtr)(delegate* unmanaged<Extension.Params*,void>)&CSExtensionOnEvent;

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
