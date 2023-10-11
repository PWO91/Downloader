unit Downloader.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.TabControl,
  FMX.ListBox, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList, Downloader.Common;

type
  TDownloaderMain = class(TForm)
    Rectangle1: TRectangle;
    TabControl1: TTabControl;
    TsDownload: TTabItem;
    Label1: TLabel;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    CornerButton3: TCornerButton;
    ActionList: TActionList;
    ImageList1: TImageList;
    AAddFileToDownload: TAction;
    CornerButton4: TCornerButton;
    procedure FormCreate(Sender: TObject);
    procedure AAddFileToDownloadExecute(Sender: TObject);
  private

  public
    procedure InitGui;
  end;

var
  DownloaderMain: TDownloaderMain;

implementation

uses
  Downloader.Item, Downloader.Browser;

{$R *.fmx}

procedure TDownloaderMain.AAddFileToDownloadExecute(Sender: TObject);
var
  DFIle: TFileSetting;
begin
  DFIle.Url := InputBox('Url', 'Url', '');
  DFIle.Dest := 'C:\Downloads\';
  if not DFIle.Url.IsEmpty then
    DownloaderBrowser.AddItem(DFIle);
end;

procedure TDownloaderMain.FormCreate(Sender: TObject);
begin
  InitGui;
end;

procedure TDownloaderMain.InitGui;
begin
  DownloaderBrowser:= TDownloaderBrowser.Create(Self);
  DownloaderBrowser.Container.Parent := TsDownload;

end;

end.
