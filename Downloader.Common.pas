unit Downloader.Common;

interface

uses
  SysUtils, IdHashMessageDigest, idHash,
  Winsock,
  Classes;

type
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

implementation


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
