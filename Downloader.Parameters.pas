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
    BindingsList1: TBindingsList;
    Edit2: TEdit;
    ComboBox1: TComboBox;
    CornerButton1: TCornerButton;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Edit3: TEdit;
    Label6: TLabel;
    Edit4: TEdit;
    procedure CornerButton1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
  private
    FParScanClipboard : String;
    FParDownloadPath  : String;
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

procedure TDownloaderParameter.LoadParameters;
var
  Ctx: TRTTIContext;
  F : TRTTIField;
  T: TRttiType;
  P: TRttiProperty;
  SL: TStringList;
  JSON: TJSONObject;
  JSONPair : TJSONPair;
begin
  JSON := TJSONObject.Create;
  Ctx := TRTTIContext.Create();
  SL:= TStringList.Create;
  T := Ctx.GetType(DownloaderParameter.ClassInfo);
  try
    SL.LoadFromFile('parameters.json');
    JSON := TJSonObject.ParseJSONValue(SL.Text) as TJSONObject;

    for JSONPair in JSON do
      T.GetProperty(JSONPair.JsonString.Value).SetValue(DownloaderParameter, JSONPair.JsonValue.Value);

  finally
    JSON.Free;
    SL.Free;
  end;

  ComboBox1.Items.Text:= FParScanClipboard;
  Edit2.Text := FParDownloadPath;

end;

procedure TDownloaderParameter.SaveParameters;
var
  Ctx: TRTTIContext;
  F : TRTTIField;
  T: TRttiType;
  P: TRttiProperty;
  SL: TStringList;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  Ctx := TRTTIContext.Create();
  SL:= TStringList.Create;
  T := Ctx.GetType(DownloaderParameter.ClassInfo);
  try

    for P In T.GetProperties do
      if P.Name.StartsWith('ProgramPar') then
      JSON.AddPair(P.Name,P.GetValue(DownloaderParameter).AsString);

    SL.Text:= JSON.ToString;
    SL.SaveToFile('parameters.json');
  finally
    JSON.Free;
    SL.Free;
  end;
end;

end.
