unit Downloader.Item;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Actions,
  FMX.ActnList, FMX.StdCtrls,
  Threading, System.ImageList, FMX.ImgList, Downloader.Common, FMX.Effects,
  IOUtils,
  Notification, System.Notification,
  Fmx.ListBox,
  DateUtils;

type
  TDownloaderItem = class(TForm)
    Container: TLayout;
    Rectangle1: TRectangle;
    ActionList: TActionList;
    ADownloadFile: TAction;
    NetHTTPClient: TNetHTTPClient;
    ProgressBar1: TProgressBar;
    SaveDialog: TSaveDialog;
    LbUrl: TLabel;
    BtDownload: TCornerButton;
    BtPause: TCornerButton;
    BtAbort: TCornerButton;
    ADownloadPause: TAction;
    ImageList: TImageList;
    ADownloadAbort: TAction;
    GlowEffect1: TGlowEffect;
    NetHTTPClientInfo: TNetHTTPClient;
    LbDownloadInfo: TLabel;
    BtHide: TCornerButton;
    ADeleteItem: TAction;
    StyleBook1: TStyleBook;
    EdUrl: TEdit;
    procedure ADownloadFileExecute(Sender: TObject);
    procedure NetHTTPClientReceiveData(const Sender: TObject; AContentLength,
      AReadCount: Int64; var AAbort: Boolean);
    procedure ADownloadPauseExecute(Sender: TObject);
    procedure NetHTTPClientRequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    procedure ADeleteItemExecute(Sender: TObject);
    procedure NetHTTPClientInfoRequestError(const Sender: TObject;
      const AError: string);
  private
    LastTime: TDateTime;
    SecondDiff : Integer;
    AReadCountDiff: Int64;
    Speed: Single;

    AReadCountLast: Int64;
    SFile: TFileStream;
    FDFile: TFileSetting;
    FDownloadTask: ITask;
    FAbort: Boolean;
    FResumeDownload: Boolean;
    FSizeUnknow: Boolean;
    procedure ShowNotification(Title, Msg: String);
  public
    property DFile: TFileSetting read FDFile write FDFile;
    constructor CreateItem(AOwner: TComponent; _DFile: TFileSetting);

  end;

implementation

uses
  Downloader.Main, Downloader.Parameters;

{$R *.fmx}

procedure TDownloaderItem.ADeleteItemExecute(Sender: TObject);
begin
  TListBox(Self.Owner.Owner).Items.Delete(TListBoxItem(Self.Owner).Index);
end;

procedure TDownloaderItem.ADownloadFileExecute(Sender: TObject);
var
  aResponse: IHTTPResponse;
  LocalFilePath: string;
  FileLength: Int64;
  Secret: string;
