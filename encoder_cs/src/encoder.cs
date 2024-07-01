using System.Runtime.InteropServices;
using System.Reflection.Emit;

using dmSDK.Dlib;
using dmSDK.Extension;
using dmSDK.Lua;

// naming conventions: https://stackoverflow.com/a/1618325/468516

public unsafe class CS
{
    static public string EXTENSION_NAME = "my_cs_extension";

    private static int CsLuaAdd(Lua.State* L)
    {
        Console.WriteLine("    CS: CsLuaAdd");
        int a = LuaL.checkinteger(L, 1);
        int b = LuaL.checkinteger(L, 2);
        Lua.pushinteger(L, a + b);
        return 1;
    }

    private static int CsLuaDecode(Lua.State* L)
    {
        String s = LuaL.checkstring(L, 1);

        char[] buffer = s.ToCharArray();
        for (int i = 0; i < buffer.Length; ++i)
        {
            buffer[i] = (char)(buffer[i] - 1);
        }

        Lua.pushstring(L, new String(buffer));
        return 1;
    }

    static private int CSExtensionAppInitialize(ref Extension.AppParams parameters)
    {
        if (parameters.ConfigFile != null)
        {
            Console.WriteLine(String.Format("    CS: ConfigFile ptr: {0}", (IntPtr)parameters.ConfigFile));

            string str = ConfigFile.GetString(parameters.ConfigFile, "test.string", "default");
            Console.WriteLine(String.Format("    CS: Extension App Initialize! {0} = {1}", "test.string", str));

            int i = ConfigFile.GetInt(parameters.ConfigFile, "test.int", -1);
            Console.WriteLine(String.Format("    CS: Extension App Initialize! {0} = {1}", "test.int", i));

            float f = ConfigFile.GetFloat(parameters.ConfigFile, "test.float", -1);
            Console.WriteLine(String.Format("    CS: Extension App Initialize! {0} = {1}", "test.float", f));
        }

        Console.WriteLine(String.Format("    CS: Extension App Initialize done!"));
        return 0; // TODO: Return dmsdk ExtensionResult enum
    }

    static private int CSExtensionAppFinalize(ref Extension.AppParams parameters)
    {
        Console.WriteLine(String.Format("    CS: Extension App Finalize!"));
        return 0;
    }

    static private int CSExtensionInitialize(ref Extension.Params parameters)
    {
        Console.WriteLine(String.Format("    CS: Extension Initialize!"));

        // Register a new Lua module
        LuaL.RegHelper[] functions = {
            new() {name = "add", func = Extension.GetFunctionPointer(CsLuaAdd)},
            new() {name = "decode", func = Extension.GetFunctionPointer(CsLuaDecode)},
            new() {name = null, func = 0}
        };

        LuaL.Register(parameters.L, "decoder_cs", functions);
        Lua.pop(parameters.L, 1);

        Console.WriteLine("Registered decoder_cs extension");
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
        Console.WriteLine("CsRegisterExtensionInternal!");

        IntPtr app_initialize = Extension.GetFunctionPointer(CSExtensionAppInitialize);
        IntPtr app_finalize = Extension.GetFunctionPointer(CSExtensionAppFinalize);;
        IntPtr initialize = Extension.GetFunctionPointer(CSExtensionInitialize);;
        IntPtr finalize = Extension.GetFunctionPointer(CSExtensionFinalize);;
        IntPtr update = Extension.GetFunctionPointer(CSExtensionUpdate);;
        IntPtr on_event = 0;//Extension.GetFunctionPointer(CSExtensionOnEvent);;

        g_ExtensionBlob = GCHandle.Alloc(new byte[256], GCHandleType.Pinned);

        Extension.Register((void*)g_ExtensionBlob.AddrOfPinnedObject(), 256,
                            EXTENSION_NAME,
                            app_initialize,
                            app_finalize,
                            initialize,
                            finalize,
                            update,
                            on_event);
    }

    [UnmanagedCallersOnly(EntryPoint = "ExtensionCSharp")]
    public static void ExtensionCSharp()
    {sdf
        CsRegisterExtensionInternal();
    }
}
