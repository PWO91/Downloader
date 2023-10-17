unit Downloader.Common;

interface

uses
  SysUtils, IdHashMessageDigest, idHash,
  Winsock,
  Classes,
  Types,
  StrUtils,
  Fmx.Dialogs,IpHlpApi, winapi.IPtypes,
  Windows;

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

implementation

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
