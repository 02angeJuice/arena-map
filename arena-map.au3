#requireAdmin
#pragma compile(Icon, ./src/icon/icon.ico)
#AutoIt3Wrapper_UseX64=NO
#include <./src/imageSearchEX.au3>
#include <./src/image-process.au3>
#include <WinAPI.au3>
#include <Date.au3>
#include <Misc.au3>
#include <Array.au3>
#include <File.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIConstantsEx.au3>
#Include <StaticConstants.au3>
#Include <WindowsConstants.au3>

global $gName = 'Seven Knights 2', $hWND = WinGetHandle($gName)
global $paused = false, $titlePaused = false
global $gTimer, $gSec, $gMin, $gHour, $gTime
global $count = 0
global $arrPlay[16] = ['🔸 🔸 🔸', '🟡 🔸 🔸', '🟡 🟡 🔸', '🟡 🟡 🟡', '🔸 🔸 🔸', '🟨 🔸 🔸', '🟨 🟨 🔸', '🟨 🟨 🟨', '🔸 🔸 🔸', '⚙️ 🔸 🔸', '⚙️ ⚙️ 🔸', '⚙️ ⚙️ ⚙️', '🔸 🔸 🔸', '❤️ 🔸 🔸', '❤️ ❤️ 🔸', '❤️ ❤️ ❤️']
global $arrIdle[3] = ['🟡  HOME : play & pause ', '🟡  END : exit ', '🟡  F5 : resize window ']


#include "./src/animate.au3"
#include "./src/stateControl.au3"
#include "./src/helperControl.au3"

;~ Opt('MustDeclareVars', 1)
Opt('TrayAutoPause', 0)

Opt("MouseCoordMode", 2)

HotKeySet("{END}", "onExit")
HotKeySet("{HOME}", "togglePlay")
HotKeySet("{F5}", "setWindowSize")

setWindowSize()
trayAnimate('gear','on', 40)

$gTimer = TimerInit()
AdlibRegister("fetchTitle", 1000)

while Sleep(2000)
	if $paused <> true then
		TraySetIcon("./src/icon/icon.ico")
		_Animate_Stop()
		$titlePaused = false
	else
		_Animate_Start("", 1)
		$titlePaused = true
		dailyPopup()
		stateCheck()
	endif
wend

func dailyPopup()
	local $popup = [830, 54], $popupColor = "0xFFFFFF"
	color($popup, $popupColor)
endfunc