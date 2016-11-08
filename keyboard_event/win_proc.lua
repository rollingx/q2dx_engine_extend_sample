--[[
	按下alt键时触发的是WM_SYSKEYDOWN, WM_SYSKEYUP事件,不触发KEYDOWN, KEYUP事件.
]]

--[[
	F1			|		试阵
	F2			|		run test.lua
	F4			|		kill all building
				|
	page up 	|		zoom in
	page down 	|		zoom out
				|
	arrow_up	|		move up
	arrow_down	|		move down
	arrow_left	|		move left
	arrow_right	|		move right
				|
	pause 		|		pause/resume
				|
	ctrl+d 		|		open/close rpc delay
	ctrl+p 		|		take screen shot
	ctrl+r 		|		reload this script(after modify)
				|
	+			|		add fps
	-			|		sub fps
]]


local WIN_MESSAGE = {
	-- key board event
	WM_KEYDOWN = 0x0100,
	WM_KEYUP = 0x0101,
	WM_SYSKEYDOWN = 0x0104,
	WM_SYSKEYUP = 0x0105,
	-- mouse event
	WM_MOUSEMOVE = 0x0200,
	WM_LBUTTONDOWN = 0x0201,
	WM_LBUTTONUP = 0x0202,
	WM_LBUTTONDBLCLK = 0x0203,
	WM_RBUTTONDOWN = 0x0204,
	WM_RBUTTONUP = 0x0205,
	WM_RBUTTONDBLCLK = 0x0206,
	WM_MBUTTONDOWN = 0x0207,
	WM_MBUTTONUP = 0x0208,
	WM_MBUTTONDBLCLK = 0x0209,
	WM_MOUSEWHEEL = 0x020A,
}

-- 虚拟键码表
local VK_CONST = {
	VK_F1 = 0x70,
	VK_F2 = 0x71,
	VK_F3 = 0x72,
	VK_F4 = 0x73,
	VK_F5 = 0x74,
	VK_F6 = 0x75,
	VK_F7 = 0x76,
	VK_F8 = 0x77,
	VK_F9 = 0x78,
	VK_F10 = 0x79,
	VK_F11 = 0x7a,
	VK_F12 = 0x7b,

	VK_PRIOR = 0x21,	--Page Up
	VK_NEXT = 0x22,	--Page Down

	VK_LEFT = 0x25,
	VK_UP = 0x26,
	VK_RIGHT = 0x27,
	VK_DOWN = 0x28,

	VK_PAUSE = 0x13,

	VK_OEM_PLUS = 0xbb,
	VK_OEM_MINUS = 0xbd,

	VK_SNAPSHOT = 44, -- not working, don't know why

	VK_A = 0x41,
	VK_D = 0x44,
	VK_G = 0x47,
	VK_P = 0x50,
	VK_R = 0x52,

	VK_SHIFT = 0x10,
	VK_CTRL = 0x11,
	VK_ALT = 0x12,

	VK_ESC = 0x1b,
}

local press_down_key_map = {}


local function f_vk_f1()
	server.rpc_server_fight_friend(user:getUid())
end

local function f_vk_f2()
	xpcall(function()dofile("scripts/test.lua")end, __G__TRACKBACK__)
end

local function f_vk_f3()
end

local function f_vk_f4()
	-- kill all building
	local buildingLayer = game.getBuildingLayer()
	local buildings = buildingLayer:getAliveBuildings()
    for index, building in pairs(buildings) do
       	building:hurt(100000, nil, nil)
    end
end

local function f_vk_f5()
end

local function f_vk_f6()
end

local function f_vk_f7()
end

local function f_vk_f8()
end

local function f_vk_f9()
end

local function f_vk_f10()
end

local function f_vk_f11()
end

local function f_vk_f12()
end

local function _getScale()
	local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
	for k, v in pairs(scene.scaleLayer) do
		return v:getScale()
	end
end

local function _getPosition()
    local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
	for k, v in pairs(scene.scaleLayer) do
		return {v:getPosition()}
	end	
end

local function _fitScale(newScale)
	local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
	local scaleScope = scene:getScaleScope()
	return math.max(scaleScope.min, math.min(scaleScope.max, newScale))
end

local function _fitPosition(newPos)
    local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
	local posScope	= game:getMapLayer():getPositionScope()
	return scene:checkAndGetSuitablePosition(newPos.x, newPos.y, posScope.minX,
                posScope.maxX, posScope.minY, posScope.maxY)
end

local POW_2_8 = math.pow(2, 16)

local function _getXYByLParam(lParam)
	return lParam%POW_2_8, lParam/POW_2_8
end

local _scale = 0.5
local _position = {0,0}

local function isCanScale()
	local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not (scene and scene.scaleLayer and scene.getScaleScope) then return false end
    return true
