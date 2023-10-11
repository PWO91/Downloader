unit Downloader.Common;

interface

uses
  SysUtils;

type
  TFileSetting = record
    Url: string;
    Dest: string;
    InitialSize: Int64;
  end;

 function ExtractUrlFileName(const AUrl: string): string;
 function GetFileSize(p_sFilePath : string) : Int64;

implementation

function ExtractUrlFileName(const AUrl: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('/', AUrl);
  Result := Copy(AUrl, i + 1, Length(AUrl) - (i));
end;

function GetFileSize(p_sFilePath : string) : Int64;
var
  oFile : file of Byte;
begin
  Result := -1;
  AssignFile(oFile, p_sFilePath);
  try
    Reset(oFile);
    Result := FileSize(oFile);
  finally
    CloseFile(oFile);
  end;
end;

end.
