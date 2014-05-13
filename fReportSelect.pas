unit fReportSelect;
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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Trpcb, ORNet, ORFn,
  ComCtrls, ORCtrls, Menus, OleCtrls, SHDocVw,
  {kw}uCore, rCore, StrUtils, JvExControls, JvButton, JvTransparentButton{kw};

type
  TfrmReportSelect = class(TForm)
    Image1: TImage;
    lbSelectedReports: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    TabControl1: TTabControl;
    buDeleteAll: TButton;
    Button2: TButton;
    Button3: TButton;
    Timer1: TTimer;
    Panel3: TPanel;
    Panel4: TPanel;
    tvReports: TORTreeView;
    laInstructions: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    JvTransparentButton1: TJvTransparentButton;
    JvTransparentButton2: TJvTransparentButton;
    buDeleteAllReports: TJvTransparentButton;
    buClose: TJvTransparentButton;
    Panel5: TPanel;
    Button1: TButton;
    Image2: TImage;
    buAddReport: TJvTransparentButton;
    buRemoveReport: TJvTransparentButton;
    //procedure buCloseORIGClick(Sender: TObject);
    procedure buDeleteSelectedSearchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvReportsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvReportsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvReportsCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure tvReportsExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    //procedure buAddReportORIGClick(Sender: TObject);
    //procedure buRemoveReportORIGClick(Sender: TObject);
    procedure buOKClick(Sender: TObject);
    procedure buDeleteAllClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure lbSelectedReportsClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure buCloseClick(Sender: TObject);
    procedure buAddReportClick(Sender: TObject);
    procedure buRemoveReportClick(Sender: TObject);
  private
    SortIdx1, SortIdx2, SortIdx3: Integer; //from CPRS
    FSelectedSearchName: string;
  public
    property SelectedSearchName: string read FSelectedSearchName write FSelectedSearchName;
    procedure LoadTreeView;
    procedure LoadSelectedReports();
    function ExistsInListBoxReportList(thisReportName: string) : boolean;
    function ParameterExists() : boolean;
  end;

  TNodeData = class(TObject)   //kw - added
     sText : string;
  end;

procedure SaveContext();  

const
  CRLF = #13#10;

  ////// From CPRS fReports.pas ////////////
  CT_REPORTS    =10;        // ID for REPORTS tab used by frmFrame
  QT_OTHER      = 0;
  QT_HSTYPE     = 1;
  QT_DATERANGE  = 2;
  QT_IMAGING    = 3;
  QT_NUTR       = 4;
  QT_PROCEDURES = 19;
  QT_SURGERY    = 28;
  QT_HSCOMPONENT   = 5;
  QT_HSWPCOMPONENT = 6;
  TX_NOREPORT     = 'No report is currently selected.';
  TX_NOREPORT_CAP = 'No Report Selected';

  { TIU Imaging icons }  //from CPRS uConst.pas
  IMG_NO_IMAGES     = 6;
  IMG_1_IMAGE       = 1;
  IMG_2_IMAGES      = 2;
  IMG_MANY_IMAGES   = 3;
  IMG_CHILD_HAS_IMAGES = 4;
  IMG_IMAGES_HIDDEN = 5;

  INSTRUCTIONS = ' This form allows you to select which reports you would like to include in your search.' + CRLF +
                 ' The search term(s) you enter will be applied to All selected reports.' + CRLF +
                 ' To select a single report, click a report in the left pane, then click the ''>'' button to add it to your list.' + CRLF +
                 ' To deselect a single report, click a report in the right pane, then click the ''<'' button to remove it from your list.' + CRLF +
                 ' To deselect ALL reports at the same time, click the ''Delete All'' button.' + CRLF + CRLF +
                 ' *** Ad Hoc and Remote Reports are NOT supported at this time ***';

  CAPTION_STANDARD = 'Standard Searches';
  CAPTION_ADVANCED = 'Advanced Searches';

