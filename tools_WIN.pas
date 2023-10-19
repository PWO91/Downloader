unit tools_WIN;

interface

{$IFDEF MSWINDOWS}
uses Classes {$IFDEF MSWINDOWS} , Windows {$ENDIF}, System.SysUtils, FMX.Types, VCL.Forms, VCL.Graphics, Vcl.Controls;


  procedure TakeScreenshot(Dest: TBitmap);
  procedure WriteWindowsToStream(AStream: TStream; PixelFormat:TPixelFormat );
  function CaptureWindow: TBitmap;
{$ENDIF MSWINDOWS}

implementation

{$IFDEF MSWINDOWS}

function CaptureWindow: TBitmap;
var
  DC: HDC;
  wRect: TRect;
  Width, Height: Integer;
begin
  DC := GetWindowDC(GetDesktopWindow);
  Result := TBitmap.Create;
  try
    GetWindowRect(GetDesktopWindow, wRect);
    Width := wRect.Right - wRect.Left;
    Height := wRect.Bottom - wRect.Top;
    Result.Width := Width;
    Result.Height := Height;
    Result.Modified := True;
    BitBlt(Result.Canvas.Handle, 0, 0, Width, Height, DC, 0, 0, SRCCOPY);
  finally
    ReleaseDC(GetDesktopWindow, DC);
  end;
end;

procedure WriteWindowsToStream(AStream: TStream; PixelFormat:TPixelFormat );
var
  dc: HDC; lpPal : PLOGPALETTE;
  bm: TBitMap;
begin
{test width and height}
  bm := TBitmap.Create;
  bm.PixelFormat :=  PixelFormat;

  bm.Width := Screen.Width;
  bm.Height := Screen.Height;
  //get the screen dc
  dc := GetDc(0);
  if (dc = 0) then exit;
 //do we have a palette device?
  if (GetDeviceCaps(dc, RASTERCAPS) AND RC_PALETTE = RC_PALETTE) then
  begin
    //allocate memory for a logical palette
    GetMem(lpPal, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)));
    //zero it out to be neat
    FillChar(lpPal^, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)), #0);
    //fill in the palette version
    lpPal^.palVersion := $300;
    //grab the system palette entries
    lpPal^.palNumEntries :=GetSystemPaletteEntries(dc,0,256,lpPal^.palPalEntry);
    if (lpPal^.PalNumEntries <> 0) then
    begin
      //create the palette
      bm.Palette := CreatePalette(lpPal^);
    end;
    FreeMem(lpPal, sizeof(TLOGPALETTE) + (255 * sizeof(TPALETTEENTRY)));
  end;
  //copy from the screen to the bitmap
  BitBlt(bm.Canvas.Handle,0,0,Screen.Width,Screen.Height,Dc,0,0,SRCCOPY);

  bm.Canvas.TextOut(0,0,'Screencast');
  bm.Canvas.TextOut(Mouse.CursorPos.X, Mouse.CursorPos.Y, '■');


  bm.SaveToStream(AStream);

  FreeAndNil(bm);
  //release the screen dc
  ReleaseDc(0, dc);
end;


procedure TakeScreenshot(Dest: TBitmap);
var
  Stream: TMemoryStream;
begin
  try
    Stream := TMemoryStream.Create;
    WriteWindowsToStream(Stream, TPixelFormat.pf8bit);
    Stream.Position := 0;
    Dest.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

{$ENDIF MSWINDOWS}
end.
