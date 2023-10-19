unit Downloader.Common;

interface

uses
  SysUtils, IdHashMessageDigest, idHash,
  Winsock,
  Classes,
  Types,
  StrUtils,
  Fmx.Dialogs,IpHlpApi, winapi.IPtypes,
  Windows,
  Vcl.Imaging.jpeg,
  Fmx.Graphics,
  VCL.Graphics,
  System.UITypes;
type

  TNetworkConf = record
    Card: String;
    IP: String;
    Mask: String;
    Gateway: String;
  end;

  TNetworksConf = array of TNetworkConf;

  TFileSetting = record
    Url: string;
    Dest: string;
    FileName: String;
    Path: String;
    InitialSize: Int64;
  end;

  TUser = record
    Username: String;
    IP: String;
  end;

 function ExtractUrlFileName(const AUrl: string): string;
 function GetFileSize(p_sFilePath : string) : Int64;
 function MD5(const fileName : string) : string;
 function NewFile(Url, Dest, FileName, Path: String): TFileSetting;
 function GetLocalIP: string;
 function GetBroadcat(IP:String): String;
 function RetrieveLocalAdapterInformation: TNetworksConf;
 function GetBuildInfoAsString: string;
 function MemoryStreamToString(M: TMemoryStream): AnsiString;
 procedure ResizeBitmap(var Bitmap: TBitmap; Compression: Single);
 procedure ResizeBMP(b : TBitmap; NewWidth, NewHeight : integer);

implementation

procedure ResizeBMP(b : TBitmap; NewWidth, NewHeight : integer);
var
tbmp : TBitmap;
begin
  tbmp := TBitmap.Create;
  tbmp.Width := b.Width;
  tbmp.Height := b.Height;
  BitBlt(tbmp.Canvas.Handle,0,0,tbmp.Width,tbmp.Height,
  b.Canvas.Handle,0,0,SRCCOPY);
  b.Width := NewWidth;
  b.Height := NewHeight;
  StretchBlt(b.Canvas.Handle,0,0,b.Width,b.Height,tbmp.Canvas.Handle,
  0,0,tbmp.Width,tbmp.Height,SRCCOPY);
  tbmp.Free;
end;

procedure ResizeBitmap(var Bitmap: TBitmap; Compression: Single);
var
  buffer: TBitmap;
begin
  buffer := TBitmap.Create;
  try
    buffer.SetSize(Trunc(Bitmap.Width * Compression), Trunc(Bitmap.Height * Compression));
    buffer.Canvas.StretchDraw(Rect(0, 0, Trunc(Bitmap.Width * Compression), Trunc(Bitmap.Height * Compression)), Bitmap);
    Bitmap.SetSize(Trunc(Bitmap.Width * Compression), Trunc(Bitmap.Height * Compression));
    Bitmap.Canvas.Draw(0, 0, buffer);
  finally
    buffer.Free;
  end;
end;

function MemoryStreamToString(M: TMemoryStream): AnsiString;
begin
  SetString(Result, PAnsiChar(M.Memory), M.Size);
end;

procedure GetBuildInfo(var V1, V2, V3, V4: word);
var
  VerInfoSize, VerValueSize, Dummy: DWORD;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize > 0 then
  begin
      GetMem(VerInfo, VerInfoSize);
      try
        if GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo) then
        begin
          VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
          with VerValue^ do
          begin
            V1 := dwFileVersionMS shr 16;
            V2 := dwFileVersionMS and $FFFF;
            V3 := dwFileVersionLS shr 16;
            V4 := dwFileVersionLS and $FFFF;
          end;
        end;
      finally
        FreeMem(VerInfo, VerInfoSize);
      end;
  end;
end;

function GetBuildInfoAsString: string;
var
  V1, V2, V3, V4: word;
begin
  GetBuildInfo(V1, V2, V3, V4);
  Result := IntToStr(V1) + '.' + IntToStr(V2) + '.' +
    IntToStr(V3) + '.' + IntToStr(V4);
end;

function RetrieveLocalAdapterInformation: TNetworksConf;
var pAdapterInfo:PIP_ADAPTER_INFO;
    BufLen,Status:cardinal; i:Integer;
begin
  BufLen:= sizeof(IP_ADAPTER_INFO);
  GetAdaptersInfo(nil, BufLen);
  pAdapterInfo:= AllocMem(BufLen);
  try
    Status:= GetAdaptersInfo(pAdapterInfo,BufLen);
    if (Status <> ERROR_SUCCESS) then
    begin
      case Status of
        ERROR_NOT_SUPPORTED: raise exception.create('GetAdaptersInfo is not supported by the operating ' +
                                     'system running on the local computer.');
        ERROR_NO_DATA: raise exception.create('No network adapter on the local computer.');
      else
        raiselastOSerror;
      end;
      Exit;
    end;
    while (pAdapterInfo<>nil) do
    begin
     SetLength(Result, Length(Result) + 1);
     Result[High(Result)].IP        := pAdapterInfo^.IpAddressList.IpAddress.S;
     Result[High(Result)].Mask      := pAdapterInfo^.IpAddressList.IpMask.S;
     Result[High(Result)].Gateway   := pAdapterInfo^.GatewayList.IpAddress.S;
     Result[High(Result)].Card      := pAdapterInfo^.Description;
     pAdapterInfo:= pAdapterInfo^.Next;
    end;
  finally
    Freemem(pAdapterInfo);
  end;
end;

function GetBroadcat(IP:String): String;
begin


end;

function GetLocalIP: string;
type
  TaPInAddr = array [0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array [0..63] of Ansichar;
  i: Integer;
  GInitData: TWSADATA;
begin
  WSAStartup($101, GInitData);
  Result := '';
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(Buffer);
  if phe = nil then
    Exit;
  pptr := PaPInAddr(phe^.h_addr_list);
  i := 0;
  while pptr^[i] <> nil do
  begin
    Result := StrPas(inet_ntoa(pptr^[i]^));
    Inc(i);
  end;
  WSACleanup;
end;

function ExtractUrlFileName(const AUrl: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('/', AUrl);
  Result := Copy(AUrl, i + 1, Length(AUrl) - (i));
end;

function GetFileSize(p_sFilePath : string) : Int64;
var
  oFile : file of Byte;
begin
  Result := -1;
  AssignFile(oFile, p_sFilePath);
  try
    Reset(oFile);
    Result := FileSize(oFile);
  finally
    CloseFile(oFile);
  end;
end;


function MD5(const fileName : string) : string;
 var
   idmd5 : TIdHashMessageDigest5;
   fs : TFileStream;
   hash : T4x4LongWordRecord;
 begin
   idmd5 := TIdHashMessageDigest5.Create;
   fs := TFileStream.Create(fileName, fmOpenRead OR fmShareDenyWrite) ;
   try
     Result := idmd5.HashStreamAsHex(fs);
   finally
     fs.Free;
     idmd5.Free;
   end;
 end;


function NewFile(Url, Dest, FileName, Path: String): TFileSetting;
begin
  Result.Url      := Url;
  Result.Dest     := Dest;
  Result.FileName := FileName;
  Result.Path     := Path;
end;

end.
