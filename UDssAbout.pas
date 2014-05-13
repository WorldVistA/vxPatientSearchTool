unit UDssAbout;
{
Copyright 2012 Document Storage Systems, Inc. 
 
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
}
interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  jpeg;

type
  PVerTranslation = ^TVerTranslation;
  TVerTranslation = record
    Language : Word;
    CharSet  : Word;
  end;

type
  TDSSAboutDlg = class(TForm)
    Panel1: TPanel;
    lblCopyright: TLabel;
    lblCompany: TLabel;
    btnOk: TButton;
    Bevel1: TBevel;
    Memo1: TMemo;
    lblWebAddress: TLabel;
    lblCNTVersion: TLabel;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
    procedure lblWebAddressClick(Sender: TObject);
  private
  public                                         
  end;

var
  DSSAboutDlg: TDSSAboutDlg;

function FileVersionGet(const sgFileName: string) : string; 

implementation

{$R *.DFM}

uses shellAPI, DateUtils;

function FileVersionGet(const sgFileName: string) : string; 
var
  infoSize: DWORD;
  verBuf: pointer;
  verSize: UINT;
  wnd: UINT;
  FixedFileInfo : PVSFixedFileInfo;
begin 
  infoSize := GetFileVersioninfoSize(PChar(sgFileName), wnd);

  result := '';
  if infoSize <> 0 then
  begin
  GetMem(verBuf, infoSize);
    try
      if GetFileVersionInfo(PChar(sgFileName), wnd, infoSize, verBuf) then
        begin
        VerQueryValue(verBuf, '\', Pointer(FixedFileInfo), verSize);

        result := IntToStr(FixedFileInfo.dwFileVersionMS div $10000) + '.' +
        IntToStr(FixedFileInfo.dwFileVersionMS and $0FFFF) + '.' +
        IntToStr(FixedFileInfo.dwFileVersionLS div $10000) + '.' +
        IntToStr(FixedFileInfo.dwFileVersionLS and $0FFFF);
        end;
    finally
      FreeMem(verBuf);
    end;
  end;
end; 

procedure TDSSAboutDlg.FormShow(Sender: TObject);
var
  Memstat: TMemoryStatus;
  MyVerInfo: TOSVersionInfo;
  OSystem: string;
  sInternalName : string;
  ret: string;
begin
  //ProgramIcon.Picture.Assign(Application.Icon);
  // Version info
  MyVerInfo.dwOSVersionInfoSize :=SizeOf(TOSVersionInfo);
  GetVersionEx(MyVerInfo);

  // Memory Info
  Memstat.dwLength := SizeOf(TMemoryStatus);
  GlobalMemoryStatus(MemStat);

  // Text
  lblCompany.Caption := 'Patient Search Tool';
  //lblAppName.Caption := '';//'Patient Search Tool';
  ret := FileVersionGet('DSSPatientRecordSearch.dll');
  lblCNTVersion.Caption := 'Version: ' + ret;
  lblCopyright.Caption := 'Copyright ' + chr(169) + ' 2011-'+ IntToStr(YearOf(Now)) + ', DSS Inc.';

  OSystem := OSystem + ' ' + InttoStr(MyVerInfo.dwmajorVersion) + '.' + InttoStr(MyVerInfo.dwminorVersion) + ' build(' + InttoStr(MyVerInfo.dwBuildNumber) + ')';
  //labelOS.Caption := OSystem;
  //labelMemory.Caption := 'Memory Available: ' + IntToStr(Round(MemStat.dwTotalPhys/1024)) + ' KB';
end;

procedure TDSSAboutDlg.lblWebAddressClick(Sender: TObject);
  var TempString : array[0..79] of char;
begin
  StrPCopy(TempString,lblWebAddress.Caption);
  ShellExecute(0, Nil, TempString, Nil, Nil, SW_NORMAL);
end;

end.

