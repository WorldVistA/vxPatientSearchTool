unit rReports;
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

uses Windows, SysUtils, Classes, ORNet, ORFn, ComCtrls, Chart, graphics, Dialogs,
  fSearchCriteria;

{ Consults }
procedure ListConsults(Dest: TStrings);
procedure LoadConsultText(Dest: TStrings; IEN: Integer);

{ Reports }
procedure ListReports(Dest: TStrings);
procedure ListLabReports(Dest: TStrings);
procedure ListReportDateRanges(Dest: TStrings);
procedure ListHealthSummaryTypes(Dest: TStrings);
procedure ListImagingExams(Dest: TStrings);
procedure ListProcedures(Dest: TStrings);
procedure ListNutrAssessments(Dest: TStrings);
procedure ListSurgeryReports(Dest: TStrings);
procedure ColumnHeaders(Dest: TStrings; AReportType: String);
procedure SaveColumnSizes(aColumn: String);
//procedure LoadReportText(Dest: TStrings; ReportType: string; const Qualifier: string; ARpc, AHSTag: string); //kw - ORIG
function LoadReportText(Dest: TStrings; ReportType: string; const Qualifier: string; ARpc, AHSTag: string) : string; //kw
procedure RemoteQueryAbortAll;
procedure RemoteQuery(Dest: TStrings; AReportType: string; AHSType, ADaysback,
            AExamID: string; Alpha, AOmega: Double; ASite, ARemoteRPC, AHSTag: String);
procedure DirectQuery(Dest: TStrings; AReportType: string; AHSType, ADaysback,
            AExamID: string; Alpha, AOmega: Double; ASite, ARemoteRPC, AHSTag: String);
function ReportQualifierType(ReportType: Integer): Integer;
function ImagingParams: String;
function AutoRDV: String;
function HDRActive: String;
procedure PrintReportsToDevice(AReport: string; const Qualifier, Patient,
     ADevice: string; var ErrMsg: string; aComponents: TStringlist;
     ARemoteSiteID, ARemoteQuery, AHSTag: string);
function HSFileLookup(aFile: String; const StartFrom: string;
         Direction: Integer): TStrings;
procedure HSComponentFiles(Dest: TStrings; aComponent: String);
procedure HSSubItems(Dest: TStrings; aItem: String);
procedure HSReportText(Dest: TStrings; aComponents: TStringlist);
procedure HSComponents(Dest: TStrings);
procedure HSABVComponents(Dest: TStrings);
procedure HSDispComponents(Dest: TStrings);
procedure HSComponentSubs(Dest: TStrings; aItem: String);
procedure HealthSummaryCheck(Dest: TStrings; aQualifier: string);
function GetFormattedReport(AReport: string; const Qualifier, Patient: string;
           aComponents: TStringlist; ARemoteSiteID, ARemoteQuery, AHSTag: string): TStrings;
procedure PrintWindowsReport(ARichEdit: TRichEdit; APageBreak, ATitle: string;
  var ErrMsg: string; IncludeHeader: Boolean = false);
function DefaultToWindowsPrinter: Boolean;
procedure PrintGraph(GraphImage: TChart; PageTitle: string);
procedure PrintBitmap(Canvas: TCanvas; DestRect: TRect; Bitmap: TBitmap);
procedure CreatePatientHeader(var HeaderList: TStringList; PageTitle: string);
procedure SaveDefaultPrinter(DefPrinter: string) ;
function GetRemoteStatus(aHandle: string): String;
function GetAdhocLookup: integer;
procedure SetAdhocLookup(aLookup: integer);
procedure GetRemoteData(Dest: TStrings; aHandle: string; aItem: PChar);
procedure ModifyHDRData(Dest: string; aHandle: string; aID: string);
procedure PrintVReports(Dest, ADevice, AHeader: string; AReport: TStringList);

function IsRemoteReport(thisReportIDString: string) : boolean; //kw - added

const
  REMOTE_REPORT = '1'; //kw - added

var
  thisfrmSearchCriteria: fSearchCriteria.TfrmSearchCriteria;
  //reportID: string; //moved to fSearchCriteria.pas

implementation

uses Printers, clipbrd,
  uCore, rCore, uReports, fReportSelect;

var
  //thisfrmSearchCriteria: fSearchCriteria.TfrmSearchCriteria;

  uTree:       TStringList;
  uReportsList:    TStringList;
  uLabReports: TStringList;
  uDateRanges: TStringList;
  uHSTypes:    TStringList;

{ Consults }

procedure ListConsults(Dest: TStrings);
var
  i: Integer;
  x: string;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWCS LIST OF CONSULT REPORTS', [Patient.DFN]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  with RPCBrokerV do
  begin
    SortByPiece(TStringList(Results), U, 2);
    InvertStringList(TStringList(Results));
    SetListFMDateTime('mmm dd,yy', TStringList(Results), U, 2);
    for i := 0 to Results.Count - 1 do
    begin
      x := Results[i];
      x := Pieces(x, U, 1, 2) + U + Piece(x, U, 3) + '  (' + Piece(x, U, 4) + ')';
      Results[i] := x;
    end;
    FastAssign(Results, Dest);
  end;