var
  frmReportSelect: TfrmReportSelect;
  pfrmSearchCriteria: TForm;
  origContext: string;

  ///////////// From CPRS fReports.pas //////////////////////////////////
  uHSComponents: TStringList;  //components selected
                               //segment^OccuranceLimit^TimeLimit^Header...
                               //^(value of uComponents...)
  uHSAll: TStringList;  //List of all displayable Health Summaries
  uLocalReportData: TStringList;  //Storage for Local report data
  uRemoteReportData: TStringList; //Storage for status of Remote data
  uReportInstruction: String;     //User Instructions
  uNewColumn: TListColumn;
  uListItem: TListItem;
  uColumns: TStringList;
  uTreeStrings: TStrings;
  uMaxOcc: string;
  uHState: string;
  uQualifier: string;
  uReportType: string;
  uSortOrder: string;
  uQualifierType: Integer;
  uFirstSort: Integer;
  uSecondSort: Integer;
  uThirdSort: Integer;
  uColChange: string;               //determines when column widths have changed
  uUpdateStat: boolean;             //flag turned on when remote status is being updated
  ulvSelectOn: boolean;             //flag turned on when multiple items in lvReports control have been selected
  uListState: Integer;              //Checked state of list of Adhoc components Checked: Abbreviation, UnChecked: Name
  //uECSReport: TECSReport;           //Event Capture Report, initiated in fFrame when Click Event Capture under Tools
  UpdatingLvReports: Boolean;       //Currently updating lvReports
  UpdatingTvProcedures: Boolean;    //Currently updating tvProcedures

  uRemoteCount: Integer;
  uFrozen: Boolean;
  uHTMLDoc: string;
  uReportRPC: string;
  uHTMLPatient: ANSIstring;
  uRptID: String;
  uReportID: string;
  uRemoteType, uLabRepID : string;
  uDirect: String;
  uEmptyImageList: TImageList;
  ColumnToSort: Integer;
  ColumnSortForward: Boolean;
  //GraphForm: TfrmGraphs;
  //GraphFormActive: boolean;
  /////////////////////////////////////////////////////////////////////////

implementation

uses fSearchCriteria, rReports, uReports;

{$R *.dfm}

var
  thisfrmSearchCriteria: fSearchCriteria.TfrmSearchCriteria;

function TfrmReportSelect.ParameterExists() : boolean;
begin
  try
    result := false;

    try
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 0 then   //Standard search
        CallV('DSIWA XPAR GET VALUE', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + thisfrmSearchCriteria.ReportName])
      else
        if thisfrmSearchCriteria.pcSearch.ActivePageIndex= 1 then //Advanced search
          CallV('DSIWA XPAR GET VALUE', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + thisfrmSearchCriteria.ReportName]);
      thisfrmSearchCriteria.stUpdateContext(origContext);

      if ((Piece(RPCBrokerV.Results[0],'^',1) <> '') and (Piece(RPCBrokerV.Results.Text,'^',1) <> RPC_ERROR)) then
        result := true
      else
        result := false;
    except
      on E: EStringListError do
        result := false;
    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' TfrmReportSelect.ParameterExists()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmReportSelect.buOKClick(Sender: TObject);
{
  This is where we write the selected report ID strings to our parameter, DSIWA SEARCH TOOL SELECTED REPORTS
}
begin
  Close;
end;

procedure TfrmReportSelect.buAddReportClick(Sender: TObject);
var
  searchTerms: TStringList;
  i: integer;
  thisValue: TStringList;
  thisReportName: string;
  columnHeaders: TStringList;
  debugStr: string; //debug
