unit Downloader.Parameters;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.StorageBin, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, JSON,
  FireDAC.Stan.StorageJSON, FMX.ListBox, FMX.Grid.Style, Fmx.Bind.Grid,
  Data.Bind.Controls, Fmx.Bind.Navigator, Data.Bind.Grid, FMX.ScrollBox,
  FMX.Grid, Downloader.Common;

type
  TDownloaderParameter = class(TForm)
    Container: TLayout;
    FDParameters: TFDMemTable;
    FDParametersDownloadPath: TStringField;
    FDParametersSecretKey: TStringField;
    FDStanStorageJSONLink: TFDStanStorageJSONLink;
    BindSourceDB: TBindSourceDB;
    BindingsList: TBindingsList;
    FDParametersScanClipboard: TStringField;
    CBScanClipbaord: TCheckBox;
    LinkControlToField1: TLinkControlToField;
    GroupBox1: TGroupBox;
    Secure: TGroupBox;
    Edit1: TEdit;
    LinkControlToField2: TLinkControlToField;
    GroupBox2: TGroupBox;
    Edit2: TEdit;
    LinkControlToField3: TLinkControlToField;
    LbCards: TListBox;
    FDParametersNetworkAdapter: TIntegerField;
    GroupBox3: TGroupBox;
    procedure CornerButton1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FParScanClipboard : String;
    FParDownloadPath  : String;
    FAdapters: TNetworksConf;
  public
    procedure SaveParameters;
    procedure LoadParameters;
    property ProgramParScanClipboard: String read FParScanClipboard write FParScanClipboard;
    property ProgramParDownloadPath: String read FParDownloadPath write FParDownloadPath;
  end;

var
  DownloaderParameter: TDownloaderParameter;

implementation

{$R *.fmx}

procedure TDownloaderParameter.ComboBox1Change(Sender: TObject);
begin
  FParScanClipboard := TComboBox(Sender).Selected.Text;
end;

procedure TDownloaderParameter.CornerButton1Click(Sender: TObject);
begin
  SaveParameters;
end;

procedure TDownloaderParameter.Edit2Change(Sender: TObject);
begin
  FParDownloadPath := TEdit(Sender).Text;
end;

procedure TDownloaderParameter.FormCreate(Sender: TObject);
var
  i: Integer;
begin

  FAdapters := RetrieveLocalAdapterInformation;

  for i:=Low(FAdapters) to High(FAdapters) do
  begin
    if FAdapters[i].IP <> '0.0.0.0' then
    LbCards.Items.Add(FAdapters[i].Card + ' - ' + FAdapters[i].IP+ ' - ' + FAdapters[i].Mask + ' - ' + FAdapters[i].Gateway);
  end;

  if FileExists('parameters.json') then
    FDParameters.LoadFromFile('parameters.json');
end;

procedure TDownloaderParameter.FormDestroy(Sender: TObject);
begin
    if FDParameters.State = TDataSetState.dsEdit then
    FDParameters.Post;
    FDParameters.SaveToFile('parameters.json');
end;

procedure TDownloaderParameter.LoadParameters;
begin

end;

procedure TDownloaderParameter.SaveParameters;
begin


end;

end.