end;

procedure LoadConsultText(Dest: TStrings; IEN: Integer);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWCS REPORT TEXT', [Patient.DFN, IEN]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

{ Reports }

function IsRemoteReport(thisReportIDString: string) : boolean; //kw - added
begin
  result := true;
  if Piece(thisReportIDString,U,7) = '' then
    result := false;
end;

procedure ExtractSection(Dest: TStrings; const Section: string; Mixed: Boolean);
//kw - Load the 'Section' text into a string list (ie, Dest)
//Ref:  id^Name^Qualifier^HSTag;Routine^Entry^Routine^Remote^Type^Category^RPC^ifn^SortOrder^MaxDaysBack^Direct^HDR^FHIE
var
  i: Integer;
  isAdHoc: boolean;
begin
  try
    i := -1;
    repeat
    //kw - Spin thru the broker results until we find the [SECTION] that was passed in as a param
    //     We'll either hit the end of the list, or we will find the Section
      Inc(i)
    until (i = RPCBrokerV.Results.Count) or (RPCBrokerV.Results[i] = Section);

    Inc(i);

    while (i < RPCBrokerV.Results.Count) and (RPCBrokerV.Results[i] <> '$$END') do //kw - ORIG - $$END designates the end of the Section
    //while (i < RPCBrokerV.Results.Count) and ( (Piece(RPCBrokerV.Results[i],'^',1) <> '[PARENT END]') and (Piece(RPCBrokerV.Results[i],'^',3) <> 'Clinical Reports')) do //kw
      begin
{
      //**********************************************************************************************
      //kw - REINSTATE this IF you want to restrict which reports show up in the reports TTreeview
      //kw - Filter out all unwanted reports
      if Piece(RPCBrokerV.Results[i],'^',7) = REMOTE_REPORT then
        begin
        Inc(i);
        //Continue;
        //if ( (Piece(RPCBrokerV.Results[i],'^',1) = '[PARENT END]') and (Piece(RPCBrokerV.Results[i],'^',3) = 'Clinical Reports')) then
          //Break;
        end
      else
      //**********************************************************************************************
}
        begin
        isAdHoc := false;
        if Piece(RPCBrokerV.Results[i],'^', 1) <> 'h0' then
          isAdHoc := false
        else
          isAdHoc := true;

        //if Section = '[HEALTH SUMMARY TYPES]' then //kw - debug
          //showmessage(Section + CRLF + 'i = ' + inttoStr(i) + CRLF + RPCBrokerV.Results[i]); //kw - debug

        //Ref:  id^Name^Qualifier^HSTag;Routine^Entry^Routine^Remote^Type^Category^RPC^ifn^SortOrder^MaxDaysBack^Direct^HDR^FHIE

        if Mixed = true then
          begin
          if {(Piece(RPCBrokerV.Results[i],'^', 7) <> '1') and} (isAdHoc = false) then  //kw - added to filter out AdHoc and Remote reports
            Dest.Add(MixedCase(RPCBrokerV.Results[i]))  //ORIG - Broker results contains the report list at this point
          end
        else
          if {(Piece(RPCBrokerV.Results[i],'^', 7) <> '1') and} (isAdHoc = false) then  //kw - added to filter out AdHoc and Remote reports
            Dest.Add(RPCBrokerV.Results[i]);  //ORIG - Add the current broker result (i) to our string list
        Inc(i);
        end;
      end;
  except
    on E: Exception do
    MessageDlg(GENERAL_EXCEPTION_MSG + ' rReports.ExtractSection()' + CRLF +
      E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure LoadReportLists;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP REPORT LISTS', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  uDateRanges := TStringList.Create;
  uHSTypes    := TStringList.Create;
  uReportsList    := TStringList.Create;
  ExtractSection(uDateRanges, '[DATE RANGES]', true);
  ExtractSection(uHSTypes,    '[HEALTH SUMMARY TYPES]', true);
  ExtractSection(uReportsList,    '[REPORT LIST]', true);
end;

procedure LoadLabReportLists;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP LAB REPORT LISTS', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  uLabReports  := TStringList.Create;
  ExtractSection(uLabReports, '[LAB REPORT LIST]', true);
end;

procedure LoadTree(Tab: String);
begin
  thisfrmSearchCriteria := (fReportSelect.pfrmSearchCriteria as TfrmSearchCriteria); //Get a pointer to the main form
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP3 EXPAND COLUMNS', [Tab]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  uTree    := TStringList.Create;
  ExtractSection(uTree, '[REPORT LIST]', false);
end;

procedure ListReports(Dest: TStrings);
var
  i: Integer;
begin
  if uTree = nil
    then LoadTree('REPORTS')
  else
    begin
      uTree.Clear;
      LoadTree('REPORTS');
    end;

  try
    for i := 0 to uTree.Count - 1 do
      begin
      Dest.Add(Pieces(uTree[i], '^', 1, 20));
      //frmReportSelect.lbSelectedReports.AddItem(Dest.Strings[i],nil); //kw - debug
      end;
  except
    on E: Exception do
      MessageDlg('An error has occurred in procedure rReports.ListReports()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure ListLabReports(Dest: TStrings);
var
  i: integer;
begin
  {if uLabreports = nil then LoadLabReportLists;
  for i := 0 to uLabReports.Count - 1 do Dest.Add(Pieces(uLabReports[i], U, 1, 10)); }
  if uTree = nil
    then LoadTree('LABS')
  else
    begin
      uTree.Clear;
      LoadTree('LABS');
    end;
  for i := 0 to uTree.Count - 1 do Dest.Add(Pieces(uTree[i], '^', 1, 20));
end;

procedure ListReportDateRanges(Dest: TStrings);
begin
  if uDateRanges = nil then LoadReportLists;
  FastAssign(uDateRanges, Dest);
end;

procedure ListHealthSummaryTypes(Dest: TStrings);
begin
  if uHSTypes = nil then LoadReportLists;
  MixedCaseList(uHSTypes);
  FastAssign(uHSTypes, Dest);
end;

procedure HealthSummaryCheck(Dest: TStrings; aQualifier: string);

begin
  if aQualifier = '1' then
    begin
      ListHealthSummaryTypes(Dest);
    end;
end;

procedure ColumnHeaders(Dest: TStrings; AReportType: String);
//Get list of Column headers for a ListView type report from file 101.24
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP COLUMN HEADERS',[AReportType]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  FastAssign(RPCBrokerV.Results, Dest);
end;

procedure SaveColumnSizes(aColumn: String);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWCH SAVECOL', [aColumn]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

procedure ListImagingExams(Dest: TStrings);
var
  x: string;
  i: Integer;
begin
  thisfrmSearchCriteria := (fReportSelect.pfrmSearchCriteria as TfrmSearchCriteria); //Get a pointer to the main form so we can get current PatientIEN
  //CallV('ORWRA IMAGING EXAMS1', [Patient.DFN]); //kw - ORIG
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRA IMAGING EXAMS1', [thisfrmSearchCriteria.PatientIEN]);
  thisfrmSearchCriteria.stUpdateContext(origContext);

  with RPCBrokerV do
  begin
    SetListFMDateTime('mm/dd/yyyy hh:nn', TStringList(Results), U, 3);
    for i := 0 to Results.Count - 1 do
    begin
      x := Results[i];
      if Piece(x,U,7) = 'Y' then SetPiece(x,U,7, ' - Abnormal');
        x := Piece(x,U,1) + U + 'i' + Pieces(x,U,2,3)+ U + Piece(x,U,4)
             + U + Piece(x,U,6)  + Piece(x,U,7) + U
             + MixedCase(Piece(Piece(x,U,9),'~',2)) + U + Piece(x,U,5) +  U + '[+]'
             + U + Pieces(x, U, 15,17);                                                 
(*      x := Piece(x,U,1) + U + 'i' + Pieces(x,U,2,3)+ U + Piece(x,U,4)
        + U + Piece(x,U,6) + Piece(x,U,7) + U + Piece(x,U,5) +  U + '[+]' + U + Piece(x, U, 15);*)
      Results[i] := x;
    end;
    FastAssign(Results, Dest);
  end;
end;

procedure ListProcedures(Dest: TStrings);
var
  x,sdate: string;
  i: Integer;
begin
  thisfrmSearchCriteria := (fReportSelect.pfrmSearchCriteria as TfrmSearchCriteria); //Get a pointer to the main form so we can get current PatientIEN
  //CallV('ORWMC PATIENT PROCEDURES1', [Patient.DFN]);
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWMC PATIENT PROCEDURES1', [thisfrmSearchCriteria.PatientIEN]);
  thisfrmSearchCriteria.stUpdateContext(origContext);

  with RPCBrokerV do
  begin
    for i := 0 to Results.Count - 1 do
    begin
      x := Results[i];
      if length(piece(x, U, 8)) > 0 then
        begin
          sdate := ShortDateStrToDate(piece(piece(x, U, 8),'@',1)) + ' ' + piece(piece(x, U, 8),'@',2);
        end;
      x := Piece(x, U, 1) + U + 'i' + Piece(x, U, 2) + U + sdate + U + Piece(x, U, 3) + U + Piece(x, U, 9) + '^[+]';
      Results[i] := x;
    end;
    FastAssign(Results, Dest);
  end;
end;

procedure ListNutrAssessments(Dest: TStrings);
var
  x: string;
  i: Integer;
begin
  thisfrmSearchCriteria := (fReportSelect.pfrmSearchCriteria as TfrmSearchCriteria); //kw - Get a pointer to the main form so we can get current PatientIEN
  //CallV('ORWRP1 LISTNUTR', [Patient.DFN]);
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP1 LISTNUTR', [thisfrmSearchCriteria.PatientIEN]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  with RPCBrokerV do
  begin
    for i := 0 to Results.Count - 1 do
      begin
        x := Results[i];
        x := Piece(x, U, 1) + U + 'i' + Piece(x, U, 3) + U + Piece(x, U, 3);
        Results[i] := x;
      end;
    FastAssign(Results, Dest);
  end;
end;

procedure ListSurgeryReports(Dest: TStrings);
{ returns a list of surgery cases for a patient, without documents}
//Facility^Case #^Date/Time of Operation^Operative Procedure^Surgeon name)
var
  i: integer;
  x, AFormat: string;
begin
  thisfrmSearchCriteria := (fReportSelect.pfrmSearchCriteria as TfrmSearchCriteria); //Get a pointer to the main form so we can get current PatientIEN
  //CallV('ORWSR RPTLIST', [Patient.DFN]);
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWSR RPTLIST', [thisfrmSearchCriteria.PatientIEN]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  with RPCBrokerV do
   begin
    for i := 0 to Results.Count - 1 do
      begin
        x := Results[i];
        if Piece(Piece(x, U, 3), '.', 2) = '' then AFormat := 'mm/dd/yyyy' else AFormat := 'mm/dd/yyyy hh:nn';
        x := Piece(x, U, 1) + U + 'i' + Piece(x, U, 2) + U + FormatFMDateTimeStr(AFormat, Piece(x, U, 3))+ U +
             Piece(x, U, 4)+ U + Piece(x, U, 5);
        if Piece(Results[i], U, 6) = '+' then x := x + '^[+]';
        Results[i] := x;
      end;
    FastAssign(Results, Dest);
  end;
end;

//procedure LoadReportText(Dest: TStrings; ReportType: string; const Qualifier: string; ARpc, AHSTag: string);
function LoadReportText(Dest: TStrings; ReportType: string; const Qualifier: string; ARpc, AHSTag: string) : string;
var
  HSType, DaysBack, ExamID, MaxOcc, AReport, x: string;
  Alpha, Omega, Trans: double;

  thisResult: string; //debug
  i: integer; //debug
begin
  HSType := '';
  DaysBack := '';
  ExamID := '';
  Alpha := 0;
  Omega := 0;
  if CharAt(Qualifier, 1) = 'T' then
    begin
      Alpha := StrToFMDateTime(Piece(Qualifier,';',1));
      Omega := StrToFMDateTime(Piece(Qualifier,';',2));
      if Alpha > Omega then
        begin
          Trans := Omega;
          Omega := Alpha;
          Alpha := Trans;
        end;
      MaxOcc := Piece(Qualifier,';',3);
      SetPiece(AHSTag,';',4,MaxOcc);
    end;
  if CharAt(Qualifier, 1) = 'd' then
    begin
      MaxOcc := Piece(Qualifier,';',2);
      SetPiece(AHSTag,';',4,MaxOcc);
      x := Piece(Qualifier,';',1);
      DaysBack := Copy(x, 2, Length(x));
    end;
  if CharAt(Qualifier, 1) = 'h' then
    HSType   := Copy(Qualifier, 2, Length(Qualifier));
  if CharAt(Qualifier, 1) = 'i' then
    ExamID   := Copy(Qualifier, 2, Length(Qualifier));


  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  AReport := ReportType + '~' + AHSTag;  // <------------------------------------------------ //kw - SAVE 'AReport' AS NEW PARAMETER
  thisfrmSearchCriteria := (fReportSelect.pfrmSearchCriteria as TfrmSearchCriteria); //Get a pointer to the main form
  thisfrmSearchCriteria.ReportID := AReport; //kw - Copy it to the global var 'reportID' so we can get to it from from frmReportSelect.
  //fSearchCriteria.reportIDList.Add(AReport);
  thisfrmSearchCriteria.ReportID := AReport;
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if Length(ARpc) > 0 then
    begin
      try
        thisfrmSearchCriteria := (fReportSelect.pfrmSearchCriteria as TfrmSearchCriteria); //Get a pointer to the main form so we can get current PatientIEN
                           //CallV(ARpc, [Patient.DFN, AReport, HSType, DaysBack, ExamID, Alpha, Omega]);   //kw - ORIG commented

        //showmessage(thisfrmSearchCriteria.PatientIEN +  #13#10 + AReport +  HSType + DaysBack + ExamID +  floatToStr(Alpha) +  ' ' + floatToStr(Omega)); //kw - debug
        //CallV(ARpc, [thisfrmSearchCriteria.PatientIEN, AReport, HSType, DaysBack, ExamID, Alpha, Omega]); //kw
        result := thisfrmSearchCriteria.PatientIEN + U + AReport +   U + HSType +  U + DaysBack +  U + ExamID + U + floatToStr(Alpha) + U + floatToStr(Omega);

        //kw - Debug
          //for i := 0 to RPCBrokerV.Results.Count-1 do
            //fReportSelect.frmReportSelect.memText.Lines.Add(RPCBrokerV.Results[i]);
        //if RPCBrokerV.Results.Count > 0 then
          //showmessage('RPCBrokerV.Results.Count = ' + inttostr(RPCBrokerV.Results.Count));

        //QuickCopy(RPCBrokerV.Results, Dest);

        //Dest := RPCBrokerV.Results;
        //for i := 0 to RPCBrokerV.Results.Count-1 do
          //Dest.Add(RPCBrokerV.Results[i]);

        //kw - debug ///////////////////////////////////////////////
        {
        for i := 0 to RPCBrokerV.Results.Count-1 do
          thisResult := thisResult + RPCBrokerV.Results[i] + #13#10;
        showmessage(thisResult);
        }
        //kw - end debug //////////////////////////////////////////

      finally
        //kw - YOU CANT DO THIS HERE
        // If you do, then you lose the reference, and you wont be able to list the sub-reports.
        // FIGURE OUT SOMEWHERE ELSE TO FREE IT, OR ANOTHER WAY TO DO IT 
        //if thisfrmSearchCriteria <> nil then
          //thisfrmSearchCriteria.Free; //Free the pointer to the main form
      end
    end
  else
    begin
      Dest.Add('RPC is missing from report definition (file 101.24).');
      Dest.Add('Please contact Technical Support.');
    end;
end;

procedure RemoteQueryAbortAll;
begin
  CallV('XWB DEFERRED CLEARALL',[nil]);
end;

procedure RemoteQuery(Dest: TStrings; AReportType: string; AHSType, ADaysback,
            AExamID: string; Alpha, AOmega: Double; ASite, ARemoteRPC, AHSTag: String);
var
  AReport: string;
begin
  AReport := AReportType + ';1' + '~' + AHSTag;
  if length(AHSType) > 0 then
    AHSType := piece(AHSType,':',1) + ';' + piece(AHSType,':',2);  //format for backward compatibility

  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('XWB REMOTE RPC', [ASite, ARemoteRPC, 0, Patient.DFN + ';' + Patient.ICN,AReport, AHSType, ADaysBack, AExamID, Alpha, AOmega]);
  thisfrmSearchCriteria.stUpdateContext(origContext);

  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure DirectQuery(Dest: TStrings; AReportType: string; AHSType, ADaysback,
            AExamID: string; Alpha, AOmega: Double; ASite, ARemoteRPC, AHSTag: String);
var
  AReport: string;
begin
  AReport := AReportType + ';1' + '~' + AHSTag;
  if length(AHSType) > 0 then
    AHSType := piece(AHSType,':',1) + ';' + piece(AHSType,':',2);  //format for backward compatibility

  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('XWB DIRECT RPC', [ASite, ARemoteRPC, 0, Patient.DFN + ';' + Patient.ICN,AReport, AHSType, ADaysBack, AExamID, Alpha, AOmega]);
  thisfrmSearchCriteria.stUpdateContext(origContext);

  QuickCopy(RPCBrokerV.Results,Dest);
end;

function ReportQualifierType(ReportType: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to uReportsList.Count - 1 do
    if StrToIntDef(Piece(uReportsList[i], U, 1), 0) = ReportType
      then Result := StrToIntDef(Piece(uReportsList[i], U, 3), 0);
end;

function ImagingParams: String;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  Result := sCallV('ORWTPD GETIMG',[nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

function AutoRDV: String;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  Result := sCallV('ORWCIRN AUTORDV', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

function HDRActive: String;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  Result := sCallV('ORWCIRN HDRON', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

procedure PrintVReports(Dest, ADevice, AHeader: string; AReport: TStringList);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP PRINT V REPORT', [ADevice, Patient.DFN, AHeader, AReport]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

procedure PrintReportsToDevice(AReport: string; const Qualifier, Patient, ADevice: string;
 var ErrMsg: string; aComponents: TStringlist; ARemoteSiteID, ARemoteQuery, AHSTag: string);
{ prints a report on the selected device }
var
  HSType, DaysBack, ExamID, MaxOcc, ARpt, x: string;
  Alpha, Omega: double;
  j: integer;
  RemoteHandle,Report: string;
  aHandles: TStringlist;
begin
  HSType := '';
  DaysBack := '';
  ExamID := '';
  Alpha := 0;
  Omega := 0;
  aHandles := TStringList.Create;
  if CharAt(Qualifier, 1) = 'T' then
    begin
      Alpha := StrToFMDateTime(Piece(Qualifier,';',1));
      Omega := StrToFMDateTime(Piece(Qualifier,';',2));
      MaxOcc := Piece(Qualifier,';',3);
      SetPiece(AHSTag,';',4,MaxOcc);
    end;
  if CharAt(Qualifier, 1) = 'd' then
    begin
      MaxOcc := Piece(Qualifier,';',2);
      SetPiece(AHSTag,';',4,MaxOcc);
      x := Piece(Qualifier,';',1);
      DaysBack := Copy(x, 2, Length(x));
    end;
  if CharAt(Qualifier, 1) = 'h' then HSType   := Copy(Qualifier, 2, Length(Qualifier));
  if CharAt(Qualifier, 1) = 'i' then ExamID   := Copy(Qualifier, 2, Length(Qualifier));
  if Length(ARemoteSiteID) > 0 then
    begin
      RemoteHandle := '';
      for j := 0 to RemoteReports.Count - 1 do
        begin
          Report := TRemoteReport(RemoteReports.ReportList.Items[j]).Report;
          if Report = ARemoteQuery then
            begin
              RemoteHandle := TRemoteReport(RemoteReports.ReportList.Items[j]).Handle
                + '^' + Pieces(Report,'^',9,10);
              break;
            end;
        end;
      if Length(RemoteHandle) > 1 then
        with RemoteSites.SiteList do
            aHandles.Add(ARemoteSiteID + '^' + RemoteHandle);
    end;
  ARpt := AReport + '~' + AHSTag;
  if aHandles.Count > 0 then
    begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      ErrMsg := sCallV('ORWRP PRINT REMOTE REPORT',[ADevice, Patient, ARpt, aHandles]);
      thisfrmSearchCriteria.stUpdateContext(origContext);
      if Piece(ErrMsg, U, 1) = '0' then ErrMsg := '' else ErrMsg := Piece(ErrMsg, U, 2);
    end
  else
    begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      ErrMsg := sCallV('ORWRP PRINT REPORT',[ADevice, Patient, ARpt, HSType,DaysBack, ExamID, aComponents, Alpha, Omega]);
      thisfrmSearchCriteria.stUpdateContext(origContext);
      if Piece(ErrMsg, U, 1) = '0' then ErrMsg := '' else ErrMsg := Piece(ErrMsg, U, 2);
    end;
  aHandles.Clear;
  aHandles.Free;
end;

function GetFormattedReport(AReport: string; const Qualifier, Patient: string;
         aComponents: TStringlist; ARemoteSiteID, ARemoteQuery, AHSTag: string): TStrings;
{ prints a report on the selected device }
var
  HSType, DaysBack, ExamID, MaxOcc, ARpt, x: string;
  Alpha, Omega: double;
  j: integer;
  RemoteHandle,Report: string;
  aHandles: TStringlist;
begin
  HSType := '';
  DaysBack := '';
  ExamID := '';
  Alpha := 0;
  Omega := 0;
  aHandles := TStringList.Create;
  if CharAt(Qualifier, 1) = 'T' then
    begin
      Alpha := StrToFMDateTime(Piece(Qualifier,';',1));
      Omega := StrToFMDateTime(Piece(Qualifier,';',2));
      MaxOcc := Piece(Qualifier,';',3);
      SetPiece(AHSTag,';',4,MaxOcc);
    end;
  if CharAt(Qualifier, 1) = 'd' then
    begin
      MaxOcc := Piece(Qualifier,';',2);
      SetPiece(AHSTag,';',4,MaxOcc);
      x := Piece(Qualifier,';',1);
      DaysBack := Copy(x, 2, Length(x));
    end;
  if CharAt(Qualifier, 1) = 'h' then HSType   := Copy(Qualifier, 2, Length(Qualifier));
  if CharAt(Qualifier, 1) = 'i' then ExamID   := Copy(Qualifier, 2, Length(Qualifier));
  if Length(ARemoteSiteID) > 0 then
    begin
      RemoteHandle := '';
      for j := 0 to RemoteReports.Count - 1 do
        begin
          Report := TRemoteReport(RemoteReports.ReportList.Items[j]).Report;
          if Report = ARemoteQuery then
            begin
              RemoteHandle := TRemoteReport(RemoteReports.ReportList.Items[j]).Handle
                + '^' + Pieces(Report,'^',9,10);
              break;
            end;
        end;
      if Length(RemoteHandle) > 1 then
        with RemoteSites.SiteList do
            aHandles.Add(ARemoteSiteID + '^' + RemoteHandle);
    end;
  ARpt := AReport + '~' + AHSTag;
  if aHandles.Count > 0 then
    begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      CallV('ORWRP PRINT WINDOWS REMOTE',[Patient, ARpt, aHandles]);
      thisfrmSearchCriteria.stUpdateContext(origContext);
      Result := RPCBrokerV.Results;
    end
  else
    begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      CallV('ORWRP PRINT WINDOWS REPORT',[Patient, ARpt, HSType,DaysBack, ExamID, aComponents, Alpha, Omega]);
      thisfrmSearchCriteria.stUpdateContext(origContext);
      Result := RPCBrokerV.Results;
    end;
  aHandles.Clear;
  aHandles.Free;
end;

function DefaultToWindowsPrinter: Boolean;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  Result := (StrToIntDef(sCallV('ORWRP WINPRINT DEFAULT',[]), 0) > 0);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

procedure PrintWindowsReport(ARichEdit: TRichEdit; APageBreak, Atitle: string; var ErrMsg: string; IncludeHeader: Boolean = false);
var
  i, j, x, y, LineHeight: integer;
  aGoHead: string;
  aHeader: TStringList;
const
  TX_ERR_CAP = 'Print Error';
  TX_FONT_SIZE = 10;
  TX_FONT_NAME = 'Courier New';
begin
  aHeader := TStringList.Create;
  aGoHead := '';
  if piece(Atitle,';',2) = '1' then
    begin
      Atitle := piece(Atitle,';',1);
      aGoHead := '1';
    end;
  CreatePatientHeader(aHeader ,ATitle);
  with ARichEdit do
    begin
(*      if Lines[Lines.Count - 1] = APageBreak then      //  remove trailing form feed
        Lines.Delete(Lines.Count - 1);
      while (Lines[0] = '') or (Lines[0] = APageBreak) do
        Lines.Delete(0);                               //  remove leading blank lines and form feeds*)

        {v20.4 - SFC-0602-62899 - RV}
        while (Lines.Count > 0) and ((Lines[Lines.Count - 1] = '') or (Lines[Lines.Count - 1] = APageBreak)) do
          Lines.Delete(Lines.Count - 1);                 //  remove trailing blank lines and form feeds
        while (Lines.Count > 0) and ((Lines[0] = '') or (Lines[0] = APageBreak)) do
          Lines.Delete(0);                               //  remove leading blank lines and form feeds

      if Lines.Count > 1 then
        begin
(*          i := Lines.IndexOf(APageBreak);
          if ((i >= 0 ) and (i < Lines.Count - 1)) then        // removed in v15.9 (RV)
            begin*)
              Printer.Canvas.Font.Size := TX_FONT_SIZE;
              Printer.Canvas.Font.Name := TX_FONT_NAME;
              Printer.Title := ATitle;
              x := Trunc(Printer.Canvas.TextWidth(StringOfChar('=', TX_FONT_SIZE)) * 0.75);
              LineHeight := Printer.Canvas.TextHeight(TX_FONT_NAME);
              y := LineHeight * 5;            // 5 lines = .83" top margin   v15.9 (RV)
              Printer.BeginDoc;

              //Do we need to add the header?
              IF IncludeHeader then begin
               for j := 0 to aHeader.Count - 1 do
                begin
                 Printer.Canvas.TextOut(x, y, aHeader[j]);
                 y := y + LineHeight;
                end;
              end;

              for i := 0 to Lines.Count - 1 do
                begin
                  if Lines[i] = APageBreak then
                    begin
                      Printer.NewPage;
                      y := LineHeight * 5;   // 5 lines = .83" top margin    v15.9 (RV)
                      if (IncludeHeader) then
                        begin
                          for j := 0 to aHeader.Count - 1 do
                            begin
                              Printer.Canvas.TextOut(x, y, aHeader[j]);
                              y := y + LineHeight;
                            end;
                        end;
                    end
                  else
                    begin
                      Printer.Canvas.TextOut(x, y, Lines[i]);
                      y := y + LineHeight;
                    end;
                end;
              Printer.EndDoc;
(*            end
          else                               // removed in v15.9 (RV)  TRichEdit.Print no longer used.
            try
              Font.Size := TX_FONT_SIZE;
              Font.Name := TX_FONT_NAME;
              Print(ATitle);
            except
              ErrMsg := TX_ERR_CAP;
            end;*)
        end
      else if ARichEdit.Lines.Count = 1 then
        if Piece(ARichEdit.Lines[0], U, 1) <> '0' then
          ErrMsg := Piece(ARichEdit.Lines[0], U, 2);
    end;
  aHeader.Free;
end;

procedure CreatePatientHeader(var HeaderList: TStringList; PageTitle: string);
// standard patient header, from HEAD^ORWRPP
var
  tmpStr, tmpItem: string;
begin
  with HeaderList do
    begin
      Add(' ');
      Add(StringOfChar(' ', (74 - Length(PageTitle)) div 2) + PageTitle);
      Add(' ');
      tmpStr := Patient.Name + '   ' + Patient.SSN;
      tmpItem := tmpStr + StringOfChar(' ', 39 - Length(tmpStr)) + Encounter.LocationName;
      tmpStr := FormatFMDateTime('mmm dd, yyyy', Patient.DOB) + ' (' + IntToStr(Patient.Age) + ')';
      tmpItem := tmpItem + StringOfChar(' ', 74 - (Length(tmpItem) + Length(tmpStr))) + tmpStr;
      Add(tmpItem);
      Add(StringOfChar('=', 74));
      Add('*** WORK COPY ONLY ***' + StringOfChar(' ', 24) + 'Printed: ' + FormatFMDateTime('mmm dd, yyyy  hh:nn', FMNow));
      Add(' ');
      Add(' ');
    end;
end;

procedure PrintGraph(GraphImage: TChart; PageTitle: string);
var
  AHeader: TStringList;
  i, y, LineHeight: integer;
  GraphPic: TBitMap;
  Magnif: integer;
const
  TX_FONT_SIZE = 12;
  TX_FONT_NAME = 'Courier New';
  CF_BITMAP = 2;      // from Windows.pas
begin
  ClipBoard;
  AHeader := TStringList.Create;
  CreatePatientHeader(AHeader, PageTitle);
  GraphPic := TBitMap.Create;
  try
    GraphImage.CopyToClipboardBitMap;
    GraphPic.LoadFromClipBoardFormat(CF_BITMAP, ClipBoard.GetAsHandle(CF_BITMAP), 0);
    with Printer do
      begin
        Canvas.Font.Size := TX_FONT_SIZE;
        Canvas.Font.Name := TX_FONT_NAME;
        Title := PageTitle;
        Magnif := (Canvas.TextWidth(StringOfChar('=', 74)) div GraphImage.Width);
        LineHeight := Printer.Canvas.TextHeight(TX_FONT_NAME);
        y := LineHeight;
        BeginDoc;
        try
          for i := 0 to AHeader.Count - 1 do
            begin
              Canvas.TextOut(0, y, AHeader[i]);
              y := y + LineHeight;
            end;
          y := y + (4 * LineHeight);
          //GraphImage.PrintPartial(Rect(0, y, Canvas.TextWidth(StringOfChar('=', 74)), y + (Magnif * GraphImage.Height)));
          PrintBitmap(Canvas, Rect(0, y, Canvas.TextWidth(StringOfChar('=', 74)), y + (Magnif * GraphImage.Height)), GraphPic);
        finally
          EndDoc;
        end;
      end;
  finally
    ClipBoard.Clear;
    GraphPic.Free;
    AHeader.Free;
  end;
end;

procedure SaveDefaultPrinter(DefPrinter: string) ;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP SAVE DEFAULT PRINTER', [DefPrinter]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

function HSFileLookup(aFile: String; const StartFrom: string;
          Direction:Integer): TStrings;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 HS FILE LOOKUP', [aFile, StartFrom, Direction]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  MixedCaseList(RPCBrokerV.Results);
  Result := RPCBrokerV.Results;
end;

procedure HSComponentFiles(Dest: TStrings; aComponent: String);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 HS COMP FILES', [aComponent]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure HSSubItems(Dest: TStrings; aItem: String);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 HS SUBITEMS', [aItem]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  MixedCaseList(RPCBrokerV.Results);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure HSReportText(Dest: TStrings; aComponents: TStringlist);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 HS REPORT TEXT', [aComponents, Patient.DFN]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure HSComponents(Dest: TStrings);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 HS COMPONENTS', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure HSABVComponents(Dest: TStrings);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 COMPABV', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure HSDispComponents(Dest: TStrings);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 COMPDISP', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure HSComponentSubs(Dest: TStrings; aItem: String);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 HS COMPONENT SUBS',[aItem]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  MixedCaseList(RPCBrokerV.Results);
  QuickCopy(RPCBrokerV.Results,Dest);
end;

function GetRemoteStatus(aHandle: string): String;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('XWB REMOTE STATUS CHECK', [aHandle]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  Result := RPCBrokerV.Results[0];
end;

function GetAdhocLookup: integer;
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 GETLKUP', [nil]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  if RPCBrokerV.Results.Count > 0 then
    Result := StrToInt(RPCBrokerV.Results[0])
  else
    Result := 0;
end;

procedure SetAdhocLookup(aLookup: integer);

begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP2 SAVLKUP', [IntToStr(aLookup)]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

procedure GetRemoteData(Dest: TStrings; aHandle: string; aItem: PChar);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('XWB REMOTE GETDATA', [aHandle]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  if RPCBrokerV.Results.Count < 1 then
    RPCBrokerV.Results[0] := 'No data found.';
  if (RPCBrokerV.Results.Count < 2) and (RPCBrokerV.Results[0] = '') then
    RPCBrokerV.Results[0] := 'No data found.';
  QuickCopy(RPCBrokerV.Results,Dest);
end;

procedure ModifyHDRData(Dest: string; aHandle: string; aID: string);
begin
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('ORWRP4 HDR MODIFY', [aHandle, aID]);
  thisfrmSearchCriteria.stUpdateContext(origContext);
end;

procedure PrintBitmap(Canvas:  TCanvas; DestRect:  TRect;  Bitmap:  TBitmap);
var
  BitmapHeader:  pBitmapInfo;
  BitmapImage :  POINTER;
  HeaderSize  :  DWORD;    // Use DWORD for D3-D5 compatibility
  ImageSize   :  DWORD;
begin
  GetDIBSizes(Bitmap.Handle, HeaderSize, ImageSize);
  GetMem(BitmapHeader, HeaderSize);
  GetMem(BitmapImage,  ImageSize);
  try
    GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
    StretchDIBits(Canvas.Handle,
                  DestRect.Left, DestRect.Top,     // Destination Origin
                  DestRect.Right  - DestRect.Left, // Destination Width
                  DestRect.Bottom - DestRect.Top,  // Destination Height
                  0, 0,                            // Source Origin
                  Bitmap.Width, Bitmap.Height,     // Source Width & Height
                  BitmapImage,
                  TBitmapInfo(BitmapHeader^),
                  DIB_RGB_COLORS,
                  SRCCOPY)
  finally
    FreeMem(BitmapHeader);
    FreeMem(BitmapImage)
  end
end {PrintBitmap};

initialization
  { nothing to initialize }

finalization
  uTree.Free;
  uReportsList.Free;
  uLabReports.Free;
  uDateRanges.Free;
  uHSTypes.Free;

end.