begin
//   1   2      3          4          5      6      7      8     9      10  11    12         13        14    15  16
//   id^Name^Qualifier^HSTag;Routine^Entry^Routine^Remote^Type^Category^RPC^ifn^SortOrder^MaxDaysBack^Direct^HDR^FHIE

  thisValue := TStringList.Create;
  thisValue.Add(TNodeData(tvReports.Selected.Data).sText);
  thisReportName := Piece(thisValue[0],'^',2);
  thisfrmSearchCriteria.ReportID := thisValue[0];
  thisfrmSearchCriteria.ReportName := thisReportName;

  if (Piece(thisValue[0],U,1) <> '[PARENT START]') {and (Piece(thisValue[0],U,7) <> '1')} then //disallow parent nodes and remote reports to be added
    begin
    if not ExistsInListBoxReportList(thisfrmSearchCriteria.ReportName) then //dont add it again if it's already in the list
      begin
      if (thisfrmSearchCriteria.ReportID <> '') then
        begin
        lbSelectedReports.Items.Add(thisfrmSearchCriteria.ReportName); //Add the report TITLE to the list box
        end;
      end;
    end;

  try
    if (Piece(thisValue[0],U,1) <> '[PARENT START]') {and (Piece(thisValue[0],U,7) <> '1')} then //disallow parent nodes and remote reports to be added to the parameter list
      begin
      if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 0 then  //tsStandardSearch
        begin
        //Does the search name already exist?
        if ParameterExists() then
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + STD_PREFIX + thisReportName]);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + STD_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end
        else
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + STD_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end;
        thisfrmSearchCriteria.stUpdateContext(origContext);
        end
      else
        begin
        //Does the search name already exist?
        if ParameterExists() then
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + ADV_PREFIX + thisReportName]);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + ADV_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end
        else
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + ADV_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end;
        thisfrmSearchCriteria.stUpdateContext(origContext);
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmReportSelect.buAddReportClick(()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;
{
procedure TfrmReportSelect.buAddReportORIGClick(Sender: TObject);
var
  searchTerms: TStringList;
  i: integer;
  thisValue: TStringList;
  thisReportName: string;
  columnHeaders: TStringList;
  debugStr: string; //debug
begin
//   1   2      3          4          5      6      7      8     9      10  11    12         13        14    15  16
//   id^Name^Qualifier^HSTag;Routine^Entry^Routine^Remote^Type^Category^RPC^ifn^SortOrder^MaxDaysBack^Direct^HDR^FHIE

  thisValue := TStringList.Create;
  thisValue.Add(TNodeData(tvReports.Selected.Data).sText);
  thisReportName := Piece(thisValue[0],'^',2);
  thisfrmSearchCriteria.ReportID := thisValue[0];
  thisfrmSearchCriteria.ReportName := thisReportName;

  if (Piece(thisValue[0],U,1) <> '[PARENT START]') //and (Piece(thisValue[0],U,7) <> '1') then //disallow parent nodes and remote reports to be added
    begin
    if not ExistsInListBoxReportList(thisfrmSearchCriteria.ReportName) then //dont add it again if it's already in the list
      begin
      if (thisfrmSearchCriteria.ReportID <> '') then
        begin
        lbSelectedReports.Items.Add(thisfrmSearchCriteria.ReportName); //Add the report TITLE to the list box
        end;
      end;
    end;

  try
    if (Piece(thisValue[0],U,1) <> '[PARENT START]') //and (Piece(thisValue[0],U,7) <> '1') then //disallow parent nodes and remote reports to be added to the parameter list
      begin
      if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 0 then  //tsStandardSearch
        begin
        //Does the search name already exist?
        if ParameterExists() then
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + STD_PREFIX + thisReportName]);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + STD_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end
        else
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + STD_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end;
        thisfrmSearchCriteria.stUpdateContext(origContext);
        end
      else
        begin
        //Does the search name already exist?
        if ParameterExists() then
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + ADV_PREFIX + thisReportName]);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + ADV_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end
        else
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + ADV_PREFIX + thisReportName, thisValue]);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBrokerV.Results.Text, '^', 2), mtError, [mbOk], 0);
          end;
        thisfrmSearchCriteria.stUpdateContext(origContext);
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmReportSelect.buAddReportClick(()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmReportSelect.buCloseClick(Sender: TObject);
begin
  self.Close;
end;
{
procedure TfrmReportSelect.buCloseORIGClick(Sender: TObject);
begin
  self.Close;
end;
}
procedure TfrmReportSelect.buDeleteSelectedSearchClick(Sender: TObject);
var
  i: integer;
begin
  try

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buDeleteSelectedSearchClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmReportSelect.buRemoveReportClick(Sender: TObject);
{
 We don't need to test for which main form page we're on (ie, Std or Adv).
 This is because the report name is being formed in lbSelectedReportsClick()
 with the prefixes 'STD:' and 'ADV:'.  Because of this, we have a properly
 formed parameter instance name to delete.
}
var
  i: integer;
  debugStr: string; //debug
begin
  try

    if lbSelectedReports.ItemIndex = -1 then
      begin
      MessageDlg('No search selected.' + CRLF + 'Please select a report to delete.', mtInformation, [mbOk], 0);
      Exit;
      end;

    if MessageDlg('Delete the selected report.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
      begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
        CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + thisfrmSearchCriteria.ReportName]);
        if Piece(RPCBrokerV.Results[0], '^', 1) = '-1' then
          showmessage(RPCBrokerV.Results[0])
        else
          begin  //If no RPC error, then sync up the reports listbox and the report ID list
            if lbSelectedReports.Count > 0 then
              for i := lbSelectedReports.Items.Count-1 downto 0 do
                begin
                if lbSelectedReports.Selected[i] then
                  begin
                  lbSelectedReports.Items.Delete(i);
                  lbSelectedReports.Refresh;
                  end;
                end;
          end;

      thisfrmSearchCriteria.stUpdateContext(origContext);
      end;

    lbSelectedReports.Clear;
    LoadSelectedReports();

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buRemoveReportClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
{
procedure TfrmReportSelect.buRemoveReportORIGClick(Sender: TObject);
 //We dont need to test for which main form page we're on (ie, Std or Adv).
 //This is because the report name is being formed in lbSelectedReportsClick()
 //with the prefixes 'STD:' and 'ADV:'.  Because of this, we have a properly
 //formed parameter instance name to delete.
var
  i: integer;
  debugStr: string; //debug
begin
  try

    if lbSelectedReports.ItemIndex = -1 then
      begin
      MessageDlg('No search selected.' + CRLF + 'Please select a report to delete.', mtInformation, [mbOk], 0);
      Exit;
      end;

    if MessageDlg('Delete the selected report.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
      begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
        CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + thisfrmSearchCriteria.ReportName]);
        if Piece(RPCBrokerV.Results[0], '^', 1) = '-1' then
          showmessage(RPCBrokerV.Results[0])
        else
          begin  //If no RPC error, then sync up the reports listbox and the report ID list
            if lbSelectedReports.Count > 0 then
              for i := lbSelectedReports.Items.Count-1 downto 0 do
                begin
                if lbSelectedReports.Selected[i] then
                  begin
                  lbSelectedReports.Items.Delete(i);
                  lbSelectedReports.Refresh;
                  end;
                end;
          end;

      thisfrmSearchCriteria.stUpdateContext(origContext);
      end;

    lbSelectedReports.Clear;
    LoadSelectedReports();

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buRemoveReportClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmReportSelect.buDeleteAllClick(Sender: TObject);
var
  i: integer;
