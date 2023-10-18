unit Downloader.Files;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.ListBox, FMX.Controls.Presentation, System.Actions,
  FMX.ActnList, FMX.Edit, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  JSON, Downloader.Common,
  Threading,
  Windows,
  Downloader.Parameters;

type
  TDownloaderFiles = class(TForm)
    LBFiles: TListBox;
    Container: TLayout;
    Layout1: TLayout;
    EdIPAdress: TEdit;
    CornerButton1: TCornerButton;
    ActionList: TActionList;
    AGetFilesList: TAction;
    NetHTTPClient: TNetHTTPClient;
    WorkIndicator: TAniIndicator;
    Label2: TLabel;
    StyleBook1: TStyleBook;
    Main: TLayout;
    Left: TLayout;
    Splitter1: TSplitter;
    LbUsers: TListBox;
    CornerButton2: TCornerButton;
    ARefreshUsers: TAction;
    procedure Button1Click(Sender: TObject);
    procedure AGetFilesListExecute(Sender: TObject);
    procedure NetHTTPClientRequestError(const Sender: TObject;
      const AError: string);
    procedure FormCreate(Sender: TObject);
    procedure EdIPAdressKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure ARefreshUsersExecute(Sender: TObject);
  private
    GetFilesTask: ITask;
  public
    procedure AddUser(User: TUser);
  end;

var
  DownloaderFiles: TDownloaderFiles;

implementation

uses
  Downloader.Server, Downloader.Files.Item, Downloader.Files.Users;

{$R *.fmx}

procedure TDownloaderFiles.AddUser(User: TUser);
var
  LbItem: TListBoxItem;
  Item: TDownloaderFilesUsers;
begin
  LbItem      := TListBoxItem.Create(LbUsers);
  LbItem.Text := '';

  //Create item with created file container
  //-----------------------------------------------------------------
  Item:= TDownloaderFilesUsers.CreateItem(LbItem, User);

  Item.Container.Parent   := LbItem;
  LbItem.Width            := Item.Width;
  LbItem.Height           := 35;

  if LbUsers.Count = 0 then
  LbItem.Margins.Top      := 5;

  LbItem.Margins.Left     := 5;
  LbItem.Margins.Right    := 5;
  LbItem.Margins.Bottom   := 5;

  LbUsers.AddObject(LbItem);
end;

procedure TDownloaderFiles.AGetFilesListExecute(Sender: TObject);
begin
  //Get list o files from server
  //-----------------------------------------------------------------

  //Thread to not blocking application
  //-----------------------------------------------------------------
  AGetFilesList.Enabled := False;
  WorkIndicator.Enabled := True;
  GetFilesTask          := TTask.Create(

    procedure()
    var
      Url: string;
      aResponse: IHTTPResponse;
      JSONObject : TJSONObject;
      JSONPair : TJSONPair;
      i: Integer;
      LbItem: TListBoxItem;
      Item: TDownloaderFilesItem;
      DFile: TFIleSetting;
    begin
      Url := 'http://' + EdIPAdress.Text + ':'+DownloaderParameter.HTTPPort.ToString+'/?GetFiles=a';
      aResponse := NetHTTPClient.Get(Url);
      LBFiles.Clear;
      try
        JSONObject := TJSonObject.ParseJSONValue(aResponse.ContentAsString()) as TJSONObject;
        for JSONPair in JSONObject do
        begin
          TThread.Synchronize(TThread.CurrentThread,

            procedure()
            begin
              LbItem      := TListBoxItem.Create(LBFiles);
              LbItem.Text := '';

              //Create file container
              //-----------------------------------------------------------------
              DFile.Url       := Url;
              DFile.FileName  := JSONPair.JsonValue.GetValue<String>;
              DFile.Url       := 'http://' + EdIPAdress.Text + ':'+DownloaderParameter.HTTPPort.ToString+'/?DownloadFile=' + DFile.FileName;
              DFile.Dest      := 'C:\Downloads\';
              //Create item with created file container
              //-----------------------------------------------------------------
              Item:= TDownloaderFilesItem.CreateItem(LbItem, DFile);

              Item.Container.Parent   := LbItem;
              LbItem.Width            := Item.Width;
              LbItem.Height           := 75;

              if LBFiles.Count = 0 then
              LbItem.Margins.Top      := 5;

              LbItem.Margins.Left     := 5;
              LbItem.Margins.Right    := 5;
              LbItem.Margins.Bottom   := 5;

              LBFiles.AddObject(LbItem);
            end

          );
         end;
       finally
         JSONObject.Free;
         TThread.Synchronize(TThread.CurrentThread,
         procedure () begin
           AGetFilesList.Enabled := True;
           WorkIndicator.Enabled := False;
         end);
       end;
   end
  );

  GetFilesTask.Start;

end;

procedure TDownloaderFiles.ARefreshUsersExecute(Sender: TObject);
begin
  LbUsers.Items.Clear;
  DownloaderServer.GetUserList;
end;

procedure TDownloaderFiles.Button1Click(Sender: TObject);
begin
  DownloaderServer.GetUserList;
end;

procedure TDownloaderFiles.EdIPAdressKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if ord(Key) = VK_RETURN then
  begin
    AGetFilesList.Execute;
  end;
end;

procedure TDownloaderFiles.FormCreate(Sender: TObject);
begin
  TTask.Create(

    procedure()
    begin
      while true do
      begin
        Sleep(500);
        TThread.Synchronize(TThread.CurrentThread,


          procedure()
          begin
            Label2.Visible := (LBFiles.Count = 0);
          end

        );
    end;

    end

  ).Start;
end;

procedure TDownloaderFiles.NetHTTPClientRequestError(const Sender: TObject;
  const AError: string);
begin
  ShowMessage(AError);
  AGetFilesList.Enabled := True;
  WorkIndicator.Enabled := False;
end;

end.
