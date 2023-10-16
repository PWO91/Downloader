unit Downloader.Dialog.Urls;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, System.Actions, FMX.ActnList;

type
  TDownloaderDialogUrls = class(TForm)
    ActionList: TActionList;
    Label1: TLabel;
    edUrl: TEdit;
    CornerButton1: TCornerButton;
    CornerButton2: TCornerButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DownloaderDialogUrls: TDownloaderDialogUrls;

implementation

{$R *.fmx}

end.
