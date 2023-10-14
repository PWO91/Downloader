unit Downloader.Browser;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Objects, Downloader.Common, FMX.ExtCtrls,
  FMX.Controls.Presentation, FMX.StdCtrls,
  Threading;

type
  TDownloaderBrowser = class(TForm)
    LBDownload: TListBox;
    Container: TLayout;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddItem(DFile: TFileSetting);
  end;

var
  DownloaderBrowser: TDownloaderBrowser;

implementation

uses
  Downloader.Item;

{$R *.fmx}

{ TDownloaderBrowser }

procedure TDownloaderBrowser.AddItem(DFile: TFileSetting);
var
  LbItem: TListBoxItem;
  Item: TDownloaderItem;
begin
  LbItem := TListBoxItem.Create(LBDownload);
  LbItem.Text := '';
  Item        := TDownloaderItem.CreateItem(LbItem, DFile);

  Item.Rectangle1.Parent  := LbItem;
  LbItem.Width            := Item.Width;
  LbItem.Height           := 50;

  if LBDownload.Count = 0 then
  LbItem.Margins.Top      := 5;

  LbItem.Margins.Left     := 5;
  LbItem.Margins.Right    := 5;
  LbItem.Margins.Bottom   := 5;

  LBDownload.AddObject(LbItem);
end;

procedure TDownloaderBrowser.FormCreate(Sender: TObject);
begin
  TTask.Create(

    procedure()
    begin
      while true do
      begin
        Sleep(500);
        TThread.Synchronize(TThread.CurrentThread,


          procedure()
          begin
            DownloaderBrowser.Label2.Visible := (DownloaderBrowser.LBDownload.Count = 0);
          end

        );
    end;

    end

  ).Start;
end;

end.
