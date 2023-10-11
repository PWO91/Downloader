unit Downloader.Parameters;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  TDownloaderParameter = class(TForm)
    Container: TLayout;
    Switch1: TSwitch;
    GridPanelLayout1: TGridPanelLayout;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Switch2: TSwitch;
    Label4: TLabel;
    Switch3: TSwitch;
    Label5: TLabel;
    Switch4: TSwitch;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DownloaderParameter: TDownloaderParameter;

implementation

{$R *.fmx}

end.
