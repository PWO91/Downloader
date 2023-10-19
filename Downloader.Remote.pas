unit Downloader.Remote;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Objects,
  System.Actions, FMX.ActnList,
  Threading,
  Vcl.Imaging.jpeg, FMX.ListBox, FMX.Edit, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient;

type
  TDownloaderRemote = class(TForm)
    Image1: TImage;
    Container: TLayout;
    Layout2: TLayout;
    ActionList: TActionList;
    AStartSession: TAction;
    Right: TLayout;
    ARefreshAll: TAction;
    CornerButton1: TCornerButton;
    CornerButton3: TCornerButton;
    AStopSession: TAction;
    EdIP: TEdit;
    IdTCPClient: TIdTCPClient;
    CornerButton2: TCornerButton;
    AFullScreen: TAction;
    procedure AStartSessionExecute(Sender: TObject);
    procedure AStopSessionExecute(Sender: TObject);
    procedure AFullScreenExecute(Sender: TObject);
  private
    aTask: ITask;
    StopTask: Boolean;
    FPartnerIP: String;
  public
    { Public declarations }
  end;

var
  DownloaderRemote: TDownloaderRemote;

implementation

uses
  Downloader.Common, Downloader.Remote.Full, Downloader.Main;

{$R *.fmx}

procedure TDownloaderRemote.AFullScreenExecute(Sender: TObject);
begin

  if DownloaderMain.MainTabs.ActiveTab = DownloaderMain.TabItem4 then
  begin
    Container.Parent := DownloaderMain.TsRemote;
    DownloaderMain.MainTabs.ActiveTab :=DownloaderMain.TabItem2;
    AFullScreen.Text := 'Full screen';
    Exit;
  end;

  Container.Parent := DownloaderMain.TabItem4;
  DownloaderMain.MainTabs.ActiveTab :=DownloaderMain.TabItem4;
  AFullScreen.Text := 'Close full'
end;

procedure TDownloaderRemote.AStartSessionExecute(Sender: TObject);
begin

    if Assigned(aTask) then
      if aTask.Status = TTaskStatus.Running then Exit;


    begin
      aTask := TTask.Create(
      procedure()
        var
          MS, DS: TMemoryStream;
        begin
          IdTCPClient.Host:= EdIP.Text;
          while not (aTask.Status = TTaskStatus.Canceled) do
          begin
            MS := TMemoryStream.Create;
            DS := TMemoryStream.Create;
            if not IdTCPClient.Connected then
            IdTCPClient.Connect;
            IdTCPClient.IOHandler.LargeStream:= True;
            IdTCPClient.IOHandler.ReadStream(MS, -1, False);
            Image1.Bitmap.LoadFromStream(MS);
            MS.Free;
            DS.Free;
          end;
          IdTCPClient.Disconnect;
        end
      );
    end;

    aTask.Start;

end;

procedure TDownloaderRemote.AStopSessionExecute(Sender: TObject);
begin
    aTask.Cancel;
end;

end.
