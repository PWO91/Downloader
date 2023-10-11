unit Downloader.Item;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Actions,
  FMX.ActnList, FMX.StdCtrls,
  Threading, System.ImageList, FMX.ImgList, Downloader.Common, FMX.Effects,
  IOUtils;

type
  TDownloaderItem = class(TForm)
    Container: TLayout;
    EdUrl: TEdit;
    Rectangle1: TRectangle;
    ActionList: TActionList;
    ADownloadFile: TAction;
    NetHTTPClient: TNetHTTPClient;
    ProgressBar1: TProgressBar;
    SaveDialog: TSaveDialog;
    LbUrl: TLabel;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
    CornerButton3: TCornerButton;
    ADownloadPause: TAction;
    ImageList: TImageList;
    ADownloadAbort: TAction;
    GlowEffect1: TGlowEffect;
    NetHTTPClientInfo: TNetHTTPClient;
    procedure ADownloadFileExecute(Sender: TObject);
    procedure NetHTTPClientReceiveData(const Sender: TObject; AContentLength,
      AReadCount: Int64; var AAbort: Boolean);
    procedure ADownloadPauseExecute(Sender: TObject);
    procedure NetHTTPClientRequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
  private
    SFile: TFileStream;
    FDFile: TFileSetting;
    FDownloadTask: ITask;
    FAbort: Boolean;
    FResumeDownload: Boolean;
  public
    property DFile: TFileSetting read FDFile write FDFile;
    constructor CreateItem(AOwner: TComponent; _DFile: TFileSetting);
  end;

implementation

{$R *.fmx}

procedure TDownloaderItem.ADownloadFileExecute(Sender: TObject);
var
  aResponse: IHTTPResponse;
  LocalFilePath: string;
begin

  FABort    := False;
  aResponse := NetHTTPClientInfo.Head(FDFile.Url);

  //Create local path for downloaded file
  //-----------------------------------------------------------------
  LocalFilePath := FDFile.Dest + ExtractUrlFileName(FDFile.Url);

  //Check if file exist
  //-----------------------------------------------------------------
  if FileExists(LocalFilePath) then
  begin
    //Check exist and not compleated - resume download
    //-----------------------------------------------------------------
    if GetFileSize(LocalFilePath) < aResponse.ContentLength then
    begin
      FResumeDownload     := True;
      SFile               := TFileStream.Create(FDFile.Dest + ExtractUrlFileName(FDFile.Url), fmOpenReadWrite);
      FDFile.InitialSize  := SFile.Size;
      SFile.Position      := FDFile.InitialSize;
      ProgressBar1.Max    := aResponse.ContentLength;
      ProgressBar1.Value  := FDFile.InitialSize;
    end else
    begin
      //Or do nothing
      //-----------------------------------------------------------------
      Exit;
    end;
  end else
  begin
    //If not exist - prepare for new download
    //-----------------------------------------------------------------
    SFile               := TFileStream.Create(FDFile.Dest + ExtractUrlFileName(FDFile.Url), fmCreate);
    ProgressBar1.Max    := aResponse.ContentLength;
    ProgressBar1.Value  := 0;
  end;


  //New download task
  //-----------------------------------------------------------------
  FDownloadTask := TTask.Create(

    procedure ()
      begin
        if FResumeDownload then
          NetHTTPClient.GetRange(FDFile.Url,SFile.Size, aResponse.ContentLength, SFile) else
          NetHTTPClient.Get(FDFile.Url, SFile);
      end
    );

  //Start task
  //-----------------------------------------------------------------
  FDownloadTask.Start;

  end;

procedure TDownloaderItem.ADownloadPauseExecute(Sender: TObject);
begin
  if FDownloadTask.Status = TTaskStatus.Running then
    FAbort := True;
end;

constructor TDownloaderItem.CreateItem(AOwner: TComponent; _DFile: TFileSetting);
begin
  inherited Create(AOwner);
  FDFile      := _DFile;
  EdUrl.Text  := FDFile.Url;
end;

procedure TDownloaderItem.NetHTTPClientReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  AAbort              := FAbort;
  ProgressBar1.Value  := FDFile.InitialSize + AReadCount;

  if FAbort then
  begin
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

end.
