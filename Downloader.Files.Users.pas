unit Downloader.Files.Users;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, Downloader.Common,
  FMX.Ani, FMX.Effects,
  Fmx.ListBox;

type
  TDownloaderFilesUsers = class(TForm)
    Container: TLayout;
    Rectangle1: TRectangle;
    LbUserName: TLabel;
    Image1: TImage;
    LbIPAdress: TLabel;
    ColorAnimation1: TColorAnimation;
    procedure Rectangle1Click(Sender: TObject);
    procedure Rectangle1MouseEnter(Sender: TObject);
    procedure Rectangle1MouseLeave(Sender: TObject);
  private
    FUser: TUser;
  public
    constructor CreateItem(AOwner: TComponent; User: TUser);
  end;

implementation

uses
  Downloader.Files, Downloader.Remote;

{$R *.fmx}

{ TDownloaderFilesUsers }

constructor TDownloaderFilesUsers.CreateItem(AOwner: TComponent; User: TUser);
begin
  inherited Create(AOwner);
  FUser := User;
  LbUserName.Text := FUser.Username;
  LbIPAdress.Text := FUser.IP;
end;

procedure TDownloaderFilesUsers.Rectangle1Click(Sender: TObject);
begin
  with DownloaderFiles do
  begin
    EdIPAdress.Text := FUser.IP;
    AGetFilesList.Execute;
  end;

  with DownloaderRemote do
  begin
    EdIP.Text := FUser.IP;
  end;

end;

procedure TDownloaderFilesUsers.Rectangle1MouseEnter(Sender: TObject);
begin
  //TListBox(Self.Owner.Owner).ItemByIndex(TListBoxItem(Self.Owner).Index).Height:= 70;
end;

procedure TDownloaderFilesUsers.Rectangle1MouseLeave(Sender: TObject);
begin
 //TListBox(Self.Owner.Owner).ItemByIndex(TListBoxItem(Self.Owner).Index).Height:= 45;
end;

end.