begin
  try
    if MessageDlg('You are about to permanently delete ALL your selected reports.' + CRLF +
                  'Once done, this action cannot be reversed, and you will need' + CRLF +
                  'to recreate your reports list.' + CRLF + CRLF +
                  'Are you sure?', mtWarning, [mbYes,mbNo], 0) = mrYes then
      begin
        if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 0 then  //tsStandardSearch
          begin
          for i := 0 to lbSelectedReports.Count - 1 do
            begin
            thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
            CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + STD_PREFIX + lbSelectedReports.Items[i]]);
            thisfrmSearchCriteria.stUpdateContext(origContext);
            end;
          end
        else
          if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 1 then  //tsAdvancedSearch
            begin
            for i := 0 to lbSelectedReports.Count - 1 do
              begin
              thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
              CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL REPORTS~' + ADV_PREFIX + lbSelectedReports.Items[i]]);
              thisfrmSearchCriteria.stUpdateContext(origContext);
              end;
            end;

      lbSelectedReports.Clear;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmReportSelect.buDeleteAllClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmReportSelect.Button2Click(Sender: TObject);
var
  i: integer;
  str: string;
//Debug routine
begin
{
  /////////////// DEBUG ///////////////////////////////////////
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('DSIWA XPAR GET ALL', ['USR~DSIWA SEARCH TOOL REPORTS~Q']);
  for i := 0 to RPCBrokerV.Results.Count-1 do
    str := str + RPCBrokerV.Results[i] + #13#10;
  showmessage(str);
  thisfrmSearchCriteria.stUpdateContext(origContext);
  /////////////////////////////////////////////////////////////
}
end;

