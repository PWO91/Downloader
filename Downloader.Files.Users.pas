unit Downloader.Files.Users;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, Downloader.Common;

type
  TDownloaderFilesUsers = class(TForm)
    Container: TLayout;
    Rectangle1: TRectangle;
    LbUserName: TLabel;
    Image1: TImage;
    procedure Rectangle1Click(Sender: TObject);
  private
    FUser: TUser;
  public
    constructor CreateItem(AOwner: TComponent; User: TUser);
  end;

implementation

uses
  Downloader.Files;

{$R *.fmx}

{ TDownloaderFilesUsers }

constructor TDownloaderFilesUsers.CreateItem(AOwner: TComponent; User: TUser);
begin
  inherited Create(AOwner);
  FUser := User;
  LbUserName.Text := FUser.Username;
end;

procedure TDownloaderFilesUsers.Rectangle1Click(Sender: TObject);
begin
  with DownloaderFiles do
  begin
    EdIPAdress.Text := FUser.IP;
    AGetFilesList.Execute;
  end;

end;

end.
