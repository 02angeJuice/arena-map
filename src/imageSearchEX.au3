
#include <screencapture.au3>
#include <array.au3>
#include <GUIConstantsEx.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <BmpSearch.au3>
#include <GDIPlus.au3>

Func imageSearchEX($TitleOrClass,$bmpLocal) ;tham số $hwnd là handle dạng mã hex, $bmplocal là đường dẫn của ảnh mẫu cần tìm
  $hwnd = WinGetHandle($TitleOrClass)
  $iWidth = _WinAPI_GetWindowWidth($hwnd) ; $browser = the handle of the window which I am capturing
  $iHeight = _WinAPI_GetWindowHeight($hwnd)
  $hDDC = _WinAPI_GetDC($hwnd)
  $hCDC = _WinAPI_CreateCompatibleDC($hDDC)
  $hBMP = _WinAPI_CreateCompatibleBitmap($hDDC, $iWidth, $iHeight)
  _WinAPI_SelectObject($hCDC, $hBMP)
  DllCall("User32.dll", "int", "PrintWindow", "hwnd", $hwnd, "hwnd", $hCDC, "int", 0)
  ;~ $hwnd = WinGetHandle($TitleOrClass)
  ;~ $iWidth = _WinAPI_GetWindowWidth($hwnd)
  ;~ $iHeight = _WinAPI_GetWindowHeight($hwnd)
  Return imageSearchEXarea($hwnd,$bmpLocal,$iWidth,$iHeight)
  EndFunc
Func imageSearchEXarea($TitleOrClass,$bmpLocal,$iWidth,$iHeight); hàm này dùng khi muốn search trong một khu vực nhỏ(không tìm toàn bộ cửa sổ)
  $hwnd = WinGetHandle($TitleOrClass)
  Local $p[2]
_GDIPlus_Startup()

Local $hImage = _GDIPlus_ImageLoadFromFile($bmplocal)
$hImageWidthHalf = _GDIPlus_ImageGetWidth($hImage)/2
$hImageHightHalf = _GDIPlus_ImageGetHeight($hImage)/2
;Get the hBitmap of the image i want to search for
$Bitmap = _GDIPlus_BitmapCreateFromFile($bmpLocal)
$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($Bitmap)

;Doing the actual window capture and saving it inside $hBMP
$iWidth = _WinAPI_GetWindowWidth($hwnd) ; $browser = the handle of the window which I am capturing
$iHeight = _WinAPI_GetWindowHeight($hwnd)
$hDDC = _WinAPI_GetDC($hwnd)
$hCDC = _WinAPI_CreateCompatibleDC($hDDC)
$hBMP = _WinAPI_CreateCompatibleBitmap($hDDC, $iWidth, $iHeight)
_WinAPI_SelectObject($hCDC, $hBMP)
DllCall("User32.dll", "int", "PrintWindow", "hwnd", $hwnd, "hwnd", $hCDC, "int", 0)
;Searching for the image
$pos = _BmpSearch($hBMP, $hBitmap,10); có thể thay số 10 bằng số từ 1-5000, là số ảnh giống nhau tối đa muốn tìm đc
;~ _ArrayDisplay($pos)
if $pos=0 Then; nếu $pos=0 tức là không tìm đc hình và hàm trả về 0
   Return 0
   EndIf
$p[0]=$pos[1][2] + $hImageWidthHalf
$p[1]=$pos[1][3] + $hImageHightHalf
;delete resources
;ngược lại thì hàm trả về đúng tọa độ ảnh đã tìm được, nên nhớ đây là tọa độ trong cửa sổ đó thôi nhé
 _WinAPI_ReleaseDC($hwnd, $hDDC)
_WinAPI_DeleteDC($hCDC)
_WinAPI_DeleteObject($hBMP)

_GDIPlus_Shutdown()
Return $p

EndFunc

