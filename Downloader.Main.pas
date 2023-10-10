unit Downloader.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.TabControl,
  FMX.ListBox, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList;

type
  TDownloaderMain = class(TForm)
    Button1: TButton;
    Rectangle1: TRectangle;
    TabControl1: TTabControl;
    TsDownload: TTabItem;
    Label1: TLabel;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    CornerButton3: TCornerButton;
    ActionList: TActionList;
    ImageList1: TImageList;
    Action1: TAction;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CornerButton3Click(Sender: TObject);
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

procedure TDownloaderMain.Button1Click(Sender: TObject);
var
  DownloaderItem: TDownloaderItem;
begin
  DownloaderItem := TDownloaderItem.Create(Self);
  DownloaderItem.Container.Parent := TsDownload;
end;

procedure TDownloaderMain.CornerButton3Click(Sender: TObject);
begin
  DownloaderBrowser.AddItem;
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