procedure TfrmReportSelect.Button3Click(Sender: TObject);
var
  i: integer;
  str: string;
begin

  thisfrmSearchCriteria := (self.Owner as TfrmSearchCriteria); //pointer to the main form
  for i := 0 to thisfrmSearchCriteria.ReportIDList.Count-1 do
    str := str + thisfrmSearchCriteria.ReportIDList[i] + #13#10;
  showmessage(str);

end;

procedure TfrmReportSelect.Button4Click(Sender: TObject);
begin
{
  ///////////////// DEBUG /////////////////////////////////////////
  CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL REPORTS~STD:All Outpatient']);
  showmessage('thisfrmSearchCriteria.RPCBroker.Results.Count = ' + inttostr(RPCBrokerV.Results.Count));
  showmessage('Value: '+ #13#10 + RPCBrokerV.Results.Text);
  /////////////////////////////////////////////////////////////////
}
end;

procedure SaveContext();
begin
  //Save the current Context
  origContext := RPCBrokerV.CurrentContext;
  thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
end;

procedure TfrmReportSelect.FormActivate(Sender: TObject);
begin
  try
    //SaveContext(); //<<<<<<<<< BUG FIX 20121004 - commented >>>>>>>>>>>
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' TfrmReportSelect.FormActivate()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmReportSelect.FormCreate(Sender: TObject);
begin
  try
    thisfrmSearchCriteria := (self.Owner as TfrmSearchCriteria); //pointer to the main form
    pfrmSearchCriteria := (thisfrmSearchCriteria as TfrmSearchCriteria);

    uFrozen := False;
    uHSComponents := TStringList.Create;
    uHSAll := TStringList.Create;

    uLocalReportData := TStringList.Create;
    uRemoteReportData := TStringList.Create;

    uColumns := TStringList.Create;
    uTreeStrings := TStringList.Create;
    uEmptyImageList := TImageList.Create(Self);
    uEmptyImageList.Width := 0;
    RowObjects := TRowObject.Create;
    uRemoteCount := 0;

    uCore.RemoteSites := TRemoteSiteList.Create;

    //laInstructions.Caption := INSTRUCTIONS;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmReportSelect.FormCreate()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmReportSelect.FormDestroy(Sender: TObject);
begin
  inherited;
  RemoteQueryAbortAll;
  RowObjects.Free;
  uHSComponents.Free;
  uHSAll.Free;
  uLocalReportData.Free;
  uRemoteReportData.Free;
  uColumns.Free;
  uTreeStrings.Free;
  uEmptyImageList.Free;

  if rReports.thisfrmSearchCriteria <> nil then
    rReports.thisfrmSearchCriteria.Free;

  if uCore.RemoteSites <> nil then
    uCore.RemoteSites.Free;
end;

procedure TfrmReportSelect.LoadTreeView;
var
  i,j: integer;
  currentNode, parentNode, grandParentNode, gtGrandParentNode: TTreeNode;
  x: string;
  addchild, addgrandchild, addgtgrandchild: boolean;
begin
  try
    tvReports.Items.Clear;
    ListReports(uTreeStrings);
    addchild := false;
    addgrandchild := false;
    addgtgrandchild := false;
    parentNode := nil;
    grandParentNode := nil;
    gtGrandParentNode := nil;
    currentNode := nil;
    for i := 0 to uTreeStrings.Count - 1 do
      begin
        x := uTreeStrings[i];

        if UpperCase(Piece(x,'^',1))='[PARENT END]' then
          begin
            if addgtgrandchild = true then
              begin
              currentNode := gtgrandParentNode;
              addgtgrandchild := false;
              end
            else
              if addgrandchild = true then
                begin
                currentNode := grandParentNode;
                addgrandchild := false;
                end
              else
                begin
                currentNode := parentNode;
                addchild := false;
                end;
            continue;
          end;


        if UpperCase(Piece(x,'^',1))='[PARENT START]' then
          begin
            if addgtgrandchild = true then
                currentNode := tvReports.Items.AddChildObject(gtGrandParentNode,Piece(x,'^',3),MakeReportTreeObject(Pieces(x,'^',2,21)))
              else
                if addgrandchild = true then
                  begin
                    begin
                    currentNode := tvReports.Items.AddChildObject(grandParentNode,Piece(x,'^',3),MakeReportTreeObject(Pieces(x,'^',2,21)));
                    addgtgrandchild := true;
                    gtgrandParentNode := currentNode;
                    end;
                  end
                else
                  if addchild = true then
                    begin
                      begin
                      currentNode := tvReports.Items.AddChildObject(parentNode,Piece(x,'^',3),MakeReportTreeObject(Pieces(x,'^',2,21)));
                      addgrandchild := true;
                      grandParentNode := currentNode;
                      end
                    end
                  else
                    begin
                      begin
                      currentNode := tvReports.Items.AddObject(currentNode,Piece(x,'^',3),MakeReportTreeObject(Pieces(x,'^',2,21)));
                      parentNode := currentNode;
                      addchild := true;
                      end;
                    end;
          end

        else
          begin
            begin
              if addchild = false then
                begin
                  currentNode := tvReports.Items.AddObject(currentNode,Piece(x,'^',2),MakeReportTreeObject(x));
                  parentNode := currentNode;
                end
              else
                begin
                  if addgtgrandchild = true then
                      currentNode := tvReports.Items.AddChildObject(gtGrandParentNode,Piece(x,'^',2),MakeReportTreeObject(x))
                  else
                    if addgrandchild = true then
                        currentNode := tvReports.Items.AddChildObject(grandParentNode,Piece(x,'^',2),MakeReportTreeObject(x))
                    else
                        currentNode := tvReports.Items.AddChildObject(parentNode,Piece(x,'^',2),MakeReportTreeObject(x));
                end;
            end;
          end;


        //create the data class
        if currentNode <> nil then //kw - Don't add Remote reports to the tree
          begin
          currentNode.Data := TNodeData.Create;
          //set the nodes data value - in this case the reportID string from ExpandColumns
          TNodeData(currentNode.Data).sText := x;
          end;

      end;

    if tvReports.Items.Count > 0 then begin
      tvReports.Selected := tvReports.Items.GetFirstNode;

    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmReportSelect.LoadTreeView()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmReportSelect.tvReportsClick(Sender: TObject);
var
  i,j: integer;
  ListItem: TListItem;
  aHeading, aReportType, aRPC, aQualifier, aStartTime, aStopTime, aMax, aRptCode, aRemote, aCategory, aSortOrder, aDaysBack, x: string;
  aIFN: integer;
  aID, aHSTag, aRadParam, aColChange, aDirect, aHDR, aFHIE, aFHIEONLY, aQualifierID: string;
  CurrentParentNode, CurrentNode: TTreeNode;
begin
  inherited;

end;


function tfrmReportSelect.ExistsInListBoxReportList(thisReportName: string) : boolean;
var
  i: integer;
begin
  if lbSelectedReports.Count = 0 then
    begin
    result := false;
    Exit;
    end;

  result := false;
  for i := 0 to lbSelectedReports.Count-1 do
    begin
    if Pos(thisReportName, lbSelectedReports.Items[i]) <> 0 then
      result := true;
    end;
end;

procedure TfrmReportSelect.tvReportsCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
  inherited;
  tvReports.Selected := Node;
end;

procedure TfrmReportSelect.tvReportsExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
begin
  inherited;
  tvReports.Selected := Node;
end;

procedure TfrmReportSelect.tvReportsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_LBUTTON, VK_RETURN, VK_SPACE:
    begin
      tvReportsClick(Sender);
      Key := 0;
    end;
  end;
end;

procedure TfrmReportSelect.LoadSelectedReports;
{
 Load reports from DSIWA SEARCH TOOL REPORTS parameter,
 that were previously selected by the user.
}
var
  i: integer;
  paramNames: TStringList;
begin
  paramNames := TStringList.Create;

  try
    self.lbSelectedReports.Clear;
    thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
    CallV('DSIWA XPAR GET ALL FOR ENT', ['USR~DSIWA SEARCH TOOL REPORTS~B']); //according to the RPC definition, 'B' is ALWAYS used
    //showmessage(RPCBrokerV.Results.Text); //debug
    thisfrmSearchCriteria.stUpdateContext(origContext);
    for i := 0 to RPCBrokerV.Results.Count - 1 do
      begin
      //Load up the list box, eliminating the name prefix for display purposes
        case thisfrmSearchCriteria.pcSearch.TabIndex of
          STANDARD_SEARCH_PAGE: begin
                                self.Caption := CAPTION_STANDARD;
                                if Piece(RPCBrokerV.Results[i], PREFIX_DELIM, 1) = STD then
                                  begin
                                  //self.lbSelectedReports.AddItem(Piece(Piece(RPCBrokerV.Results[i],'^',1), PREFIX_DELIM, 2),nil);
                                  self.lbSelectedReports.AddItem(Piece(Piece(RPCBrokerV.Results[i], PREFIX_DELIM, 3), '^',1),nil);
                                  //thisfrmSearchCriteria.ReportIDList.Add(RPCBrokerV.Results[i]);
                                  paramNames.Add(Piece(RPCBrokerV.Results[i], U, 1));
                                  end;
                                end;
          ADVANCED_SEARCH_PAGE: begin
                                self.Caption := CAPTION_ADVANCED;
                                if Piece(RPCBrokerV.Results[i], PREFIX_DELIM, 1) = ADV then
                                  begin
                                  self.lbSelectedReports.AddItem(Piece(Piece(RPCBrokerV.Results[i],PREFIX_DELIM,3), '^', 1),nil);
                                  //thisfrmSearchCriteria.ReportIDList.Add(RPCBrokerV.Results[i]);
                                  paramNames.Add(Piece(RPCBrokerV.Results[i], U, 1));
                                  end;
                                end;
        end;
      end;

{
  ///////////// Debug ////////////////////////////////////////
    for i := 0 to paramNames.Count - 1 do
      begin
      CallV('DSIWA XPAR GET VALUE',['USR~DSIWA SEARCH TOOL REPORTS~' + paramNames[i]]);
      showmessage('ReportIDList: '+ #13#10 + RPCBrokerV.Results[0]);
      thisfrmSearchCriteria.ReportIDList.Add(RPCBrokerV.Results[0]);
      end;
  ////////////////////////////////////////////////////////////      
}
    lbSelectedReports.Refresh;
    paramNames.Free;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadSelectedReports()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmReportSelect.FormShow(Sender: TObject);
begin
  //Load the 'Available Reports' tree ONLY if it hasn't been loaded, yet. This should happen ONLY ONCE.
  //If the tree already exists, then don't load it again cuz you'll end up adding all the nodes AGAIN
  if (tvReports.GetNodeAt(1,1) = nil) then
    LoadTreeView();

  LoadSelectedReports();
  laInstructions.SetFocus;
end;

procedure TfrmReportSelect.lbSelectedReportsClick(Sender: TObject);
begin
  if thisfrmSearchCriteria.pcSearch.ActivePageIndex= 0 then   //Standard search
     thisfrmSearchCriteria.ReportName := STD_PREFIX + lbSelectedReports.Items[lbSelectedReports.ItemIndex]
  else
    if thisfrmSearchCriteria.pcSearch.ActivePageIndex= 1 then //Advanced search
      thisfrmSearchCriteria.ReportName := ADV_PREFIX + lbSelectedReports.Items[lbSelectedReports.ItemIndex];
end;

end.
