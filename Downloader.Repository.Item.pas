unit Downloader.Repository.Item;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Actions,
  FMX.ActnList, FMX.StdCtrls, FMX.Objects, FMX.Controls.Presentation,
  FMX.Layouts,
  Fmx.ListBox,
  Downloader.Common;

type
  TDownloaderRepositoryItem = class(TForm)
    Container: TLayout;
    LbFile: TLabel;
    Rectangle1: TRectangle;
    CornerButton1: TCornerButton;
    ActionList: TActionList;
    ARemoveItem: TAction;
    procedure ARemoveItemExecute(Sender: TObject);
  private
    FDFile: TFileSetting;
  public
    property DFile: TFileSetting read FDFile write FDFile;
    constructor CreateItem(AOwner: TComponent; DFile: TFileSetting);
  end;

var
  DownloaderRepositoryItem: TDownloaderRepositoryItem;

implementation

uses
  Downloader.Repository;

{$R *.fmx}

procedure TDownloaderRepositoryItem.ARemoveItemExecute(Sender: TObject);
begin
  TListBox(Self.Owner.Owner).Items.Delete(TListBoxItem(Self.Owner).Index);
end;

constructor TDownloaderRepositoryItem.CreateItem(AOwner: TComponent;
  DFile: TFileSetting);
begin
  inherited Create(AOwner);
  FDFile      := DFile;
  LbFile.Text := DFile.FileName
end;

end.
