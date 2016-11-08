#include "LWinProc.h"
#include "CCLuaEngine.h"
#include "CCLuaStack.h"

extern "C" {
#include "lua.h"
}

int LWinProc::execute(UINT message, WPARAM wParam, LPARAM lParam)
{
    CCLuaStack *stack = CCLuaEngine::defaultEngine()->getLuaStack();

    lua_State *l = stack->getLuaState();
    
    // call global lua function LWINPROC_HOOK
    lua_getglobal(l, "LWINPROC_HOOK");

    if (!lua_isfunction(l, -1))
    {
        CCLOG("[LUA ERROR] name '%s' does not represent a Lua function", "LWINPROC_HOOK");
        lua_pop(l, 1);
        return 0;
    }

    lua_pushinteger(l, (lua_Integer)message);
    lua_pushinteger(l, (lua_Integer)wParam);
    lua_pushinteger(l, (lua_Integer)lParam);
    return stack->executeFunction(3);
}