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
  Downloader.Parameters;

type



  TDownloaderServer = class(TDataModule)
    IdHTTPServer: TIdHTTPServer;
    IdUDPServer: TIdUDPServer;
    IdUDPClient: TIdUDPClient;
    NetHTTPClient: TNetHTTPClient;
    procedure IdHTTPServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure DataModuleCreate(Sender: TObject);
    procedure IdUDPServerUDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    function IdServerIOHandlerSSLOpenSSLVerifyPeer(Certificate: TIdX509;
      AOk: Boolean; ADepth, AError: Integer): Boolean;
    procedure IdServerIOHandlerSSLOpenSSLGetPassword(var Password: string);
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
