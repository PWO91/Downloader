unit Downloader.Server;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext,
  Fmx.Dialogs,
  JSON,
  AnsiStrings, Downloader.Common, IdUDPServer, IdUDPBase, IdUDPClient, IdGlobal,
  IdSocketHandle, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, IdServerIOHandler, IdSSL, IdSSLOpenSSL,
  Downloader.Parameters, tools_WIN,
  Vcl.Imaging.jpeg,
  Vcl.Graphics, IdTCPServer, JclSysInfo;

type



  TDownloaderServer = class(TDataModule)
    IdHTTPServer: TIdHTTPServer;
    IdUDPServer: TIdUDPServer;
    IdUDPClient: TIdUDPClient;
    NetHTTPClient: TNetHTTPClient;
    IdTCPServer: TIdTCPServer;
    procedure IdHTTPServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure DataModuleCreate(Sender: TObject);
    procedure IdUDPServerUDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    function IdServerIOHandlerSSLOpenSSLVerifyPeer(Certificate: TIdX509;
      AOk: Boolean; ADepth, AError: Integer): Boolean;
    procedure IdServerIOHandlerSSLOpenSSLGetPassword(var Password: string);
    procedure IdTCPServerException(AContext: TIdContext; AException: Exception);
    procedure IdTCPServerExecute(AContext: TIdContext);
  private
    Users: TJSONObject;
    function GetInfo: string;

  public

    procedure GetUserList;
  end;

var
  DownloaderServer: TDownloaderServer;

implementation

uses
  Downloader.Files, Downloader.Repository, Downloader.Files.Users;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

//Prepare JON response with list of all files
//-----------------------------------------------------------------
procedure TDownloaderServer.DataModuleCreate(Sender: TObject);
begin
  Users := TJSONObject.Create;
  IdUDPServer.DefaultPort := DownloaderParameter.UDPPort;
  IdUDPServer.Active:= True;
  IdHTTPServer.Active:= True;
  IdTCPServer.Active:= True;
end;



function TDownloaderServer.GetInfo: string;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('Username', DownloaderParameter.User); //Fill the list
    Result := JSON.ToString;
  finally
    JSON.Free;
  end;
end;

procedure TDownloaderServer.GetUserList;
begin
  IdUDPClient.Active:= True;
  IdUDPClient.Broadcast('GetUser',DownloaderParameter.UDPPort,'192.168.0.255');
  IdUDPClient.Active:= False;
end;

procedure TDownloaderServer.IdHTTPServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Path: string;
  MS: TMemoryStream;
  BT: TBitmap;
  Jpg: TJPEGImage;
  JSon: TJSonObject;
