program Downloader;

uses
  System.StartUpCopy,
  FMX.Forms,
  Downloader.Main in 'Downloader.Main.pas' {DownloaderMain},
  Downloader.Item in 'Downloader.Item.pas' {DownloaderItem},
  Downloader.Common in 'Downloader.Common.pas',
  Downloader.Browser in 'Downloader.Browser.pas' {DownloaderBrowser},
  Downloader.Parameters in 'Downloader.Parameters.pas' {DownloaderParameter},
  Downloader.Server in 'Downloader.Server.pas' {DownloaderServer: TDataModule},
  Downloader.Files in 'Downloader.Files.pas' {DownloaderFiles},
  Downloader.Files.Item in 'Downloader.Files.Item.pas' {DownloaderFilesItem},
  Downloader.Repository in 'Downloader.Repository.pas' {DownloaderRepository},
  Downloader.Repository.Item in 'Downloader.Repository.Item.pas' {DownloaderRepositoryItem},
  Downloader.Files.Users in 'Downloader.Files.Users.pas' {DownloaderFilesUsers},
  Downloader.Dialog.Urls in 'Downloader.Dialog.Urls.pas' {DownloaderDialogUrls},
  Downloader.Splash in 'Downloader.Splash.pas',
  SysUtils {DownloaderSplash};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDownloaderMain, DownloaderMain);
  Application.CreateForm(TDownloaderServer, DownloaderServer);
  Application.Run;
end.
