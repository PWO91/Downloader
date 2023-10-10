unit Downloader.Browser;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Objects;

type
  TDownloaderBrowser = class(TForm)
    LBDownload: TListBox;
    Container: TLayout;
  private
    { Private declarations }
  public
    procedure AddItem;
  end;

var
  DownloaderBrowser: TDownloaderBrowser;

implementation

uses
  Downloader.Item;

{$R *.fmx}

{ TDownloaderBrowser }

procedure TDownloaderBrowser.AddItem;
var
  LbItem: TListBoxItem;
  Item: TDownloaderItem;
begin
  LbItem := TListBoxItem.Create(LBDownload);
  LbItem.Text := '';
  Item:= TDownloaderItem.Create(LbItem);

  Item.Rectangle1.Parent := LbItem;
  LbItem.Width := Item.Width;
  LbItem.Height:= 55;
  if LBDownload.Count = 0 then
  LbItem.Margins.Top := 5;
  LbItem.Margins.Left := 5;
  LbItem.Margins.Right := 5;
  LbItem.Margins.Bottom := 5;

  LBDownload.AddObject(LbItem);
end;

end.
