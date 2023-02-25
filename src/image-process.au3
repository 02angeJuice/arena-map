global $FFDefaultSnapShot = 0
global $FFDefautDebugMode = 00
global $FFDllHandle = -1
global $FFLastSnap = 0
global const $FFNbSnapMax = 1024
global $FFLastSnapStatus[$FFNbSnapMax]
global const $FFCurrentVersion="2.2"

InitFFDll()

func InitFFDll()
	for $i = 0 To $FFNbSnapMax-1
		$FFLastSnapStatus[$i] = 0
		next
	if @AutoItX64 then
		global $DllName = "processing-x64.dll"
	else
		global $DllName = "processing.dll"
	endif
		$FFDllHandle = DllOpen('./'&$DllName)
	if $FFDllHandle=-1 then
		$FFDllHandle=$DllName
		MsgBox(0,"Error","Failed to load "&$DllName&", application probably won't properly work. "&@LF&"Check if the file "&$DllName&"is installed near this script")
		exit(100)
		return
	endif
	if ($FFCurrentVersion<>FFGetVersion()) then
		MsgBox(0, "Error", "Wrong version of "&$DllName&". The dll is version "&FFGetVersion()&" while version "&$FFCurrentVersion&" is required.");
		Exit(101)
		endif
	FFSetDebugMode($FFDefautDebugMode)
endfunc

func CloseFFDll()
	if $FFDllHandle<>-1 then DllClose($FFDllHandle)
endfunc

func FFSetDebugMode($DebugMode)
	DllCall($FFDllHandle, "none", "SetDebugMode", "int", $DebugMode)
endfunc

func FFTrace($DebugString)
	DllCall($FFDllHandle, "none", "DebugTrace", "str", $DebugString)
endfunc

func FFTraceError($DebugString)
	DllCall($FFDllHandle, "none", "DebugError", "str", $DebugString)
endfunc

func FFSetWnd($WindowHandle, $ClientOnly=true)
	DllCall($FFDllHandle, "none", "SetHWnd", "HWND", $WindowHandle, "BOOLEAN", $ClientOnly)
endfunc


func FFSnapShot(const $Left=0, const $Top=0, const $Right=0, const $Bottom=0, const $NoSnapShot=$FFDefaultSnapShot, const $WindowHandle=-1)
	if ($WindowHandle <> -1) then FFSetWnd($WindowHandle)
	$FFDefaultSnapShot = $NoSnapShot
	local $Res = DllCall($FFDllHandle, "int", "SnapShot", "int", $Left, "int", $Top, "int", $Right, "int", $Bottom, "int", $NoSnapShot)
	if ( ((not IsArray($Res)) AND ($Res=0)) OR $Res[0]=0) then
		MsgBox(0, "FFSnapShot", "SnapShot ("&$Left&","&$Top&","&$Right&","&$Bottom&","&$NoSnapShot&","&Hex($WindowHandle,8)&") failed ")
		if (IsArray($Res)) then
			MsgBox(0, "FFSnapShot Error", "IsArray($Res):"&IsArray($Res)&" - Ubound($Res):"&UBound($Res)&" - $Res[0]:"&$Res[0])
		else
			MsgBox(0, "FFSnapShot Error", "IsArray($Res):"&IsArray($Res)&" - $Res:"&$Res)
		endif
		$FFLastSnapStatus[$NoSnapShot] = -1
		SetError(2)
		return false
	endif
	$FFLastSnapStatus[$NoSnapShot] = 1
	$FFLastSnap  = $NoSnapShot
	return true
endfunc

func FFGetVersion()
	local $Result = DllCall($FFDllHandle, "str", "FFVersion")
	if ( (not IsArray($Result))  ) then
		SetError(2)
		return "???"
	endif
	return $Result[0]
endfunc

func FFGetPixel($pos, $NoSnapShot=$FFLastSnap)
	local $Result = DllCall($FFDllHandle, "int", "FFGetPixel", "int", $pos[0], "int", $pos[1], "int", $NoSnapShot)
	if ( (not IsArray($Result)) or ($Result[0]=-1) ) then
		SetError(2)
		return -1
	endif
	return $Result[0]
endfunc