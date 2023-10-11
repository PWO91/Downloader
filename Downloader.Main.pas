unit Downloader.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.TabControl,
  FMX.ListBox, System.ImageList, FMX.ImgList, System.Actions, FMX.ActnList, Downloader.Common,
  Messages,
  Windows,
  FMX.Platform,
  Rtti,
  RegularExpressions, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

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
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure AAddFileToDownloadExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    LastClipboardValue: String;
    procedure ClipboardListener(Value: string);
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

procedure TDownloaderMain.ClipboardListener(Value: string);
var
  RegularExpression : TRegEx;
  Match : TMatch;
  DFIle: TFileSetting;
begin
  RegularExpression.Create('^http.*\.(zip|bin|mkv)$');
  Match := RegularExpression.Match(Value);
  if Match.Success then
   begin
    DFIle.Url := Value;
    DFIle.Dest := 'C:\Downloads\';
    DownloaderBrowser.AddItem(DFIle);
    self.FormStyle := TFormStyle.StayOnTop;
   end;

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

procedure TDownloaderMain.Timer1Timer(Sender: TObject);
var
  uClipBoard : IFMXClipboardService;
  Value: TValue;
begin
  if SupportsPlatformService(IFMXClipboardService, uClipBoard) then
  begin
    Value := uClipBoard.GetClipboard;
    if not Value.IsEmpty then
    begin
      if Value.IsType<string> then
      begin
        if Value.AsString <> LastClipboardValue then
         begin
          LastClipboardValue := Value.AsString;
          ClipboardListener(LastClipboardValue);
         end;
      end
    end;
  end;
end;


end.
