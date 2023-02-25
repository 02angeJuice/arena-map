func togglePlay()
	$paused = not $paused
	if $paused <> true then
		WinSetTitle($hWND, "", $gName&' '&'🔅 off')
	else
		WinSetTitle($hWND, "", $gName&' '&'🔅 on')
	endif
	return $paused
endfunc

func trayAnimate($name, $order, $frames=0)
	local $n = '\' & $name & '\' & $name & '-'
	if $order == 'on' then
		For $i = 0 To $frames
			_Animate_AddIcon('./src'& $n & $i & '.ico', 0)
		Next
		return 1
	else
		return 0
	endif
endfunc

func fetchTitle()
	_TicksToTime(Int(TimerDiff($gTimer)), $gHour, $gMin, $gSec)
	local $sTime = $gTime
	local $gTime = timeFormat($gHour, $gMin, $gSec)

	if $sTime <> $gTime then
		local $titlAdd = $gTime

		if $titlePaused <> true then
			WinSetTitle($hWND, "", $gName&' '&$arrIdle[0]&' '&$arrIdle[2]&' '&$arrIdle[1])
		else
			WinSetTitle($hWND, "", $gName&' '&$arrPlay[$count])
			$count += 1

			if $count == UBound($arrPlay) then	;~ $count == $arrPlay.length
				$count = 0
			endif
		endif

	endif
endfunc

func timeFormat($h, $m, $s)
	if $h == 0 and $m == 0 then
		return StringFormat("%i", $s)
	elseif $h == 0 and $m <> 0 then
		return StringFormat("%i:%i", $m, $s)
	else
		return StringFormat("%i:%i:%i", $h, $m, $s)
	endif
endfunc

func color($position, $color, $click = true, $addX = 0, $addY = 0)
	FFSnapShot(0, 0, 0, 0, 1, $hWND)
	local $colorCode = Hex(FFGetPixel($position, 1))
	local $trimCode = StringTrimLeft($colorCode, 2)
	local $targetCode =  "0x"&$trimCode

	if $targetCode == $color then
		if $click <> false then
			targetClick(1, $position, $addX, $addY)
		endif
		return 1
	else
		return 0
	endif
endfunc

func imgClick($img, $click = true, $addX = 0, $addY = 0)
	Opt("MouseCoordMode", 1)

	local $winSize = WinGetPos($hWND)
	;~ local $image = imageSearchEX($hWND, "./images/" & $img &".png")
	$p = imageSearchEX($hWND, "./src/images/"& $img &".png")

	local $target[2]
	if IsArray($p) = true then
		ConsoleWrite("IMAGE FOUNDDDDD  !!" & @CRLF)		
		$centerX = $p[0] + $winSize[0]
		$centerY = $p[1] + $winSize[1]
		$target[0] = $centerX
		$target[1] = $centerY

		if $click <> false then
			ConsoleWrite($centerX & $centerY & @CRLF)
			ConsoleWrite($target[0] & $target[1] & @CRLF)
			targetClick(1, $target, $addX, $addY)
		endif
		return 1
	else
		ConsoleWrite("IMAGE NOT FOUND" & @CRLF)

		return 0
	endif
endfunc

func targetClick($check, $position, $addX, $addY)
	local $savePos = MouseGetPos()

	if $check == 1 then
		BlockInput(1)
		WinActivate($hWND)
		click($position[0] + $addX,  $position[1] + $addY)
		;~ altTab()
		MouseMove($savePos[0], $savePos[1], 1)
		BlockInput(0)
	endif
endfunc

func click($positionX, $positionY)
	BlockInput(1)
	MouseMove($positionX, $positionY, 1)
	Sleep(50)
	MouseClick("left")
	Sleep(125)
	BlockInput(0)
endfunc

func altTab()
	Send("{ALT DOWN}")
	Sleep(125)
	Send("{TAB}")
	Sleep(125)
	Send("{ALT UP}")
endfunc

func setWindowSize()
	WinActivate($hWND)
	local $pos = WinGetPos($hWND)
	if UBound($pos) <> 0 then
		local $newX = (@DesktopWidth - $pos[2]) / 2
		local $newY = (@DesktopHeight - $pos[3]) / 2

		if $pos[2] <> 960 or $pos[3] <> 540 then
			WinMove($hWND, '', $newX, $newY, 960, 540)
		endif

		WinActivate($hWND)
	endif
endfunc

func onExit()
	AdlibUnRegister("fetchTitle")
	$gName = 'Seven Knights 2'
	WinSetTitle($hWND, "", $gName)
	MsgBox(0, "Exit", "The app is shutting down.", .5)
	exit
endfunc

