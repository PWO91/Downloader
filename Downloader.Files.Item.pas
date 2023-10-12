unit Downloader.Files.Item;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Actions,
  FMX.ActnList, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Layouts, Downloader.Common,
  FMX.Objects, FMX.Effects;

type
  TDownloaderFilesItem = class(TForm)
    Container: TLayout;
    ActionList: TActionList;
    LbFileName: TLabel;
    CornerButton1: TCornerButton;
    ADownloadFile: TAction;
    Rectangle1: TRectangle;
    procedure ADownloadFileExecute(Sender: TObject);
  private
    FUrl: String;
    FFileName: string;
  public
    constructor CreateItem(AOwner: TComponent; Url, FileName: String);
  end;

implementation

uses
   Downloader.Browser;

{$R *.fmx}

procedure TDownloaderFilesItem.ADownloadFileExecute(Sender: TObject);
var
  DFile: TFileSetting;
begin
  DFile.Dest := 'C:\Downloads\';
  DFile.Url := 'http://' + FUrl + ':8899/?DownloadFile=' + FFileName;
  DFile.FileName := FFileName;
  DownloaderBrowser.AddItem(DFile);
end;

constructor TDownloaderFilesItem.CreateItem(AOwner: TComponent; Url,
  FileName: String);
begin
  inherited Create(AOwner);
  FUrl:= Url;
  FFileName := FileName;
  LbFileName.Text:= FFileName;
end;

end.