begin

  if ARequestInfo.Command = 'GET' then
    //Return list of file
    //-----------------------------------------------------------------
    if ARequestInfo.Params.Names[0] = 'GetFiles' then
    begin
        AResponseInfo.ContentText := DownloaderRepository.RepositoryToJSon;
    end;

    if ARequestInfo.Params.Names[0] = 'GetInfo' then
    begin
        AResponseInfo.ContentText := GetInfo;
    end;

    //Return file
    //-----------------------------------------------------------------
    if ARequestInfo.Params.Names[0] = 'DownloadFile' then
    begin

        if (ARequestInfo.RawHeaders.Values['Secret'] <> DownloaderParameter.Secret) then
        begin
          AResponseInfo.ResponseNo := 401;
        end else
        begin
          Path := DownloaderRepository.GetFilePathByName(ARequestInfo.Params.ValueFromIndex[0]);
          AResponseInfo.ContentStream := TFileStream.Create(Path, fmOpenRead or fmShareCompat);
          AResponseInfo.ContentLength := AResponseInfo.ContentStream.Size;
          AResponseInfo.WriteHeader;
          AResponseInfo.WriteContent;
          AResponseInfo.ContentStream.Free;
          AResponseInfo.ContentStream := nil;
        end;
    end;

    //Return screen
    //-----------------------------------------------------------------
    if ARequestInfo.Params.Names[0] = 'Screen' then
    begin
        begin
          MS:= TMemoryStream.Create;
          WriteWindowsToStream(MS, TPixelFormat.pf8bit);
          BT:= CaptureWindow;
          Jpg := TJPEGImage.Create;
          Jpg.Assign(BT);
          jpg.PixelFormat    :=jf24bit;  // or jf8bit
          Jpg.CompressionQuality := 100;
          Jpg.ProgressiveDisplay := False;
          Jpg.ProgressiveEncoding := False;
          Jpg.SaveToStream(MS);
          AResponseInfo.ContentStream:= MS;
          AResponseInfo.ContentLength := AResponseInfo.ContentStream.Size;
          AResponseInfo.WriteHeader;
          AResponseInfo.WriteContent;
          AResponseInfo.ContentStream.Free;
          AResponseInfo.ContentStream := nil;
          MS.Free;
          Jpg.Free;
          Bt.Free;
        end;
    end;

    if ARequestInfo.Params.Names[0] = 'SystemInfo' then
    begin
        begin
          JSon := TJSonObject.Create;
          JSon.AddPair('WindowsVersion', GetWindowsVersionString);
          JSon.AddPair('ServicePack', GetWindowsServicePackVersionString);
          JSon.AddPair('OSVersion', GetOSVersionString);
          AResponseInfo.ContentText := JSon.ToJSON;
          AResponseInfo.WriteHeader;
          AResponseInfo.WriteContent;
          AResponseInfo.ContentStream.Free;
          AResponseInfo.ContentStream := nil;
          JSon.Free;
        end;
    end;
end;

procedure TDownloaderServer.IdServerIOHandlerSSLOpenSSLGetPassword(
  var Password: string);
begin
  Password := '';
end;

function TDownloaderServer.IdServerIOHandlerSSLOpenSSLVerifyPeer(
  Certificate: TIdX509; AOk: Boolean; ADepth, AError: Integer): Boolean;
begin
if ADepth = 0 then
  begin
    Result := AOk;
  end
  else
  begin
    Result := True;
  end;
end;

procedure TDownloaderServer.IdTCPServerException(AContext: TIdContext;
  AException: Exception);
begin
  ShowMessage(AException.Message);
end;

procedure TDownloaderServer.IdTCPServerExecute(AContext: TIdContext);
var
  MS, DS: TMemoryStream;
  BT: TBitmap;
  Jpg: TJPEGImage;

begin
  MS:= TMemoryStream.Create;
  WriteWindowsToStream(MS, TPixelFormat.pf8bit);
  AContext.Connection.IOHandler.LargeStream:= True;
  AContext.Connection.IOHandler.Write(MS,0,True);
  MS.Free;
end;

procedure TDownloaderServer.IdUDPServerUDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  s: string;
begin
  s := BytesToString(AData);

  if s = 'GetUser' then
    IdUDPClient.Send(ABinding.PeerIP, 8898, 'UserInfo');

  if s = 'UserInfo' then
  begin
    TThread.Synchronize(AThread,

    procedure()
    var
      ClientInfo: THttpClient;
      JSONObject: TJSONObject;
      Url: String;
      aResponse: IHTTPResponse;
      User: TUser;
    begin
      ClientInfo := THttpClient.Create;
      try
        Url :=  'http://' + ABinding.PeerIP + ':'+DownloaderParameter.HTTPPort.ToString+'/?GetInfo=a';
        aResponse := ClientInfo.Get(Url);
        JSONObject := TJSonObject.ParseJSONValue(aResponse.ContentAsString()) as TJSONObject;

        TThread.Synchronize(TThread.Current,

        procedure()
        begin
          User.Username:= JSONObject.GetValue<String>('Username');
          User.IP := ABinding.PeerIP;
          DownloaderFiles.AddUser(User);
        end

        );

      finally
        ClientInfo.Free;
      end;


    end

    );
  end;

end;

{ TSSLHelper }


end.
