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
  Windows;

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
    procedure Button1Click(Sender: TObject);
    procedure AGetFilesListExecute(Sender: TObject);
    procedure NetHTTPClientRequestError(const Sender: TObject;
      const AError: string);
    procedure FormCreate(Sender: TObject);
    procedure EdIPAdressKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
  private
    GetFilesTask: ITask;
  public
    { Public declarations }
  end;

var
  DownloaderFiles: TDownloaderFiles;

implementation

uses
  Downloader.Server, Downloader.Files.Item;

{$R *.fmx}

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
      Url := 'http://' + EdIPAdress.Text + ':8899/?GetFiles=a';
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
              DFile.Url       := 'http://' + EdIPAdress.Text + ':8899/?DownloadFile=' + DFile.FileName;
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