end

local function isCanMove()
	local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not (scene and scene.scaleLayer and game:getMapLayer() and game:getMapLayer().getPositionScope) then return false end
    return true
end

local function f_vk_pageup()
	local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not scene then return end
    _scale = _getScale()
	_scale = (_scale + 0.1) or 0.5
	_scale = _fitScale(_scale)
	scene:scaleTo(_scale)
    _position = _getPosition()
    scene:positionTo(_fitPosition(ccp(_position[1], _position[2])))
	print("current scale = ".._scale)
end

local function f_vk_pagedown()
	local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not scene then return end
	_scale = _getScale()
	_scale = (_scale - 0.1) or 0.5
	_scale = _fitScale(_scale)
	scene:scaleTo(_scale)
    _position = _getPosition()
    scene:positionTo(_fitPosition(ccp(_position[1], _position[2])))
	print("current scale = ".._scale)
end

local position_step = 40

local function f_vk_left()
    local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not scene then return end
    _position = _getPosition()
    scene:positionTo(_fitPosition(ccp(_position[1] + position_step, _position[2])))
end

local function f_vk_right()
    local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not scene then return end
	_position = _getPosition()
    scene:positionTo(_fitPosition(ccp(_position[1] - position_step, _position[2])))
end

local function f_vk_up()
    local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not scene then return end
	_position = _getPosition()
	
    scene:positionTo(_fitPosition(ccp(_position[1], _position[2] - position_step)))
end

local function f_vk_down()
    local sharedDirector = CCDirector:sharedDirector()
    local scene = sharedDirector:getRunningScene()
    if not scene then return end
	_position = _getPosition()
    scene:positionTo(_fitPosition(ccp(_position[1], _position[2] + position_step)))
end

local bPaused = false
local function f_vk_pause_resume()
	if bPaused then
		CCDirector:sharedDirector():resume()
	else
	 	CCDirector:sharedDirector():pause()
	end
	bPaused = not bPaused
end
--only work while fighting
local speed = 1
local function f_vk_oem_plus()
	speed = speed * 2
	speed = math.min(8, speed)
	if gFrameRate then
		CCDirector:sharedDirector():setAnimationInterval(1/(gFrameRate*speed))
	end
	print("current game speed X"..speed)
end

local function f_vk_oem_minus()
	speed = speed / 2
	speed = math.max(1/8, speed)
	if gFrameRate then
		CCDirector:sharedDirector():setAnimationInterval(1/(gFrameRate*speed))
	end
	print("current game speed X"..speed)
end

local function f_vk_snapshot()
	QShareSDK:sharedQShareSDK():saveScreenToFile("xxxx.png", CCRectMake(0, 0, 0, 0))
end 

-- switch between 0s and 5s
local function f_enable_disable_delay_rpc()
	RPC_DELAY_TIME = (RPC_DELAY_TIME == 0) and 5 or 0
	print("RPC_DELAY_TIME", RPC_DELAY_TIME)
end

local function f_garbage_collect()
	collectgarbage()
end

local function f_reload()
	package.loaded["win_proc"] = nil
	require("win_proc")
end


local function f_ctrl_a()
	print("ctrl+a")
end

local function f_shift_a()
	print("shift+a")
end

local function f_ctrl_shift_a()
	print("ctrl+shift+a")
end

local function f_alt_a()
	print("alt+a")
end

local function f_a()
	print("a")
end

local KeyBoardCallBackConfig = {
	[VK_CONST.VK_F1] 		= 		f_vk_f1,
	[VK_CONST.VK_F2] 		= 		f_vk_f2,
	[VK_CONST.VK_F3] 		= 		f_vk_f3,
	[VK_CONST.VK_F4]		=		f_vk_f4,

	[VK_CONST.VK_F5] 		= 		f_vk_f5,
	[VK_CONST.VK_F6] 		= 		f_vk_f6,
	[VK_CONST.VK_F7] 		= 		f_vk_f7,
	[VK_CONST.VK_F8]		=		f_vk_f8,

	[VK_CONST.VK_F9] 		= 		f_vk_f9,
	[VK_CONST.VK_F10] 		= 		f_vk_f10,
	[VK_CONST.VK_F11] 		= 		f_vk_f11,
	[VK_CONST.VK_F12]		=		f_vk_f12,

	[VK_CONST.VK_PRIOR] 	= 		f_vk_pageup,
	[VK_CONST.VK_NEXT] 		= 		f_vk_pagedown,

	[VK_CONST.VK_LEFT] 		= 		f_vk_left,
	[VK_CONST.VK_RIGHT] 	= 		f_vk_right,
	[VK_CONST.VK_UP] 		= 		f_vk_up,
	[VK_CONST.VK_DOWN] 		= 		f_vk_down,

	[VK_CONST.VK_PAUSE] 	=		f_vk_pause_resume,

	[VK_CONST.VK_OEM_PLUS] 	= 		f_vk_oem_plus,	
	[VK_CONST.VK_OEM_MINUS] =		f_vk_oem_minus,

	[VK_CONST.VK_SNAPSHOT] 	=		f_vk_snapshot,
	

	[VK_CONST.VK_A] = f_a,
}

