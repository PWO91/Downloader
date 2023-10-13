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
    FDFile: TFileSetting;
  public
    constructor CreateItem(AOwner: TComponent; Url, FileName: String); overload;
    constructor CreateItem(AOwner: TComponent; DFile: TFileSetting); overload;
  end;

implementation

uses
   Downloader.Browser, Downloader.Parameters;

{$R *.fmx}

procedure TDownloaderFilesItem.ADownloadFileExecute(Sender: TObject);
begin
  DownloaderBrowser.AddItem(FDFile);
  ADownloadFile.Enabled:= False;
end;

constructor TDownloaderFilesItem.CreateItem(AOwner: TComponent; Url,
  FileName: String);
begin
  //Constructor to create file in download page
  //-----------------------------------------------------------------
  inherited Create(AOwner);
  FDFile.Url:= Url;
  FDFile.FileName := FileName;
  LbFileName.Text:= FDFile.FileName;
end;

constructor TDownloaderFilesItem.CreateItem(AOwner: TComponent;
  DFile: TFileSetting);
begin
  //Second constructor to create file in download page
  //-----------------------------------------------------------------
  inherited Create(AOwner);
  FDFile := DFile;
  LbFileName.Text:= FDFile.FileName;
end;

end.
