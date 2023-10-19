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
  Threading, FMX.Menus,
  IdStack, FMX.Ani, FMX.Effects,
  VCL.Graphics, tools_WIN, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent,
  Vcl.Imaging.jpeg, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

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
    CornerButton5: TCornerButton;
    ARepositoryPage: TAction;
    TsRepository: TTabItem;
    TsABout: TTabItem;
    Label1: TLabel;
    Rectangle2: TRectangle;
    StyleBook: TStyleBook;
    Label2: TLabel;
    AAbout: TAction;
    MainMenu: TMainMenu;
    MMProgram: TMenuItem;
    MenuItem1: TMenuItem;
    AExitProgram: TAction;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    ADownloadFileFromInternet: TAction;
    LbLocalIP: TLabel;
    MainTabs: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Rectangle3: TRectangle;
    Label3: TLabel;
    AniIndicator1: TAniIndicator;
    GlowEffect1: TGlowEffect;
    FloatAnimation1: TFloatAnimation;
    Label4: TLabel;
    TabItem3: TTabItem;
    Button1: TButton;
    NetHTTPClient: TNetHTTPClient;
    CornerButton6: TCornerButton;
    TsRemote: TTabItem;
    ASessionPage: TAction;
    CornerButton7: TCornerButton;
    AComputerInfoPage: TAction;
    Memo1: TMemo;
    Image1: TImage;
    TabItem4: TTabItem;
    procedure FormCreate(Sender: TObject);
    procedure ADownloadPageExecute(Sender: TObject);
    procedure ClipboardMonitorTimer(Sender: TObject);
    procedure AParametersPageExecute(Sender: TObject);
    procedure AFilesPageExecute(Sender: TObject);
    procedure ARepositoryPageExecute(Sender: TObject);
    procedure AAboutExecute(Sender: TObject);
    procedure AExitProgramExecute(Sender: TObject);
    procedure ADownloadFileFromInternetExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ASessionPageExecute(Sender: TObject);
    procedure AComputerInfoPageExecute(Sender: TObject);
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
  Downloader.Item, Downloader.Browser, Downloader.Remote, Downloader.Parameters, Downloader.Server, Downloader.Files,
  Downloader.Repository, Downloader.Dialog.Urls;
{$R *.fmx}

procedure TDownloaderMain.AAboutExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TsAbout;
end;

procedure TDownloaderMain.AComputerInfoPageExecute(Sender: TObject);
begin
  //
end;

procedure TDownloaderMain.ADownloadFileFromInternetExecute(Sender: TObject);
var
  UrlsDialog: TDownloaderDialogUrls;
  DFile: TFileSetting;
begin
  UrlsDialog := TDownloaderDialogUrls.Create(self);
  try
    if UrlsDialog.ShowModal = mrOk then
    begin
      DFile.Url       := UrlsDialog.edUrl.Text;
      DFile.FileName  := ExtractUrlFileName(UrlsDialog.edUrl.Text);
      DownloaderBrowser.AddItem(DFile);
    end;
  finally
    UrlsDialog.Free;
  end;
end;

procedure TDownloaderMain.ADownloadPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TsDownload;
end;

procedure TDownloaderMain.AExitProgramExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TDownloaderMain.AFilesPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TsFiles;
end;

procedure TDownloaderMain.AParametersPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TSParameters;
end;

procedure TDownloaderMain.ARepositoryPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TsRepository;
end;

procedure TDownloaderMain.ASessionPageExecute(Sender: TObject);
begin
  TabControl1.ActiveTab := TsRemote;
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

procedure TDownloaderMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DownloaderParameter.SaveParameters;
end;

procedure TDownloaderMain.FormCreate(Sender: TObject);
begin

  InitGui;

  LbLocalIP.Text := GetLocalIP;

end;

procedure TDownloaderMain.InitGui;
begin

  Label4.Text := GetBuildInfoAsString;

  DownloaderBrowser                     := TDownloaderBrowser.Create(Self);
  DownloaderBrowser.Container.Parent    := TsDownload;

  DownloaderParameter                   := TDownloaderParameter.Create(Self);
  DownloaderParameter.Container.Parent  := TsParameters;
  DownloaderParameter.Container.Repaint;

  DownloaderFiles                       := TDownloaderFiles.Create(Self);
  DownloaderFiles.Container.Parent      := TsFiles;

  DownloaderRepository                  := TDownloaderRepository.Create(Self);
  DownloaderRepository.Container.Parent := TsRepository;

  DownloaderRemote                  := TDownloaderRemote.Create(Self);
  DownloaderRemote.Container.Parent := TsRemote;

  DownloaderParameter.LoadParameters;

  TabControl1.ActiveTab := TsDownload;
  MainTabs.ActiveTab := TabItem1;

  TTask.Create(
    procedure()
    begin
      Sleep(2000);
      TThread.Synchronize(TTHread.Current,
      procedure()
      begin
        MainTabs.SetActiveTabWithTransition(TabItem2, TTabTransition.Slide);
      end
      );
    end
  ).Start;

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
