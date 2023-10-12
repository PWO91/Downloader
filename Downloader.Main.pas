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
  RegularExpressions, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  System.Notification,
  Threading;

type
  TDownloaderMain = class(TForm)
    Rectangle1: TRectangle;
    TabControl1: TTabControl;
    TsDownload: TTabItem;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    CornerButton3: TCornerButton;
    ActionList: TActionList;
    ImageList: TImageList;
    ADownloadPage: TAction;
    CornerButton4: TCornerButton;
    ClipboardMonitor: TTimer;
    TSParameters: TTabItem;
    AParametersPage: TAction;
    NotificationCenter: TNotificationCenter;
    TSFiles: TTabItem;
    AFilesPage: TAction;
    Container: TLayout;
    Header: TRectangle;
    Separator1: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure ADownloadPageExecute(Sender: TObject);
    procedure ClipboardMonitorTimer(Sender: TObject);
    procedure AParametersPageExecute(Sender: TObject);
    procedure AFilesPageExecute(Sender: TObject);
  private
    LastClipboardValue: String;
    TaskGui: TTask;
    procedure ClipboardListener(Value: string);
  public
    procedure InitGui;
  end;

var
  DownloaderMain: TDownloaderMain;

implementation

uses
  Downloader.Item, Downloader.Browser, Downloader.Parameters, Downloader.Server, Downloader.Files;

{$R *.fmx}

procedure TDownloaderMain.ADownloadPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TsDownload;
end;

procedure TDownloaderMain.AFilesPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TsFiles;
end;

procedure TDownloaderMain.AParametersPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TSParameters;
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
  DownloaderBrowser                     := TDownloaderBrowser.Create(Self);
  DownloaderBrowser.Container.Parent    := TsDownload;

  DownloaderParameter                   := TDownloaderParameter.Create(Self);
  DownloaderParameter.Container.Parent  := TsParameters;

  DownloaderFiles                       := TDownloaderFiles.Create(Self);
  DownloaderFiles.Container.Parent      := TsFiles;

end;

procedure TDownloaderMain.ClipboardMonitorTimer(Sender: TObject);
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
