program Downloader;

uses
  System.StartUpCopy,
  FMX.Forms,
  Downloader.Main in 'Downloader.Main.pas' {DownloaderMain},
  Downloader.Item in 'Downloader.Item.pas' {DownloaderItem},
  Downloader.Common in 'Downloader.Common.pas',
  Downloader.Browser in 'Downloader.Browser.pas' {DownloaderBrowser};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDownloaderMain, DownloaderMain);
  Application.Run;
end.
