#Region Header

#cs

    Title:          Animated Tray Icons UDF Library for AutoIt3
    Filename:       Animate.au3
    Description:    Creates and manages animated system tray icons
    Author:         Yashied
    Version:        1.2
    Requirements:   AutoIt v3.3 +, Developed/Tested on Windows XP Pro Service Pack 2 and Windows Vista/7
    Uses:           GDIPlus.au3, WinAPI.au3
    Notes:          -

    Available functions:

    _Animate_AddIcon
	_Animate_IsAnimate
    _Animate_LoadFromBitmap
    _Animate_LoadFromFile
    _Animate_SetDelay
    _Animate_ShowIcon
    _Animate_Start
    _Animate_Stop
    _Animate_Release

    Example:

        #Include <GUIConstantsEx.au3>
        #Include <SliderConstants.au3>
        #Include <StaticConstants.au3>
        #Include <WindowsConstants.au3>

        #Include "Animate.au3"

        Opt('MustDeclareVars', 1)
        Opt('TrayAutoPause', 0)

        Global $Button, $Slider, $Msg

        _Animate_LoadFromFile(@ScriptDir & '\Flag.png')

        ;~For $i = 1 To 12
        ;~  _Animate_AddIcon(@ScriptDir & '\Flag\' & $i & '.ico', 0)
        ;~Next

        _Animate_SetDelay(50)
        _Animate_ShowIcon()

        GUICreate('Animation Test', 400, 110)
        GUICtrlCreateLabel('Fast', 10, 30, 28, 14, $SS_RIGHT)
        GUICtrlCreateLabel('Slow', 355, 30, 28, 14)
        $Slider = GUICtrlCreateSlider(42, 25, 310, 26, BitOR($TBS_AUTOTICKS, $WS_TABSTOP))
        GUICtrlSendMsg(-1, $TBM_SETTICFREQ, 10, 0)
        GUICtrlSetLimit(-1, 250, 10)
        GUICtrlSetData(-1, 50)
        $Button = GUICtrlCreateButton('Start', 160, 75, 80, 25)
        GUICtrlSetState(-1, BitOR($GUI_DEFBUTTON, $GUI_FOCUS))
        GUISetState()

        While 1
            $Msg = GUIGetMsg()
            Switch $Msg
                Case $GUI_EVENT_CLOSE
                    ExitLoop
                Case $Slider
                    _Animate_SetDelay(GUICtrlRead($Slider))
                Case $Button
                    If _Animate_IsAnimate() Then
                        GUICtrlSetData($Button, 'Start')
                        _Animate_Stop()
                    Else
                        GUICtrlSetData($Button, 'Stop')
                        _Animate_Start()
                    EndIf
            EndSwitch
        WEnd

#ce

#Include-once

#Include <GDIPlus.au3>
#Include <WinAPI.au3>

#EndRegion Header

#Region Local Variables and Constants

Dim $aiId[1][12] = [[0, DllCallbackRegister('_AI_Timer', 'none', ''), 0, 100, 0, 0, 0, -1, 0, 0, _AI_AutoIt(), 0]]

#cs

DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$aiId[0][0 ]   - Number of icons contained in an array
     [0][1 ]   - Handle to the callback function
     [0][2 ]   - Handle to the Timer
     [0][3 ]   - Timeout before changing icons, in milliseconds
     [0][4 ]   - Animation counter
     [0][5 ]   - Animation start item
     [0][6 ]   - Times counter
     [0][7 ]   - Times limit
     [0][8 ]   - Synchronization control flag
	 [0][9 ]   - Timer control flag
	 [0][10]   - Handle to AutoIt window
	 [0][11]   - Reserved

$aiId[i][0 ]   - Handle to icon (HIcon)
     [i][1-11] - Unused

#ce

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_AddIcon
; Description....: Adds an icon in the frames list.
; Syntax.........: _Animate_AddIcon ( $sFile, $iIndex )
; Parameters.....: $sFile  - The filename of the icon to be add in the list.
;                  $iIndex - The icon identifier if the file contain multiple icons.
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_AddIcon($sFile, $iIndex)

	Local $Ret = DllCall('shell32.dll', 'uint', 'ExtractIconExW', 'wstr', $sFile, 'int', $iIndex, 'ptr', 0, 'ptr*', 0, 'uint', 1)

	If (@error) Or (Not $Ret[0]) Then
		Return 0
	EndIf
	ReDim $aiId[$aiId[0][0] + 2][UBound($aiId, 2)]
	$aiId[$aiId[0][0] + 1][0] = $Ret[4]
	$aiId[0][0] += 1
	Return 1
EndFunc   ;==>_Animate_AddIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_IsAnimate
; Description....: Checks whether an icon in system tray is animating.
; Syntax.........: _Animate_IsAnimate (  )
; Parameters.....: None
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_IsAnimate()
	Return Number($aiId[0][2] > 0)
EndFunc   ;==>_Animate_IsAnimate

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_LoadFromBitmap
; Description....: Loads all frames from the image object.
; Syntax.........: _Animate_LoadFromBitmap ( $hImage )
; Parameters.....: $hImage - Handle to the image object (GDI+) containing the frames to load.
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........: A frames in the image must have the size 16x16 pixels. For example, if the image contains 12 frames, its height
;                  should be 16 pixels, length 192 (12 * 16) pixels. All previous loaded frames will be destroyed.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_LoadFromBitmap($hImage)

	_GDIPlus_Startup()

	Local $Size, $Count = 0

	$Size = DllCall($__g_hGDIPDll, 'uint', 'GdipGetImageDimension', 'ptr', $hImage, 'float*', 0, 'float*', 0)
	If (Not @error) And (Not $Size[0]) Then
		$Count = Floor($Size[2] / $Size[3])
	EndIf
	If Not $Count Then
		_GDIPlus_Shutdown()
		Return 0
	EndIf

	Local $tBITMAPINFOHEADER = DllStructCreate('dword;long;long;ushort;ushort;dword;dword;long;long;dword;dword')
	Local $tICONINFO = DllStructCreate('int;dword;dword;ptr;ptr')
	Local $hBitmap[2] = [0, 0], $hIcon[$Count + 1] = [$Count]
	Local $tData, $hFrame, $Ret

	For $i = 1 To $Count
		$hFrame = _GDIPlus_BitmapCloneArea($hImage, $Size[3] * ($i - 1), 0, $Size[3], $Size[3], $GDIP_PXF32ARGB)
		Do
			$hIcon[$i] = 0
			$tData = _GDIPlus_BitmapLockBits($hFrame, 0, 0, $Size[3], $Size[3], $GDIP_ILMREAD, $GDIP_PXF32ARGB)
			DllStructSetData($tBITMAPINFOHEADER, 1, DllStructGetSize($tBITMAPINFOHEADER))
			DllStructSetData($tBITMAPINFOHEADER, 2, $Size[3])
			DllStructSetData($tBITMAPINFOHEADER, 3, $Size[3])
			DllStructSetData($tBITMAPINFOHEADER, 4, 1)
			DllStructSetData($tBITMAPINFOHEADER, 5, 32)
			DllStructSetData($tBITMAPINFOHEADER, 6, 0)
			$Ret = DllCall('gdi32.dll', 'ptr', 'CreateDIBSection', 'hwnd', 0, 'ptr', DllStructGetPtr($tBITMAPINFOHEADER), 'uint', 0, 'ptr*', 0, 'ptr', 0, 'dword', 0)
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$hBitmap[0] = $Ret[0]
			$Ret = DllCall('gdi32.dll', 'dword', 'SetBitmapBits', 'ptr', $hBitmap[0], 'dword', $Size[3] ^ 2 * 4, 'ptr', DllStructGetData($tData, 'Scan0'))
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$hBitmap[1] = _WinAPI_CreateBitmap($Size[3], $Size[3], 1, 1)
			DllStructSetData($tICONINFO, 1, 1)
			DllStructSetData($tICONINFO, 2, 0)
			DllStructSetData($tICONINFO, 3, 0)
			DllStructSetData($tICONINFO, 4, $hBitmap[1])
			DllStructSetData($tICONINFO, 5, $hBitmap[0])
			$Ret = DllCall('user32.dll', 'ptr', 'CreateIconIndirect', 'ptr', DllStructGetPtr($tICONINFO))
			If (@error) Or (Not $Ret[0]) Then
				ExitLoop
			EndIf
			$hIcon[$i] = $Ret[0]
		Until 1
		For $j = 0 To 1
			If $hBitmap[$j] Then
				_WinAPI_DeleteObject($hBitmap[$j])
				$hBitmap[$j] = 0
			EndIf
		Next
		_GDIPlus_BitmapUnlockBits($hFrame, $tData)
		_GDIPlus_BitmapDispose($hFrame)
		If Not $hIcon[$i] Then
			For $j = 1 To $i - 1
				_WinAPI_DestroyIcon($hIcon[$j])
			Next
			$hIcon = 0
			ExitLoop
		EndIf
	Next

	_GDIPlus_Shutdown()

	If Not IsArray($hIcon) Then
		Return 0
	EndIf

	Local $Start = $aiId[0][2]

	_Animate_Release()
	ReDim $aiId[$Count + 1][UBound($aiId, 2)]
	For $i = 0 To $Count
		$aiId[$i][0] = $hIcon[$i]
	Next
	If $Start Then
		_Animate_Start()
	EndIf
	Return 1
EndFunc   ;==>_Animate_LoadFromBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_LoadFromFile
; Description....: Loads all frames from the composite file (like PNG).
; Syntax.........: _Animate_LoadFromFile ( $sFile )
; Parameters.....: $sFile  - The name of the file containing the frames to load.
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........: A frames in the file must have the size 16x16 pixels. For example, if the file contains 12 frames, its height
;                  should be 16 pixels, length 192 (12 * 16) pixels. All previous loaded frames will be destroyed.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_LoadFromFile($sFile)

	_GDIPlus_Startup()

	Local $hImage = _GDIPlus_BitmapCreateFromFile($sFile)
	Local $Result = _Animate_LoadFromBitmap($hImage)

	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_Shutdown()

	Return $Result
EndFunc   ;==>_Animate_LoadFromFile

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_SetDelay
; Description....: Sets the delay between drawing frames (icons).
; Syntax.........: _Animate_SetDelay ( $iDelay )
; Parameters.....: $iDelay - Time delay, in milliseconds. The minimum value - 10.
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_SetDelay($iDelay)

	Local $Ret

	$aiId[0][9] = 1
	If $iDelay < 10 Then
		$iDelay = 10
	EndIf
	If $aiId[0][2] Then
		$Ret = DllCall('user32.dll', 'uint_ptr', 'SetTimer', 'hwnd', 0, 'uint_ptr', $aiId[0][2], 'uint', $iDelay, 'ptr', DllCallbackGetPtr($aiId[0][1]))
		If (@error) Or (Not $Ret[0]) Then
			$aiId[0][9] = 0
			Return 0
		EndIf
	EndIf
	$aiId[0][3] = $iDelay
	$aiId[0][9] = 0
	Return 1
EndFunc   ;==>_Animate_SetDelay

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_ShowIcon
; Description....: Displays an icon from the frames list in the system tray.
; Syntax.........: _Animate_ShowIcon ( [$iItem] )
; Parameters.....: $iItem  - Index of icon in the frames list. The first icon is 1. If the value of this parameter is (-1),
;                            will display the current (last shown) icon. Default is (-1). Starting value is 100.
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_ShowIcon($iItem = -1)
	If (Not $aiId[0][0]) Or (Not $iItem) Or ($aiId[0][0] < $iItem) Then
		Return 0
	EndIf
	$aiId[0][9] = 1
	If $iItem > 0 Then
		$aiId[0][4] = $iItem
	Else
		If Not $aiId[0][4] Then
			$aiId[0][4] = 1
		EndIf
	EndIf
	$aiId[0][5] = $aiId[0][4]
	_AI_TraySetIcon($aiId[$aiId[0][4]][0])
	$aiId[0][9] = 0
	Return 1
EndFunc   ;==>_Animate_ShowIcon

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_Start
; Description....: Starts the animation in the system tray.
; Syntax.........: _Animate_Start ( [$iItem [, $iRepeat]] )
; Parameters.....: $iItem   - Index of icon in the frames list, which will begin animation. If the value of this parameter is (-1),
;                             animation will begin with the current (last shown) icon. Default is (-1).
;                  $iRepeat - Number of times to replay the animation. If the value of this parameter is (-1), animation will
;                             indefinitely. Default is (-1).
; Return values..: Success  - 1
;                  Failure  - 0
; Author.........: Yashied
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_Start($iItem = -1, $iRepeat = -1)

	Local $Ret

	If Not $aiId[0][0] Then
		Return 0
	EndIf
	$aiId[0][9] = 1
	If Not $aiId[0][2] Then
		$Ret = DllCall('user32.dll', 'uint_ptr', 'SetTimer', 'hwnd', 0, 'uint_ptr', 0, 'uint', $aiId[0][3], 'ptr', DllCallbackGetPtr($aiId[0][1]))
		If (@error) Or (Not $Ret[0]) Then
			$aiId[0][9] = 0
			Return 0
		EndIf
		$aiId[0][2] = $Ret[0]
	EndIf
	If ($iItem > 0) And ($iItem <= $aiId[0][0]) Then
		$aiId[0][4] = $iItem
	EndIf
	$aiId[0][5] = $aiId[0][4]
	If Not $aiId[0][5] Then
		$aiId[0][5] = 1
	EndIf
	$aiId[0][6] = 0
	$aiId[0][7] = $iRepeat
	$aiId[0][8] = 0
	$aiId[0][9] = 0
	Return 1
EndFunc   ;==>_Animate_Start

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_Stop
; Description....: Stops the animation in the system tray.
; Syntax.........: _Animate_Stop ( [$iFlag] )
; Parameters.....: $iFlag  - Stop animation control flag, valid values:
;                  |0 - Stops immediately. (Default)
;                  |1 - Stops after playing the full cycle only (ends on the frame, which started in animation).
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........:
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_Stop($iFlag = 0)

	Local $Ret

	If $aiId[0][2] Then
		If Not $iFlag Then
			$aiId[0][9] = 1
			$Ret = DllCall('user32.dll', 'int', 'KillTimer', 'hwnd', 0, 'uint_ptr', $aiId[0][2])
			If (@error) Or (Not $Ret[0]) Then
				$aiId[0][9] = 0
				Return 0
			EndIf
			$aiId[0][2] = 0
			$aiId[0][8] = 0
			$aiId[0][9] = 0
		Else
			$aiId[0][8] = 1
		EndIf
	EndIf
	Return 1
EndFunc   ;==>_Animate_Stop

; #FUNCTION# ====================================================================================================================
; Name...........: _Animate_Release
; Description....: Stops the animation and frees all resources (icons).
; Syntax.........: _Animate_Release (  )
; Parameters.....: None
; Return values..: Success - 1
;                  Failure - 0
; Author.........: Yashied
; Modified.......:
; Remarks........: After calling this function, last shown icon will remain in the system tray. Use TraySetIcon() to change it.
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _Animate_Release()
	If Not _Animate_Stop() Then
		Return 0
	EndIf
	For $i = 1 To $aiId[0][0]
		_WinAPI_DestroyIcon($aiId[$i][0])
	Next
	ReDim $aiId[1][UBound($aiId, 2)]
	$aiId[0][0] = 0
	$aiId[0][4] = 0
	Return 1
EndFunc   ;==>_Animate_Release

#EndRegion Public Functions

#Region Internal Functions

Func _AI_AutoIt()

	Local $hWnd, $Prev = AutoItWinGetTitle()

	AutoItWinSetTitle(StringFormat('{773FFDC0-70D1-4D9E-B65F-709836EB%04s}', @AutoItPID))
	$hWnd = WinGetHandle(AutoItWinGetTitle())
	AutoItWinSetTitle($Prev)
	Return $hWnd
EndFunc   ;==>_AI_AutoIt

Func _AI_Timer()
	If $aiId[0][9] Then
		Return
	EndIf
	If $aiId[0][7] > -1 Then
		If $aiId[0][4] = $aiId[0][5] Then
			$aiId[0][6] += 1
			If $aiId[0][6] > $aiId[0][7] Then
				_Animate_Stop()
				Return
			EndIf
		EndIf
	EndIf
	$aiId[0][4] += 1
	If $aiId[0][4] > $aiId[0][0] Then
		$aiId[0][4] = 1
	EndIf
	_AI_TraySetIcon($aiId[$aiId[0][4]][0])
	If ($aiId[0][8]) And ($aiId[0][4] = $aiId[0][5]) Then
		_Animate_Stop()
	EndIf
EndFunc   ;==>_AI_Timer

Func _AI_TraySetIcon($hIcon)

	Local $tNOTIFYICONDATA = DllStructCreate('dword;hwnd;uint;uint;uint;ptr')

	DllStructSetData($tNOTIFYICONDATA, 1, DllStructGetSize($tNOTIFYICONDATA))
	DllStructSetData($tNOTIFYICONDATA, 2, $aiId[0][10])
	DllStructSetData($tNOTIFYICONDATA, 3, 1)
	DllStructSetData($tNOTIFYICONDATA, 4, 2)
	DllStructSetData($tNOTIFYICONDATA, 5, 0)
	DllStructSetData($tNOTIFYICONDATA, 6, $hIcon)

	Local $Ret = DllCall('shell32.dll', 'int', 'Shell_NotifyIcon', 'dword', 1, 'ptr', DllStructGetPtr($tNOTIFYICONDATA))

    If (@error) Or (Not $Ret[0]) Then
		Return 0
	EndIf
	Return 1
EndFunc   ;==>_AI_TraySetIcon

#EndRegion Internal Functions
