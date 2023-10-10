unit Downloader.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.TabControl,
  FMX.ListBox, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList;

type
  TDownloaderMain = class(TForm)
    Container: TLayout;
    Button1: TButton;
    Rectangle1: TRectangle;
    TabControl1: TTabControl;
    TsDownload: TTabItem;
    Label1: TLabel;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    CornerButton3: TCornerButton;
    LBDownload: TListBox;
    ActionList1: TActionList;
    ImageList1: TImageList;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DownloaderMain: TDownloaderMain;

implementation

uses
  Downloader.Item;

{$R *.fmx}

procedure TDownloaderMain.Button1Click(Sender: TObject);
var
  DownloaderItem: TDownloaderItem;
begin
  DownloaderItem := TDownloaderItem.Create(Self);
  DownloaderItem.Container.Parent := Container;
end;

end.