-- ctrl + key
local ctrlDownCallBackConfig = {
	[VK_CONST.VK_A] 		= 		f_ctrl_a,
	[VK_CONST.VK_D]			=		f_enable_disable_delay_rpc,
	[VK_CONST.VK_G]			=		f_garbage_collect,
	[VK_CONST.VK_P] 		=		f_vk_snapshot,
	[VK_CONST.VK_R] 		=		f_reload,
}

-- shift + key
local shiftDownCallBackConfig = {
	[VK_CONST.VK_A] 		= 		f_shift_a,
}

-- ctrl + shift + key
local ctrlShiftDownCallBackConfig = {
	[VK_CONST.VK_A] 		= 		f_ctrl_shift_a,
}

-- alt + key
local altDownCallBackConfig = {
	[VK_CONST.VK_A] 		= 		f_alt_a,
}

local kdcb = function(message, wParam, lParam)
	press_down_key_map[wParam] = true
	if press_down_key_map[VK_CONST.VK_CTRL] and press_down_key_map[VK_CONST.VK_SHIFT] and ctrlShiftDownCallBackConfig[wParam] then
		return ctrlShiftDownCallBackConfig[wParam]()
	elseif press_down_key_map[VK_CONST.VK_CTRL] and ctrlDownCallBackConfig[wParam] then
		return ctrlDownCallBackConfig[wParam]()
	elseif press_down_key_map[VK_CONST.VK_SHIFT] and shiftDownCallBackConfig[wParam] then
		return shiftDownCallBackConfig[wParam]()		
	elseif KeyBoardCallBackConfig[wParam] then
		return KeyBoardCallBackConfig[wParam]()
	end

	if (wParam >= 0x30 and wParam <= 0x39) or (wParam >= 0x41 and wParam <= 0x5a) then
		print(string.format("%s\t0x%x\t%s", "keydown", wParam, string.char(wParam)))
	else
		print(string.format("%s\t0x%x\t%s", "keydown", wParam, "???"))
	end
	return false
end

local kucb = function(message, wParam, lParam)
	press_down_key_map[wParam] = nil
end

local syskdcb = function(message, wParam, lParam)
	if altDownCallBackConfig[wParam] then
		return altDownCallBackConfig[wParam]()
	end
end

local syskucb = function(message, wParam, lParam)

end

local mwheelcb = function(message, wParam, lParam)
	if not isCanScale() then return end
	if wParam > 0 then -- 0x780000
		f_vk_pageup()
	else -- 0xff880000
		f_vk_pagedown()
	end
end

local lastMouseX = nil
local lastMouseY = nil
local bMouseRButtonDown = false
local mrdcb = function(message, wParam, lParam)
	bMouseRButtonDown = true
end

local mrucb = function(message, wParam, lParam)
	bMouseRButtonDown = false
	lastMouseX = nil
	lastMouseY = nil
end

local mmcb = function(message, wParam, lParam)
	if not isCanMove() then return end
	local x, y = _getXYByLParam(lParam)
	if bMouseRButtonDown and lastMouseX and lastMouseY then
	    local sharedDirector = CCDirector:sharedDirector()
	    local scene = sharedDirector:getRunningScene()
	    if not scene then return end
		_position = _getPosition()
	    scene:positionTo(_fitPosition(ccp(_position[1] + (x - lastMouseX), _position[2] - (y - lastMouseY))))
	end
	lastMouseX, lastMouseY = x, y
end

local _conf = {
	[WIN_MESSAGE.WM_KEYDOWN] = kdcb,
	[WIN_MESSAGE.WM_KEYUP] = kucb,
	[WIN_MESSAGE.WM_SYSKEYDOWN] = syskdcb,
	[WIN_MESSAGE.WM_SYSKEYUP] = syskucb,

	-- [WIN_MESSAGE.WM_MOUSEMOVE] = mmcb,
	-- [WIN_MESSAGE.WM_RBUTTONDOWN] = mrdcb,
	-- [WIN_MESSAGE.WM_RBUTTONUP] = mrucb,

	[WIN_MESSAGE.WM_MOUSEWHEEL] = mwheelcb,
}

_G.LWINPROC_HOOK = function(message, wParam, lParam)
	if _conf[message] then
		_conf[message](message, wParam, lParam)
	end
	-- print(message, wParam, lParam)
end 