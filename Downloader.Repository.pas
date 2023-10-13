unit Downloader.Repository;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.ExtCtrls,
  Downloader.Common,
  IOUtils,
  JSON;

type
  TDownloaderRepository = class(TForm)
    Container: TLayout;
    LbFiles: TListBox;
    DropTarget1: TDropTarget;
    procedure DropTarget1Dropped(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure DropTarget1DragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure DropTarget1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddItem(DFile: TFileSetting);
    function RepositoryToJSon: String;
    function GetFilePathByName(FileName: String): String;
  end;

var
  DownloaderRepository: TDownloaderRepository;

implementation

uses
  Downloader.Repository.Item;

{$R *.fmx}

{ TDownloaderRepository }

procedure TDownloaderRepository.AddItem(DFile: TFileSetting);
var
  LbItem: TListBoxItem;
  Item: TDownloaderRepositoryItem;
begin
  LbItem := TListBoxItem.Create(LBFiles);
  LbItem.Text := '';
  Item        := TDownloaderRepositoryItem.CreateItem(LbItem, DFile);

  Item.Rectangle1.Parent  := LbItem;
  LbItem.Width            := Item.Width;
  LbItem.Height           := 55;

  if LBFiles.Count = 0 then
  LbItem.Margins.Top      := 5;

  LbItem.Margins.Left     := 5;
  LbItem.Margins.Right    := 5;
  LbItem.Margins.Bottom   := 5;

  LBFiles.AddObject(LbItem);
end;

procedure TDownloaderRepository.DropTarget1Click(Sender: TObject);
begin
  ShowMessage(RepositoryToJSon);
end;

procedure TDownloaderRepository.DropTarget1DragOver(Sender: TObject;
  const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  Operation:= TDragOperation.Copy;
end;

procedure TDownloaderRepository.DropTarget1Dropped(Sender: TObject;
  const Data: TDragObject; const Point: TPointF);
var
  FilePath: String;
begin
  for FilePath in Data.Files do
    if TPath.GetExtension(FilePath) <> '' then
     AddItem(NewFile('', '', ExtractFileName(FilePath),FilePath));
end;

function TDownloaderRepository.GetFilePathByName(FileName: String): String;
var
  i: Integer;
  Item: TDownloaderRepositoryItem;
begin
  for i:= 0 to  LbFiles.Count-1 do
  begin
    Item := TDownloaderRepositoryItem(LbFiles.ItemByIndex(i).Components[0]);
    if Item.DFile.FileName.Equals(FileName) then
    begin
      Result := Item.DFile.Path;
    end;
  end;
end;

function TDownloaderRepository.RepositoryToJSon: String;
var
  i: Integer;
  Item: TDownloaderRepositoryItem;
  JSONObject: TJSonObject;
  JSONValue: TJSONValue;
begin
  JSONObject:= TJSonObject.Create;
  for i:= 0 to  LbFiles.Count-1 do
  begin
    Item := TDownloaderRepositoryItem(LbFiles.ItemByIndex(i).Components[0]);
    JSONObject.AddPair('File', Item.DFile.FileName);
  end;

  Result := JSONObject.ToString;
end;

end.
