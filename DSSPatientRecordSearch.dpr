library DSSPatientRecordSearch;
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

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  SysUtils,
  Classes,
  TRPCB,
  Dialogs,
  Forms,
  Controls,
  StdCtrls,
  fSearchCriteria in 'fSearchCriteria.pas',
  fSearchTerms in 'fSearchTerms.pas' {frmSearchTerms},
  fQuickSearch in 'fQuickSearch.pas' {frmQuickSearch},
  fSavedSearches in 'fSavedSearches.pas' {frmSavedSearches},
  rReports in 'rReports.pas',
  uReports in 'uReports.pas',
  fReportSelect in 'fReportSelect.pas' {frmReportSelect},
  ORNet;

{$R *.res}

var
 frmSearchCriteria: TfrmSearchCriteria;

function SearchExecute(thisRPCBroker: TRPCBroker; thisUserIEN: string; thisPatientIEN: string; var thisUpdateContext: TUpdateContext) : TfrmSearchCriteria; stdcall; export;
var
  p: pointer;
begin
  try
    if frmSearchCriteria = nil then
      frmSearchCriteria := TfrmSearchCriteria.Create(nil);

    if not Assigned(frmSearchCriteria.RPCBroker) then
      frmSearchCriteria.RPCBroker := TRPCBroker.Create(nil);

    if Assigned(frmSearchCriteria.RPCBroker) then
      begin
      frmSearchCriteria.RPCBroker := thisRPCBroker;
      fSearchCriteria.origContext := thisRPCBroker.CurrentContext; //<<<<<<<<< BUG FIX 20121004 - Added >>>>>>>>>>>

      ////////////////////////////////////////////////////////////
      //Get a procedural pointer to CPRS' UpdateContext() function
      ////////////////////////////////////////////////////////////
      // If we do not do this, then the ORNet.UpdateContext() that is referenced by this dll
      // will occur in the dll's memory partition which is different than the ORNet.UpdateContext()
      // function that CPRS refers to (in CPRS' memory partition), and will cause CPRS to produce 'Application Context...' errors.
      // This happens because before each RPC call in Search Tool, the broker context is changed
      // to 'DSIWA PATIENT RECORD SEARCH' by calling UpdateContext(). Since CPRS does not reference
      // the UpdateContext() that Search Tool dll is referencing, CPRS does not "know" about the
      // context change, and errors.
      // By passing this procedure reference from CPRS, we ensure that both CPRS and Search Tool dll
      // are calling the same UpdateContext(), thereby keeping CPRS 'up to date' on the current broker context.

      //If the procedure address being passed in from CPRS is *not* nil, then
      // assign the stUpdateContext field to the address of CPRS' UpdateContext().
      // Otherwise, assign it the local ORNet.UpdateContext(). We do this to enable
      // Search Tool to work with applications other than CPRS, which may not have an UpdateContext() function.
      p := @thisUpdateContext;
      if p <> nil then
        frmSearchCriteria.stUpdateContext := thisUpdateContext
      else
        frmSearchCriteria.stUpdateContext := ORNet.UpdateContext;

      ////////////////////////////////////////////////////////////
      {//debug
      if frmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT) then
        showmessage('true')
      else
        showmessage('false');
      }

      /// debug ///
      //showmessage('dpr - fSearchCriteria.origContext: ' + fSearchCriteria.origContext);
      /// debug ///
      end;

    frmSearchCriteria.PatientIEN := thisPatientIEN;

    frmSearchCriteria.UserIEN := thisUserIEN;
    frmSearchCriteria.Show;
    frmSearchCriteria.BringToFront;
  except
  on E: Exception do
    MessageDlg('An exception has occurred in Patient Search Tool: SearchExecute()' + CRLF + E.Message, mtError, [mbOk], 0);
  end;
end;

function SearchActive() : boolean;  stdcall; export;
begin
  try
    result := false;
    if (Assigned(frmSearchCriteria) and frmSearchCriteria.SearchIsActive) then
      result := true;
  except
    on E: Exception do
      MessageDlg('An exception has occurred in function SearchActive()' + CRLF + E.Message, mtError, [mbOk], 0);
  end;
end;

procedure SearchCancel(); stdcall; export;
begin
  try
   if Assigned(frmSearchCriteria) then
    frmSearchCriteria.sbCancelClick(frmSearchCriteria.sbCancel);
   Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg('An exception has occurred in procedure SearchCancel()' + CRLF + E.Message, mtError, [mbOk], 0);
  end;
end;

procedure FreeSearchDLL(); stdcall; export;
begin
  try
    if Assigned(frmSearchCriteria) then
     begin
     frmSearchCriteria.Free;
     end;
  except
    on E: Exception do
      MessageDlg('An exception has occurred in procedure FreeSearchDLL()' + CRLF + E.Message, mtError, [mbOk], 0);
  end;
end;

procedure SetPatientDFN(thisPatientIEN: string); stdcall; export;
begin
  try
    if Assigned(frmSearchCriteria) then
      begin
      frmSearchCriteria.PatientIEN := thisPatientIEN;
      frmSearchCriteria.SetPatientIEN(thisPatientIEN);
      //We want to ensure that no search results are being shown
      // in the results tree. We want to do this here (below),
      // because in a scenario where there is a search in progress,
      // and the user switches patients, we must guarantee that
      // the results tree DOES NOT contain any search results
      // for the previously selected patient. Otherwise, we
      // have a big ugly patient-safety issue.
      frmSearchCriteria.vSearchTree.BeginUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
      frmSearchCriteria.vSearchTree.Clear;
      frmSearchCriteria.reDetail.Clear;
      frmSearchCriteria.vSearchTree.EndUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
      end;
  except
    on E: Exception do
      MessageDlg('An exception has occurred in procedure SetPatientDFN()' + CRLF + E.Message, mtError, [mbOk], 0);
  end;
end;

procedure ClearSearchResults(); stdcall; export;
begin
  try
    if Assigned(frmSearchCriteria) then
      begin
      frmSearchCriteria.vSearchTree.BeginUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
      frmSearchCriteria.vSearchTree.Clear;
      frmSearchCriteria.vSearchTree.EndUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
    
      frmSearchCriteria.reDetail.Clear;
      end;
  except
    on E: Exception do
      MessageDlg('An exception has occurred in procedure ClearSearchResults()' + CRLF + E.Message, mtError, [mbOk], 0);
  end;
end;

exports
 SearchActive,
 SearchExecute,
 SearchCancel,
 FreeSearchDLL,
 SetPatientDFN,
 ClearSearchResults;

begin

end.
