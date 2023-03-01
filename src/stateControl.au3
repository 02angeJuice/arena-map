local $isLobby = 1

func stateCheck()
	if $isLobby == 1 then
		return stateLobby()
	else
		return stateField()
	endif
endfunc

func stateLobby()
	local $e1 = [448, 14], $e1Color = '0xFFF4BA'
	local $e2 = [452, 19], $e2Color = '0xFFF4BA'
	local $e3 = [447, 26], $e3Color = '0xFDF2B9'
	local $e4 = [444, 20], $e4Color = '0xFFF4BA'

	local $arenaEnds = [176, 406], $arenaEndsColor = '0xDBE3F5'
	local $lobby = [366, 66], $lobbyColor = '0x819CC7'
	local $cat = [292, 473], $catColor = '0xEBE7E0'
	
	local $arenaX[4] = [840, 600, 840, 560]
	local $arenaY[4] = [460, 460, 460, 350]

	ConsoleWrite('Lobby' & @CRLF)

	ControlSend($hWND, "", "", '{G}')
	Sleep(2000)
	
	if color($lobby, $lobbyColor, false) <> true then
		;~ waiting for arena is done
		if color($arenaEnds, $arenaEndsColor, false) <> false then
			WinActivate($hWND)
			;~ send to field
			click(176, 406)
			Sleep(500)
			click(840, 450)
			;~ go to field
			Sleep(6000)
			ControlSend($hWND, "", "", '{G}')
			goToField()

			$isLobby = 0
		;~ else
			;~ local $pauseBtn = [28, 33], $pauseBtnColor = '0xF5E7CE'
			;~ if color($pauseBtn, $pauseBtnColor, false) <> true then
			;~ 	ControlSend($hWND, "", "", '{ESC}')
			;~ endif
		endif
	else
		WinActivate($hWND)
		click(75, 90)
		Sleep(500)
		click(280, 205)
		Sleep(2000)
		;~ check ticket
		if color($e1, $e1Color, false) == true AND color($e2, $e2Color, false) == true AND color($e3, $e3Color, false) == true AND color($e4, $e4Color, false) == true then
			click(910, 20)
			;~ go to field
			Sleep(6000)
			ControlSend($hWND, "", "", '{G}')
			goToField()

			$isLobby = 0
		else
			for $i = 0 to UBound($arenaX) - 1
				ConsoleWrite($arenaX[$i] & "," & $arenaY[$i] & @LF)
				Sleep(500)
				click($arenaX[$i], $arenaY[$i])
			next
		endif
	endif
endfunc

func stateField()
	local $ticket1 = [448, 21], $ticket1Color = '0xF9EEB6'
	local $ticketFull = [438, 26], $ticketFullColor = '0xFFF4BA'
	local $field = [380, 70], $fieldColor = '0x222327'

	ConsoleWrite('Field' & @CRLF)

	ControlSend($hWND, "", "", '{G}')
	Sleep(2000)
	
	if color($field, $fieldColor, false) <> true then
		;~ waiting for ticket
		if color($ticket1, $ticket1Color, false) == true OR color($ticketFull, $ticketFullColor, false) == true then
			ConsoleWrite("the ticket is ready" & @CRLF)
			WinActivate($hWND)
			;~ send to lobby
			click(910, 20)
			ControlSend($hWND, "", "", '{ESC}')
			Sleep(500)
			;~ go to lobby
			click(520, 330)

			$isLobby = 1
		endif
	else
		WinActivate($hWND)
		click(75, 90)
		Sleep(500)
		click(280, 205)
	endif
endfunc

func goToField()
	WinActivate($hWND)
	click(250, 80)
	Sleep(2000)
	imgClick('field-get-ready', true, 100, 0)
	Opt("MouseCoordMode", 2)
	Sleep(750)
	click(840, 460)
endfunc