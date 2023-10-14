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
  FireDAC.Stan.StorageJSON, FMX.ListBox;

type
  TDownloaderParameter = class(TForm)
    Container: TLayout;
    GridPanelLayout1: TGridPanelLayout;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    FDParameters: TFDMemTable;
    BindingsList1: TBindingsList;
    FDStanStorageJSONLink: TFDStanStorageJSONLink;
    FDParametersDownloadPath: TStringField;
    DSParameters: TDataSource;
    Edit2: TEdit;
    BindSourceDB1: TBindSourceDB;
    LinkControlToField1: TLinkControlToField;
    ComboBox1: TComboBox;
    FDParametersScanClipboard: TIntegerField;
    CornerButton1: TCornerButton;
    ComboBox2: TComboBox;
    FDParametersAutomaticDownload: TIntegerField;
    LinkPropertyToFieldItemIndex2: TLinkPropertyToField;
    Edit1: TEdit;
    LinkControlToField2: TLinkControlToField;
    LinkPropertyToFieldListBoxIndex: TLinkPropertyToField;
    procedure FormCreate(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DownloaderParameter: TDownloaderParameter;

implementation

{$R *.fmx}

procedure TDownloaderParameter.CornerButton1Click(Sender: TObject);
begin
  FDParameters.Post;
  FDParameters.SaveToFile('parameters.json', sfJSON);
  FDParameters.Open;
  FDParameters.First;
  FDParameters.Edit;
end;

procedure TDownloaderParameter.FormCreate(Sender: TObject);
begin
  if FileExists('parameters.json') then
  begin
    try
      FDParameters.LoadFromFile('parameters.json', sfJSON);
    except

    end;
  end;
  FDParameters.Open;
   FDParameters.Edit;
end;

end.