begin
  //Ask for password
  //-----------------------------------------------------------------
  Secret := InputBox('File password',#31, '');

  //Prepare download operation
  //-----------------------------------------------------------------
  FSizeUnknow         := True;
  FABort              := False;
  FDFile.InitialSize  := 0;
  FileLength          := 0;

  //Create local path for downloaded file
  //-----------------------------------------------------------------
  LocalFilePath := DownloaderParameter.FDParametersDownloadPath.AsString + FDFile.FileName;

  //Check if it's possible to estaminate size of the file
  //-----------------------------------------------------------------
  try
    NetHTTPClientInfo.CustomHeaders['Secret'] := Secret;
    FSizeUnknow := False;
    aResponse := NetHTTPClientInfo.Head(FDFile.Url);

    if aResponse.StatusCode = 401 then
    begin
      ShowMessage('Incorrect password!');
      Exit;
    end;

    FileLength := aResponse.ContentLength;
  except
    FSizeUnknow := True;
  end;


  //Check if file exist
  //-----------------------------------------------------------------
  if FileExists(LocalFilePath) and not FSizeUnknow then
  begin
    //Check exist and not compleated - resume download
    //-----------------------------------------------------------------
    if (GetFileSize(LocalFilePath) < FileLength)   then
    begin
      FResumeDownload     := True;
      SFile               := TFileStream.Create(FDFile.Dest + FDFile.FileName, fmOpenReadWrite);
      FDFile.InitialSize  := SFile.Size;
      SFile.Position      := FDFile.InitialSize;
    end else
    begin
      //Or do nothing - file exist in direcotry and size is this same
      //-----------------------------------------------------------------
      ShowMessage('This file already exist in ' + FDFile.Dest);
      Exit;
    end;
  end else
  begin
    //If not exist, or size of file cant be estaminate, start new download
    //-----------------------------------------------------------------
    SFile               := TFileStream.Create(LocalFilePath, fmCreate);
  end;


  //New download task
  //-----------------------------------------------------------------
  LastTime:= Now();
  AReadCountLast := 0;
  FDownloadTask := TTask.Create(

    procedure ()
      begin
        NetHTTPClient.CustomHeaders['Secret'] := Secret;
        if FResumeDownload then
          NetHTTPClient.GetRange(FDFile.Url,FDFile.InitialSize, aResponse.ContentLength, SFile) else
          NetHTTPClient.Get(FDFile.Url, SFile);

          TThread.Synchronize(TThread.Current,

           //Download complete or aborted - show notification adn update gui
           //-----------------------------------------------------------------
          procedure()
          begin
            ShowNotification('Downloaded',FDFile.FileName);
            ADownloadFile.Enabled   := False;
            ADownloadPause.Enabled  := False;
            ADownloadAbort.Enabled  := False;
            LbDownloadInfo.Text     := 'Downloaded';
          end

          );

      end
    );


  //Start task
  //-----------------------------------------------------------------
  FDownloadTask.Start;
end;

procedure TDownloaderItem.ADownloadPauseExecute(Sender: TObject);
begin
  //Abort downloading
  //-----------------------------------------------------------------
  if FDownloadTask.Status = TTaskStatus.Running then
    FAbort := True;
end;

constructor TDownloaderItem.CreateItem(AOwner: TComponent; _DFile: TFileSetting);
begin
  inherited Create(AOwner);
  FDFile              := _DFile;
  EdUrl.Text          := FDFile.Url;
  LbDownloadInfo.Text := FDFile.FileName;
end;

procedure TDownloaderItem.NetHTTPClientInfoRequestError(const Sender: TObject;
  const AError: string);
begin
//
end;

procedure TDownloaderItem.NetHTTPClientReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  //Operation during download
  //-----------------------------------------------------------------

  //Calculate download speed
  //-----------------------------------------------------------------

  SecondDiff := MIlliSecondsBetween(LastTime,Now());
  AReadCountDiff :=  ((AReadCount - AReadCountLast));

  if SecondDiff > 1000 then
  begin
    Speed := AReadCountDiff / 1024 / 1024;
    LastTime := Now();
    AReadCountLast:=AReadCount;
  end;

  AAbort                  := FAbort;
  ProgressBar1.Value      := FDFile.InitialSize + AReadCount;
  LbDownloadInfo.Text     := 'Downloaded: ' + DFile.FileName + ' - ' + IntToStr((FDFile.InitialSize + AReadCount) div 1024 div 1024) + '/' + IntToStr(AContentLength div 1024 div 1024) + ' MB Speed: ' +  Format('%.2f', [Speed]) + ' MB/s';
  ADownloadPause.Enabled  := True;
  ADownloadFile.Enabled   := False;
  ProgressBar1.Max := AContentLength;
  ProgressBar1.Value := AReadCount;
  if FAbort then
  begin
     //User download abort
     //-----------------------------------------------------------------
    ADownloadFile.Enabled   := True;
    ADownloadPause.Enabled  := False;
    FDownloadTask.Cancel;
    SFile.Free;
  end;


end;

procedure TDownloaderItem.NetHTTPClientRequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
begin
  //Release file in case of download completed
  //-----------------------------------------------------------------
  if Assigned(SFile) then
    SFile.Free;
end;

procedure TDownloaderItem.ShowNotification(Title, Msg: String);
var
  MyNotification: TNotification;
begin
  //Create Windows notification
  //-----------------------------------------------------------------
  MyNotification := DownloaderMain.NotificationCenter.CreateNotification;
  try
    MyNotification.Name := 'Downloader';
    MyNotification.Title := Title;
    MyNotification.AlertBody := Msg;

    DownloaderMain.NotificationCenter.PresentNotification(MyNotification);
  finally
    MyNotification.Free;
  end;
end;

end.
