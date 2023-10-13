unit Downloader.Common;

interface

uses
  SysUtils, IdHashMessageDigest, idHash,
  Classes;

type
  TFileSetting = record
    Url: string;
    Dest: string;
    FileName: String;
    Path: String;
    InitialSize: Int64;
  end;

 function ExtractUrlFileName(const AUrl: string): string;
 function GetFileSize(p_sFilePath : string) : Int64;
 function MD5(const fileName : string) : string;
 function NewFile(Url, Dest, FileName, Path: String): TFileSetting;

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


function MD5(const fileName : string) : string;
 var
   idmd5 : TIdHashMessageDigest5;
   fs : TFileStream;
   hash : T4x4LongWordRecord;
 begin
   idmd5 := TIdHashMessageDigest5.Create;
   fs := TFileStream.Create(fileName, fmOpenRead OR fmShareDenyWrite) ;
   try
     Result := idmd5.HashStreamAsHex(fs);
   finally
     fs.Free;
     idmd5.Free;
   end;
 end;


function NewFile(Url, Dest, FileName, Path: String): TFileSetting;
begin
  Result.Url      := Url;
  Result.Dest     := Dest;
  Result.FileName := FileName;
  Result.Path     := Path;
end;

end.
