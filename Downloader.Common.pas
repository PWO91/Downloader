unit Downloader.Common;

interface

uses
  SysUtils;

type
  TFileSetting = record
    Url: string;
    Dest: string;
  end;

 function ExtractUrlFileName(const AUrl: string): string;

implementation

function ExtractUrlFileName(const AUrl: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('/', AUrl);
  Result := Copy(AUrl, i + 1, Length(AUrl) - (i));
end;

end.
