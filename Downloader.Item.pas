unit Downloader.Item;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Actions,
  FMX.ActnList, FMX.StdCtrls,
  Threading, System.ImageList, FMX.ImgList, Downloader.Common;

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
    procedure ADownloadFileExecute(Sender: TObject);
    procedure NetHTTPClientReceiveData(const Sender: TObject; AContentLength,
      AReadCount: Int64; var AAbort: Boolean);
    procedure ADownloadPauseExecute(Sender: TObject);
  private
    SFile: TFileStream;
    FDFile: TFileSetting;
    FDownloadTask: ITask;
    FAbort: Boolean;
  public
    property DFile: TFileSetting read FDFile write FDFile;
  end;

var
  DownloaderItem: TDownloaderItem;

implementation

{$R *.fmx}

procedure TDownloaderItem.ADownloadFileExecute(Sender: TObject);
var
  aResponse: IHTTPResponse;
begin
  FABort := False;
  SFile := TFileStream.Create('C:\Downloads\ccc.zip', fmCreate);
  aResponse := NetHTTPClient.Head(EdUrl.Text);
  ProgressBar1.Max:= aResponse.ContentLength;

  FDownloadTask := TTask.Create(

    procedure ()
      begin
        //Start file downloading
        NetHTTPClient.Get(EdUrl.Text, SFile);

        TThread.Synchronize(TThread.CurrentThread,
        procedure ()
        //Update gui
        //----------------------------------------
        begin

        end);

      end
    );

    FDownloadTask.Start;



  end;

procedure TDownloaderItem.ADownloadPauseExecute(Sender: TObject);
begin
  if Assigned(FDownloadTask) then
  begin
    FDownloadTask.Cancel;
    FAbort := True;
  end;
end;

procedure TDownloaderItem.NetHTTPClientReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  AAbort := FAbort;
  ProgressBar1.Value:= AReadCount;
end;

end.
