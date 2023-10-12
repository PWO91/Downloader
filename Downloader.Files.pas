unit Downloader.Files;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.ListBox, FMX.Controls.Presentation, System.Actions,
  FMX.ActnList, FMX.Edit, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  JSON;

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
    procedure Button1Click(Sender: TObject);
    procedure AGetFilesListExecute(Sender: TObject);
  private
    { Private declarations }
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
var
  Url: string;
  aResponse: IHTTPResponse;
  JSONObject : TJSONObject;
  JSONPair : TJSONPair;
  i: Integer;
  LbItem: TListBoxItem;
  Item: TDownloaderFilesItem;
begin
  Url := 'http://' + EdIPAdress.Text + ':8899/?GetFiles=a';
  aResponse := NetHTTPClient.Get(Url);
  LBFiles.Clear;
  JSONObject := TJSonObject.ParseJSONValue(aResponse.ContentAsString()) as TJSONObject;
   try
     for JSONPair in JSONObject do
     begin
      LbItem := TListBoxItem.Create(LBFiles);
      LbItem.Text := '';
      Item:= TDownloaderFilesItem.CreateItem(LbItem, EdIPAdress.Text, JSONPair.JsonValue.GetValue<String>);

      Item.Container.Parent := LbItem;
      LbItem.Width := Item.Width;
      LbItem.Height:= 75;
      if LBFiles.Count = 0 then
      LbItem.Margins.Top := 5;
      LbItem.Margins.Left := 5;
      LbItem.Margins.Right := 5;
      LbItem.Margins.Bottom := 5;

      LBFiles.AddObject(LbItem);
     end;


   finally
     JSONObject.Free;
   end;

end;

procedure TDownloaderFiles.Button1Click(Sender: TObject);
begin
  DownloaderServer.GetUserList;
end;

end.
