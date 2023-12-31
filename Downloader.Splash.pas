unit Downloader.Splash;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TDownloaderSplash = class(TForm)
    Rectangle1: TRectangle;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DownloaderSplash: TDownloaderSplash;

implementation

{$R *.fmx}

end.
