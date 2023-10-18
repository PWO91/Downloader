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
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, System.JSON,
  FireDAC.Stan.StorageJSON, FMX.ListBox, FMX.Grid.Style, Fmx.Bind.Grid,
  Data.Bind.Controls, Fmx.Bind.Navigator, Data.Bind.Grid, FMX.ScrollBox,
  FMX.Grid, Downloader.Common,
  REST.Json;

type
  TDownloaderParameter = class(TForm)
    Parameters: TLayout;
    FDParameters: TFDMemTable;
    FDParametersDownloadPath: TStringField;
    FDParametersSecretKey: TStringField;
    FDParametersScanClipboard: TStringField;
    CBScanClipbaord: TCheckBox;
    GroupBox1: TGroupBox;
    Secure: TGroupBox;
    GroupBox2: TGroupBox;
    EDDownloadPath: TEdit;
    LbCards: TListBox;
    FDParametersNetworkAdapter: TIntegerField;
    GroupBox3: TGroupBox;
    StyleBook1: TStyleBook;
    EdSecret: TEdit;
    GroupBox4: TGroupBox;
    EdUserNick: TEdit;
    GroupBox5: TGroupBox;
    EdUDPPort: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EdHTTPPort: TEdit;
    VertScrollBox1: TVertScrollBox;
    Container: TLayout;
    procedure CornerButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
  private
    FAdapters: TNetworksConf;
  public
    procedure SaveParameters;
    procedure LoadParameters;
    function DownloadPath: String;
    function Secret: String;
    function User: String;
    function UDPPort : Integer;
    function HTTPPort : Integer;
  end;

var
  DownloaderParameter: TDownloaderParameter;

implementation

{$R *.fmx}

procedure TDownloaderParameter.CornerButton1Click(Sender: TObject);
begin
  SaveParameters;
end;

function TDownloaderParameter.DownloadPath: String;
begin
  Result := EDDownloadPath.Text;
end;

procedure TDownloaderParameter.FormCreate(Sender: TObject);
var
  i: Integer;
begin

  FDParameters.Active := True;

  FAdapters := RetrieveLocalAdapterInformation;

  for i:=Low(FAdapters) to High(FAdapters) do
  begin
    if FAdapters[i].IP <> '0.0.0.0' then
    LbCards.Items.Add(FAdapters[i].Card + ' - ' + FAdapters[i].IP+ ' - ' + FAdapters[i].Mask + ' - ' + FAdapters[i].Gateway);
  end;


end;

procedure TDownloaderParameter.GroupBox1Click(Sender: TObject);
begin
  SaveParameters;
end;

function TDownloaderParameter.HTTPPort: Integer;
begin
  Result := EdHTTPPort.Text.ToInteger;
end;

procedure TDownloaderParameter.LoadParameters;
var
  JSonValue:TJSonValue;
  SL: TStringList;
begin
  SL:= TStringList.Create;
  SL.LoadFromFile('parameters.json');
  JSonValue:= TJSonObject.ParseJSONValue(SL.Text);

  CBScanClipbaord.IsChecked := JSonValue.GetValue<Boolean>('ScanClipboard');
  EDDownloadPath.Text       := JSonValue.GetValue<String>('DownloadPath');
  EDSecret.Text             := JSonValue.GetValue<String>('Secret');
  LBCards.ItemIndex         := JSonValue.GetValue<Integer>('NetworkAdapter');
  EdUserNick.Text           := JSonValue.GetValue<String>('UserNick');
  edUDPPort.Text            := JSonValue.GetValue<String>('UDPPort');
  edHTTPPort.Text           := JSonValue.GetValue<String>('HTTPPort');
  SL.Free;
  JSonValue.Free;

end;

procedure TDownloaderParameter.SaveParameters;
var
  JSON: TJsonObject;
  SL: TStringList;
begin
  JSON:= TJSonObject.Create;
  SL:= TStringList.Create;
  JSON.AddPair(TJSONPair.Create('ScanClipboard', (CBScanClipbaord.IsChecked.ToString)));
  JSON.AddPair(TJSONPair.Create('DownloadPath', EDDownloadPath.Text));
  JSON.AddPair(TJSONPair.Create('Secret', EdSecret.Text));
  JSON.AddPair(TJSONPair.Create('NetworkAdapter', LbCards.ItemIndex.ToString));
  JSON.AddPair(TJSONPair.Create('UserNick', EdUserNick.Text));
  JSON.AddPair(TJSONPair.Create('UDPPort', EdUDPPort.Text));
  JSON.AddPair(TJSONPair.Create('HTTPPort', EdHTTPPort.Text));
  SL.Text := JSON.ToJSON;
  SL.SaveToFile('parameters.json');

  SL.Free;
  JSON.Free;

end;


function TDownloaderParameter.Secret: String;
begin
  Result := EdSecret.Text;
end;

function TDownloaderParameter.UDPPort: Integer;
begin
  Result := EdUDPPort.Text.ToInteger;
end;

function TDownloaderParameter.User: String;
begin
  Result:= EdUserNick.Text;
end;

end.
