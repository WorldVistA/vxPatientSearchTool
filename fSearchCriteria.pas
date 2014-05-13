unit fSearchCriteria;
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
  Dialogs, Trpcb, Buttons, ORFN, ORNet, StdCtrls, ORDtTm,
  ExtCtrls, ComCtrls, Menus, VirtualTrees,
  {DBAdvOfficeButtons,} AdvProgr, AdvCombo, VA508AccessibilityManager,
  EllipsLabel, Mask, JvExMask, JvSpin, ORDtTmRng,
  JvExExtCtrls,   JvRadioGroup, JvExControls, JvButton, JvTransparentButton, JvProgressBar,
  JvSpecialProgress, JvExStdCtrls, JvCheckBox, JvCombobox;

type
  //Use this single tree-data record type for all searches.
  // For each search type, add the needed field(s) at design-time.
  // Fields that are not referenced by a particular search are ignored.
  // This way, we can avoid having a different record structure for each search area (TIU, Problem Text, Consults, Orders, Reports)
  PTreeData = ^TTreeData;
  TTreeData = record
    FCaption: string; //Apply's to all search areas

    //TIU Notes
    FTIUDocNum: string;
    FProblemIFN: string; //Piece 1   //ORQQPL PROBLEM LIST:  ifn^status^description^ICD^onset^last modified^SC^SpExp^Condition^Loc^loc.type^prov^service
    FActiveStatus: string;

    //Problem Text
    FProblemDescription: string;
    FProvider: string;
    FLocation: string;

    //Consults
    FConsultID: string;
    FDateTimeOfConsultRequest: string;
    FConsultStatus: string;
    FConsultingService: string;
    FConsultProcedure: string;

    //Orders
    FOrderID: string;

    //Reports
    FReportName: string;
    FReportID: string;
    FReportIDString: string;
    FProcID: string;
  end;

  //Used in getting a pointer to CPRS's UpdateContext() function
  //Also see .dpr file, function SearchExecute()
  TUpdateContext = function(NewContext: string): boolean;

  TfrmSearchCriteria = class(TForm)
    lblPatientName: TLabel;
    sbStatusBar: TStatusBar;
    calApptRng: TORDateTimeDlg;
    ordrDateRange: TORDateRangeDlg;
    mnuMainMenu: TMainMenu;
    meFile: TMenuItem;
    meExit: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    N3: TMenuItem;
    Close1: TMenuItem;
    meOpenSavedSearchTerms: TMenuItem;
    New1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    HowtoUseHelp1: TMenuItem;
    SearchforHelpOn1: TMenuItem;
    Contents1: TMenuItem;
    meOptions: TMenuItem;
    meShowResultsOnSearchCompletion: TMenuItem;
    cdColorDialog: TColorDialog;
    meWholeWords: TMenuItem;
    meCaseSensitive: TMenuItem;
    N4: TMenuItem;
    meBoldSearchTermBoldColor: TMenuItem;
    mnuShowBrokerHistory: TMenuItem;
    N5: TMenuItem;
    meTitleSearch: TMenuItem;
    meDocumentSearch: TMenuItem;
    ScrollBox1: TScrollBox;
    pcSearch: TPageControl;
    tsStandardSearch: TTabSheet;
    paStandardSearch: TPanel;
    Image2: TImage;
    gbProblemText: TGroupBox;
    Image3: TImage;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    laProblemTextFoundStd: TLabel;
    edProblemTextSearchTermsStd: TLabeledEdit;
    seProblemTextMaxStd: TJvSpinEdit;
    ordbStartDateProblemTextStd: TORDateBox;
    ordbEndDateProblemTextStd: TORDateBox;
    gbConsults: TGroupBox;
    Image4: TImage;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    laConsultsFoundStd: TLabel;
    edConsultsSearchTermsStd: TLabeledEdit;
    seConsultsMaxStd: TJvSpinEdit;
    ordbStartDateConsultsStd: TORDateBox;
    ordbEndDateConsultsStd: TORDateBox;
    gbOrders: TGroupBox;
    Image5: TImage;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    laOrdersFoundStd: TLabel;
    edOrdersSearchTermsStd: TLabeledEdit;
    seOrdersMaxStd: TJvSpinEdit;
    ordbStartDateOrdersStd: TORDateBox;
    ordbEndDateOrdersStd: TORDateBox;
    gbReports: TGroupBox;
    Image6: TImage;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    laReportsFoundStd: TLabel;
    edReportsSearchTermsStd: TLabeledEdit;
    seReportsMaxStd: TJvSpinEdit;
    ordbStartDateReportsStd: TORDateBox;
    ordbEndDateReportsStd: TORDateBox;
    gbTIUNotes: TGroupBox;
    Image1: TImage;
    laTIUNotesFoundStd: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label8: TLabel;
    edTIUSearchTermsStd: TLabeledEdit;
    seTIUMaxStd: TJvSpinEdit;
    ordbStartDateTIUStd: TORDateBox;
    ordbEndDateTIUStd: TORDateBox;
    cbDocumentClassStd: TComboBox;
    rgTIUNoteOptionsStd: TJvRadioGroup;
    cbIncludeAddendaStd: TJvCheckbox;
    cbIncludeUntranscribedStd: TCheckBox;
    rgSortByStd: TJvRadioGroup;
    tsAdvancedSearch: TTabSheet;
    paAdvancedSearch: TPanel;
    Image15: TImage;
    GroupBox2: TGroupBox;
    Image14: TImage;
    Label14: TLabel;
    laTIUNotesFoundAdv: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    edTIUSearchTermsAdv: TLabeledEdit;
    seTIUMaxAdv: TJvSpinEdit;
    ordbStartDateTIUAdv: TORDateBox;
    ordbEndDateTIUAdv: TORDateBox;
    cbDocumentClassAdv: TComboBox;
    rgSortByAdv: TJvRadioGroup;
    GroupBox3: TGroupBox;
    Image13: TImage;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    laProblemTextFoundAdv: TLabel;
    edProblemTextSearchTermsAdv: TLabeledEdit;
    seProblemTextMaxAdv: TJvSpinEdit;
    ordbStartDateProblemTextAdv: TORDateBox;
    ordbEndDateProblemTextAdv: TORDateBox;
    GroupBox4: TGroupBox;
    Image12: TImage;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    laConsultsFoundAdv: TLabel;
    edConsultsSearchTermsAdv: TLabeledEdit;
    seConsultsMaxAdv: TJvSpinEdit;
    ordbStartDateConsultsAdv: TORDateBox;
    ordbEndDateConsultsAdv: TORDateBox;
    GroupBox5: TGroupBox;
    Image11: TImage;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    laOrdersFoundAdv: TLabel;
    edOrdersSearchTermsAdv: TLabeledEdit;
    seOrdersMaxAdv: TJvSpinEdit;
    ordbStartDateOrdersAdv: TORDateBox;
    ordbEndDateOrdersAdv: TORDateBox;
    GroupBox6: TGroupBox;
    Image10: TImage;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    laReportsFoundAdv: TLabel;
    edReportsSearchTermsAdv: TLabeledEdit;
    seReportsMaxAdv: TJvSpinEdit;
    ordbStartDateReportsAdv: TORDateBox;
    ordbEndDateReportsAdv: TORDateBox;
    tsSearchResults: TTabSheet;
    Splitter1: TSplitter;
    Panel5: TPanel;
    Image9: TImage;
    Panel6: TPanel;
    vSearchTree: TVirtualStringTree;
    Panel7: TPanel;
    reDetail: TRichEdit;
    Panel2: TPanel;
    Image7: TImage;
    buSearchTerms: TSpeedButton;
    rgPriority: TJvRadioGroup;
    buQuickSearch: TSpeedButton;
    Panel4: TPanel;
    Image8: TImage;
    buClearTIUNotesStd: TJvTransparentButton;
    buClearProblemTextStd: TJvTransparentButton;
    buClearConsultsStd: TJvTransparentButton;
    buClearOrdersStd: TJvTransparentButton;
    buClearReportsStd: TJvTransparentButton;
    buSelectReportsStandard: TJvTransparentButton;
    laLoading: TLabel;
    cbOrderStatusStd: TJvComboBox;
    Label3: TLabel;
    Label4: TLabel;
    popActions: TPopupMenu;
    meSaveSearchResultsToFile: TMenuItem;
    PrintsearchresultstoWindowsprinter1: TMenuItem;
    PrintsearchresultstoaVistAprinter1: TMenuItem;
    meSaveSearchResultsToAFile: TMenuItem;
    meCopytoClipboard: TMenuItem;
    SelectAll1: TMenuItem;
    dlgFind: TFindDialog;
    meFind: TMenuItem;
    Label5: TLabel;
    VA508AccessibilityManager1: TVA508AccessibilityManager;
    VA508ComponentAccessibility1: TVA508ComponentAccessibility;
    anCircularProgress: TAnimate;
    rgTIUNoteOptionsAdv: TJvRadioGroup;
    cbIncludeUntranscribedAdv: TJvCheckBox;
    cbIncludeAddendaAdv: TJvCheckBox;
    buClearTIUNotesAdv: TJvTransparentButton;
    buClearProblemTextAdv: TJvTransparentButton;
    buClearConsultsAdv: TJvTransparentButton;
    buClearOrdersAdv: TJvTransparentButton;
    cbOrderStatusAdv: TJvComboBox;
    buClearReportsAdv: TJvTransparentButton;
    buSelectReportsAdvanced: TJvTransparentButton;
    sbClearAllSearchCriteria: TJvTransparentButton;
    buSaveSearchTerms: TJvTransparentButton;
    sbSearch: TJvTransparentButton;
    sbCancel: TJvTransparentButton;
    sbClose: TJvTransparentButton;
    buLoadCancel: TJvTransparentButton;
    pbReportLoading: TProgressBar;
    procedure sbtnCloseClick(Sender: TObject);
    procedure LabeledEdit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure buCloseClick(Sender: TObject);
    procedure vSearchTreeClick(Sender: TObject);
    procedure vSearchTreeGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vSearchTreePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure FormShow(Sender: TObject);
    //procedure sbSearchORIGClick(Sender: TObject);
    procedure pcSearchChange(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure buSearchTermsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure vSearchTreeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure meShowResultsOnSearchCompletionClick(Sender: TObject);
    procedure meBoldSearchTermBoldColorClick(Sender: TObject);
    procedure meCaseSensitiveClick(Sender: TObject);
    procedure cbDocumentClassStdChange(Sender: TObject);
    procedure mnuShowBrokerHistoryClick(Sender: TObject);
    procedure meDocumentSearchClick(Sender: TObject);
    procedure meTitleSearchClick(Sender: TObject);
    procedure meWholeWordsClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rgPriorityClick(Sender: TObject);
    //procedure sbClearAllSearchCriteriaORIGClick(Sender: TObject);
    //procedure sbCancelORIGClick(Sender: TObject);
    //procedure sbCloseORIGClick(Sender: TObject);
    //procedure AdvOfficeRadioGroup1Click(Sender: TObject);
    procedure buQuickSearchClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    //procedure buSaveSearchTermsORIGClick(Sender: TObject);
    procedure meOpenSavedSearchTermsClick(Sender: TObject);
    procedure seProblemTextMaxStdChange(Sender: TObject);
    procedure seProblemTextMaxAdvChange(Sender: TObject);
    procedure seConsultsMaxAdvChange(Sender: TObject);
    procedure seConsultsMaxStdChange(Sender: TObject);
    procedure seOrdersMaxStdChange(Sender: TObject);
    procedure seOrdersMaxAdvChange(Sender: TObject);
    procedure seReportsMaxStdChange(Sender: TObject);
    procedure seReportsMaxAdvChange(Sender: TObject);
    procedure seTIUMaxStdChange(Sender: TObject);
    procedure seTIUMaxAdvChange(Sender: TObject);
    procedure rgTIUNoteOptionsStdClick(Sender: TObject);
    procedure buClearTIUNotesStdClick(Sender: TObject);
    procedure buClearProblemTextStdClick(Sender: TObject);
    procedure buClearConsultsStdClick(Sender: TObject);
    procedure buClearOrdersStdClick(Sender: TObject);
    procedure buClearReportsStdClick(Sender: TObject);
    //procedure buClearTIUNotesAdvORIGClick(Sender: TObject);
    //procedure buClearProblemTextAdvORIGClick(Sender: TObject);
    //procedure buClearConsultsAdvORIGClick(Sender: TObject);
    //procedure buClearOrdersAdvORIGClick(Sender: TObject);
    //procedure buClearReportsAdvORIGClick(Sender: TObject);
    //procedure buSelectReportsAdvancedORIGClick(Sender: TObject);
    procedure meExitClick(Sender: TObject);
    //procedure buLoadCancelORIGClick(Sender: TObject);
    procedure vSearchTreeExpanding(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var Allowed: Boolean);
    procedure vSearchTreeCollapsing(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var Allowed: Boolean);
    procedure vSearchTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbOrderStatusStdChange(Sender: TObject);
    procedure cbOrderStatusAdvORIGChange(Sender: TObject);
    procedure buSaveSearchTermsORIGMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure meSaveSearchResultsToFileClick(Sender: TObject);
    procedure reDetailMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure meSaveSearchResultsToAFileClick(Sender: TObject);
    procedure meCopytoClipboardClick(Sender: TObject);
    procedure meSelectAllClick(Sender: TObject);
    procedure meFindClick(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure buSelectReportsStandardClick(Sender: TObject);
    procedure buClearTIUNotesAdvClick(Sender: TObject);
    procedure buClearProblemTextAdvClick(Sender: TObject);
    procedure buClearConsultsAdvClick(Sender: TObject);
    procedure buClearOrdersAdvClick(Sender: TObject);
    procedure cbOrderStatusAdvChange(Sender: TObject);
    procedure buClearReportsAdvClick(Sender: TObject);
    procedure buSelectReportsAdvancedClick(Sender: TObject);
    procedure sbClearAllSearchCriteriaClick(Sender: TObject);
    procedure buSaveSearchTermsClick(Sender: TObject);
    procedure buSaveSearchTermsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure sbSearchClick(Sender: TObject);
    procedure sbCancelClick(Sender: TObject);
    procedure sbCloseClick(Sender: TObject);
    procedure buLoadCancelClick(Sender: TObject);
    procedure rgTIUNoteOptionsAdvClick(Sender: TObject);
  private
    { Private declarations }
    FSearchPriority: integer;
    FFirstTickCount: LongInt;
    FElapsedTime: Extended;
    FSearchStartTime: Cardinal;
    FSearchType: boolean; //Standard or Advanced
    FSearchIsActive: boolean;
    FSearchCancelled: boolean;
    FPatientIEN: string;
    FRPCBroker: TRPCBroker;
    FslSearchResults: TStrings;
    FslReportText: TStrings;

    FSearchTerms: TStrings;
    FTIUTermsFound: TStrings; //hightlighted search term text
    FProblemTextTermsFound: TStrings; //hightlighted search term text
    FConsultsTermsFound: TStrings; //hightlighted search term text
    FOrdersTermsFound: TStrings; //hightlighted search term text
    FReportsTermsFound: TStrings; //hightlighted search term text

    FBoldedSearchTermColor: TColor; //Color of bolded search term text
    FDeepSearch: boolean;
    FreDeepSearch: TRichEdit;
    FTIUDocumentClass: string;
    FWordList: TList;
    FSingleLineBodyText: WideString;

    //reTemp: TRichEdit;

    property FirstTickCount: LongInt read FFirstTickCount write FFirstTickCount;
    property ElapsedTime: Extended read FElapsedTime write FElapsedTime;
    //procedure SetPatientIEN(Value: string);
    procedure SetRPCBroker(Value: TRPCBroker);
    procedure LoadAdvancedSearchTerms(thisSelectedSearchName: string);
    procedure LoadStandardSearchTerms(thisSelectedSearchName: string);
    function CollectAdvancedSearchTerms(var thisSearchTerms: TStringList) : TStringList;
    function CollectStandardSearchTerms(var thisSearchTerms: TStringList) : TStringList;
    function CollectSearchTerms(var thisSearchTerms: TStringList) : TStringList;
    function LoadReportIDList() : integer;
  private
    FTIURootNode: PVirtualNode;
    FProblemTextRootNode: PVirtualNode;
    FConsultsRootNode: PVirtualNode;
    FOrdersRootNode: PVirtualNode;
    FReportsRootNode: PVirtualNode;
    
    FThisNode: PVirtualNode;
    FLoadCancelled: boolean;
    FOrderStatus: integer;
    property OrderStatus: integer read FOrderStatus write FOrderStatus;
    property ThisNode: PVirtualNode read FThisNode write FThisNode;
    property LoadCancelled : boolean read FLoadCancelled write FLoadCancelled;
    //procedure FreeSearchResults();
    procedure ShowLoadingProgress();
    procedure HideLoadingProgress();
  public
    { Public declarations }
    UserIEN: string;
    FNumTIUFound: Cardinal; //Number of search results
    FNumProblemTextFound: Cardinal; //Number of search results
    FNumConsultsFound: Cardinal; //Number of search results
    FNumOrdersFound: Cardinal; //Number of search results
    FNumReportsFound: Cardinal; //Number of search results
    FSearchName: string; //User name to identify Saved search terms

    FReportName: string;
    FReportID: string; //moved here from rReports.pas
    FReportIDList: TStringList;
    FReportIDString: string;
    FReportList: TStringList;
    FProcID: string;

    stUpdateContext: TUpdateContext; //PROCEDURAL POINTER to CPRS ORNet.UpdateContext()

    procedure SetPatientIEN(Value: string);

    property TIUNotesRootNode: PVirtualNode read FTIURootNode write FTIURootNode;
    property ProblemTextRootNode: PVirtualNode read FProblemTextRootNode write FProblemTextRootNode;
    property ConsultsRootNode: PVirtualNode read FConsultsRootNode write FConsultsRootNode;
    property OrdersRootNode: PVirtualNode read FOrdersRootNode write FOrdersRootNode;
    property ReportsRootNode: PVirtualNode read FReportsRootNode write FReportsRootNode;

    property ReportIDList: TStringList read FReportIDList write FReportIDList;
    property ReportName: string read FReportName write FReportName;
    property ReportID: string read FReportID write FReportID;
    property ReportIDString: string read FReportIDString write FReportIDString;
    property slReportText: TStrings read FslReportText write FslReportText;
    property slReportList: TStringList read FReportList write FReportList;
    property ProcID: string read FProcID write FProcID;

    property SingleLineBodyText: WideString read FSingleLineBodyText write FSingleLineBodyText;
    property WordList: TList read FWordList write FWordList;
    property slSearchResults: TStrings read FslSearchResults write FslSearchResults;
    property TIUDocumentClass: string read FTIUDocumentClass write FTIUDocumentClass;
    property DeepSearch: boolean read FDeepSearch write FDeepSearch;
    property reDeepSearch: TRichEdit read FreDeepSearch write FreDeepSearch;
    property SearchStartTime: Cardinal read FSearchStartTime write FSearchStartTime;
    property slSearchTerms: TStrings read FSearchTerms write FSearchTerms;
    property slTIUTermsFound: TStrings read  FTIUTermsFound write FTIUTermsFound; //hightlighted search term text
    property slProblemTextTermsFound: TStrings read FProblemTextTermsFound write FProblemTextTermsFound; //hightlighted search term text
    property slConsultsTermsFound: TStrings read FConsultsTermsFound write FConsultsTermsFound; //hightlighted search term text
    property slOrdersTermsFound: TStrings read FOrdersTermsFound write FOrdersTermsFound; //hightlighted search term text
    property slReportsTermsFound: TStrings read FReportsTermsFound write FReportsTermsFound; //hightlighted search term text

    property NumTIUFound: Cardinal read FNumTIUFound write FNumTIUFound;
    property NumProblemTextFound: Cardinal read FNumProblemTextFound write FNumProblemTextFound;
    property NumConsultsFound: Cardinal read FNumConsultsFound write FNumConsultsFound;
    property NumOrdersFound: Cardinal read FNumOrdersFound write FNumOrdersFound;
    property NumReportsFound: Cardinal read FNumReportsFound write FNumReportsFound;
    property SearchType: boolean read FSearchType write FSearchType;
    property SearchIsActive: boolean read FSearchIsActive write FSearchIsActive;
    property SearchCancelled: boolean read FSearchCancelled write FSearchCancelled;
    property PatientIEN: string read FPatientIEN write SetPatientIEN;
    property RPCBroker: TRPCBroker read FRPCBroker write SetRPCBroker;

    procedure UpdateSearchTime();
    function ParameterExists() : boolean;
    function Separator(thisArg: Char): Boolean;
    procedure Delay(msecs: integer);
    procedure EnableAllSearchSections;
    procedure EnableReportsSearchSectionOnly;
    procedure SetupSearchTree(frmSearchCriteria: TfrmSearchCriteria);
    function AddNodeToTree(thisTree: TCustomVirtualStringTree; thisNode: PVirtualNode; thisTreeData: TTreeData): PVirtualNode;
    procedure ParseDelimited(const slThisStringList: TStrings; const thisString: string; const thisDelimiter: string);
    function ContainsSearchTerms(thisSearchTermComponent: TLabeledEdit; thisSearchResult: string) : boolean;
    function ConvertActiveStatus(thisActiveStatus: string) : string;
    procedure LoadTIUNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                                thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
    procedure LoadProblemTextNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                                thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
    procedure LoadConsultsNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                                thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
    procedure LoadOrdersNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                                thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
    procedure LoadReportsNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                                 thisNodeData: TTreeData; thisReportText: string; thisIndex: integer);
    function GetSortDirection(var thisSortByComponent: TJvRadioGroup) : char;
    procedure UpdateHits(IsAdvancedSearch: boolean; thisSearchArea: integer; thisNumberFound: integer);

    procedure LoadWordList(thisString: string);
    function SearchTermsFoundInRecordBodySequential(thisSearchTermComponent: TLabeledEdit; thisBodyText: string) : boolean;
    function SearchTermsFoundInRecordBody(thisSearchTermComponent: TLabeledEdit) : integer;

    procedure SearchTIUNotes(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
    procedure SearchProblemText(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
    procedure SearchConsults(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
    procedure SearchOrders(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
    function ConstructReportIDString(thisReportIDString: string) : string;
    function ReportIsListviewType(thisIFN: string) : boolean;
    function ReformatReportText(var thisListviewReportText: TStringList; thisBrokerResults: TStrings; thisIFN: string) : TStringList;
    procedure SearchReports(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
    function IsMultipartReport() : boolean;
    function VerifyDateRanges : string;
    procedure InitiateSearch(Sender: TObject);
    function IsWord(start: integer; stop: integer; thisString: string):boolean;
    procedure LoadSearchTerms(Sender: TObject; parentData: PTreeData);
    procedure BoldSearchTerms(Sender: TObject);
    function AllSearchDatesValid : string;
    function NoSearchTerms : boolean;
    procedure UpdateStatusBarMessage(thisMessage: string);
    procedure UpdateTotalRecordsFound();
  end;

  PWordRecord = ^WordRecord;
  WordRecord = record
    word: string;
  end;

//procedure UpdateCallList();
procedure SaveContext();
function CompareWords(thisWord: pointer; thatWord: pointer) : integer;  

const
  TOTAL_FOUND = 'Total Found: ';
  GENERAL_EXCEPTION_MSG = 'Exception in Patient Search tool - ';
  RPC_ERROR = '-1';
  RPC_SUCCESS = '1';
  U = '^';
  STD = 'STD';
  ADV = 'ADV';
  PREFIX_DELIM = ':';
  STD_PREFIX = STD + PREFIX_DELIM;
  ADV_PREFIX = ADV + PREFIX_DELIM;
  FORM_MAX_HEIGHT = 855;
  FORM_MAX_WIDTH = 965;
  DEFAULT_BOLD_SEARCH_TERM_COLOR = clRed;
  SEARCH_TOOL_CONTEXT = 'DSIWA PATIENT RECORD SEARCH';
  //SEARCH_TOOL_CONTEXT = 'OR CPRS GUI CHART';
  CRLF = #13#10;
  STANDARD_SEARCH_IN_PROGRESS = 'Standard Search In Progress . . . ';
  ADVANCED_SEARCH_IN_PROGRESS = 'Advanced Search In Progress . . . ';
  SEARCH_COMPLETE = 'Search Complete.'; // + CRLF + 'All search results will appear on the ''Search Results'' tab.';
  SEARCH_CANCELLING = 'Cancelling search ...';
  SEARCH_CANCELLED = 'Search Cancelled.';
  PROCESSING_CANCELLING = 'Cancelling processing...';
  PROCESSING_CANCELLED = 'Processing cancelled.';
  NO_SEARCH_TERMS = 'Search terms are missing';
  STANDARD_SEARCH = false;
  ADVANCED_SEARCH = true;
  STANDARD_SEARCH_PAGE = 0;
  ADVANCED_SEARCH_PAGE = 1;
  CAPTION_PATIENT_RECORD_SEARCH = 'DSS Patient Search Tool';
  CAPTION_FOUND = 'Found:  ';
  CAPTION_TIU_NOTES = 'TIU Notes';
  CAPTION_PROBLEM_TEXT = 'Problem Text';
  CAPTION_CONSULTS = 'Consults';
  CAPTION_ORDERS = 'Orders';
  CAPTION_REPORTS = 'Reports';
  SEARCH_TERM_DELIMITER = #32;
  DEFAULT_DATE_FORMAT = 'mm/dd/yyyy';
  SEARCH_AREA_TIU = 0;
  SEARCH_AREA_PROBLEM_TEXT = 1;
  SEARCH_AREA_CONSULTS = 2;
  SEARCH_AREA_ORDERS = 3;
  SEARCH_AREA_REPORTS = 4;
  //RPC_INTERVAL = 3000;
  SEARCH_PRIORITY_FACTOR = 0; //1000;
  SEARCH_PRIORITY_DEFAULT = 500; //10000;
  HIGHER_PRIORITY_SEARCH = 'Search has higher Priority';
  HIGHER_PRIORITY_CPRS = 'CPRS has higher Priority';
  EQUAL_PRIORITY = 'Equal Priority';
  SEARCH_FORM_CLOSE_MSG = 'Search results will not be saved.' + CRLF + 'Are you sure you want to Close?';
  INVALID_SEARCH_DATE = 'Invalid date in ';
  TIU_DOCUMENT_CLASS_MISSING = 'Search Cancelled:' + CRLF + 'A TIU document class must be specified.';
  PROGRESS_NOTES = '3';
  DISCHARGE_SUMMARIES = '244';
  PROBLEM_WITH_SEARCH_TOOL = 'A problem with the DSS Patient Search Tool has occurred.';

  REPORT_IMAGING = 18;
  REPORT_PROCEDURES = 19;
  REPORT_SURGERY = 28;
  LOG_SIZE = 100;

var
  frmSearchCriteria: TfrmSearchCriteria;
  origContext: string;
  origParamArray: array [0..4] of TParamRecord;
  slLastBrokerCall: TStringList;
  CallList: TStringList;
  delims: set of char = [' '];
  totalRecordsFound: integer;

implementation

uses UDssAbout, fSearchTerms, fBrokerCallHistory, fxBroker, fQuickSearch,
  fSavedSearches, fReports, fReportSelect, rReports, rCore;

{$R *.dfm}

{
procedure TfrmSearchCriteria.FreeSearchResults(thisFunctionName: string);
begin
  try
    FreeAndNil(self.FslSearchResults);
  except
    MessageDlg(PROBLEM_WITH_SEARCH_TOOL + ': Unsuccsessful Free of FslSearchResults in ' + thisFunctionName);
  end;
end;
}
procedure SaveContext();
begin
  //Save the current Context
  //origContext := RPCBrokerV.CurrentContext;
  //UpdateContext(SEARCH_TOOL_CONTEXT);
end;

function CompareWords(thisWord: pointer; thatWord: pointer) : integer;
//Compares two strings by ordinal value WITH case sensitivity
begin
  result := CompareStr(PWordRecord(thisWord)^.word, PWordRecord(thatWord)^.word);
end;

function TfrmSearchCriteria.Separator(thisArg: Char): Boolean;
begin
  result := thisArg in [#0..#47, #58..#64, #91..#96, #123..#127]; //Standard ASCII - Incl's letters and numbers, but no special characters
end;

procedure TfrmSearchCriteria.seProblemTextMaxAdvChange(Sender: TObject);
begin
  seProblemTextMaxStd.Value := seProblemTextMaxAdv.Value;
end;

procedure TfrmSearchCriteria.seProblemTextMaxStdChange(Sender: TObject);
begin
  seProblemTextMaxAdv.Value := seProblemTextMaxStd.Value;
end;

procedure TfrmSearchCriteria.seReportsMaxAdvChange(Sender: TObject);
begin
  seReportsMaxStd.Value := seReportsMaxAdv.Value;
end;

procedure TfrmSearchCriteria.seReportsMaxStdChange(Sender: TObject);
begin
  seReportsMaxAdv.Value := seReportsMaxStd.Value;
end;

procedure TfrmSearchCriteria.seTIUMaxAdvChange(Sender: TObject);
begin
  seTIUMaxStd.Value := seTIUMaxAdv.Value;
end;

procedure TfrmSearchCriteria.seTIUMaxStdChange(Sender: TObject);
begin
  seTIUMaxAdv.Value := seTIUMaxStd.Value;
end;

procedure TfrmSearchCriteria.UpdateSearchTime();
begin
  if not self.SearchCancelled then
    begin
    self.ElapsedTime := ((GetTickCount - SearchStartTime) / 1000);
    sbStatusBar.Panels[1].Text := 'Search Time: ' + FloatToStrF(self.ElapsedTime, ffFixed, 6, 2) + ' seconds';
    end
  else
    sbStatusBar.Panels[1].Text := '';
end;

procedure TfrmSearchCriteria.UpdateStatusBarMessage(thisMessage: string);
begin
  sbStatusBar.Panels[0].Text := thisMessage;
end;

procedure TfrmSearchCriteria.UpdateTotalRecordsFound();
begin
  inc(totalRecordsFound);
  sbStatusBar.Panels[3].Text := TOTAL_FOUND + intToStr(totalRecordsFound);
end;

procedure TfrmSearchCriteria.SetRPCBroker(Value: TRPCBroker);
begin
  FRPCBroker := Value;
  RPCBrokerV := Value;
end;

procedure TfrmSearchCriteria.SetupSearchTree(frmSearchCriteria: TfrmSearchCriteria);
begin

end;

procedure TfrmSearchCriteria.About1Click(Sender: TObject);
begin
  DSSAboutDlg.ShowModal;
end;

function TfrmSearchCriteria.AddNodeToTree(thisTree: TCustomVirtualStringTree; thisNode: PVirtualNode; thisTreeData: TTreeData): PVirtualNode;
var
  Data: PTreeData;
begin
  result := thisTree.AddChild(thisNode);
  Data := thisTree.GetNodeData(result);
  thisTree.ValidateNode(result, false); //Initialize the newly created node (but not it's children ie, 2nd param = false

  //TIU Notes
  Data^.FCaption := thisTreeData.FCaption;
  Data^.FTIUDocNum := thisTreeData.FTIUDocNum;
  Data^.FActiveStatus := thisTreeData.FActiveStatus;

  //Problem Text
  Data^.FProblemIFN := thisTreeData.FProblemIFN;
  Data^.FProblemDescription := thisTreeData.FProblemDescription;
  Data^.FProvider := thisTreeData.FProvider;
  Data^.FLocation := thisTreeData.FLocation;

  //Consults
  Data^.FConsultID := thisTreeData.FConsultID;
  Data^.FDateTimeOfConsultRequest := thisTreeData.FDateTimeOfConsultRequest;
  Data^.FConsultStatus := thisTreeData.FConsultStatus;
  Data^.FConsultingService := thisTreeData.FConsultingService;
  Data^.FConsultProcedure := thisTreeData.FConsultProcedure;

  //Orders
  Data^.FOrderID := thisTreeData.FOrderID;

  //Reports
  Data^.FReportName := thisTreeData.FReportName;
  Data^.FReportID := thisTreeData.FReportID;
  Data^.FReportIDString := thisTreeData.FReportIDString;
  Data^.FProcID := thisTreeData.FProcID;
end;

procedure TfrmSearchCriteria.buQuickSearchClick(Sender: TObject);
begin
  frmQuickSearch.Show;
  frmQuickSearch.BringToFront;

  //frmQuickSearch.Free;
end;
{
procedure TfrmSearchCriteria.AdvOfficeRadioGroup1Click(Sender: TObject);
begin
  if rgTIUNoteOptionsAdv.ItemIndex = 3 then
    begin
    ordbStartDateTIUAdv.Enabled := true;
    ordbEndDateTIUAdv.Enabled := true;
    end
  else
    begin
    ordbStartDateTIUAdv.Enabled := false;
    ordbEndDateTIUAdv.Enabled := false;
    end;
end;
}
procedure TfrmSearchCriteria.sbCloseClick(Sender: TObject);
begin
  try
    if MessageDlg(SEARCH_FORM_CLOSE_MSG, mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit
    else
      begin
      if self.SearchIsActive then
        begin
        self.sbCancelClick(nil);
        Application.ProcessMessages;
        end;

      self.Close;

      FreeAndNil(slLastBrokerCall);
      FreeAndNil(CallList);

      frmSearchTerms.Close;
      frmQuickSearch.Close;
      end;
    Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.sbCloseClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
{
procedure TfrmSearchCriteria.sbCloseORIGClick(Sender: TObject);
begin
  try
    if MessageDlg(SEARCH_FORM_CLOSE_MSG, mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit
    else
      begin
      if self.SearchIsActive then
        begin
        self.sbCancelClick(nil);
        Application.ProcessMessages;
        end;

      self.Close;

      FreeAndNil(slLastBrokerCall);
      FreeAndNil(CallList);

      frmSearchTerms.Close;
      frmQuickSearch.Close;
      end;
    Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.sbCloseClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmSearchCriteria.ParseDelimited(const slThisStringList: TStrings; const thisString: string; const thisDelimiter: string);
//Split the string into an array of strings by using a character as a separator.
var
  dx: integer;
  ns: string;
  txt: string;
  delta: integer;
begin
  try
   delta := Length(thisDelimiter) ;
   txt := thisString + thisDelimiter;

   slThisStringList.BeginUpdate;
   slThisStringList.Clear;
   try
     while Length(txt) > 0 do
       begin
         dx := Pos(thisDelimiter, txt) ;
         ns := Copy(txt, 0, dx-1) ;
         slThisStringList.Add(ns) ;
         txt := Copy(txt, dx + delta, MaxInt) ;
       end;
   finally
     slThisStringList.EndUpdate;
   end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' ParseDelimited()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.ContainsSearchTerms(thisSearchTermComponent: TLabeledEdit; thisSearchResult: string) : boolean;
{
 Parse the text in the search term edit box (thisSearchTermComponent), and place each individual Search Term in the TStringList.
 Then, spin thru the Search Terms string list, and see if any of the terms
 are present in the current RPC result string.   Break if/when first search term is found in the RPC result string.

 NOTE: This routine assumes ASCII #32 (space) as the Search Term delimiter in the search term edit box (thisSearchTermComponent).
}
var
  i: integer;
  thisSearchTerm: string;
begin
  try
    result := false;
    //Get the individual search terms
    self.slSearchTerms.Clear; //init
    thisSearchTerm := '';

    ParseDelimited(self.slSearchTerms, thisSearchTermComponent.Text, ' ');  //Now we have our search terms in a separate string list

    //Examine this RPC result string for Search Terms.
    for i := 0 to self.slSearchTerms.Count-1 do
      begin
      //if self.SearchCancelled then Break;
      if Pos(UpperCase(self.slSearchTerms[i]), UpperCase(thisSearchResult)) <> 0 then
        begin
        result := true;
        Break; //we don't want to keep looking if we have already found at least one search term
        ///// <Save slRPCStrings[i] for text highlighting, later> /////
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' ContainsSearchTerms()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.LoadTIUNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
  thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
begin
  try
    Application.ProcessMessages;
    if self.SearchCancelled then Exit;

    case thisSearchType of
      STANDARD_SEARCH:
        begin
          if not self.DeepSearch then //TITLE Search
            begin
            //If the Reference date/time = '', then no TIU note will exist - So skip it (Do we need this check on TIU Notes??)
            if Piece(thisSearchResults.Strings[thisIndex],'^',3) <> '' then
              begin
              //We're getting ALL the RPC results back.  Now, we want to filter the RPC results on the Search Term(s)
              if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) then
                begin
                NumTIUFound := NumTIUFound + 1;
                thisNodeData.FCaption :=
                                     FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + '  ' +  //Reference Date/Time
                                     Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //Title
                                     Piece(thisSearchResults.Strings[thisIndex],'^',6) + ', ' + //Hospital Location
                                     Piece(Piece(thisSearchResults.Strings[thisIndex],'^',5),';',2);
                //Load the field(s) that will be used for drill-down
                thisNodeData.FTIUDocNum := Piece(thisSearchResults.Strings[thisIndex],'^',1);
                AddNodeToTree(vSearchTree, thisNode, thisNodeData);
                self.UpdateHits(false, SEARCH_AREA_TIU, NumTIUFound);
                UpdateTotalRecordsFound();
                end
              end;
            end
          else //DOCUMENT (Deep) Search
            //Add the current node to the tree ONLY if the current record text contains
            // one or more search terms - Else do NOT add it to the tree.
            // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
            // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchTIUNotes)
            // to determine if the search text is in a record body.
            begin
            NumTIUFound := NumTIUFound + 1;
            thisNodeData.FCaption :=
                                 FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + '  ' +  //Reference Date/Time
                                 Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //Title
                                 Piece(thisSearchResults.Strings[thisIndex],'^',6) + ', ' + //Hospital Location
                                 Piece(Piece(thisSearchResults.Strings[thisIndex],'^',5),';',2);
            //Load the field(s) that will be used for drill-down
            thisNodeData.FTIUDocNum := Piece(thisSearchResults.Strings[thisIndex],'^',1);
            AddNodeToTree(vSearchTree, thisNode, thisNodeData);
            self.UpdateHits(false, SEARCH_AREA_TIU, NumTIUFound);
            UpdateTotalRecordsFound();
            end;
        end;
      ADVANCED_SEARCH:
        begin
          if not self.DeepSearch then
            begin
            //If the Reference date/time = '', then no TIU note will exist - So skip it (Do we need this check on TIU Notes??)
            if Piece(thisSearchResults.Strings[thisIndex],'^',3) <> '' then
              begin
              //TITLE Search: We're getting ALL the RPC results back.  Now, we want to filter the RPC results on the Search Term(s)
              //showmessage('ordbEndDateTIUAdv.Text = ' + DateTimeToStr(StrToDateTime(ordbEndDateTIUAdv.Text))); //debug
              if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) and
                  ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',3),'.',1  )) >=  ordbStartDateTIUAdv.FMDateTime ) and
                  ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',3),'.',1  )) <=  ordbEndDateTIUAdv.FMDateTime ) then
                begin
                NumTIUFound := NumTIUFound + 1;
                thisNodeData.FCaption :=
                                     FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + '  ' +  //Reference Date/Time
                                     Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //Title
                                     Piece(thisSearchResults.Strings[thisIndex],'^',6) + ', ' + //Hospital Location
                                     Piece(Piece(thisSearchResults.Strings[thisIndex],'^',5),';',2);
                //Load the field(s) that will be used for drill-down
                thisNodeData.FTIUDocNum := Piece(thisSearchResults.Strings[thisIndex],'^',1);
                AddNodeToTree(vSearchTree, thisNode, thisNodeData);
                self.UpdateHits(true, SEARCH_AREA_TIU, NumTIUFound);
                UpdateTotalRecordsFound();
                end;
              end;
            end
          else //Deep Search
            //Add the current node to the tree ONLY if the current record text contains
            // one or more search terms - Else do NOT add it to the tree.
            // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
            // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchTIUNotes)
            // to determine if the search text is in a record body.
            begin
            NumTIUFound := NumTIUFound + 1;
            thisNodeData.FCaption :=
                                 FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + '  ' +  //Reference Date/Time
                                 Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //Title
                                 Piece(thisSearchResults.Strings[thisIndex],'^',6) + ', ' + //Hospital Location
                                 Piece(Piece(thisSearchResults.Strings[thisIndex],'^',5),';',2);
            //Load the field(s) that will be used for drill-down
            thisNodeData.FTIUDocNum := Piece(thisSearchResults.Strings[thisIndex],'^',1);
            AddNodeToTree(vSearchTree, thisNode, thisNodeData);
            self.UpdateHits(true, SEARCH_AREA_TIU, NumTIUFound);
            UpdateTotalRecordsFound();
            end;
        end;
    end;

    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadTIUNode()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.meSaveSearchResultsToFileClick(Sender: TObject);
begin
{
    if self.ThisNode = nil then
      Exit;

    if dlgSaveSearchResultsToFile.Execute then
      reDetail.Lines.SaveToFile(dlgSaveSearchResultsToFile.Filename);
}
end;

procedure TfrmSearchCriteria.meShowResultsOnSearchCompletionClick(Sender: TObject);
begin
  if meShowResultsonSearchCompletion.Checked then
    meShowResultsonSearchCompletion.Checked  := false
  else
    meShowResultsonSearchCompletion.Checked  := true;
end;

procedure TfrmSearchCriteria.mnuShowBrokerHistoryClick(Sender: TObject);
begin
  fxBroker.ShowBroker();
end;

procedure TfrmSearchCriteria.pcSearchChange(Sender: TObject);
begin
{
  if meTitleSearch.Checked then
    begin
    meWholeWords.Enabled := false;
    meCaseSensitive.Enabled := false;
    end;

  if meDocumentSearch.Checked then
    begin
    meWholeWords.Enabled := true;
    meCaseSensitive.Enabled := true;
    end;
}
  if pcSearch.ActivePage = tsSearchResults then
    begin
    meOpenSavedSearchTerms.Enabled := false;
    self.sbSearch.Enabled := false;
    //self.sbCancel.Enabled := false;
    self.buSearchTerms.Enabled := false;
    self.buQuickSearch.Enabled := false;
    self.sbClearAllSearchCriteria.Enabled := false;
    meWholeWords.Enabled := false;
    meCaseSensitive.Enabled := false;
    buSaveSearchTerms.Enabled := false;
    self.sbSearch.Enabled := false;
    end
  else
    begin
    if pcSearch.ActivePage = tsStandardSearch then
      begin
      //frmSearchTerms.laStartDate.Visible := false;
      //frmSearchTerms.laEndDate.Visible := false;
      //frmSearchTerms.ordbStartDate.Visible := false;
      //frmSearchTerms.ordbEndDate.Visible := false;
      meOpenSavedSearchTerms.Enabled := true;
      self.SearchType := STANDARD_SEARCH;
      self.sbClearAllSearchCriteria.Enabled := true;

      //meWholeWords.Checked := false;
      //meCaseSensitive.Checked := false;

      meWholeWords.Enabled := true;
      meCaseSensitive.Enabled := true;

      buSaveSearchTerms.Caption := 'Save S&td Search';
      buSaveSearchTerms.Enabled := true;
      self.sbSearch.Enabled := true;
      self.buSearchTerms.Enabled := true;
      self.buQuickSearch.Enabled := true;

      if ((frmReportSelect.Showing) and (frmReportSelect.Caption = fReportSelect.CAPTION_ADVANCED)) then
        begin
        frmReportSelect.Close;
        frmReportSelect.Show;
        end;
      end;

    if pcSearch.ActivePage = tsAdvancedSearch then
      begin
      //frmSearchTerms.laStartDate.Visible := true;
      //frmSearchTerms.laEndDate.Visible := true;
      //frmSearchTerms.ordbStartDate.Visible := true;
      //frmSearchTerms.ordbEndDate.Visible := true;
      meOpenSavedSearchTerms.Enabled := true;
      self.SearchType := ADVANCED_SEARCH;
      self.sbClearAllSearchCriteria.Enabled := true;

      meWholeWords.Enabled := true;
      meCaseSensitive.Enabled := true;

      buSaveSearchTerms.Caption := 'Save Ad&v Search';
      buSaveSearchTerms.Enabled := true;
      self.sbSearch.Enabled := true;
      self.buSearchTerms.Enabled := true;
      self.buQuickSearch.Enabled := true;      

      if ((frmReportSelect.Showing) and (frmReportSelect.Caption = fReportSelect.CAPTION_STANDARD)) then
        begin
        frmReportSelect.Close;
        frmReportSelect.Show;
        end;

      end;

    self.sbCancel.Enabled := true;
    end;
end;

procedure TfrmSearchCriteria.reDetailMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{
 Save search results to file, popup menu on reDetail.
}
var
  thisPoint: TPoint;
begin

  if Button = mbRight then
    begin
    //Only show the popup menu if a node is selected
    if self.ThisNode = nil then
      Exit;

    GetCursorPos(thisPoint);
    popActions.Popup(thisPoint.X, thisPoint.Y);
    end;

end;

procedure TfrmSearchCriteria.rgPriorityClick(Sender: TObject);
begin
  if rgPriority.ItemIndex = 0 then
    self.FSearchPriority := SEARCH_PRIORITY_FACTOR
  else
    self.FSearchPriority := SEARCH_PRIORITY_DEFAULT;
end;

procedure TfrmSearchCriteria.rgTIUNoteOptionsAdvClick(Sender: TObject);
{
 The documents that are getting returned from TIU DOCUMENTS BY CONTEXT are all
 based on the document TITLE !!   Therefore, we CANNOT expect to do, say, a
 Deep search for 'Signed Notes (All)', filtered by Date range.  This is because
 TIU DOCUMENTS BY CONTEXT is only returning Notes based on the TITLE.
 *****************************************************************************
 ***  To do an Advanced Deep search using a Date range, we MUST select the
 ***  'Signed Notes by Date Range' filter.  This is the ONLY way it will work,
 ***  AND it is the way that CPRS handles it, as well.
 *****************************************************************************

 ...so this routine DISABLES the ORDate boxes on TIU for Advanced Search for ANY
 filter OTHER THAN 'Signed Notes by Date Range'.
}
begin
  if rgTIUNoteOptionsAdv.ItemIndex = 3 then
    begin
    ordbStartDateTIUAdv.Enabled := true;
    ordbEndDateTIUAdv.Enabled := true;
    end
  else
    begin
    ordbStartDateTIUAdv.Enabled := false;
    ordbEndDateTIUAdv.Enabled := false;
    end;
end;

procedure TfrmSearchCriteria.rgTIUNoteOptionsStdClick(Sender: TObject);
{
 This procedure disables seTIUMaxStd (on Standard TIU search), for any
 filter except for 'Signed Notes (All)'. Apparently, the RPC
 'TIU DOCUMENTS BY CONTEXT' does not honor the OCCLIM parameter when
 not using a date-range, as with Advanced TIU search.  To have this
 "make sense" from a GUI user point of view, and since Standard TIU
 search does not offer date-range, the 'Max Return Instances' edit
 box is enabled ONLY when the filter 'Signed Notes (All) is selected.
}
begin
  if (rgTIUNoteOptionsStd.ItemIndex = 0) then
    seTIUMaxStd.Enabled := true
  else
    seTIUMaxStd.Enabled := false;
end;

procedure TfrmSearchCriteria.meSaveSearchResultsToAFileClick(Sender: TObject);
begin
    self.meSaveSearchResultsToFileClick(nil);
end;

function TfrmSearchCriteria.ConvertActiveStatus(thisActiveStatus: string) : string;
begin
  if thisActiveStatus = 'A' then result := 'Active';
  if thisActiveStatus = 'I' then result := 'Inactive';
end;

procedure TfrmSearchCriteria.meCopytoClipboardClick(Sender: TObject);
begin
  reDetail.CopyToClipboard();
end;

procedure TfrmSearchCriteria.LoadProblemTextNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                                 thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
begin
  try
    Application.ProcessMessages;
    if self.SearchCancelled then Exit;

    ////Ignore RPC.Result[0] because it is the number of hits being returned, and NOT an actual record
    if thisIndex = 0 then Exit;
  
    case thisSearchType of
      STANDARD_SEARCH:
        begin
          if not self.DeepSearch then //TITLE Search
            begin
            //If the 'Last Modified' date/time = '', then no Problem Text will exist - So skip it (Do we need this check on Problem Text??)
            if Piece(thisSearchResults.Strings[thisIndex],'^',6) <> '' then
              begin
              if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) then
                begin
                NumProblemTextFound := NumProblemTextFound + 1;
                //ORQQPL3
                // 1     2        3        4   5        6        7    8        9     10    11     12    13
                //ifn^status^description^ICD^onset^last modified^SC^SpExp^Condition^Loc^loc.type^prov^service
                thisNodeData.FCaption :=
                                     Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //IFN
                                     ConvertActiveStatus(Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' + //Active status
                                     Piece(Piece(thisSearchResults.Strings[thisIndex],'^',12),';',2) + ', ' +  //Provider (INT;EXT)
                                     Piece(thisSearchResults.Strings[thisIndex],'^',3); //  + ', ' + //Description
                                     //Piece(thisSearchResults.Strings[thisIndex],'^',1); //Location

                //Load the fields that will be used for drill-down
                thisNodeData.FProblemIFN := Piece(thisSearchResults.Strings[thisIndex],'^',1);
                thisNodeData.FActiveStatus := Piece(thisSearchResults.Strings[thisIndex],'^',2);
                thisNodeData.FProblemDescription := Piece(thisSearchResults.Strings[thisIndex],'^',3);
                thisNodeData.FLocation := Piece(thisSearchResults.Strings[thisIndex],'^',10);
                thisNodeData.FProvider := Piece(thisSearchResults.Strings[thisIndex],'^',12);

                AddNodeToTree(vSearchTree, thisNode, thisNodeData);
                self.UpdateHits(false, SEARCH_AREA_PROBLEM_TEXT, NumProblemTextFound);
                UpdateTotalRecordsFound();
                end;
              end;
            end
          else //DOCUMENT (Deep) Search
            //Add the current node to the tree ONLY if the current record text contains
            // one or more search terms - Else do NOT add it to the tree.
            // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
            // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchProblemText)
            // to determine if the search text is in a record body.
            begin
            NumProblemTextFound := NumProblemTextFound + 1;
            thisNodeData.FCaption :=
                                 Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //IFN
                                 ConvertActiveStatus(Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' + //Active status
                                 Piece(Piece(thisSearchResults.Strings[thisIndex],'^',12),';',2) + ', ' +  //Provider (INT;EXT)
                                 Piece(thisSearchResults.Strings[thisIndex],'^',3); //  + ', ' + //Description
                                 //Piece(thisSearchResults.Strings[thisIndex],'^',10); //Location

            //Load the field(s) that will be used for drill-down
            thisNodeData.FProblemIFN := Piece(thisSearchResults.Strings[thisIndex],'^',1);
            AddNodeToTree(vSearchTree, thisNode, thisNodeData);
            self.UpdateHits(false, SEARCH_AREA_PROBLEM_TEXT, NumProblemTextFound);
            UpdateTotalRecordsFound();
            end;
        end;
      ADVANCED_SEARCH:
        begin
        if not self.DeepSearch then
          begin
          //If the 'Last Modified' date/time = '', then no Problem Text will exist - So skip it (Do we need this check on Problem Text??)
          if Piece(thisSearchResults.Strings[thisIndex],'^',6) <> '' then
            begin
            if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) and
                ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',6),'.',1  )) >=  ordbStartDateProblemTextAdv.FMDateTime ) and
                ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',6),'.',1  )) <=  ordbEndDateProblemTextAdv.FMDateTime ) then
              begin
              NumProblemTextFound := NumProblemTextFound + 1;
              //ORQQPL3
              // 1     2        3        4   5        6        7    8        9     10    11     12    13
              //ifn^status^description^ICD^onset^last modified^SC^SpExp^Condition^Loc^loc.type^prov^service
              thisNodeData.FCaption :=
                                   Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //IFN
                                   ConvertActiveStatus(Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' + //Active status
                                   Piece(Piece(thisSearchResults.Strings[thisIndex],'^',12),';',2) + ', ' +  //Provider (INT;EXT)
                                   Piece(thisSearchResults.Strings[thisIndex],'^',3); //  + ', ' + //Description
                                   //Piece(thisSearchResults.Strings[thisIndex],'^',10); //Location

              //Load the fields that will be used for drill-down
              thisNodeData.FProblemIFN := Piece(thisSearchResults.Strings[thisIndex],'^',1);
              thisNodeData.FActiveStatus := Piece(thisSearchResults.Strings[thisIndex],'^',2);
              thisNodeData.FProblemDescription := Piece(thisSearchResults.Strings[thisIndex],'^',3);
              thisNodeData.FLocation := Piece(thisSearchResults.Strings[thisIndex],'^',10);
              thisNodeData.FProvider := Piece(thisSearchResults.Strings[thisIndex],'^',12);

              AddNodeToTree(vSearchTree, thisNode, thisNodeData);
              self.UpdateHits(true, SEARCH_AREA_PROBLEM_TEXT, NumProblemTextFound);
              UpdateTotalRecordsFound();
              end;
            end;
          end
        else //Deep Search
          //Add the current node to the tree ONLY if the current record text contains
          // one or more search terms - Else do NOT add it to the tree.
          // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
          // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchTIUNotes)
          // to determine if the search text is in a record body.
          begin
          NumProblemTextFound := NumProblemTextFound + 1;
          thisNodeData.FCaption :=
                               Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //IFN
                               ConvertActiveStatus(Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' + //Active status
                               Piece(Piece(thisSearchResults.Strings[thisIndex],'^',12),';',2) + ', ' +  //Provider (INT;EXT)
                               Piece(thisSearchResults.Strings[thisIndex],'^',3); //Description

          //Load the field(s) that will be used for drill-down
          thisNodeData.FProblemIFN := Piece(thisSearchResults.Strings[thisIndex],'^',1);
          AddNodeToTree(vSearchTree, thisNode, thisNodeData);
          self.UpdateHits(true, SEARCH_AREA_PROBLEM_TEXT, NumProblemTextFound);
          UpdateTotalRecordsFound();
          end;
        end;
    end;

    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadProblemTextNode()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end; //LoadProblemTextNode

procedure TfrmSearchCriteria.LoadConsultsNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                              thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
begin
  try
    Application.ProcessMessages;
    if self.SearchCancelled then Exit;

    case thisSearchType of
      STANDARD_SEARCH:
        begin
          if not self.DeepSearch then //TITLE Search
            begin
            //If the date/time of request is '', then no consult request occurred - So skip it
            if Piece(thisSearchResults.Strings[thisIndex],'^',2) <> '' then
              begin
              if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) then
                begin
                //We found a search term in the broker Result[], so increment
                NumConsultsFound := NumConsultsFound + 1;
                //
                // 1          2             3        4               5
                //ID^dateTime of request^status^consultingService^procedure
                thisNodeData.FCaption :=
                                     Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //ID
                                     //Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //dateTime of request
                                     FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' +  //dateTime of request
                                     Piece(thisSearchResults.Strings[thisIndex],'^',3) + ', ' + //status
                                     Piece(thisSearchResults.Strings[thisIndex],'^',4) + ', ' + //consultingService
                                     Piece(thisSearchResults.Strings[thisIndex],'^',5); //procedure

                //Load the fields that will be used for drill-down
                thisNodeData.FConsultID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
                thisNodeData.FDateTimeOfConsultRequest := Piece(thisSearchResults.Strings[thisIndex],'^',2);
                thisNodeData.FConsultStatus := Piece(thisSearchResults.Strings[thisIndex],'^',3);
                thisNodeData.FConsultingService := Piece(thisSearchResults.Strings[thisIndex],'^',4);
                thisNodeData.FConsultProcedure := Piece(thisSearchResults.Strings[thisIndex],'^',5);

                AddNodeToTree(vSearchTree, thisNode, thisNodeData);
                self.UpdateHits(false, SEARCH_AREA_CONSULTS, NumConsultsFound);
                UpdateTotalRecordsFound();
                end;
              end;
            end
          else //DOCUMENT (Deep) Search
            //Add the current node to the tree ONLY if the current record text contains
            // one or more search terms - Else do NOT add it to the tree.
            // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
            // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchProblemText)
            // to determine if the search text is in a record body.
            begin
            NumConsultsFound := NumConsultsFound + 1;
            thisNodeData.FCaption :=
                                 Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //ID
                                 //Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //dateTime of request
                                 FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' +  //dateTime of request
                                 Piece(thisSearchResults.Strings[thisIndex],'^',3) + ', ' + //status
                                 Piece(thisSearchResults.Strings[thisIndex],'^',4) + ', ' + //consultingService
                                 Piece(thisSearchResults.Strings[thisIndex],'^',5); //procedure

            //Load the field(s) that will be used for drill-down
            thisNodeData.FConsultID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
            AddNodeToTree(vSearchTree, thisNode, thisNodeData);
            self.UpdateHits(false, SEARCH_AREA_CONSULTS, NumConsultsFound);
            UpdateTotalRecordsFound();
            end;
        end;
      ADVANCED_SEARCH:
        begin
        if not self.DeepSearch then
          begin
          //If the date/time of request is '', then no consult request occurred - So skip it
          if Piece(thisSearchResults.Strings[thisIndex],'^',2) <> '' then
            begin
            if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) and
                ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',2),'.',1  )) >=  ordbStartDateConsultsAdv.FMDateTime ) and
                ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',2),'.',1  )) <=  ordbEndDateConsultsAdv.FMDateTime ) then
              begin
              NumConsultsFound := NumConsultsFound + 1;
              //
              // 1          2             3        4               5
              //ID^dateTime of request^status^consultingService^procedure
              thisNodeData.FCaption :=
                                   Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //ID
                                   //Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //dateTime of request
                                   FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' +  //dateTime of request
                                   Piece(thisSearchResults.Strings[thisIndex],'^',3) + ', ' + //status
                                   Piece(thisSearchResults.Strings[thisIndex],'^',4) + ', ' + //consultingService
                                   Piece(thisSearchResults.Strings[thisIndex],'^',5); //procedure

              //Load the fields that will be used for drill-down
              thisNodeData.FConsultID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
              thisNodeData.FDateTimeOfConsultRequest := Piece(thisSearchResults.Strings[thisIndex],'^',2);
              thisNodeData.FConsultStatus := Piece(thisSearchResults.Strings[thisIndex],'^',3);
              thisNodeData.FConsultingService := Piece(thisSearchResults.Strings[thisIndex],'^',4);
              thisNodeData.FConsultProcedure := Piece(thisSearchResults.Strings[thisIndex],'^',5);

              AddNodeToTree(vSearchTree, thisNode, thisNodeData);
              self.UpdateHits(true, SEARCH_AREA_CONSULTS, NumConsultsFound);
              UpdateTotalRecordsFound();
              end;
            end;
          end
        else //Deep Search
          //Add the current node to the tree ONLY if the current record text contains
          // one or more search terms - Else do NOT add it to the tree.
          // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
          // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchTIUNotes)
          // to determine if the search text is in a record body.
          begin
          NumConsultsFound := NumConsultsFound + 1;
          thisNodeData.FCaption :=
                               Piece(thisSearchResults.Strings[thisIndex],'^',1) + ', ' +  //ID
                               //Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' + //dateTime of request
                               FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',2)) + ', ' +  //dateTime of request
                               Piece(thisSearchResults.Strings[thisIndex],'^',3) + ', ' + //status
                               Piece(thisSearchResults.Strings[thisIndex],'^',4) + ', ' + //consultingService
                               Piece(thisSearchResults.Strings[thisIndex],'^',5); //procedure

          //Load the field(s) that will be used for drill-down
          thisNodeData.FConsultID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
          AddNodeToTree(vSearchTree, thisNode, thisNodeData);
          self.UpdateHits(true, SEARCH_AREA_CONSULTS, NumConsultsFound);
          UpdateTotalRecordsFound();
          end;

        end;
    end;

    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadConsultsNode()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.LoadOrdersNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                            thisNodeData: TTreeData; thisSearchResults: TStrings; thisIndex: integer);
begin
  try

    Application.ProcessMessages;
    if self.SearchCancelled then Exit;

    case thisSearchType of
      STANDARD_SEARCH:
        begin
          if not self.DeepSearch then //TITLE Search
            begin
            //If the date/time of request is '', then no request occurred - So skip it
            if Piece(thisSearchResults.Strings[thisIndex],'^',2) <> '' then
              begin
              if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) then
                begin
                NumOrdersFound := NumOrdersFound + 1;
                // 1          2             3        4               5
                //ID^dateTime of request^status^consultingService^procedure
                thisNodeData.FCaption :=
                                     Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' +  //Order Title
                                     FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + ', ' + //status
                                     Piece(thisSearchResults.Strings[thisIndex],'^',4); // + ', ' + //Order Status (eg. Pending, Active, etc)

                //Load the fields that will be used for drill-down
                thisNodeData.FOrderID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
                AddNodeToTree(vSearchTree, thisNode, thisNodeData); //Show ALL orders
                self.UpdateHits(false, SEARCH_AREA_ORDERS, NumOrdersFound);
                UpdateTotalRecordsFound();
                end;
              end;
            end
          else //DOCUMENT (Deep) Search
            //Add the current node to the tree ONLY if the current record text contains
            // one or more search terms - Else do NOT add it to the tree.
            // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
            // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchProblemText)
            // to determine if the search text is in a record body.
            begin
            NumOrdersFound := NumOrdersFound + 1;
            thisNodeData.FCaption :=
                                 Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' +  //dateTime of request
                                 FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + ', ' + //Order Date
                                 Piece(thisSearchResults.Strings[thisIndex],'^',4); // + ', ' + //consultingService

            //Load the field(s) that will be used for drill-down
            thisNodeData.FOrderID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
            AddNodeToTree(vSearchTree, thisNode, thisNodeData); //Show ALL orders
            self.UpdateHits(false, SEARCH_AREA_ORDERS, NumOrdersFound);
            UpdateTotalRecordsFound();
            end;

        end;
      ADVANCED_SEARCH:
        begin
        if not self.DeepSearch then
          begin
            //If the date/time of request is '', then no request occurred - So skip it
            if Piece(thisSearchResults.Strings[thisIndex],'^',2) <> '' then
              begin
              if ContainsSearchTerms(thisSearchTermComponent, thisSearchResults[thisIndex]) and
                  //( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',2),'.',1  )) >=  ordbStartDateOrdersAdv.FMDateTime ) and //commented - 20120925
                  //( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',2),'.',1  )) <=  ordbEndDateOrdersAdv.FMDateTime ) then  //commented - 20120925
                  ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',3),'.',1  )) >=  ordbStartDateOrdersAdv.FMDateTime ) and  //this mod - 20120925
                  ( strToFloat(Piece(Piece(thisSearchResults.Strings[thisIndex],'^',3),'.',1  )) <=  ordbEndDateOrdersAdv.FMDateTime ) then   //this mod - 20120925
                begin
                NumOrdersFound := NumOrdersFound + 1;
                // 1          2             3        4               5
                //ID^dateTime of request^status^consultingService^procedure
                thisNodeData.FCaption :=
                                     Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' +  //Order Title
                                     FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + ', ' + //status
                                     Piece(thisSearchResults.Strings[thisIndex],'^',4); // + ', ' + //Order Status (eg. Pending, Active, etc)

                //Load the fields that will be used for drill-down
                thisNodeData.FOrderID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
                AddNodeToTree(vSearchTree, thisNode, thisNodeData); //Show ALL orders
                self.UpdateHits(true, SEARCH_AREA_ORDERS, NumOrdersFound);
                UpdateTotalRecordsFound();
                end;
              end;
          end
        else //Deep Search
          //Add the current node to the tree ONLY if the current record text contains
          // one or more search terms - Else do NOT add it to the tree.
          // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
          // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchTIUNotes)
          // to determine if the search text is in a record body.
          begin
          NumOrdersFound := NumOrdersFound + 1;
          thisNodeData.FCaption :=
                                 Piece(thisSearchResults.Strings[thisIndex],'^',2) + ', ' +  //dateTime of request
                                 FormatFMDateTimeStr('mm/dd/yyyy',Piece(thisSearchResults.Strings[thisIndex],'^',3)) + ', ' + //Order Date
                                 Piece(thisSearchResults.Strings[thisIndex],'^',4); // + ', ' + //consultingService

          //Load the field(s) that will be used for drill-down
          thisNodeData.FOrderID := Piece(thisSearchResults.Strings[thisIndex],'^',1);
          AddNodeToTree(vSearchTree, thisNode, thisNodeData); //Show ALL orders
          self.UpdateHits(true, SEARCH_AREA_ORDERS, NumOrdersFound);
          UpdateTotalRecordsFound();
          end;
        end;
    end;

    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadOrdersNode()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;

//procedure TfrmSearchCriteria.LoadReportsNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                            //thisNodeData: TTreeData; thisReportText: TStrings; thisIndex: integer);
procedure TfrmSearchCriteria.LoadReportsNode(thisSearchType: boolean; var thisSearchTermComponent: TLabeledEdit; thisNode: PVirtualNode;
                                            thisNodeData: TTreeData; thisReportText: string; thisIndex: integer);
begin
  try
    Application.ProcessMessages;
    if self.SearchCancelled then Exit;

    case thisSearchType of
      STANDARD_SEARCH:
        begin
        if not self.DeepSearch then //TITLE Search
          begin
          //if ContainsSearchTerms(thisSearchTermComponent, thisReportText[thisIndex]) then
          if ContainsSearchTerms(thisSearchTermComponent, thisReportText) then
            begin
            NumReportsFound := NumReportsFound + 1;
            thisNodeData.FCaption := self.ReportName;
            thisNodeData.FReportIDString := self.ReportIDList[thisIndex];

            //Load the fields that will be used for drill-down
            thisNodeData.FReportName := self.ReportName;
            thisNodeData.FReportID := self.ReportID;
            thisNodeData.FProcID := self.ProcID;
            AddNodeToTree(vSearchTree, thisNode, thisNodeData);
            self.UpdateHits(false, SEARCH_AREA_REPORTS, NumReportsFound);
            UpdateTotalRecordsFound();
            end;
          end
        else //DOCUMENT (Deep) Search
          //Add the current node to the tree ONLY if the current record text contains
          // one or more search terms - Else do NOT add it to the tree.
          // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
          // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchReports)
          // to determine if the search text is in a record body.
          begin
          /////Debug ///////////////////
          //showmessage('self.ReportIDList[thisIndex] = ' + self.ReportIDList[thisIndex]);
          //////////////////////////////
          NumReportsFound := NumReportsFound + 1;
          thisNodeData.FCaption :=  self.ReportName;
          thisNodeData.FReportIDString := self.ReportIDList[thisIndex];

          //Load the field(s) that will be used for drill-down
          thisNodeData.FReportName := self.ReportName;
          thisNodeData.FReportID := self.ReportID;
          thisNodeData.FProcID := self.ProcID;
          AddNodeToTree(vSearchTree, thisNode, thisNodeData);
          self.UpdateHits(false, SEARCH_AREA_REPORTS, NumReportsFound);
          UpdateTotalRecordsFound();
          end;
        end;
      ADVANCED_SEARCH:
        begin
        if not self.DeepSearch then //TITLE Search
          begin
          if ContainsSearchTerms(thisSearchTermComponent, thisReportText) then
            begin
            NumReportsFound := NumReportsFound + 1;
            thisNodeData.FCaption := self.ReportName;
            thisNodeData.FReportIDString := self.ReportIDList[thisIndex];

            //Load the fields that will be used for drill-down
            thisNodeData.FReportName := self.ReportName;
            thisNodeData.FReportID := self.ReportID;
            AddNodeToTree(vSearchTree, thisNode, thisNodeData);
            self.UpdateHits(true, SEARCH_AREA_REPORTS, NumReportsFound);
            UpdateTotalRecordsFound();
            end;
          end
        else //DOCUMENT (Deep) Search
          //Add the current node to the tree ONLY if the current record text contains
          // one or more search terms - Else do NOT add it to the tree.
          // Also, on a Deep Search we do NOT want to call ContainsSearchTerms (as above on a "shallow" search),
          // because deep search has it's OWN routine (SearchTermsFoundInRecordBody in procedure SearchReports)
          // to determine if the search text is in a record body.
          begin
          /////Debug ///////////////////
          //showmessage('self.ReportIDList[thisIndex] = ' + self.ReportIDList[thisIndex]);
          //////////////////////////////
          NumReportsFound := NumReportsFound + 1;
          thisNodeData.FCaption :=  self.ReportName;
          thisNodeData.FReportIDString := self.ReportIDList[thisIndex];

          //Load the field(s) that will be used for drill-down
          thisNodeData.FReportName := self.ReportName;
          thisNodeData.FReportID := self.ReportID;
          thisNodeData.FProcID := self.ProcID;
          AddNodeToTree(vSearchTree, thisNode, thisNodeData);
          self.UpdateHits(true, SEARCH_AREA_REPORTS, NumReportsFound);
          UpdateTotalRecordsFound();
          end;
        end;
    end;

    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadReportsNode()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.GetSortDirection(var thisSortByComponent: TJVRadioGroup) : char;
begin
  try
    case thisSortByComponent.ItemIndex of
      0: result := 'A';
      1: result := 'D';
    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.GetSortDirection()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.UpdateHits(IsAdvancedSearch: boolean; thisSearchArea: integer; thisNumberFound: integer);
begin
  try
    case thisSearchArea of
             SEARCH_AREA_TIU: begin
                              laTIUNotesFoundStd.Caption := CAPTION_FOUND;
                              laTIUNotesFoundAdv.Caption := CAPTION_FOUND;
                              if not IsAdvancedSearch then
                                laTIUNotesFoundStd.Caption := laTIUNotesFoundStd.Caption + intToStr(thisNumberFound)
                              else
                                laTIUNotesFoundAdv.Caption := laTIUNotesFoundAdv.Caption + intToStr(thisNumberFound);
                              laTIUNotesFoundStd.Invalidate;
                              laTIUNotesFoundAdv.Invalidate;
                              end;
    SEARCH_AREA_PROBLEM_TEXT: begin
                              laProblemTextFoundStd.Caption := CAPTION_FOUND;
                              laProblemTextFoundAdv.Caption := CAPTION_FOUND;
                              if not IsAdvancedSearch then
                                laProblemTextFoundStd.Caption := laProblemTextFoundStd.Caption + intToStr(thisNumberFound)
                              else
                                laProblemTextFoundAdv.Caption := laProblemTextFoundAdv.Caption + intToStr(thisNumberFound);
                              laProblemTextFoundStd.Invalidate;
                              laProblemTextFoundAdv.Invalidate;
                              end;
        SEARCH_AREA_CONSULTS: begin
                              laConsultsFoundStd.Caption := CAPTION_FOUND;
                              laConsultsFoundAdv.Caption := CAPTION_FOUND;
                              if not IsAdvancedSearch then
                                laConsultsFoundStd.Caption := laConsultsFoundStd.Caption + intToStr(thisNumberFound)
                              else
                                laConsultsFoundAdv.Caption := laConsultsFoundAdv.Caption + intToStr(thisNumberFound);
                              laConsultsFoundStd.Invalidate;
                              laConsultsFoundAdv.Invalidate;
                              end;
          SEARCH_AREA_ORDERS: begin
                              laOrdersFoundStd.Caption := CAPTION_FOUND;
                              laOrdersFoundAdv.Caption := CAPTION_FOUND;
                              if not IsAdvancedSearch then
                                laOrdersFoundStd.Caption := laOrdersFoundStd.Caption + intToStr(thisNumberFound)
                              else
                                laOrdersFoundAdv.Caption := laOrdersFoundAdv.Caption + intToStr(thisNumberFound);
                              laOrdersFoundStd.Invalidate;
                              laOrdersFoundAdv.Invalidate;
                              end;
         SEARCH_AREA_REPORTS: begin
                              laReportsFoundStd.Caption := CAPTION_FOUND;
                              laReportsFoundAdv.Caption := CAPTION_FOUND;
                              if not IsAdvancedSearch then
                                laReportsFoundStd.Caption := laReportsFoundStd.Caption + intToStr(thisNumberFound)
                              else
                                laReportsFoundAdv.Caption := laReportsFoundAdv.Caption + intToStr(thisNumberFound);
                              laReportsFoundStd.Invalidate;
                              laReportsFoundAdv.Invalidate;
                              end;
    end;

  Application.ProcessMessages; //Force repaint of the record hit counters (TLabels)
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.UpdateHits()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.LoadWordList(thisString: string);
{
 Load a TList with the INDIVIDUAL WORDS in the body text of the document being searched.
}
var
  index: Word;
  count: Longint;
  thisWord: string;
  wordRec: PWordRecord;
begin
  try
    count := 0;
    index := 1;
    thisWord := '';

    while index <= Length(thisString) do
      begin
      while (index <= Length(thisString)) and (Separator(thisString[index])) do
        Inc(index);

      if index <= Length(thisString) then
        begin
          Inc(count);
          //Load the word-list
          thisWord := '';
          while (index <= Length(thisString)) and (not Separator(thisString[index])) do
            begin
            Inc(index);
            thisWord := thisWord + thisString[index-1];
            end;
            new(wordRec);
            wordRec^.word := thisWord;
            self.WordList.Add(wordRec);
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadWordList()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.SearchTermsFoundInRecordBodySequential(thisSearchTermComponent: TLabeledEdit; thisBodyText: string) : boolean;
{
 =================================
 SEQUENTIAL Search implementation:
 =================================
 This function implements a SEQUENTIAL search on the body text of a document (in "Deep Search" mode).
 The text to be searched has not been sorted.
 
 Sequential search is an O(n) operation, whether or not the words in the document being searched are sorted.
 Sorted or not, search time depends directly on the number of words in the body text of the document being searched.

 Binary search on the other hand, is an O(log(n)) operation, where the speed of the algorithm is aprox. proportional
 to log(2) of the number of words in the document being searched, which means that squaring the number of words
 in a document to be searched means only 2x the search time. Very Fast!
}
var
  j: integer;
  searchTerm: string;
  FoundAt: LongInt;
begin
  try
    if self.SearchCancelled then Exit;

    result := false;
    self.slSearchTerms.Clear;
    ParseDelimited(self.slSearchTerms, thisSearchTermComponent.Text, ' ');  //Load our new TStringList with the search terms

    for j := 0 to self.slSearchTerms.Count-1 do
      begin
      if self.SearchCancelled then
        Break;

        if not meCaseSensitive.Checked then
          searchTerm := UpperCase(self.slSearchTerms[j])
        else
          searchTerm := self.slSearchTerms[j];

        FoundAt := 0;
        FoundAt := Pos(searchTerm, thisBodyText);
        if FoundAt > 0 then
          begin
          result := true;
          Break; //Jump out - we don't want to continue searching if we have found at least one search term
          end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SearchTermsFoundInRecordBodySequential()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.SearchTermsFoundInRecordBody(thisSearchTermComponent: TLabeledEdit) : integer;
{
 =============================
 BINARY Search implementation:
 =============================
 This function implements a BINARY search on the body text of a document (in "Deep Search" mode).
 Note: The text to be searched has already been sorted by the time this function is called.
 
 Sequential search is an O(n) operation, whether or not the words in the document being searched are sorted.
 Search time depends directly on the number of words in the body text of the document being searched.

 Binary search on the other hand, is an O(log(n)) operation, where the speed of the algorithm is aprox. proportional
 to log(2) of the number of words in the document being searched, which means that squaring the number of words
 in a document to be searched means only 2x the search time. Very Fast!

 This algorithm searches on WHOLE WORDS only. What is considered to be a whole word is
 determined by the delimiters that are used (see function TfrmSearchCriteria.Separator()).
}
var
  left, right, middle: integer;
  compareResult: integer;
  i: longint;
  j: longint;
  thisSearchTerm: PWordRecord;
begin
  try
    if self.SearchCancelled then Exit;
    
    result := -1; //init
    self.slSearchTerms.Clear;
    ParseDelimited(self.slSearchTerms, thisSearchTermComponent.Text, ' ');  //Load our TStringList with the search terms

    for i := 0 to self.slSearchTerms.Count-1 do
      begin
      if self.SearchCancelled then
        Break;
        for j := 0 to self.WordList.Count - 1 do
          begin
          left := 0;
          right := pred(self.WordList.Count);

          while (left <= right) do
            begin
              middle := (left + right) div 2;

              thisSearchTerm := new(PWordRecord);

              //Case sensitive Binary search
              if not meCaseSensitive.Checked then //NOTE: Case-sensitivity is Disabled for Standard searches
                thisSearchTerm^.word := UpperCase(self.slSearchTerms[i]) //Always UPPERCASE for Standard searches
              else
                thisSearchTerm^.word := self.slSearchTerms[i];

              compareResult := CompareWords(self.WordList.Items[j], thisSearchTerm); //Case-sensitive comparison
              Dispose(thisSearchTerm);

              if CompareResult < 0 then
                left := succ(middle)
              else
                if CompareResult > 0 then
                  right := pred(middle)
                else
                  begin
                  result := middle;
                  Exit;
                  end
            end;
            Result := -1;
          end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SearchTermsFoundInRecordBody()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.SearchTIUNotes(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
 //Parameter thisSearchType:
 //false = Standard Search
 //true = Advanced Search
 //SEE: constants STANDARD_SEARCH and ADVANCED_SEARCH
var
  i: longint;
  j: longint;
  sortDirection: string;
  includeAddenda: boolean;
  includeUntranscribed: boolean;
  Node: PVirtualNode;
  nodeData: TTreeData;
  filterOptionAdv: integer;
begin
  try
    self.UpdateSearchTime();
    Application.ProcessMessages;

    //sbStatusBar.Panels[0].Text := sbStatusBar.Panels[0].Text + CAPTION_TIU_NOTES;
    UpdateStatusBarMessage(sbStatusBar.Panels[0].Text + CAPTION_TIU_NOTES);

    if not self.SearchCancelled then
      begin
      case thisSearchType of
        STANDARD_SEARCH:  if edTIUSearchTermsStd.Text = '' then
                            Exit
                          else
                            begin
                            UpdateStatusBarMessage(STANDARD_SEARCH_IN_PROGRESS + CAPTION_TIU_NOTES);
                            if cbDocumentClassStd.ItemIndex = -1 then
                              begin
                              MessageDlg(TIU_DOCUMENT_CLASS_MISSING, mtInformation, [mbOk], 0);
                              Exit;
                              end;
                            end;
        ADVANCED_SEARCH:  if edTIUSearchTermsAdv.Text = '' then
                            Exit
                          else
                            begin
                            UpdateStatusBarMessage(ADVANCED_SEARCH_IN_PROGRESS + CAPTION_TIU_NOTES);
                            if cbDocumentClassAdv.ItemIndex = -1 then
                              begin
                              MessageDlg(TIU_DOCUMENT_CLASS_MISSING, mtInformation, [mbOk], 0);
                              Exit;
                              end;
                            end;
      end;
      Application.ProcessMessages; //Update the status bar text

      //Set up the search parameters
      case thisSearchType of
        STANDARD_SEARCH:
          begin
          sortDirection := GetSortDirection(self.rgSortByStd);
          includeAddenda := frmSearchCriteria.cbIncludeAddendaStd.Checked;
          includeUntranscribed := frmSearchCriteria.cbIncludeUntranscribedStd.Checked;
          end;
        ADVANCED_SEARCH:
          begin
          sortDirection := GetSortDirection(self.rgSortByAdv);
          includeAddenda := frmSearchCriteria.cbIncludeAddendaAdv.Checked;
          includeUntranscribed := frmSearchCriteria.cbIncludeUntranscribedAdv.Checked;
          end;
      end;

  {======================================================================
  RPC [TIU DOCUMENTS BY CONTEXT] returns the following string '^' pieces:
  =======================================================================
        1 -  Document IEN
        2 -  Document Title
        3 -  FM date of document
        4 -  Patient Name
        5 -  DUZ;Author name
        6 -  Location
        7 -  Status
        8 -  ADM/VIS: date;FMDate
        9 -  Discharge Date;FMDate
        10 - Package variable pointer
        11 - Number of images
        12 - Subject
        13 - Has children
        14 - Parent document
        15 - Order children of ID Note by title rather than date (undocumented)
  ===============================================================}    

      if not self.SearchCancelled then
        begin
          case thisSearchType of
            STANDARD_SEARCH:
              begin
              includeAddenda := frmSearchCriteria.cbIncludeAddendaStd.Checked;
              includeUntranscribed := frmSearchCriteria.cbIncludeUntranscribedStd.Checked;

              Application.ProcessMessages;
              if not self.SearchCancelled then
                begin
                stUpdateContext(SEARCH_TOOL_CONTEXT);
                Delay(self.FSearchPriority);
                CallV('TIU DOCUMENTS BY CONTEXT', [self.TIUDocumentClass,
                                                   frmSearchCriteria.rgTIUNoteOptionsStd.ItemIndex + 1,
                                                   frmSearchCriteria.PatientIEN,
                                                   '12/30/1899',  //DateTimeToFMDateTime(strToDateTime(frmSearchCriteria.ordbStartDateTIUStd.Text)),
                                                   'TODAY',  //DateTimeToFMDateTime(strToDateTime(frmSearchCriteria.ordbEndDateTIUStd.Text)),
                                                   frmSearchCriteria.UserIEN,
                                                   frmSearchCriteria.seTIUMaxStd.Value,
                                                   sortDirection,
                                                   boolToStr(includeAddenda),
                                                   boolToStr(includeUntranscribed)]);
                stUpdateContext(origContext);
                end
              else
                Exit;
              end;
            ADVANCED_SEARCH:
              begin
              includeAddenda := frmSearchCriteria.cbIncludeAddendaAdv.Checked;
              includeUntranscribed := frmSearchCriteria.cbIncludeUntranscribedAdv.Checked;

                Application.ProcessMessages;
                if not self.SearchCancelled then
                  begin
                  stUpdateContext(SEARCH_TOOL_CONTEXT);
                  Delay(self.FSearchPriority);
                  
                  case frmSearchCriteria.rgTIUNoteOptionsAdv.ItemIndex of
                    0: filterOptionAdv := 1;
                    1: filterOptionAdv := 2;
                    2: filterOptionAdv := 3;
                    3: filterOptionAdv := 5;
                  end;

                  CallV('TIU DOCUMENTS BY CONTEXT', [self.TIUDocumentClass,
                                                     {frmSearchCriteria.rgTIUNoteOptionsAdv.ItemIndex + 1,}
                                                     filterOptionAdv,
                                                     frmSearchCriteria.PatientIEN,
                                                     ordbStartDateTIUAdv.FMDateTime,
                                                     ordbEndDateTIUAdv.FMDateTime,
                                                     frmSearchCriteria.UserIEN,
                                                     frmSearchCriteria.seTIUMaxAdv.Value,
                                                     sortDirection,
                                                     boolToStr(includeAddenda),
                                                     boolToStr(includeUntranscribed)]);
                  stUpdateContext(origContext);
                  end
                else
                  Exit;
              end;
          end; //case

          Application.ProcessMessages;

          if not self.SearchCancelled then
            begin
            //Load up a string list with the RPC results of the search.
            // We'll use this to populate the Tree.
            self.slSearchResults.Clear;
            for i := 0 to RPCBrokerV.Results.Count-1 do
              begin
              if not self.SearchCancelled then
                self.slSearchResults.Add(RPCBrokerV.Results[i]) //Results of CallV('TIU DOCUMENTS BY CONTEXT')
              else
                Break;
              end;

            vSearchTree.BeginUpdate;
            ///// Root Node for TIU Notes ////////////////
            nodeData.FCaption := CAPTION_TIU_NOTES; //'TIU Notes';
            Node := AddNodeToTree(vSearchTree, nil, nodeData); // <----- ROOT NODE
            self.TIUNotesRootNode := Node;
            //////////////////////////////////////////////

            for i := 0 to slSearchResults.Count-1 do
              begin
                case thisSearchType of
                  STANDARD_SEARCH:
                    begin
                    if (i > seTIUMaxStd.Value - 1) then Break; //Display UP TO the number of records in the 'max' box 20120509

                    if (not self.DeepSearch) then //Shallow search (Record Title's only)
                      LoadTIUNode(thisSearchType, self.edTIUSearchTermsStd, Node, nodeData, self.slSearchResults, i)
                    else
                      begin //Deep search - (Record body text)

                      //Clear the word list for Binary search
                      if meWholeWords.Checked then
                        begin
                        self.WordList.Clear;
                        self.WordList.Capacity := sizeOf(Cardinal);
                        end;

                      stUpdateContext(SEARCH_TOOL_CONTEXT);
                      Delay(self.FSearchPriority);
                      if not self.SearchCancelled then CallV('TIU GET RECORD TEXT', [Piece(self.slSearchResults[i],'^',1)]); //Param = TIU Document Number
                      stUpdateContext(origContext);

                      //Load our record string for SEQUENTIAL search
                      self.SingleLineBodyText := '';
                      if not meWholeWords.Checked then
                        for j := 0 to RPCBrokerV.Results.Count-1 do
                          if not meCaseSensitive.Checked then
                            self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                          else
                            self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                      //Load our word list for BINARY search
                      if meWholeWords.Checked then
                        begin
                        for j := 0 to RPCBrokerV.Results.Count-1 do
                          if not meCaseSensitive.Checked then
                            LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                          else
                            LoadWordList(RPCBrokerV.Results[j]);
                        self.WordList.Sort(@CompareWords);
                        end;

                        //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                        if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                          if SearchTermsFoundInRecordBodySequential(self.edTIUSearchTermsStd, self.SingleLineBodyText) then  //Original O(n) search
                            LoadTIUNode(thisSearchType, self.edTIUSearchTermsStd, Node, nodeData, self.slSearchResults, i);

                        if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                          if SearchTermsFoundInRecordBody(self.edTIUSearchTermsStd) <> -1 then
                            LoadTIUNode(thisSearchType, self.edTIUSearchTermsStd, Node, nodeData, self.slSearchResults, i);
                      end;
                      self.UpdateSearchTime();
                    end;

                  ADVANCED_SEARCH:
                    begin
                    if (i > seTIUMaxStd.Value - 1) then Break; //Display UP TO the number of records in the 'max' box 20120509

                    if (not self.DeepSearch) then //TITLE search (Record Title's only)
                      LoadTIUNode(thisSearchType, self.edTIUSearchTermsAdv, Node, nodeData, self.slSearchResults, i)
                    else
                      begin //DEEP search - (Record body text)

                      //Clear the word list for Binary search
                      if meWholeWords.Checked then
                        begin
                        self.WordList.Clear;
                        self.WordList.Capacity := sizeOf(Cardinal);
                        end;

                      stUpdateContext(SEARCH_TOOL_CONTEXT);
                      Delay(self.FSearchPriority);
                      if not self.SearchCancelled then CallV('TIU GET RECORD TEXT', [Piece(self.slSearchResults[i],'^',1)]); //Param = TIU Document Number
                      stUpdateContext(origContext);

                      //Load our record string for SEQUENTIAL search
                      self.SingleLineBodyText := '';
                      if not meWholeWords.Checked then
                        for j := 0 to RPCBrokerV.Results.Count-1 do
                          if not meCaseSensitive.Checked then
                            self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                          else
                            self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                      //Load our word list for BINARY search
                      if meWholeWords.Checked then
                        begin
                        for j := 0 to RPCBrokerV.Results.Count-1 do
                          if not meCaseSensitive.Checked then
                            LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                          else
                            LoadWordList(RPCBrokerV.Results[j]);
                        self.WordList.Sort(@CompareWords);
                        end;

                        //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                        if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                          if SearchTermsFoundInRecordBodySequential(self.edTIUSearchTermsAdv, self.SingleLineBodyText) then  //Original O(n) search
                            LoadTIUNode(thisSearchType, self.edTIUSearchTermsAdv, Node, nodeData, self.slSearchResults, i);

                        if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                          if SearchTermsFoundInRecordBody(self.edTIUSearchTermsAdv) <> -1 then
                            LoadTIUNode(thisSearchType, self.edTIUSearchTermsAdv, Node, nodeData, self.slSearchResults, i);
                      end;
                      self.UpdateSearchTime();
                    end;

                end; //case
              end; //for

            vSearchTree.EndUpdate; //Yer done
            end;
        end;
      end;

    self.UpdateSearchTime();
    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SearchTIUNotes()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.seConsultsMaxAdvChange(Sender: TObject);
begin
  seConsultsMaxStd.Value := seConsultsMaxAdv.Value;
end;

procedure TfrmSearchCriteria.seConsultsMaxStdChange(Sender: TObject);
begin
  seConsultsMaxAdv.Value := seConsultsMaxStd.Value;
end;

procedure TfrmSearchCriteria.meSelectAllClick(Sender: TObject);
begin
  reDetail.SelectAll();
end;

procedure TfrmSearchCriteria.seOrdersMaxAdvChange(Sender: TObject);
begin
  seOrdersMaxStd.Value := seOrdersMaxAdv.Value;
end;

procedure TfrmSearchCriteria.seOrdersMaxStdChange(Sender: TObject);
begin
  seOrdersMaxAdv.Value := seOrdersMaxStd.Value;
end;

procedure TfrmSearchCriteria.SearchProblemText(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
{
 Parameter thisSearchType:
 false = Standard Search
 true = Advanced Search
 SEE: constants STANDARD_SEARCH and ADVANCED_SEARCH
}
var
  i: integer;
  j: integer;
  Node: PVirtualNode;
  nodeData: TTreeData;
  //slSearchResults: TStrings;
  d: integer; //debug
  debugStr: string; //debug
begin
  try
    self.UpdateSearchTime();
    Application.ProcessMessages;
    UpdateStatusBarMessage(sbStatusBar.Panels[0].Text + CAPTION_PROBLEM_TEXT);

    if not self.SearchCancelled then
      begin
      case thisSearchType of
        STANDARD_SEARCH:  if edProblemTextSearchTermsStd.Text = '' then Exit
                          else UpdateStatusBarMessage(STANDARD_SEARCH_IN_PROGRESS + CAPTION_PROBLEM_TEXT);
        ADVANCED_SEARCH:  if edProblemTextSearchTermsAdv.Text = '' then Exit
                          else UpdateStatusBarMessage(ADVANCED_SEARCH_IN_PROGRESS + CAPTION_PROBLEM_TEXT);
      end;

      Application.ProcessMessages; //Update status bar text

      case thisSearchType of
        STANDARD_SEARCH:
          begin
          if not self.SearchCancelled then
            begin
            stUpdateContext(SEARCH_TOOL_CONTEXT);
            Delay(self.FSearchPriority);
            CallV('ORQQPL PROBLEM LIST', [PatientIEN]);
            stUpdateContext(origContext);
            end
          else
            Exit;
          end;
        ADVANCED_SEARCH:
          begin
          if not self.SearchCancelled then
            begin
            stUpdateContext(SEARCH_TOOL_CONTEXT);
            Delay(self.FSearchPriority);
            CallV('ORQQPL PROBLEM LIST', [self.PatientIEN]);  { TODO : ORQQPL PROBLEM LIST does not have Date parameters (?) }
            stUpdateContext(origContext);
            end
          else
            Exit;
          end;
      end;

      Application.ProcessMessages;
      if not self.SearchCancelled then
        begin
        //Load up a string list with the RPC results of the search.
        // We'll use this to populate the Tree.
        slSearchResults := TStringList.Create; //kw 20120313 - commented
        //self.slSearchResults.Clear; //kw 20120313 - added

        for i := 0 to RPCBrokerV.Results.Count-1 do
          self.slSearchResults.Add(RPCBrokerV.Results[i]);
        //If there are no Problems for this patient, RPCBrokerV.Results[0] will = 0
        // and RPCBrokerV.Results[1] will = ' No data available.'
        // Below, if we try to call ORQQPL DETAIL when there is no Problem data available,
        // we will get an M Server error.  So, we handle the situation here, by jumping
        // out of this routine altogether if the current patient has no data in their Problem List.
        // Otherwise, do the rest of this routine, as usual.
        if RPCBrokerV.Results[0] = '0' then
          Exit;

        vSearchTree.BeginUpdate;
        ///// Root Node for Problem Text ////////////////
        nodeData.FCaption := CAPTION_PROBLEM_TEXT; //'Problem Text';
        Node := AddNodeToTree(vSearchTree, nil, nodeData); // <----- ROOT NODE
        self.ProblemTextRootNode := Node;
        //////////////////////////////////////////////

        //We want to make sure that the number of records displayed, is NOT less than
        //the number specified in the 'Max Return Instances' spinEdit for this search
        //area (avoiding a ListIndex Error). If the number of returned records IS less
        //than the number specified in the 'Max Return Instances' spinEdit for this search
        //area, then we set the value of the spinEdit to the number of returned records,
        //in which case we display all the returned records.
        //if RPCBrokerV.Results.Count < strToInt(floatToStr(seProblemTextMaxStd.Value)) then
          //seProblemTextMaxStd.Value := RPCBrokerV.Results.Count-1;

        for i := 0 to self.slSearchResults.Count-1 do //OLD way - Displays ALL returned records
        //Display the number of records designated in the spin edit
        //for i := 0 to strToInt(floatToStr(seProblemTextMaxStd.Value)) do
          begin
            case thisSearchType of
              STANDARD_SEARCH:
                begin
                if (i > seProblemTextMaxStd.Value) then Break; //Display UP TO the number of records in the 'max' box 20120509

                if (not self.DeepSearch) then //Shallow search (Record Title's only)
                  LoadProblemTextNode(thisSearchType, self.edProblemTextSearchTermsStd, Node, nodeData, slSearchResults, i)
                else
                  begin
                      begin //Deep search - (Record body text)
                      //Clear the word list for Binary search
                      if meWholeWords.Checked then
                        begin
                        self.WordList.Clear;
                        self.WordList.Capacity := sizeOf(Cardinal);
                        end;

                      stUpdateContext(SEARCH_TOOL_CONTEXT);
                      Delay(self.FSearchPriority);
                      if not self.SearchCancelled then CallV('ORQQPL DETAIL', [self.PatientIEN, Piece(self.slSearchResults[i],'^',1),'']);
                      stUpdateContext(origContext);

                      //Load our record string for SEQUENTIAL search
                      self.SingleLineBodyText := '';
                      if not meWholeWords.Checked then
                        for j := 0 to RPCBrokerV.Results.Count-1 do
                          if not meCaseSensitive.Checked then
                            self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                          else
                            self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                      //Load our word list for BINARY search
                      if meWholeWords.Checked then
                        begin
                        for j := 0 to RPCBrokerV.Results.Count-1 do
                          if not meCaseSensitive.Checked then
                            LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                          else
                            LoadWordList(RPCBrokerV.Results[j]);
                        self.WordList.Sort(@CompareWords);
                        end;

                        //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                        if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                          if SearchTermsFoundInRecordBodySequential(self.edProblemTextSearchTermsStd, self.SingleLineBodyText) then  //Original O(n) search
                            LoadProblemTextNode(thisSearchType, self.edProblemTextSearchTermsStd, Node, nodeData, self.slSearchResults, i);

                        if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                          if SearchTermsFoundInRecordBody(self.edProblemTextSearchTermsStd) <> -1 then
                            LoadProblemTextNode(thisSearchType, self.edProblemTextSearchTermsStd, Node, nodeData, self.slSearchResults, i);
                      end;
                  end;
                  self.UpdateSearchTime();
                end;
              ADVANCED_SEARCH:
                begin
                if (i > seProblemTextMaxAdv.Value) then Break; //Display UP TO the number of records in the 'max' box 20120509

                if (not self.DeepSearch) then //TITLE search (Record Title's only)
                  LoadProblemTextNode(thisSearchType, self.edProblemTextSearchTermsAdv, Node, nodeData, slSearchResults, i)
                else
                  begin
                  //Clear the word list for Binary search
                  if meWholeWords.Checked then
                    begin
                    self.WordList.Clear;
                    self.WordList.Capacity := sizeOf(Cardinal);
                    end;

                  stUpdateContext(SEARCH_TOOL_CONTEXT);
                  Delay(self.FSearchPriority);
                  if not self.SearchCancelled then CallV('ORQQPL DETAIL', [self.PatientIEN, Piece(self.slSearchResults[i],'^',1)]);
                  stUpdateContext(origContext);

                  //Load our record string for SEQUENTIAL search
                  self.SingleLineBodyText := '';
                  if not meWholeWords.Checked then
                    for j := 0 to RPCBrokerV.Results.Count-1 do
                      if not meCaseSensitive.Checked then
                        self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                      else
                        self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                  //Load our word list for BINARY search
                  if meWholeWords.Checked then
                    begin
                    for j := 0 to RPCBrokerV.Results.Count-1 do
                      if not meCaseSensitive.Checked then
                        LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                      else
                        LoadWordList(RPCBrokerV.Results[j]);
                    self.WordList.Sort(@CompareWords);
                    end;

                    //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                    if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                      if SearchTermsFoundInRecordBodySequential(self.edProblemTextSearchTermsAdv, self.SingleLineBodyText) then  //Original O(n) search
                        LoadProblemTextNode(thisSearchType, self.edProblemTextSearchTermsAdv, Node, nodeData, self.slSearchResults, i);

                    if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                      if SearchTermsFoundInRecordBody(self.edProblemTextSearchTermsAdv) <> -1 then
                        LoadProblemTextNode(thisSearchType, self.edProblemTextSearchTermsAdv, Node, nodeData, self.slSearchResults, i);
                  end;
                end;
            end;
          end;
          self.UpdateSearchTime();
          vSearchTree.EndUpdate; //Yer done
        end;
      end;

    self.UpdateSearchTime();
    Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SearchProblemText()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end; //Search ProblemText

procedure TfrmSearchCriteria.SearchConsults(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
var
  i: integer;
  j: integer;
  Node: PVirtualNode;
  nodeData: TTreeData;
begin
  try
    self.UpdateSearchTime();
    Application.ProcessMessages;
    UpdateStatusBarMessage(sbStatusBar.Panels[0].Text + CAPTION_CONSULTS);
    Application.ProcessMessages;

    case thisSearchType of
      STANDARD_SEARCH:  if edConsultsSearchTermsStd.Text = '' then Exit
                        else UpdateStatusBarMessage(STANDARD_SEARCH_IN_PROGRESS + CAPTION_CONSULTS);
      ADVANCED_SEARCH:  if edConsultsSearchTermsAdv.Text = '' then Exit
                        else UpdateStatusBarMessage(ADVANCED_SEARCH_IN_PROGRESS + CAPTION_CONSULTS);
    end;

    Application.ProcessMessages; //Update status bar text

    case thisSearchType of
      STANDARD_SEARCH:
        begin
        if not self.SearchCancelled then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          Delay(self.FSearchPriority);
          CallV('ORQQCN LIST', [PatientIEN]); //, ordbStartDateConsultsStd.FMDateTime, ordbEndDateConsultsStd.FMDateTime]);
          stUpdateContext(origContext);
          end
        else
          Exit;
        end;
      ADVANCED_SEARCH:
        begin
        if not self.SearchCancelled then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          Delay(self.FSearchPriority);
          CallV('ORQQCN LIST', [PatientIEN, ordbStartDateConsultsAdv.FMDateTime, ordbEndDateConsultsAdv.FMDateTime]);
          stUpdateContext(origContext);
          end
        else
          Exit;
        end;        
    end;

    Application.ProcessMessages;
    if not self.SearchCancelled then
      begin
      //Load up a string list with the RPC results of the search.
      // We'll use this to populate the Tree.
      self.slSearchResults := TStringList.Create; //kw 20120313 - commented - Created in FormShow
      //self.slSearchResults.Clear; //kw 20120313 - added

      for i := 0 to RPCBrokerV.Results.Count-1 do
        self.slSearchResults.Add(RPCBrokerV.Results[i]);

      vSearchTree.BeginUpdate;
      ///// Root Node for Consults ////////////////
      nodeData.FCaption := CAPTION_CONSULTS; //'Consults';
      //Node := AddProblemTextNodeToTree(vSearchTree, nil, nodeData);
      Node := AddNodeToTree(vSearchTree, nil, nodeData); // <----- ROOT NODE
      self.ConsultsRootNode := Node;
      //////////////////////////////////////////////

        //We want to make sure that the number of records displayed, is NOT less than
        //the number specified in the 'Max Return Instances' spinEdit for this search
        //area (avoiding a ListIndex Error). If the number of returned records IS less
        //than the number specified in the 'Max Return Instances' spinEdit for this search
        //area, then we set the value of the spinEdit to the number of returned records,
        //in which case we display all the returned records.
        //if RPCBrokerV.Results.Count < strToInt(floatToStr(seConsultsMaxStd.Value)) then
          //seConsultsMaxStd.Value := RPCBrokerV.Results.Count-1;

        for i := 0 to self.slSearchResults.Count-1 do //OLD way - Displays ALL returned records
        //Display the number of records designated in the spin edit
        //for i := 0 to strToInt(floatToStr(seConsultsMaxStd.Value-1)) do
        begin
          case thisSearchType of
            STANDARD_SEARCH:
              begin
              if (i > seConsultsMaxStd.Value - 1) then Break; //Display UP TO the number of records in the 'max' box 20120509

              if (not self.DeepSearch) then //Shallow search (Record Title's only)
                LoadConsultsNode(thisSearchType, self.edConsultsSearchTermsStd, Node, nodeData, self.slSearchResults, i)
              else
                begin //Deep search - (Record body text)
                //Clear the word list for Binary search
                if meWholeWords.Checked then
                  begin
                  self.WordList.Clear;
                  self.WordList.Capacity := sizeOf(Cardinal);
                  end;

                stUpdateContext(SEARCH_TOOL_CONTEXT);
                Delay(self.FSearchPriority);
                if not self.SearchCancelled then CallV('ORQQCN DETAIL', [Piece(self.slSearchResults.Strings[i],'^',1)]);
                stUpdateContext(origContext);

                //Load our record string for SEQUENTIAL search
                self.SingleLineBodyText := '';
                if not meWholeWords.Checked then
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                    else
                      self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                //Load our word list for BINARY search
                if meWholeWords.Checked then
                  begin
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                    else
                      LoadWordList(RPCBrokerV.Results[j]);
                  self.WordList.Sort(@CompareWords);
                  end;

                  //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                  if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                    if SearchTermsFoundInRecordBodySequential(self.edConsultsSearchTermsStd, self.SingleLineBodyText) then  //Original O(n) search
                      LoadConsultsNode(thisSearchType, self.edConsultsSearchTermsStd, Node, nodeData, self.slSearchResults, i);

                  if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                    if SearchTermsFoundInRecordBody(self.edConsultsSearchTermsStd) <> -1 then
                      LoadConsultsNode(thisSearchType, self.edConsultsSearchTermsStd, Node, nodeData, self.slSearchResults, i);
                end;
                self.UpdateSearchTime();
              end;
            ADVANCED_SEARCH:
              begin
              if (i > seConsultsMaxAdv.Value - 1) then Break; //Display UP TO the number of records in the 'max' box 20120509

              if (not self.DeepSearch) then //TITLE search (Record Title's only)
                LoadConsultsNode(thisSearchType, self.edConsultsSearchTermsAdv, Node, nodeData, self.slSearchResults, i)
              else
                begin
                //Clear the word list for Binary search
                if meWholeWords.Checked then
                  begin
                  self.WordList.Clear;
                  self.WordList.Capacity := sizeOf(Cardinal);
                  end;

                stUpdateContext(SEARCH_TOOL_CONTEXT);
                Delay(self.FSearchPriority);
                if not self.SearchCancelled then CallV('ORQQCN DETAIL', [Piece(self.slSearchResults.Strings[i],'^',1)]);
                stUpdateContext(origContext);

                //Load our record string for SEQUENTIAL search
                self.SingleLineBodyText := '';
                
                if (not meWholeWords.Checked) then
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                    else
                      self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                //Load our word list for BINARY search
                if (meWholeWords.Checked) then
                  begin
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                    else
                      LoadWordList(RPCBrokerV.Results[j]);
                  self.WordList.Sort(@CompareWords);
                  end;

                  //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                  if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                    if SearchTermsFoundInRecordBodySequential(self.edConsultsSearchTermsAdv, self.SingleLineBodyText) then  //Original O(n) search
                      LoadConsultsNode(thisSearchType, self.edConsultsSearchTermsAdv, Node, nodeData, self.slSearchResults, i);

                  if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                    if SearchTermsFoundInRecordBody(self.edConsultsSearchTermsAdv) <> -1 then
                      LoadConsultsNode(thisSearchType, self.edConsultsSearchTermsAdv, Node, nodeData, self.slSearchResults, i);

                self.UpdateSearchTime();
                end;
              end;
          end;
        end;
        vSearchTree.EndUpdate; //Yer done
      end;

    self.UpdateSearchTime();
    Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SearchConsults()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end; //SearchConsults

procedure TfrmSearchCriteria.SearchOrders(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
var
  i: integer;
  j: integer;
  Node: PVirtualNode;
  nodeData: TTreeData;
begin
  try
    self.UpdateSearchTime();
    Application.ProcessMessages;
    UpdateStatusBarMessage(sbStatusBar.Panels[0].Text + CAPTION_ORDERS);
    Application.ProcessMessages;

    case thisSearchType of
      STANDARD_SEARCH:  if edOrdersSearchTermsStd.Text = '' then Exit
                        else UpdateStatusBarMessage(STANDARD_SEARCH_IN_PROGRESS + CAPTION_ORDERS);
      ADVANCED_SEARCH:  if edOrdersSearchTermsAdv.Text = '' then Exit
                        else UpdateStatusBarMessage(ADVANCED_SEARCH_IN_PROGRESS + CAPTION_ORDERS);
    end;

    Application.ProcessMessages; //Update status bar text

    case thisSearchType of
      STANDARD_SEARCH:
        begin
        if not self.SearchCancelled then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          Delay(self.FSearchPriority);
          CallV('ORQOR LIST', [PatientIEN,'',self.OrderStatus,1000101,'T',0,0]);
          stUpdateContext(origContext);
          end
        else
          Exit;
        end;
      ADVANCED_SEARCH:
        begin
        if not self.SearchCancelled then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          Delay(self.FSearchPriority);
          CallV('ORQOR LIST', [PatientIEN,'',self.OrderStatus,ordbStartDateOrdersAdv.FMDateTime,ordbEndDateOrdersAdv.FMDateTime,0,0]);
          stUpdateContext(origContext);
          end
        else
          Exit;
        end;
    end;

    Application.ProcessMessages;
    if not self.SearchCancelled then
      begin
      //Load up a string list with the RPC results of the search.
      // We'll use this to populate the Tree.
      self.slSearchResults := TStringList.Create; //kw 20120313 - commented - Created in FormShow

      for i := 0 to RPCBrokerV.Results.Count-1 do
        self.slSearchResults.Add(RPCBrokerV.Results[i]);


      vSearchTree.BeginUpdate;
      ///// Root Node for Consults ////////////////
      nodeData.FCaption := CAPTION_ORDERS; //'Orders';
      Node := AddNodeToTree(vSearchTree, nil, nodeData); // <----- ROOT NODE
      self.OrdersRootNode := Node;
      //////////////////////////////////////////////


        //We want to make sure that the number of records displayed, is NOT less than
        //the number specified in the 'Max Return Instances' spinEdit for this search
        //area (avoiding a ListIndex Error). If the number of returned records IS less
        //than the number specified in the 'Max Return Instances' spinEdit for this search
        //area, then we set the value of the spinEdit to the number of returned records,
        //in which case we display all the returned records.
        //if RPCBrokerV.Results.Count < strToInt(floatToStr(seOrdersMaxStd.Value)) then
          //seOrdersMaxStd.Value := RPCBrokerV.Results.Count-1; //ORIG

        for i := 0 to slSearchResults.Count-1 do
        begin
          case thisSearchType of
            STANDARD_SEARCH:
              begin
              if (i > seOrdersMaxStd.Value - 1) then Break; //Display UP TO the number of records in the 'max' box 20120509

              if (not self.DeepSearch) then //Shallow search (Record Title's only)
                LoadOrdersNode(thisSearchType, self.edOrdersSearchTermsStd, Node, nodeData, self.slSearchResults, i)
              else
                begin //Deep search - (Record body text)
                //Clear the word list for Binary search
                if meWholeWords.Checked then
                  begin
                  self.WordList.Clear;
                  self.WordList.Capacity := sizeOf(Cardinal);
                  end;

                stUpdateContext(SEARCH_TOOL_CONTEXT);
                Delay(self.FSearchPriority);
                if not self.SearchCancelled then CallV('ORQOR DETAIL', [Piece(self.slSearchResults.Strings[i],';',1), PatientIEN]);
                stUpdateContext(origContext);

                //Load our record string for SEQUENTIAL search
                self.SingleLineBodyText := '';
                if not meWholeWords.Checked then
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                    else
                      self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                //Load our word list for BINARY search
                if meWholeWords.Checked then
                  begin
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                    else
                      LoadWordList(RPCBrokerV.Results[j]);
                  self.WordList.Sort(@CompareWords);
                  end;

                  //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                  if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                    if SearchTermsFoundInRecordBodySequential(self.edOrdersSearchTermsStd, self.SingleLineBodyText) then  //Original O(n) search
                      LoadOrdersNode(thisSearchType, self.edOrdersSearchTermsStd, Node, nodeData, self.slSearchResults, i);

                  if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                    if SearchTermsFoundInRecordBody(self.edOrdersSearchTermsStd) <> -1 then
                      LoadOrdersNode(thisSearchType, self.edOrdersSearchTermsStd, Node, nodeData, self.slSearchResults, i);
                end;
                self.UpdateSearchTime();
              end;
            ADVANCED_SEARCH:
              begin
              if (i > seOrdersMaxAdv.Value - 1) then Break; //Display UP TO the number of records in the 'max' box 20120509

              if (not self.DeepSearch) then //TITLE search (Record Title's only)
                LoadOrdersNode(thisSearchType, self.edOrdersSearchTermsAdv, Node, nodeData, self.slSearchResults, i)
              else
                begin
                //Clear the word list for Binary search
                if meWholeWords.Checked then
                  begin
                  self.WordList.Clear;
                  self.WordList.Capacity := sizeOf(Cardinal);
                  end;

                stUpdateContext(SEARCH_TOOL_CONTEXT);
                Delay(self.FSearchPriority);
                //if not self.SearchCancelled then CallV('ORQQCN MED RESULTS', [Piece(self.slSearchResults.Strings[i],'^',1)]);
                if not self.SearchCancelled then CallV('ORQOR DETAIL', [Piece(self.slSearchResults.Strings[i],';',1), PatientIEN]);
                stUpdateContext(origContext);

                //Load our record string for SEQUENTIAL search
                self.SingleLineBodyText := '';
                if not meWholeWords.Checked then
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + RPCBroker.Results[j])
                    else
                      self.SingleLineBodyText := self.SingleLineBodyText + RPCBroker.Results[j];

                //Load our word list for BINARY search
                if meWholeWords.Checked then
                  begin
                  for j := 0 to RPCBrokerV.Results.Count-1 do
                    if not meCaseSensitive.Checked then
                      LoadWordList(UpperCase(RPCBrokerV.Results[j]))
                    else
                      LoadWordList(RPCBrokerV.Results[j]);
                  self.WordList.Sort(@CompareWords);
                  end;

                  //Add this record to the tree ONLY if we find at least one search term in the record body that was loaded above, else skip it
                  if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                    if SearchTermsFoundInRecordBodySequential(self.edOrdersSearchTermsAdv, self.SingleLineBodyText) then  //Original O(n) search
                      LoadOrdersNode(thisSearchType, self.edOrdersSearchTermsAdv, Node, nodeData, self.slSearchResults, i);

                  if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                    if SearchTermsFoundInRecordBody(self.edOrdersSearchTermsAdv) <> -1 then
                      LoadOrdersNode(thisSearchType, self.edOrdersSearchTermsAdv, Node, nodeData, self.slSearchResults, i);
                end;
                self.UpdateSearchTime();
              end;
          end;
        end;
        vSearchTree.EndUpdate; //Yer done
      end;

    self.UpdateSearchTime();
    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SearchOrders()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end; //SearchOrders

function TfrmSearchCriteria.IsMultipartReport() : boolean;
begin
  result := false;
  
end;

function TfrmSearchCriteria.ConstructReportIDString(thisReportIDString: string) : string;
{//Example ReportID:
//     1          2             3          4           5       6   7 8 9         10         11   12   16
// OR_RXOP^All Outpatient^T-7;T;10;6^RXOP;ORDV06;49^HSQUERY^ORDV01^1^V^0^ORWRP REPORT TEXT^1079^9:3^^^^1^
begin

  //result := Piece(thisReportIDString,'^',1) + ':' + Piece(thisReportIDString,'^',2) + '~' + Piece(thisReportIDString,'^',4);
  result := Piece(thisReportIDString,'^',1) +':' +
            Piece(thisReportIDString,'^',2) + '~' +
            Piece(thisReportIDString,'^',3) +
            Piece(thisReportIDString,'^',4);
}
var
  i,j: integer;
  ListItem: TListItem;
  aHeading, aReportType, aRPC, aQualifier, aStartTime, aStopTime, aMax, aRptCode, aRemote, aCategory, aSortOrder, aDaysBack, x: string;
  aIFN: integer;
  aID, aHSTag, aRadParam, aColChange, aDirect, aHDR, aFHIE, aFHIEONLY, aQualifierID: string;
  CurrentParentNode, CurrentNode: TTreeNode;
begin
    inherited;
  try
    result := ''; //kw - init

    aID         := UpperCase(Piece(thisReportIDString, U, 1)) + ':' + UpperCase(Piece(thisReportIDString, U, 2));
    aHeading    := Piece(thisReportIDString, U, 2);
    aQualifier  := Piece(thisReportIDString, U, 3);
    aRemote     := Piece(thisReportIDString, U, 7);
    aReportType := Piece(thisReportIDString, U, 8);
    aCategory   := Piece(thisReportIDString, U, 9);
    aRPC        := UpperCase(Piece(thisReportIDString, U, 10));
    aIFN        := StrToIntDef(Piece(thisReportIDString, U, 11),0);
    aHSTag      := UpperCase(Piece(thisReportIDString, U, 4));
    aSortOrder  := Piece(thisReportIDString, U, 12);
    aDaysBack   := Piece(thisReportIDString, U, 13);
    aDirect     := Piece(thisReportIDString, U, 14);
    aHDR        := Piece(thisReportIDString, U, 15);
    aFHIE       := Piece(thisReportIDString, U, 16);
    aFHIEONLY   := Piece(thisReportIDString, U, 17);


    aStartTime  :=  Piece(aQualifier,';',1);
    aStopTime   :=  Piece(aQualifier,';',2);
    aMax        :=  Piece(aQualifier,';',3);
    aRptCode    :=  Piece(aQualifier,';',4);
    aQualifierID:= '';

        //kw - create the data class
        currentNode := TTreeNode.Create(frmReportSelect.tvReports.Items);
        currentNode.Data := TNodeData.Create;
        //set the nodes data value - in this case the reportID string from ExpandColumns
        TNodeData(currentNode.Data).sText := thisReportIDString;

    if (aReportType <> 'M') and (aRPC = '') and (CharAt(aID,1) = 'H') then
      begin
        aReportType :=  'R';
        aRptCode    :=  LowerCase(CharAt(aID,1)) + Copy(aID, 2, Length(aID));
        aID         :=  '1';
        aRPC        :=  'ORWRP REPORT TEXT';
        aHSTag      :=  '';
      end;
    if aReportType = '' then aReportType := 'R';
    uReportRPC := aRPC;
    uRptID := aID;
    uReportID := aID;
    uDirect := aDirect;
    uReportType := aReportType;
    uQualifier := aQualifier;
    uSortOrder := aSortOrder;
    uRemoteType := aRemote + '^' + aReportType + '^' + IntToStr(aIFN) + '^' + aHeading + '^' + aRptCode + '^' + aDaysBack + '^' + aHDR + '^' + aFHIE + '^' + aFHIEONLY;

    uHState := aHSTag;

    if (aRemote = '1') or (aRemote = '2') then
      begin
      if not(uReportType = 'V') then

      end;

    if uReportType = 'H' then
      begin

      end
    else
      if uReportType = 'V' then
        begin

        end
      else
        begin

        end;
    uLocalReportData.Clear;
    //RowObjects.Clear;
    uRemoteReportData.Clear;

    if aReportType = 'G' then
      //Graph(aIFN)
    else
    if aReportType = 'M' then
      begin

      end
    else
      begin
       uQualifierType := StrToIntDef(aRptCode,0);
        case uQualifierType of
          QT_OTHER:
            begin      //      = 0
              //memText.Lines.Clear;
              If copy(aRptCode,1,2) = 'h0' then  //HS Adhoc
                begin

                end
              else
                begin

                end;
            end;
          QT_HSTYPE:
            begin      //      = 1

            end;
          QT_DATERANGE:
            begin      //      = 2

            end;
          QT_IMAGING:
            begin      //      = 3

              uQualifier := StringReplace(aRadParam, '^', ';', [rfReplaceAll]);

              if uLocalReportData.Count > 0 then x := #13#10 + 'Select an imaging exam...'
                else x := #13#10 + 'No imaging reports found...';

              uReportInstruction := PChar(x);

            end;
          QT_NUTR:
            begin      //      = 4

              ListNutrAssessments(uLocalReportData);

              if uLocalReportData.Count > 0 then x := #13#10 + 'Select an assessment date...'
                else x := #13#10 + 'No nutritional assessments found...';

              uReportInstruction := PChar(x);

            end;
          QT_HSCOMPONENT:
            begin      //      = 5
              uReportInstruction := #13#10 + 'Retrieving data...';

              if (length(piece(aHSTag,';',2)) > 0) then
                begin
                  if aCategory <> '0' then
                    begin

                      if aQualifierID = '' then
                        begin
                          //if aHDR = '1' then
                          //else

                        end
                      else
                        begin
                          //if aHDR = '1' then
                          //else

                        end;

                    end
                  else
                    begin
                      if not (aRemote = '2' ) then
                        begin
                        end;
                      if not(piece(uRemoteType, '^', 9) = '1') then
                        begin
                          result := LoadReportText(uLocalReportData, aID, aQualifier, aRPC, uHState);
                        end;
                    end;
                end
              else
                begin
                  if (aRemote = '1') or (aRemote = '2') then

                  if not(piece(uRemoteType, '^', 9) = '1') then // and (uLocalReportData.Count > 0) )then   //kw <-------------------------
                    result := LoadReportText(uLocalReportData, aID, aQualifier, aRPC, uHState);
                  if uLocalReportData.Count < 1 then
                    uReportInstruction := '<No Report Available>'
                  else
                    begin

                    end;     

                  if aCategory <> '0' then
                    begin

                    end
                  else
                    begin
                      if uLocalReportData.Count < 1 then
                        begin
                          uReportInstruction := '<No Report Available>';
                        end
                      else
                        begin

                        end;
                    end;
                end;
              StatusText('');
            end;
          QT_HSWPCOMPONENT:
            begin      //      = 6

              uReportInstruction := #13#10 + 'Retrieving data...';

              if (length(piece(aHSTag,';',2)) > 0) then
                begin
                  if aCategory <> '0' then
                    begin

                      if aQualifierID = '' then
                        begin
                          //if aHDR = '1' then
                          //else

                        end
                      else
                        begin

                          //if aHDR = '1' then
                          //else

                        end;

                    end
                  else
                    begin

                      if not (aRemote = '2' ) and (not(piece(uRemoteType, '^', 9) = '1')) then
                        begin
                          result := LoadReportText(uLocalReportData, aID, aQualifier, aRPC, uHState);
                        end;

                    end;
                end
              else
                begin
                  if not(piece(uRemoteType, '^', 9) = '1') then
                    result := LoadReportText(uLocalReportData, aID, aQualifier, aRPC, uHState);
                  if uLocalReportData.Count < 1 then
                    uReportInstruction := '<No Report Available>'
                  else
                    begin

                    end;

                  if aCategory <> '0' then
                    begin

                    end
                  else
                    begin
                    end;
                end;
              StatusText('');
            end;
          QT_PROCEDURES:
            begin      //      = 19
              ListProcedures(uLocalReportData);

              if uLocalReportData.Count > 0
                then x := #13#10 + 'Select a procedure...'
                else x := #13#10 + 'No procedures found...';
              uReportInstruction := PChar(x);
            end;
          QT_SURGERY:
            begin      //      = 28
              ListSurgeryReports(uLocalReportData);

              if uLocalReportData.Count > 0
                then x := #13#10 + 'Select a surgery case...'
                else x := #13#10 + 'No surgery cases found...';
              uReportInstruction := PChar(x);

            end;
          else
            begin      //      = ?
              uQualifierType := QT_OTHER;

              uReportInstruction := #13#10 + 'Retrieving data...';
              //TabControl1.OnChange(nil);
              result := LoadReportText(uLocalReportData, aID, aRptCode, aRPC, uHState);
              if not(piece(uRemoteType, '^', 9) = '1') then
                result := LoadReportText(uLocalReportData, aID, '', aRPC, uHState);
              if uLocalReportData.Count < 1 then
                uReportInstruction := '<No Report Available>'
              else
                begin

                end;

              StatusText('');
            end;

        end;
      end;

    //kw
    //if ((aReportType <> 'R') and (not ExistsInReportList(rReports.reportID))) then
      //lbSelectedReports.Items.Add(rReports.reportID);

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.ConstructReportIDString()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;

function TfrmSearchCriteria.ReportIsListviewType(thisIFN: string) : boolean;
begin
  try
    //Get list of Column headers for a ListView type report from file 101.24
    stUpdateContext(SEARCH_TOOL_CONTEXT);
    Delay(self.FSearchPriority);
    CallV('ORWRP COLUMN HEADERS',[thisIFN]);   //,[AReportType]);
    stUpdateContext(origContext);
    if RPCBrokerV.Results.Count > 0 then
      result := true
    else
      result := false;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.ReportIsListviewType()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.ReformatReportText(var thisListviewReportText: TStringList; thisBrokerResults: TStrings; thisIFN: string) : TStringList;
//Note: 'thisListviewReportText' created by the caller
var
  slReformatted: TStringList;
  i: integer;
  slColumnHeaders: TStringList;
  currentLineNum: integer;
  nextLineNum: integer;
  slthisReportText: TStringList;
  debugStr: string;
begin
  try
    //Save off the incoming broker results, cuz you'll need them below
    //If you don't do this, then the results from ORWRP COLUMN HEADERS will overwrite the incoming broker results
    //Then we'll use slthisReportText instead of thisBrokerResults
    slthisReportText := TStringList.Create;
    if thisBrokerResults.Count > 0 then
      begin
      for i := 0 to thisBrokerResults.Count - 1 do
        slthisReportText.Add(thisBrokerResults[i]);
      end;

    //Grab any column headings for this report
    if thisBrokerResults.Count > 0 then
      begin
      slColumnHeaders := TStringList.Create;
      stUpdateContext(SEARCH_TOOL_CONTEXT);
      Delay(self.FSearchPriority);
      if not self.SearchCancelled then CallV('ORWRP COLUMN HEADERS', [thisIFN]);
      stUpdateContext(origContext);
      if ((not self.SearchCancelled) and (RPCBrokerV.Results.Count > 0)) then
        for i := 0 to RPCBrokerV.Results.Count - 1 do
          slColumnHeaders.Add(Piece(RPCBrokerV.Results[i],U,1));
      end;

    currentLineNum := 0;
    nextLineNum := 0;
    if ((not self.SearchCancelled) and (slthisReportText.Count > 0)) then
      begin
      currentLineNum := strToInt(Piece(slthisReportText[0],U,1));
      nextLineNum := strToInt(Piece(slthisReportText[1],U,1));
      thisListviewReportText.Add(slColumnHeaders[0] + ': ' + Piece(slthisReportText[0],U,2)); //grab the first line

      //Now spin thru the rest of the report lines
      for i := 1 to slthisReportText.Count - 1 do
        begin
        if i = (slthisReportText.Count - 1) then
          Break;

        Delay(self.FSearchPriority);

        currentLineNum := strToInt(Piece(slthisReportText[i],U,1));
        if (i+1) <= slthisReportText.Count then
          nextLineNum := strToInt(Piece(slthisReportText[i+1],U,1));

        if (i+1) <= slthisReportText.Count then
          begin
          thisListviewReportText.Add(slColumnHeaders[currentLineNum] + ': ' + Piece(slthisReportText[i],U,2))
          end;

        if ((nextLineNum < currentLineNum) or (i = slthisReportText.Count - 1)) then
            thisListviewReportText.Add('--------------------------------------------');

        end;

      result := thisListviewReportText;
      end
    else
      begin
      thisListviewReportText.Clear;
      result := thisListviewReportText;
      end;

    if slColumnHeaders <> nil then
      slColumnHeaders.Free;

    if slthisReportText <> nil then
      slthisReportText.Free;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.ReformatReportText()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;

procedure TfrmSearchCriteria.SearchReports(frmSearchCriteria: TfrmSearchCriteria; thisSearchType: boolean = false);
var
  i: integer;
  j: integer;
  k: integer;
  Node: PVirtualNode;
  nodeData: TTreeData;
  //slSearchResults: TStrings; //changed to field of TfrmSearchCriteria
  debugStr: string; //debug
  reportIDString: string;
  thisIFN: string;
  isListViewType: boolean;
  slListviewReportText: TStringList;
begin
  try
    Application.ProcessMessages;
    UpdateStatusBarMessage(sbStatusBar.Panels[0].Text + CAPTION_REPORTS);
    Application.ProcessMessages;

    case thisSearchType of
      STANDARD_SEARCH:  if edReportsSearchTermsStd.Text = '' then Exit
                        else UpdateStatusBarMessage(STANDARD_SEARCH_IN_PROGRESS + CAPTION_REPORTS);
      ADVANCED_SEARCH:  if edReportsSearchTermsAdv.Text = '' then Exit
                        else UpdateStatusBarMessage(ADVANCED_SEARCH_IN_PROGRESS + CAPTION_REPORTS);
    end;

    Application.ProcessMessages; //Update status bar text

    if not self.SearchCancelled then
      begin
      vSearchTree.BeginUpdate;
      ///// Root Node for Reports ////////////////
      nodeData.FCaption := CAPTION_REPORTS; //'Reports';
      Node := AddNodeToTree(vSearchTree, nil, nodeData); // <----- ROOT NODE
      self.ReportsRootNode := Node;
      //////////////////////////////////////////////


      //showmessage('self.ReportIDList.Count = ' + intToStr(self.ReportIDList.Count)); //debug
      if LoadReportIDList() = 0 then
        Exit;

      for k := 0 to self.ReportIDList.Count - 1 do  //search one report at a time
        begin

        ///////////////////////////////////////////////////////////////////
        // RUN each report in the list, and ASSIGN the RPC results (the report text) to self.slSearchResults
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        //showmessage('self.ReportIDList' + '['+inttostr(k)+']'+': ' + self.ReportIDList[k]); //debug
        //showmessage('Report ID: ' + Piece(self.ReportIDList[k],U,1) + ':' + Piece(self.ReportIDList[k],U,2) + '~' + Piece(self.ReportIDList[k],U,4)); //debug
          case thisSearchType of
            STANDARD_SEARCH:
              begin
              thisIFN := Piece(self.ReportIDList[k],U,11);
                if self.ReportIsListViewType(thisIFN) then
                  begin
                  isListViewType := true;
                  slListviewReportText := TStringList.Create;
                  stUpdateContext(SEARCH_TOOL_CONTEXT);
                  Delay(self.FSearchPriority);
                  if not self.SearchCancelled then CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(self.ReportIDList[k],U,1) + ':' + Piece(self.ReportIDList[k],U,2) + '~' + Piece(self.ReportIDList[k],U,4),'','','',ordbStartDateReportsAdv.FMDateTime, ordbEndDateReportsAdv.FMDateTime]);
                  stUpdateContext(origContext);
                  //Reformat the resulting report text, cuz it will have report-line#^ at the beginning of each returned line
                  self.ReformatReportText(slListviewReportText, RPCBrokerV.Results, thisIFN); //slListviewReportText comes back loaded with reformatted report text

                  //Finish this routine as usual
                  end
                else
                  begin
                  //It's a "flat" report, not a listview type, so just grab the resulting report text, and finish this routine as usual
                  isListViewType := false;
                  stUpdateContext(SEARCH_TOOL_CONTEXT);
                  Delay(self.FSearchPriority);
                  if not self.SearchCancelled then CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(self.ReportIDList[k],U,1) + ':' + Piece(self.ReportIDList[k],U,2) + '~' + Piece(self.ReportIDList[k],U,4),'','','','1750101',DateTimeToFMDateTime(Now)]);
                  stUpdateContext(origContext);
                  end;
              end;
            ADVANCED_SEARCH:
              begin
              thisIFN := Piece(self.ReportIDList[k],U,11);
                if self.ReportIsListViewType(thisIFN) then
                  begin
                  isListViewType := true;
                  slListviewReportText := TStringList.Create;
                  stUpdateContext(SEARCH_TOOL_CONTEXT);
                  Delay(self.FSearchPriority);
                  if not self.SearchCancelled then CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(self.ReportIDList[k],U,1) + ':' + Piece(self.ReportIDList[k],U,2) + '~' + Piece(self.ReportIDList[k],U,4),'','','', ordbStartDateReportsAdv.FMDateTime, ordbEndDateReportsAdv.FMDateTime]);
                  stUpdateContext(origContext);
                  //Reformat the resulting report text, cuz it will have report-line#^ at the beginning of each returned line
                    self.ReformatReportText(slListviewReportText, RPCBrokerV.Results, thisIFN); //slListviewReportText comes back loaded with reformatted report text

                  //Finish this routine as usual
                  end
                else
                  begin
                  //It's a "flat" report, not a listview type, so just grab the resulting report text, and finish this routine as usual
                  isListViewType := false;
                  stUpdateContext(SEARCH_TOOL_CONTEXT);
                  Delay(self.FSearchPriority);
                  if not self.SearchCancelled then CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(self.ReportIDList[k],U,1) + ':' + Piece(self.ReportIDList[k],U,2) + '~' + Piece(self.ReportIDList[k],U,4),'','','', ordbStartDateReportsAdv.FMDateTime, ordbEndDateReportsAdv.FMDateTime]);
                  stUpdateContext(origContext);
                  end;
              end;
          end;

        self.ReportName := Piece(self.ReportIDList[k],'^',2);
        stUpdateContext(origContext);

        //If the report is a listview type, then we need to populate slReportText with
        // the REFORMATTED report text. Otherwise, slReportText just get the broker results, straight up
        if isListViewType then
          begin
          slReportText.Clear;
          for i := 0 to slListviewReportText.Count - 1 do
            self.slReportText.Add(slListviewReportText[i]);
          //We don't need this variable anymore, so free it
          if slListviewReportText <> nil then
            slListviewReportText.Free;
          end
        else
          begin
          slReportText.Clear;
          for i := 0 to RPCBrokerV.Results.Count - 1 do
            self.slReportText.Add(RPCBrokerV.Results[i]);
          end;

        //We want to make sure that the number of records displayed, is NOT less than
        //the number specified in the 'Max Return Instances' spinEdit for this search
        //area (avoiding a ListIndex Error). If the number of returned records IS less
        //than the number specified in the 'Max Return Instances' spinEdit for this search
        //area, then we set the value of the spinEdit to the number of returned records,
        //in which case we display all the returned records.
        if thisSearchType = STANDARD_SEARCH then
          begin
          if self.ReportIDList.Count < strToInt(floatToStr(seReportsMaxStd.Value)) then
            seReportsMaxStd.Value := self.ReportIDList.Count-1;
          end
        else
          if thisSearchType = ADVANCED_SEARCH then
            begin
            if self.ReportIDList.Count < strToInt(floatToStr(seReportsMaxAdv.Value)) then
              seReportsMaxAdv.Value := self.ReportIDList.Count-1;
            end;

          case thisSearchType of
            STANDARD_SEARCH:
              begin
              ///////////////////////////////////////////////////////////////////////////////////
              ///// NOTE: 'Title' Search does NOT apply to Reports                          /////
              /////       because there is no RPC call (like for Consults, for eg.)         /////
              /////       that returns a List of report titles.                             /////
              /////       Therefore, report searches are ALWAYS "deep" (document) searches, /////
              /////       and Report search just ignores the main menu 'Options | Title'.   /////
              ///////////////////////////////////////////////////////////////////////////////////
                //Clear the word list for Binary search
                if meWholeWords.Checked then //NOTE: Disabled on Standard Search, so this line ain't doin' nuthin'
                  begin
                  self.WordList.Clear;
                  self.WordList.Capacity := sizeOf(Cardinal);
                  end;

                stUpdateContext(SEARCH_TOOL_CONTEXT);
                Delay(self.FSearchPriority);
                stUpdateContext(origContext);

                //Load our report text for SEQUENTIAL search
                self.SingleLineBodyText := '';
                if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then //meWholeWords.Checked ALWAYS false for Standard search
                  for j := 0 to self.slReportText.Count-1 do
                    if not meCaseSensitive.Checked then  //meCaseSensitive.Checked ALWAYS false for Standard search
                      self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + self.slReportText[j])
                    else
                      self.SingleLineBodyText := self.SingleLineBodyText + self.slReportText[j];

                //Load our word list for BINARY search
                if ((not self.SearchCancelled) and meWholeWords.Checked) then //This is NEVER .Checked for Standard search
                  begin
                  for j := 0 to self.slReportText.Count-1 do
                    if not meCaseSensitive.Checked then  //This is NEVER .Checked for Standard search
                      LoadWordList(UpperCase(self.slReportText[j]))
                    else
                      LoadWordList(self.slReportText[j]);
                  self.WordList.Sort(@CompareWords);
                  end; //for

                /////////////////////////////////////// NOTE: NOT USED FOR STANDARD SEARCH //////////////////////////////////////
                if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                  if SearchTermsFoundInRecordBodySequential(self.edReportsSearchTermsStd, self.SingleLineBodyText) then  //Original O(n) search
                    begin
                    //showmessage('SingleLineBodyText: ' +  self.SingleLineBodyText); //debug
                    nodeData.FReportIDString := self.ReportIDList[k];
                    LoadReportsNode(thisSearchType, self.edReportsSearchTermsStd, Node, nodeData, self.SingleLineBodyText, k);
                    end;

                if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                  if SearchTermsFoundInRecordBody(self.edReportsSearchTermsStd) <> -1 then
                    begin
                    nodeData.FReportIDString := self.ReportIDList[k];
                    LoadReportsNode(thisSearchType, self.edReportsSearchTermsStd, Node, nodeData, self.SingleLineBodyText, i);
                    end;
                ///////////////////////////End - NOTE: NOT USED FOR STANDARD SEARCH//////////////////////////////////////////////
              end;
            ADVANCED_SEARCH:
              begin
              ///////////////////////////////////////////////////////////////////////////////////
              ///// NOTE: 'Title' Search does NOT apply to Reports                          /////
              /////       because there is no RPC call (like for Consults, for eg.)         /////
              /////       that returns a List of report titles.                             /////
              /////       Therefore, report searches are ALWAYS "deep" (document) searches, /////
              /////       and Report search just ignores the main menu 'Options | Title'.   /////
              ///////////////////////////////////////////////////////////////////////////////////
                //Clear the word list for Binary search
                if meWholeWords.Checked then //NOTE: Disabled on Standard Search, so this line ain't doin' nuthin'
                  begin
                  self.WordList.Clear;
                  self.WordList.Capacity := sizeOf(Cardinal);
                  end;

                stUpdateContext(SEARCH_TOOL_CONTEXT);
                Delay(self.FSearchPriority);
                stUpdateContext(origContext);

                //Load our report text for SEQUENTIAL search
                self.SingleLineBodyText := '';
                if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then //meWholeWords.Checked ALWAYS false for Standard search
                  for j := 0 to self.slReportText.Count-1 do
                    if not meCaseSensitive.Checked then  //meCaseSensitive.Checked ALWAYS false for Standard search
                      self.SingleLineBodyText := UpperCase(self.SingleLineBodyText + self.slReportText[j])
                    else
                      self.SingleLineBodyText := self.SingleLineBodyText + self.slReportText[j];

                //Load our word list for BINARY search
                if ((not self.SearchCancelled) and meWholeWords.Checked) then //This is NEVER .Checked for Standard search
                  begin
                  for j := 0 to self.slReportText.Count-1 do
                    if not meCaseSensitive.Checked then  //This is NEVER .Checked for Standard search
                      LoadWordList(UpperCase(self.slReportText[j]))
                    else
                      LoadWordList(self.slReportText[j]);
                  self.WordList.Sort(@CompareWords);
                  end; //for

                if ((not self.SearchCancelled) and (not meWholeWords.Checked)) then  //SEQUENTIAL Search
                  if SearchTermsFoundInRecordBodySequential(self.edReportsSearchTermsAdv, self.SingleLineBodyText) then  //Original O(n) search
                    begin
                    nodeData.FReportIDString := self.ReportIDList[k];
                    LoadReportsNode(thisSearchType, self.edReportsSearchTermsAdv, Node, nodeData, self.SingleLineBodyText, k);
                    end;

                if ((not self.SearchCancelled) and meWholeWords.Checked) then  //BINARY Search
                  if SearchTermsFoundInRecordBody(self.edReportsSearchTermsAdv) <> -1 then
                    begin
                    nodeData.FReportIDString := self.ReportIDList[k];
                    LoadReportsNode(thisSearchType, self.edReportsSearchTermsAdv, Node, nodeData, self.SingleLineBodyText, K);
                    end;
              end;
          end;
        end;
        vSearchTree.EndUpdate; //Yer done
      end;

    Application.ProcessMessages;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SearchReports()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
      

end; //SearchReports

function TfrmSearchCriteria.VerifyDateRanges : string;
begin
  result := '';
  if ordbStartDateTIUAdv.FMDateTime > ordbEndDateTIUAdv.FMDateTime then
    begin
    anCircularProgress.Active := false;
    anCircularProgress.Visible := false;
    result := 'TIU search Start Date not allowed to be greater than TIU search End Date.' + CRLF + SEARCH_CANCELLED;
    SearchCancelled := true;
    sbSearch.Enabled := true;
    Exit;
    end;
  if ordbStartDateProblemTextAdv.FMDateTime > ordbEndDateProblemTextAdv.FMDateTime then
    begin
    anCircularProgress.Active := false;
    anCircularProgress.Visible := false;
    result := 'Problem Text search Start Date not allowed to be greater than Problem Text search End Date.' + CRLF + SEARCH_CANCELLED;
    SearchCancelled := true;
    sbSearch.Enabled := true;
    Exit;
    end;
  if ordbStartDateConsultsAdv.FMDateTime > ordbEndDateConsultsAdv.FMDateTime then
    begin
    anCircularProgress.Active := false;
    anCircularProgress.Visible := false;
    result := 'Consults search Start Date not allowed to be greater than Consults search End Date.' + CRLF + SEARCH_CANCELLED;
    SearchCancelled := true;
    sbSearch.Enabled := true;
    Exit;
    end;
  if ordbStartDateOrdersAdv.FMDateTime > ordbEndDateOrdersAdv.FMDateTime then
    begin
    anCircularProgress.Active := false;
    anCircularProgress.Visible := false;
    result := 'Orders search Start Date not allowed to be greater than Orders search End Date.' + CRLF + SEARCH_CANCELLED;
    SearchCancelled := true;
    sbSearch.Enabled := true;
    Exit;
    end;
  if ordbStartDateReportsAdv.FMDateTime > ordbEndDateReportsAdv.FMDateTime then
    begin
    anCircularProgress.Active := false;
    anCircularProgress.Visible := false;
    result := 'Reports search Start Date not allowed to be greater than Reports search End Date.' + CRLF + SEARCH_CANCELLED;
    SearchCancelled := true;
    sbSearch.Enabled := true;
    Exit;
    end;
end;

procedure TfrmSearchCriteria.InitiateSearch(Sender: TObject);
var
  dateRangeMessage: string;
begin
  try
    self.ElapsedTime := 0; //init
    sbStatusBar.Panels[1].Text := '';
    SearchStartTime := GetTickCount(); //self.FirstTickCount;

    self.reDeepSearch := TRichEdit.Create(self);
    self.reDeepSearch.Parent := self;
    self.reDeepSearch.Visible := false; // <-------- true for debugging

    case pcSearch.ActivePageIndex of
      STANDARD_SEARCH_PAGE:
        begin
        if not self.SearchCancelled then SearchTIUNotes(self, STANDARD_SEARCH);
        if not self.SearchCancelled then SearchProblemText(self, STANDARD_SEARCH);
        if not self.SearchCancelled then SearchConsults(self, STANDARD_SEARCH);
        if not self.SearchCancelled then SearchOrders(self, STANDARD_SEARCH);
        if not self.SearchCancelled then SearchReports(self, STANDARD_SEARCH);
        end;
      ADVANCED_SEARCH_PAGE:
        begin
        dateRangeMessage := VerifyDateRanges();
        if dateRangeMessage = '' then
          begin
          if not self.SearchCancelled then SearchTIUNotes(self, ADVANCED_SEARCH);
          if not self.SearchCancelled then SearchProblemText(self, ADVANCED_SEARCH);
          if not self.SearchCancelled then SearchConsults(self, ADVANCED_SEARCH);
          if not self.SearchCancelled then SearchOrders(self, ADVANCED_SEARCH);
          if not self.SearchCancelled then SearchReports(self, ADVANCED_SEARCH);
          end
        else
          MessageDlg(dateRangeMessage, mtError, [mbOk], 0);
        end;
    end;

    if self.SearchCancelled then UpdateStatusBarMessage(SEARCH_CANCELLED);
    if self.SearchCancelled then
      self.SearchIsActive := false;
    Application.ProcessMessages;

    self.ElapsedTime := ((GetTickCount - SearchStartTime) / 1000);
    sbStatusBar.Panels[1].Text := 'Search Time: ' + FloatToStr(self.ElapsedTime) + ' seconds';
    sbStatusBar.Panels[3].Text := TOTAL_FOUND + intToStr(totalRecordsFound);

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' InitiateSearch()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;

procedure TfrmSearchCriteria.Delay(msecs: integer);
begin
  try
    Application.ProcessMessages;
    self.FirstTickCount := GetTickCount;

    if self.SearchCancelled then
      begin
      Application.ProcessMessages;
      Exit;
      end
    else
      begin

      repeat
        if pcSearch.ActivePageIndex <> 2 then //no update when on results page
          self.UpdateSearchTime();
        Application.ProcessMessages;
      until ((GetTickCount - self.FirstTickCount) >= longInt(msecs));
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' Delay()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.sbCancelClick(Sender: TObject);
begin
  UpdateStatusBarMessage(SEARCH_CANCELLING);

  //Without this, you'll get an AV if you have an in-progress search,
  // and you go to the CPRS GUI while the search is running, and try to close CPRS.
  stUpdateContext(origContext);
  Application.ProcessMessages;

  anCircularProgress.Visible := false;
  anCircularProgress.Active := false;

  Application.ProcessMessages;

  self.SearchCancelled := true;
  self.SearchIsActive := false;

  //We don't want to enable the Search button
  // if we're on the Search Results page
  if pcSearch.ActivePage <> tsSearchResults then
    sbSearch.Enabled := true;

  Application.ProcessMessages;
end;
{
procedure TfrmSearchCriteria.sbCancelORIGClick(Sender: TObject);
begin

  UpdateStatusBarMessage(SEARCH_CANCELLING);

  //Without this, you'll get an AV if you have an in-progress search,
  // and you go to the CPRS GUI while the search is running, and try to close CPRS.
  stUpdateContext(origContext);
  Application.ProcessMessages;

  anCircularProgress.Visible := false;
  anCircularProgress.Active := false;

  Application.ProcessMessages;

  self.SearchCancelled := true;
  self.SearchIsActive := false;

  //We don't want to enable the Search button
  // if we're on the Search Results page
  if pcSearch.ActivePage <> tsSearchResults then
    sbSearch.Enabled := true;

  Application.ProcessMessages;

end;
}
procedure TfrmSearchCriteria.sbClearAllSearchCriteriaClick(Sender: TObject);
//Clear search terms on the ACTIVE PAGE only
begin
  try
    if pcSearch.ActivePage = tsStandardSearch then
      begin
      //Clear all Standard search components
      edTIUSearchTermsStd.Clear;
      seTIUMaxStd.Value := seTIUMaxStd.MinValue;
      edProblemTextSearchTermsStd.Clear;
      seProblemTextMaxStd.Value := seProblemTextMaxStd.MinValue;
      edConsultsSearchTermsStd.Clear;
      seConsultsMaxStd.Value := seConsultsMaxStd.MinValue;
      edOrdersSearchTermsStd.Clear;
      seOrdersMaxStd.Value := seOrdersMaxStd.MinValue;
      edReportsSearchTermsStd.Clear;
      seReportsMaxStd.Value := seReportsMaxStd.MinValue;

      //Clear the START dates, but not the END dates
      //Standard Search does not currently use date-ranges (the components Visible=false)
      ordbStartDateTIUStd.Clear;
      ordbStartDateProblemTextStd.Clear;
      ordbStartDateConsultsStd.Clear;
      ordbStartDateOrdersStd.Clear;
      ordbStartDateReportsStd.Clear;
      end;

    if pcSearch.ActivePage = tsAdvancedSearch then
      begin
      //Clear all Advanced search components
      edTIUSearchTermsAdv.Clear;
      seTIUMaxAdv.Value := seTIUMaxAdv.MinValue;
      edProblemTextSearchTermsAdv.Clear;
      seProblemTextMaxAdv.Value := seProblemTextMaxAdv.MinValue;
      edConsultsSearchTermsAdv.Clear;
      seConsultsMaxAdv.Value := seConsultsMaxAdv.MinValue;
      edOrdersSearchTermsAdv.Clear;
      seOrdersMaxAdv.Value := seOrdersMaxAdv.MinValue;
      edReportsSearchTermsAdv.Clear;
      seReportsMaxAdv.Value := seReportsMaxAdv.MinValue;

      //Clear the START dates, but not the END dates
      ordbStartDateTIUAdv.Clear;
      ordbStartDateProblemTextAdv.Clear;
      ordbStartDateConsultsAdv.Clear;
      ordbStartDateOrdersAdv.Clear;
      ordbStartDateReportsAdv.Clear;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' sbClearAllSearchCriteriaClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;
{
procedure TfrmSearchCriteria.sbClearAllSearchCriteriaORIGClick(Sender: TObject);
//Clear search terms on the ACTIVE PAGE only
begin
  try
    if pcSearch.ActivePage = tsStandardSearch then
      begin
      //Clear all Standard search components
      edTIUSearchTermsStd.Clear;
      seTIUMaxStd.Value := seTIUMaxStd.MinValue;
      edProblemTextSearchTermsStd.Clear;
      seProblemTextMaxStd.Value := seProblemTextMaxStd.MinValue;
      edConsultsSearchTermsStd.Clear;
      seConsultsMaxStd.Value := seConsultsMaxStd.MinValue;
      edOrdersSearchTermsStd.Clear;
      seOrdersMaxStd.Value := seOrdersMaxStd.MinValue;
      edReportsSearchTermsStd.Clear;
      seReportsMaxStd.Value := seReportsMaxStd.MinValue;

      //Clear the START dates, but not the END dates
      //Standard Search does not currently use date-ranges (the components Visible=false)
      ordbStartDateTIUStd.Clear;
      ordbStartDateProblemTextStd.Clear;
      ordbStartDateConsultsStd.Clear;
      ordbStartDateOrdersStd.Clear;
      ordbStartDateReportsStd.Clear;
      end;

    if pcSearch.ActivePage = tsAdvancedSearch then
      begin
      //Clear all Advanced search components
      edTIUSearchTermsAdv.Clear;
      seTIUMaxAdv.Value := seTIUMaxAdv.MinValue;
      edProblemTextSearchTermsAdv.Clear;
      seProblemTextMaxAdv.Value := seProblemTextMaxAdv.MinValue;
      edConsultsSearchTermsAdv.Clear;
      seConsultsMaxAdv.Value := seConsultsMaxAdv.MinValue;
      edOrdersSearchTermsAdv.Clear;
      seOrdersMaxAdv.Value := seOrdersMaxAdv.MinValue;
      edReportsSearchTermsAdv.Clear;
      seReportsMaxAdv.Value := seReportsMaxAdv.MinValue;

      //Clear the START dates, but not the END dates
      ordbStartDateTIUAdv.Clear;
      ordbStartDateProblemTextAdv.Clear;
      ordbStartDateConsultsAdv.Clear;
      ordbStartDateOrdersAdv.Clear;
      ordbStartDateReportsAdv.Clear;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' sbClearAllSearchCriteriaClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
function TfrmSearchCriteria.AllSearchDatesValid() : string;
var
  thisDateTime: TDateTime;

    function IsValidDate(thisDateString : string; var thisDateTime : TDateTime): boolean;
      begin
      result := true;
        try
          thisDateTime := StrToDateTime(thisDateString);
        except
          thisDateTime := 0;
          result := false;
        end;
      end;

begin
  try
    result := '';                            //Filter By: Signed Notes by Date Range
    if ((edTIUSearchTermsAdv.Text <> '') and (rgTIUNoteOptionsAdv.ItemIndex = 4) and (not IsValidDate(ordbStartDateTIUAdv.Text, thisDateTime))) then
      result := 'TIU Notes Start Date'
    else
      if ((edTIUSearchTermsAdv.Text <> '') and (not IsValidDate(ordbEndDateTIUAdv.Text, thisDateTime))) then
        result := 'TIU Notes End Date'
      else
        if ((edProblemTextSearchTermsAdv.Text <> '') and (not IsValidDate(ordbStartDateProblemTextAdv.Text, thisDateTime))) then
          result := 'Problem Text Start Date'
      else
        if ((edProblemTextSearchTermsAdv.Text <> '') and (not IsValidDate(ordbEndDateProblemTextAdv.Text, thisDateTime))) then
          result := 'Problem Text End Date'
      else
        if ((edConsultsSearchTermsAdv.Text <> '') and (not IsValidDate(ordbStartDateConsultsAdv.Text, thisDateTime))) then
          result := 'Consults Start Date'
      else
        if ((edConsultsSearchTermsAdv.Text <> '') and (not IsValidDate(ordbEndDateConsultsAdv.Text, thisDateTime))) then
          result := 'Consults End Date'
      else
        if ((edOrdersSearchTermsAdv.Text <> '') and (not IsValidDate(ordbStartDateOrdersAdv.Text, thisDateTime))) then
          result := 'Orders Start Date'
      else
        if ((edOrdersSearchTermsAdv.Text <> '') and (not IsValidDate(ordbEndDateOrdersAdv.Text, thisDateTime))) then
          result := 'Orders End Date'
      else
        if ((edReportsSearchTermsAdv.Text <> '') and (not IsValidDate(ordbStartDateReportsAdv.Text, thisDateTime))) then
          result := 'Reports Start Date'
      else
        if ((edReportsSearchTermsAdv.Text <> '') and (not IsValidDate(ordbEndDateReportsAdv.Text, thisDateTime))) then
          result := 'Reports End Date';
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' AllSearchDatesValid()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.NoSearchTerms : boolean;
begin
  result := true;
  if pcSearch.ActivePage = tsStandardSearch then
    begin
    if ((edTIUSearchTermsStd.Text <> '') or
        (edProblemTextSearchTermsStd.Text <> '') or
        (edConsultsSearchTermsStd.Text <> '') or
        (edOrdersSearchTermsStd.Text <> '') or
        (edReportsSearchTermsStd.Text <> '')) then
    result := false;
    end
  else
    if pcSearch.ActivePage = tsAdvancedSearch then
      begin
      if ((edTIUSearchTermsAdv.Text <> '') or
          (edProblemTextSearchTermsAdv.Text <> '') or
          (edConsultsSearchTermsAdv.Text <> '') or
          (edOrdersSearchTermsAdv.Text <> '') or
          (edReportsSearchTermsAdv.Text <> '')) then
      result := false;
      end;
end;

procedure TfrmSearchCriteria.sbSearchClick(Sender: TObject);
var
  //i: integer;
  searchArea: string;
begin
  try
    self.LoadCancelled := false; //init

    if frmQuickSearch.Showing then
      frmQuickSearch.Close;

    Application.ProcessMessages;

    totalRecordsFound := 0; //init

    stUpdateContext(origContext);

    if self.SearchIsActive then
      Exit;

    if NoSearchTerms() then
      begin
      UpdateStatusBarMessage('Search Cancelled');
      MessageDlg(SEARCH_CANCELLED + ':' + CRLF + NO_SEARCH_TERMS, mtInformation, [mbOk], 0);
      sbSearch.Enabled := true;
      Exit;
      end;

    anCircularProgress.Active := true;
    anCircularProgress.Visible := true;
    UpdateStatusBarMessage('');
    NumTIUFound := 0;
    NumProblemTextFound := 0;
    NumConsultsFound := 0;
    NumOrdersFound := 0;
    NumReportsFound := 0;

    sbSearch.Enabled := false;
    //SetupSearchTree(self);
    self.SearchCancelled := false;
    self.SearchIsActive := true;

    laTIUNotesFoundStd.Caption := CAPTION_FOUND;
    laProblemTextFoundStd.Caption := CAPTION_FOUND;
    laConsultsFoundStd.Caption := CAPTION_FOUND;
    laOrdersFoundStd.Caption := CAPTION_FOUND;
    laReportsFoundStd.Caption := CAPTION_FOUND;

    laTIUNotesFoundAdv.Caption := CAPTION_FOUND;
    laProblemTextFoundAdv.Caption := CAPTION_FOUND;
    laConsultsFoundAdv.Caption := CAPTION_FOUND;
    laOrdersFoundAdv.Caption := CAPTION_FOUND;
    laReportsFoundAdv.Caption := CAPTION_FOUND;

    self.NumTIUFound := 0;
    self.NumProblemTextFound := 0;
    self.NumConsultsFound := 0;
    self.NumOrdersFound := 0;
    self.NumReportsFound := 0;
    laTIUNotesFoundStd.Caption := CAPTION_FOUND + '0';
    laProblemTextFoundStd.Caption := CAPTION_FOUND + '0';
    laConsultsFoundStd.Caption := CAPTION_FOUND + '0';
    laOrdersFoundStd.Caption := CAPTION_FOUND + '0';
    laReportsFoundStd.Caption := CAPTION_FOUND + '0';
    laTIUNotesFoundAdv.Caption := CAPTION_FOUND + '0';
    laProblemTextFoundAdv.Caption := CAPTION_FOUND + '0';
    laConsultsFoundAdv.Caption := CAPTION_FOUND + '0';
    laOrdersFoundAdv.Caption := CAPTION_FOUND + '0';
    laReportsFoundAdv.Caption := CAPTION_FOUND + '0';

    //Make sure the tree gets cleared before the current search is initiated
    // so that we don't get previous root nodes painted, in ADDITION TO the
    // root nodes for the current search.
    vSearchTree.BeginUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
    vSearchTree.Clear;
    vSearchTree.EndUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28

    reDetail.Clear;
    Application.ProcessMessages;

    if pcSearch.ActivePage = tsAdvancedSearch then
      begin
      searchArea := AllSearchDatesValid();
      if searchArea <> '' then
        begin
        self.sbCancelClick(nil);
        MessageDlg(SEARCH_CANCELLED + ': ' + CRLF + INVALID_SEARCH_DATE + searchArea, mtInformation, [mbOk], 0);
        end
      else
        self.InitiateSearch(Sender);
      end
    else
      self.InitiateSearch(Sender); //We're on the Standard Search page, so no Date validation performed

    if not self.SearchCancelled then
      begin
      self.SearchIsActive := false;
      UpdateStatusBarMessage(SEARCH_COMPLETE);
      sbSearch.Enabled := true;
      reDetail.Clear; //get ready for new search results
      if meShowResultsOnSearchCompletion.Checked then
        begin
        self.buSearchTerms.Enabled := false;
        self.buQuickSearch.Enabled := false;
        self.pcSearch.ActivePage := tsSearchResults;
        self.sbSearch.Enabled := false;
        sbClearAllSearchCriteria.Enabled := false;
        buSaveSearchTerms.Enabled := false;
        end
      else
        begin
        self.buSearchTerms.Enabled := false;
        self.buQuickSearch.Enabled := false;
        sbClearAllSearchCriteria.Enabled := true;
        buSaveSearchTerms.Enabled := true;
        end;
      end;

    anCircularProgress.Visible := false;
    anCircularProgress.Active := false;

    Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' sbSearchClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
{
procedure TfrmSearchCriteria.sbSearchORIGClick(Sender: TObject);
var
  searchArea: string;
begin
  try
    self.LoadCancelled := false; //init

    if frmQuickSearch.Showing then
      frmQuickSearch.Close;

    Application.ProcessMessages;

    totalRecordsFound := 0; //init

    stUpdateContext(origContext);

    if self.SearchIsActive then
      Exit;

    if NoSearchTerms() then
      begin
      UpdateStatusBarMessage('Search Cancelled');
      MessageDlg(SEARCH_CANCELLED + ':' + CRLF + NO_SEARCH_TERMS, mtInformation, [mbOk], 0);
      sbSearch.Enabled := true;
      Exit;
      end;

    anCircularProgress.Active := true;
    anCircularProgress.Visible := true;
    UpdateStatusBarMessage('');
    NumTIUFound := 0;
    NumProblemTextFound := 0;
    NumConsultsFound := 0;
    NumOrdersFound := 0;
    NumReportsFound := 0;

    sbSearch.Enabled := false;
    //SetupSearchTree(self);
    self.SearchCancelled := false;
    self.SearchIsActive := true;

    laTIUNotesFoundStd.Caption := CAPTION_FOUND;
    laProblemTextFoundStd.Caption := CAPTION_FOUND;
    laConsultsFoundStd.Caption := CAPTION_FOUND;
    laOrdersFoundStd.Caption := CAPTION_FOUND;
    laReportsFoundStd.Caption := CAPTION_FOUND;

    laTIUNotesFoundAdv.Caption := CAPTION_FOUND;
    laProblemTextFoundAdv.Caption := CAPTION_FOUND;
    laConsultsFoundAdv.Caption := CAPTION_FOUND;
    laOrdersFoundAdv.Caption := CAPTION_FOUND;
    laReportsFoundAdv.Caption := CAPTION_FOUND;

    self.NumTIUFound := 0;
    self.NumProblemTextFound := 0;
    self.NumConsultsFound := 0;
    self.NumOrdersFound := 0;
    self.NumReportsFound := 0;
    laTIUNotesFoundStd.Caption := CAPTION_FOUND + '0';
    laProblemTextFoundStd.Caption := CAPTION_FOUND + '0';
    laConsultsFoundStd.Caption := CAPTION_FOUND + '0';
    laOrdersFoundStd.Caption := CAPTION_FOUND + '0';
    laReportsFoundStd.Caption := CAPTION_FOUND + '0';
    laTIUNotesFoundAdv.Caption := CAPTION_FOUND + '0';
    laProblemTextFoundAdv.Caption := CAPTION_FOUND + '0';
    laConsultsFoundAdv.Caption := CAPTION_FOUND + '0';
    laOrdersFoundAdv.Caption := CAPTION_FOUND + '0';
    laReportsFoundAdv.Caption := CAPTION_FOUND + '0';

    //Make sure the tree gets cleared before the current search is initiated
    // so that we don't get previous root nodes painted, in ADDITION TO the
    // root nodes for the current search.
    vSearchTree.BeginUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
    vSearchTree.Clear;
    vSearchTree.EndUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28

    reDetail.Clear;
    Application.ProcessMessages;

    if pcSearch.ActivePage = tsAdvancedSearch then
      begin
      searchArea := AllSearchDatesValid();
      if searchArea <> '' then
        begin
        self.sbCancelClick(nil);
        MessageDlg(SEARCH_CANCELLED + ': ' + CRLF + INVALID_SEARCH_DATE + searchArea, mtInformation, [mbOk], 0);
        end
      else
        self.InitiateSearch(Sender);
      end
    else
      self.InitiateSearch(Sender); //We're on the Standard Search page, so no Date validation performed

    if not self.SearchCancelled then
      begin
      self.SearchIsActive := false;
      UpdateStatusBarMessage(SEARCH_COMPLETE);
      sbSearch.Enabled := true;
      reDetail.Clear; //get ready for new search results
      if meShowResultsOnSearchCompletion.Checked then
        begin
        self.buSearchTerms.Enabled := false;
        self.buQuickSearch.Enabled := false;
        self.pcSearch.ActivePage := tsSearchResults;
        self.sbSearch.Enabled := false;
        sbClearAllSearchCriteria.Enabled := false;
        buSaveSearchTerms.Enabled := false;
        end
      else
        begin
        self.buSearchTerms.Enabled := false;
        self.buQuickSearch.Enabled := false;
        sbClearAllSearchCriteria.Enabled := true;
        buSaveSearchTerms.Enabled := true;
        end;
      end;

    anCircularProgress.Visible := false;
    anCircularProgress.Active := false;

    Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' sbSearchClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
function TfrmSearchCriteria.IsWord(start: integer; stop: integer; thisString: string) : boolean;
begin
  try
    if (   ((start >= 1) and  (thisString[start] in delims)) or (start < 1)    )
       and
       (   ((stop <= length(thisString)) and  (thisString[stop] in delims)) or (stop > length(thisString))    ) then
      result := true
    else
      result := false;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' IsWord()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.BoldSearchTerms(Sender: TObject);
var
  k: integer;
  j: integer;
  searchTerm: string;
  count: integer;
  FoundAt: longInt;
  StartPos, ToEnd: integer;

  //meDebug: TMemo; //debug
begin
  try
    reDetail.Enabled := false;

    for k := 0 to self.slSearchTerms.Count-1 do
      begin
      ////////////////////////////////////////////////////////////////////////////
      //We have to do this if using dialogs SearchTerms and QuickSearch.
      // If we don't do this, then #13#10 gets interpreted as
      // being a valid word (search term). If this happens, then every word
      // that is displayed in the reDetail window goes bold (everything gets selected
      // then bolded). Once that happens, ALL other detail text remains bold no matter
      // which vSearchTree node is clicked, because the local variable FoundAt is affected.
      // So, here we're simply avoiding the problem, altogether.
      // NOTE: I initially thought this problem could be controlled by including
      // #13#10 in the 'delims' set (var delims: set of char = [' ']). This won't work
      // because delims is a set of Char, and does not work with strings.
      // So, we have to control it here:
      //  if self.slSearchTerms[k] = #13#10 then Continue; //<-------------- No longer needed. See 'MORE INFO' below
      //
      // ***** see 'MORE INFO' below *****
      //
      // MORE INFO:
      // It turns out that while the above explanation is true, the problem was
      // finally traced to the TMemo's on the dialog forms, SearchTerms and QuickSearch.
      // For whatever reason, TMemo apparently embeds text and special characters
      // differently than TRichEdit. This is what was causing the problem.
      //
      // FIXED THIS PROBLEM BY:
      // Replaced the TMemo's on dialog forms, SearchTerms and QuickSearch with
      // TRichEdit's, and setting the 'PlainText' properties to 'true', thereby
      // avoiding the special-character problem, altogether.
      ////////////////////////////////////////////////////////////////////////////

      Delay(self.FSearchPriority);
      if not meCaseSensitive.Checked then
        begin
        searchTerm := UpperCase(self.slSearchTerms[k]);
        end
      else
        searchTerm := self.slSearchTerms[k];

      StartPos := 0;
      j := 0;
      FoundAt := -1;

      pbReportLoading.Max := Length(reDetail.Text);
      pbReportLoading.Position := 0; //init

        while j <= Length(reDetail.Text) do
          begin
          Application.ProcessMessages; //Check for Load cancel
          if self.LoadCancelled then
            begin
            reDetail.Clear;
            self.UpdateStatusBarMessage(PROCESSING_CANCELLED);
            Break;
            end;


          Delay(self.FSearchPriority);
          // ToEnd is the length from StartPos to the end of the text in the rich edit control
          ToEnd := Length(reDetail.Text) - StartPos;

          if (not meWholeWords.Checked) and (not meCaseSensitive.Checked) then
            FoundAt := reDetail.FindText(searchTerm, StartPos, ToEnd, [])
          else
            if (meWholeWords.Checked) and (not meCaseSensitive.Checked) then
              FoundAt := reDetail.FindText(searchTerm, StartPos, ToEnd, [stWholeWord])
          else
            if (not meWholeWords.Checked) and (meCaseSensitive.Checked) then
              FoundAt := reDetail.FindText(searchTerm, StartPos, ToEnd, [stMatchCase])
          else
            if (meWholeWords.Checked) and (meCaseSensitive.Checked) then
              FoundAt := reDetail.FindText(searchTerm, StartPos, ToEnd, [stWholeWord, stMatchCase]);


          if FoundAt <> -1 then
            begin
              reDetail.SelStart := FoundAt;
              reDetail.SelLength := Length(searchTerm);
              reDetail.SelAttributes.style := [fsbold];
              reDetail.SelAttributes.Color := self.FBoldedSearchTermColor;
            end;

          if ((j <= Length(reDetail.Text)) and (FoundAt <> -1)) then
            begin
            StartPos := FoundAt + reDetail.SelLength;
            j := StartPos;
            Delay(self.FSearchPriority);
            pbReportLoading.Position := StartPos;
            end
          else
            Break;
          end; //while
      end; //for

      reDetail.Enabled := true;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' BoldSearchTerms()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.meBoldSearchTermBoldColorClick(Sender: TObject);
begin
  try
    if cdColorDialog.Execute then
      self.FBoldedSearchTermColor := cdColorDialog.Color;
    if pcSearch.ActivePage = tsSearchResults then
    self.vSearchTreeClick(nil); //Re-parse the search results window (reDetail) and bold with the newly selected color
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' meBoldSearchTermBoldColorClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.meCaseSensitiveClick(Sender: TObject);
begin
  if meCaseSensitive.Checked then
    meCaseSensitive.Checked:= false
  else
    meCaseSensitive.Checked:= true;
end;

procedure TfrmSearchCriteria.meTitleSearchClick(Sender: TObject);
begin
  meTitleSearch.Checked := true;
  self.DeepSearch := false;

  //Disable these for Title Search
  meWholeWords.Checked := false;
  meWholeWords.Enabled := false;
  meCaseSensitive.Checked := false;
  meCaseSensitive.Enabled := false;
end;

procedure TfrmSearchCriteria.meDocumentSearchClick(Sender: TObject);
begin
  meDocumentSearch.Checked := true;
  self.DeepSearch := true;

  //Enable these for Document (Deep) Search
  meWholeWords.Enabled := true;
  meCaseSensitive.Enabled := true;
end;

procedure TfrmSearchCriteria.meExitClick(Sender: TObject);
begin
  sbCancelClick(nil);
  Application.ProcessMessages;
  self.Close;
end;

procedure TfrmSearchCriteria.meWholeWordsClick(Sender: TObject);
begin
  if meWholeWords.Checked then
    meWholeWords.Checked:= false
  else
    meWholeWords.Checked:= true;
end;

procedure TfrmSearchCriteria.LoadSearchTerms(Sender: TObject; parentData: PTreeData);
begin
  case self.SearchType of
    STANDARD_SEARCH:
      begin
      if parentData.FCaption = CAPTION_TIU_NOTES then
        ParseDelimited(self.slSearchTerms, edTIUSearchTermsStd.Text, ' ')
      else
        if parentData.FCaption = CAPTION_PROBLEM_TEXT then
          ParseDelimited(self.slSearchTerms, edProblemTextSearchTermsStd.Text, ' ')
      else
        if parentData.FCaption = CAPTION_CONSULTS then
          ParseDelimited(self.slSearchTerms, edConsultsSearchTermsStd.Text, ' ')
      else
        if parentData.FCaption = CAPTION_ORDERS then
          ParseDelimited(self.slSearchTerms, edOrdersSearchTermsStd.Text, ' ')
      else
        if parentData.FCaption = CAPTION_REPORTS then
          ParseDelimited(self.slSearchTerms, edReportsSearchTermsStd.Text, ' ');
      end;
    ADVANCED_SEARCH:
      begin
      if parentData.FCaption = CAPTION_TIU_NOTES then
        ParseDelimited(self.slSearchTerms, edTIUSearchTermsAdv.Text, ' ')
      else
        if parentData.FCaption = CAPTION_PROBLEM_TEXT then
          ParseDelimited(self.slSearchTerms, edProblemTextSearchTermsAdv.Text, ' ')
      else
        if parentData.FCaption = CAPTION_CONSULTS then
          ParseDelimited(self.slSearchTerms, edConsultsSearchTermsAdv.Text, ' ')
      else
        if parentData.FCaption = CAPTION_ORDERS then
          ParseDelimited(self.slSearchTerms, edOrdersSearchTermsAdv.Text, ' ')
      else
        if parentData.FCaption = CAPTION_REPORTS then
          ParseDelimited(self.slSearchTerms, edReportsSearchTermsAdv.Text, ' ');
      end;
  end; 
end;

procedure TfrmSearchCriteria.ShowLoadingProgress();
begin
  laLoading.Visible := true;
  pbReportLoading.Visible := true;
  buLoadCancel.Visible := true;
end;

procedure TfrmSearchCriteria.HideLoadingProgress();
begin
  laLoading.Visible := false;
  pbReportLoading.Visible := false;
  buLoadCancel.Visible := false;
end;


procedure TfrmSearchCriteria.vSearchTreeClick(Sender: TObject);
var
  parentNode: PVirtualNode;
  parentData: PTreeData;
  Node: PVirtualNode;
  nodeData: PTreeData;
  Data: PTreeData; // <----------Need this ??
  i: integer;
  nodeLevel: integer;

  thisReportID: string;
  thisWPValue: TStringList;
  str: string; //debug
  slTempList: TStringList;

  //Reports vars
  thisIFN: string;
  k: integer;
  isListViewType: boolean;
  slListviewReportText: TStringList;
  debugStr: string; //debug
begin
  try
    if self.ThisNode = nil then Exit; //Jump out if no node has focus

    Node := vSearchTree.FocusedNode; //Get the currently selected (focused) node

    //PROBLEM:
    //  If any tree node has focus, and the user clicks in the tree's Client area, but NOT direcly
    //  on another node (say, off to the side of some other node so as to not select it), then
    //  the remainder of this procedure was being run, causing the text of the result to be
    //  re-parsed for bolding of search terms even though the node that currently has focus is
    //  not clicked on, again.
    //FIX:
    //  self.ThisNode gets assigned in procedure TfrmSearchCriteria.vSearchTreeMouseDown(), which
    //  fires BEFORE this procedure (OnClick). Since "nodes" are actually pointers (addresses), we
    //  grab the address of the node that was clicked in the client area (whether clicked on direcly,
    //  or off to the side of the node text), and compare it to the currently focused node.
    //  If the addresses match, then we have clicked on the previously focused node again, or have
    //  now selected a new node, which now has the focus. Otherwise, we have clicked somewhere else i
    //  in the tree's client area and not directly on any node, in which case we want to just exit
    //  this routine so that we don't end up re-parsing/re-bolding search terms for the previously
    //  selected (focused) node. 
    if Node = self.ThisNode then
      begin
      self.LoadCancelled := false;
      reDetail.Clear;    

      nodeLevel := vSearchTree.GetNodeLevel(Node);
      HideLoadingProgress();

      //Show loading progress form if the clicked node is a search result, and NOT a parent node
      // frmLoadingProgress is updated in frmSearchCriteria.BoldSearchTerms()
      if not vSearchTree.HasChildren[Node] then
        begin
        pbReportLoading.Position := 0;
        if nodeLevel <> 0 then //Do not show the 'Loading...' progress bar if a root node is clicked
          ShowLoadingProgress();
        end;

      if nodeLevel = 0 then //it's a Root node, so jump out, because there is no report text associated with root nodes
        Exit;

      parentNode := Node.Parent;
      parentData := vSearchTree.GetNodeData(parentNode);

      nodeData := vSearchTree.GetNodeData(Node);
      if not Assigned(Node) then
        Exit;

      Data := vSearchTree.GetNodeData(Node); // <-------------------------------------------Need this ??
      //self.Caption := Data.FCaption; //Display selected record in form caption on Click

      //Showmessage(Data.FCaption); //debug

      //////////////////////////////////////////////////////////////////////////////////////////
      ///// This is where you drill down and place details in the TRichEdit Results window /////
      //////////////////////////////////////////////////////////////////////////////////////////

      //if not DeepSearch then
        //begin
        if parentData.FCaption = CAPTION_TIU_NOTES then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          Delay(self.FSearchPriority);
          CallV('TIU GET RECORD TEXT', [nodeData.FTIUDocNum]);
          stUpdateContext(origContext);

          for i := 0 to RPCBrokerV.Results.Count - 1 do
            begin
            reDetail.Lines.Add(RPCBrokerV.Results[i]);
            end;

          LoadSearchTerms(Sender, parentData);
          BoldSearchTerms(Sender);
          vSearchTree.SetFocus; //set focus back to the Tree so we can use KeyDown again, on the tree
          end;

      if parentData.FCaption = CAPTION_PROBLEM_TEXT then
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        Delay(self.FSearchPriority);
        CallV('ORQQPL DETAIL', [self.PatientIEN, Data.FProblemIFN]);
        stUpdateContext(origContext);
        for i := 0 to RPCBrokerV.Results.Count - 1 do
          begin
          Delay(self.FSearchPriority);
          if RPCBrokerV.Results[i] <> '' then
            reDetail.Lines.Add(RPCBrokerV.Results[i]);
          end;
        LoadSearchTerms(Sender, parentData);
        BoldSearchTerms(Sender);
        vSearchTree.SetFocus; //set focus back to the Tree so we can use KeyDown again, on the tree
        end;

      if parentData.FCaption = CAPTION_CONSULTS then
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        Delay(self.FSearchPriority);
        CallV('ORQQCN DETAIL', [Data.FConsultID]);
        stUpdateContext(origContext);
        for i := 0 to RPCBrokerV.Results.Count - 1 do
          if RPCBrokerV.Results[i] <> '' then
            reDetail.Lines.Add(RPCBrokerV.Results[i]);
        LoadSearchTerms(Sender, parentData);
        BoldSearchTerms(Sender);
        vSearchTree.SetFocus; //set focus back to the Tree so we can use KeyDown again, on the tree
        end;

      if parentData.FCaption = CAPTION_ORDERS then
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        Delay(self.FSearchPriority);
        CallV('ORQOR DETAIL', [Piece(Data^.FOrderID,';',1), PatientIEN]);
        stUpdateContext(origContext);
        for i := 0 to RPCBrokerV.Results.Count - 1 do
          if RPCBrokerV.Results[i] <> '' then
            reDetail.Lines.Add(RPCBrokerV.Results[i]);
        LoadSearchTerms(Sender, parentData);
        BoldSearchTerms(Sender);
        vSearchTree.SetFocus; //set focus back to the Tree so we can use KeyDown again, on the tree
        end;


      if parentData.FCaption = CAPTION_REPORTS then
        begin
        //Use Data.FReportID to run the report
        slTempList := TStringList.Create;

        //if self.SearchType = STANDARD_SEARCH then
          //begin
          /////////////// spin thru slTempList to match the node caption with the parameter name
          /////////////// if you find it, grab the report ID string
          ///////////////     thisReportIDString := slTempList[i]  
          /////////////// run the report
          /////////////// ...do the rest of the search/bold algorithm
          for i := 0 to slTempList.Count - 1 do
            begin
            if Piece(slTempList[i],':',2) = nodeData.FCaption then
              self.ReportIDString := slTempList[i];
            Break;
            end;

          stUpdateContext(SEARCH_TOOL_CONTEXT);

              nodeData := vSearchTree.GetNodeData(Node);

              ///////////////////////////////////////////////////////////////////
              // RUN each report in the list, and ASSIGN the RPC results (the report text) to self.slSearchResults
              stUpdateContext(SEARCH_TOOL_CONTEXT);
                case self.SearchType of
                  STANDARD_SEARCH:
                    begin
                    //thisIFN := Piece(self.ReportIDList[k],U,11);
                    thisIFN := Piece(nodeData.FReportIDString,U,11);
                      if self.ReportIsListViewType(thisIFN) then
                        begin
                        slListviewReportText := TStringList.Create;
                        isListViewType := true;
                        Delay(self.FSearchPriority);
                        CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(nodeData.FReportIDString,U,1) + ':' + Piece(nodeData.FReportIDString,U,2) + '~' + Piece(nodeData.FReportIDString,U,4),'','','','1750101',DateTimeToFMDateTime(Now)]);
                        //Reformat the resulting report text, cuz it will have report-line#^ at the beginning of each returned line
                        self.ReformatReportText(slListviewReportText, RPCBrokerV.Results, thisIFN); //slListviewReportText comes back loaded with reformatted report text
                        end
                      else
                        begin
                        //It's a "flat" report, not a listview type, so just grab the resulting report text, and finish this routine as usual
                        isListViewType := false;
                        Delay(self.FSearchPriority);
                        CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(nodeData.FReportIDString,U,1) + ':' + Piece(nodeData.FReportIDString,U,2) + '~' + Piece(nodeData.FReportIDString,U,4),'','','','1750101',DateTimeToFMDateTime(Now)]);
                        end;
                    end;
                  ADVANCED_SEARCH:
                    begin
                    thisIFN := Piece(nodeData.FReportIDString,U,11);
                      if self.ReportIsListViewType(thisIFN) then
                        begin
                        slListviewReportText := TStringList.Create;
                        isListViewType := true;
                        Delay(self.FSearchPriority);
                        CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(nodeData.FReportIDString,U,1) + ':' + Piece(nodeData.FReportIDString,U,2) + '~' + Piece(nodeData.FReportIDString,U,4),'','','', ordbStartDateReportsAdv.FMDateTime, ordbEndDateReportsAdv.FMDateTime]);
                        //Reformat the resulting report text, cuz it will have report-line#^ at the beginning of each returned line
                        self.ReformatReportText(slListviewReportText, RPCBrokerV.Results, thisIFN); //slListviewReportText comes back loaded with reformatted report text
                        end
                      else
                        begin
                        //It's a "flat" report, not a listview type, so just grab the resulting report text, and finish this routine as usual
                        isListViewType := false;
                        Delay(self.FSearchPriority);
                        CallV('ORWRP REPORT TEXT', [self.PatientIEN, Piece(nodeData.FReportIDString,U,1) + ':' + Piece(nodeData.FReportIDString,U,2) + '~' + Piece(nodeData.FReportIDString,U,4),'','','', ordbStartDateReportsAdv.FMDateTime, ordbEndDateReportsAdv.FMDateTime]);
                        end
                    end;
                end;

        stUpdateContext(origContext);

        if isListViewType then
          begin
          for i := 0 to slListviewReportText.Count - 1 do
            if slListviewReportText[i] <> '' then
              reDetail.Lines.Add(slListviewReportText[i]);
          end
        else
          begin
          for i := 0 to RPCBrokerV.Results.Count - 1 do
            if RPCBrokerV.Results[i] <> '' then
              reDetail.Lines.Add(RPCBrokerV.Results[i]);
          end;

        LoadSearchTerms(Sender, parentData);
        BoldSearchTerms(Sender);
        vSearchTree.SetFocus; //set focus back to the Tree so we can use KeyDown again, on the tree

        if slTempList <> nil then
          slTempList.Free;

        if slListviewReportText <> nil then
          slListviewReportText.Free;
        end;

        HideLoadingProgress();
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' vSearchTreeClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.vSearchTreeCollapsing(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
begin
  vSearchTree.SetFocusedNode(nil); //Moved procedure SetFocusedNode() in class TBaseVirtualTree to public from private
end;

procedure TfrmSearchCriteria.vSearchTreeExpanding(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var Allowed: Boolean);
begin
  vSearchTree.SetFocusedNode(nil); //Moved procedure SetFocusedNode() in class TBaseVirtualTree to public from private
end;

procedure TfrmSearchCriteria.vSearchTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
var
  Data: PTreeData;
begin
  try
    Data := vSearchTree.GetNodeData(Node);
    CellText := Data^.FCaption;

    case Column of
      0: Text := Data.FCaption;
      //1: Text := Data.FColumn1;
    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' vSearchTreeGetText()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.vSearchTreeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  try
    inherited;
    if Key in [VK_UP, VK_DOWN] then
      begin
      self.ThisNode := vSearchTree.FocusedNode;
      vSearchTreeClick(vSearchTree);
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' vSearchTreeKeyUp()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.vSearchTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  nodeTop: integer;
begin
  try
    //Also See: Top of procedure TfrmSearchCriteria.vSearchTreeClick()
    self.ThisNode := vSearchTree.GetNodeAt(X, Y, true, nodeTop);
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' vSearchTreeMouseDown()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.vSearchTreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
{ TODO : Apparently, this procedure is not working.  Need to look into it. }
begin
  try
    case Column of
      0: begin
         TargetCanvas.Font.Style := Font.Style + [fsBold];
         TargetCanvas.Font.Color := clBlue;
         end;
      1: begin
         TargetCanvas.Font.Style := Font.Style + [];
         TargetCanvas.Font.Color := clBlack;
         end;
    end;
    vSearchTree.Refresh;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' vSearchTreePaintText()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.SetPatientIEN(Value: string);
var
  x: string;
begin
  try
   fPatientIEN := Value;
   /// debug ///
   //showmessage('SetPatientIEN - fSearchCriteria.origContext: ' + fSearchCriteria.origContext);
   //Exit;
   /// debug ///

   ORNet.AuthorizedOption(SEARCH_TOOL_CONTEXT);
   stUpdateContext(SEARCH_TOOL_CONTEXT);
   {//debug
   if stUpdateContext(SEARCH_TOOL_CONTEXT) then
    showmessage('true')
   else
    showmessage('false');
   }
   x := sCallV('ORWPT SELECT', [fPatientIEN]);
   stUpdateContext(origContext);
   self.Caption := 'Patient Name: ' + Piece(x, U, 1);
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' SetPatientIEN()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.buClearConsultsAdvClick(Sender: TObject);
begin
  edConsultsSearchTermsAdv.Clear;
end;
{
procedure TfrmSearchCriteria.buClearConsultsAdvORIGClick(Sender: TObject);
begin
  edConsultsSearchTermsAdv.Clear;
end;
}
procedure TfrmSearchCriteria.buClearConsultsStdClick(Sender: TObject);
begin
  edConsultsSearchTermsStd.Clear;
end;

procedure TfrmSearchCriteria.buClearOrdersAdvClick(Sender: TObject);
begin
  edOrdersSearchTermsAdv.Clear;
end;
{
procedure TfrmSearchCriteria.buClearOrdersAdvORIGClick(Sender: TObject);
begin
  edOrdersSearchTermsAdv.Clear;
end;
}
procedure TfrmSearchCriteria.buClearOrdersStdClick(Sender: TObject);
begin
  edOrdersSearchTermsStd.Clear;
end;

procedure TfrmSearchCriteria.buClearProblemTextAdvClick(Sender: TObject);
begin
  edProblemTextSearchTermsAdv.Clear;
end;
{
procedure TfrmSearchCriteria.buClearProblemTextAdvORIGClick(Sender: TObject);
begin
  edProblemTextSearchTermsAdv.Clear;
end;
}
procedure TfrmSearchCriteria.buClearProblemTextStdClick(Sender: TObject);
begin
  edProblemTextSearchTermsStd.Clear;
end;

procedure TfrmSearchCriteria.buClearReportsAdvClick(Sender: TObject);
begin
  edReportsSearchTermsAdv.Clear;
end;
{
procedure TfrmSearchCriteria.buClearReportsAdvORIGClick(Sender: TObject);
begin
  edReportsSearchTermsAdv.Clear;
end;
}
procedure TfrmSearchCriteria.buClearReportsStdClick(Sender: TObject);
begin
  edReportsSearchTermsStd.Clear;
end;

procedure TfrmSearchCriteria.buClearTIUNotesAdvClick(Sender: TObject);
begin
  edTIUSearchTermsAdv.Clear;
end;
{
procedure TfrmSearchCriteria.buClearTIUNotesAdvORIGClick(Sender: TObject);
begin
  edTIUSearchTermsAdv.Clear;
end;
}
procedure TfrmSearchCriteria.buClearTIUNotesStdClick(Sender: TObject);
begin
  edTIUSearchTermsStd.Clear;
end;

procedure TfrmSearchCriteria.buCloseClick(Sender: TObject);
begin
  try
    self.Close;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buCloseClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.buLoadCancelClick(Sender: TObject);
begin
  self.UpdateStatusBarMessage(PROCESSING_CANCELLING);
  self.LoadCancelled := true;
end;
{
procedure TfrmSearchCriteria.buLoadCancelORIGClick(Sender: TObject);
begin
  self.UpdateStatusBarMessage(PROCESSING_CANCELLING);
  self.LoadCancelled := true;
end;
}
procedure TfrmSearchCriteria.LoadAdvancedSearchTerms(thisSelectedSearchName: string);
var
  i: integer;
begin
  try
    stUpdateContext(SEARCH_TOOL_CONTEXT);
    CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + thisSelectedSearchName]);
    stUpdateContext(origContext);
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadAdvancedSearchTerms(), in ' + CRLF +
                 'call to DSIWA XPAR GET WP' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

  try
    for i := 0 to RPCBroker.Results.Count - 1 do
      begin
      //This is where we load the search terms into the corresponding GUI components
        case i of
          0:  rgPriority.ItemIndex                    := strToInt(RPCBroker.Results[i]); //cpu priority
          1:	edTIUSearchTermsAdv.Text                := RPCBroker.Results[i]; //search terms
          2:	rgTIUNoteOptionsAdv.ItemIndex           := strToInt(RPCBroker.Results[i]); //filter by
          3:  rgSortByAdv.ItemIndex                   := strToInt(RPCBroker.Results[i]); //sort by
          4:	cbIncludeAddendaAdv.Checked             := StrToBool(RPCBroker.Results[i]); //include Addenda
          5:	seTIUMaxAdv.Value                       := strToInt(RPCBroker.Results[i]);
          6:	cbDocumentClassAdv.ItemIndex            := strToInt(RPCBroker.Results[i]);
          7:  ordbStartDateTIUAdv.FMDateTime          := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          8:  ordbEndDateTIUAdv.FMDateTime            := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          9:	edProblemTextSearchTermsAdv.Text        := RPCBroker.Results[i];
          10:	seProblemTextMaxAdv.Value               := strToInt(RPCBroker.Results[i]);
          11: ordbStartDateProblemTextAdv.FMDateTime  := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          12: ordbEndDateProblemTextAdv.FMDateTime    := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          13:	edConsultsSearchTermsAdv.Text           := RPCBroker.Results[i];
          14:	seConsultsMaxAdv.Value                  := strToInt(RPCBroker.Results[i]);
          15: ordbStartDateConsultsAdv.FMDateTime     := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          16: ordbEndDateConsultsAdv.FMDateTime       := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          17:	edOrdersSearchTermsAdv.Text             := RPCBroker.Results[i];
          18:	seOrdersMaxAdv.Value                    := strToInt(RPCBroker.Results[i]);
          19: ordbStartDateOrdersAdv.FMDateTime       := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          20: ordbEndDateOrdersAdv.FMDateTime         := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i]));
          21:	edReportsSearchTermsAdv.Text            := RPCBroker.Results[i];
          22:	seReportsMaxAdv.Value                   := strToInt(RPCBroker.Results[i]);
          //23: ordbStartDateReportsAdv.FMDateTime      := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i])); //orig
          //24: ordbEndDateReportsAdv.FMDateTime        := DateTimeToFMDateTime(strToDate(RPCBroker.Results[i])); //orig
          23: ordbStartDateReportsAdv.Text            := FormatFMDateTimeStr('mm/dd/yy',RPCBroker.Results[i]);
          24: ordbEndDateReportsAdv.Text              := FormatFMDateTimeStr('mm/dd/yy',RPCBroker.Results[i]);
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' LoadAdvancedSearchTerms()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.LoadStandardSearchTerms(thisSelectedSearchName: string);
var
  i: integer;
begin
  stUpdateContext(SEARCH_TOOL_CONTEXT);
  CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + thisSelectedSearchName]);
  stUpdateContext(origContext);
  for i := 0 to RPCBroker.Results.Count - 1 do
    begin
    //This is where we load the search terms into the corresponding GUI components
      case i of
        0:  rgPriority.ItemIndex              := strToInt(RPCBroker.Results[i]); //cpu priority
        1:	edTIUSearchTermsStd.Text          := RPCBroker.Results[i]; //search terms
        2:	rgTIUNoteOptionsStd.ItemIndex     := strToInt(RPCBroker.Results[i]); //filter by
        3:  rgSortByStd.ItemIndex             := strToInt(RPCBroker.Results[i]); //sort by
        4:	cbIncludeAddendaStd.Checked       := StrToBool(RPCBroker.Results[i]); //include Addenda
        5:	seTIUMaxStd.Value                 := strToInt(RPCBroker.Results[i]);
        6:	cbDocumentClassStd.ItemIndex      := strToInt(RPCBroker.Results[i]);
        7:	edProblemTextSearchTermsStd.Text  := RPCBroker.Results[i];
        8:	seProblemTextMaxStd.Value         := strToInt(RPCBroker.Results[i]);
        9:	edConsultsSearchTermsStd.Text     := RPCBroker.Results[i];
        10:	seConsultsMaxStd.Value            := strToInt(RPCBroker.Results[i]);
        11:	edOrdersSearchTermsStd.Text       := RPCBroker.Results[i];
        12:	seOrdersMaxStd.Value              := strToInt(RPCBroker.Results[i]);
        13:	edReportsSearchTermsStd.Text      := RPCBroker.Results[i];
        14:	seReportsMaxStd.Value             := strToInt(RPCBroker.Results[i]);
      end;
    end;
end;

procedure TfrmSearchCriteria.meOpenSavedSearchTermsClick(Sender: TObject);
var
  searchTerms: TStringList;
  i: integer;
  debugstr: string;
begin
  try
    frmSavedSearches := TfrmSavedSearches.Create(self);
    searchTerms := TStringList.Create;

    stUpdateContext(SEARCH_TOOL_CONTEXT);
    CallV('DSIWA XPAR GET ALL FOR ENT', ['USR~DSIWA SEARCH TOOL TERMS~B']); //according to the RPC definition, 'B' is ALWAYS used
    stUpdateContext(origContext);
    for i := 0 to RPCBroker.Results.Count - 1 do
      begin
      //Load up the list box, and eliminate the search name prefix, for display
        case pcSearch.TabIndex of
          STANDARD_SEARCH_PAGE: begin
                                frmSavedSearches.Caption := CAPTION_STANDARD;
                                if Piece(RPCBroker.Results[i], PREFIX_DELIM, 1) = STD then
                                  frmSavedSearches.lbSavedSearches.AddItem(Piece(Piece(RPCBroker.Results[i],'^',1), PREFIX_DELIM, 2),nil);
                                end;
          ADVANCED_SEARCH_PAGE: begin
                                frmSavedSearches.Caption := CAPTION_ADVANCED;
                                if Piece(RPCBroker.Results[i], PREFIX_DELIM, 1) = ADV then
                                  frmSavedSearches.lbSavedSearches.AddItem(Piece(Piece(RPCBroker.Results[i],'^',1), PREFIX_DELIM, 2),nil);
                                end;
        end;
      end;

    frmSavedSearches.ShowModal;

    //Load this search
    self.FSearchName := frmSavedSearches.SelectedSearchName;

    if Assigned(frmSavedSearches) then
      frmSavedSearches.Free;
    Application.ProcessMessages;

    //Load all the search terms fields
    case pcSearch.TabIndex of
      STANDARD_SEARCH_PAGE: LoadStandardSearchTerms(self.FSearchName);
      ADVANCED_SEARCH_PAGE: LoadAdvancedSearchTerms(self.FSearchName);
    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' meOpenSavedSearchTermsClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.CollectAdvancedSearchTerms(var thisSearchTerms: TStringList) : TStringList;
{
 Collect all Advanced Search terms into a single TStringList
}
var
  priority: integer;
  filterBy: integer;
  sortBy: integer;
  includeAddenda: integer;
  i: integer; //debug
  debugStr: string; //debug
begin
  try
    case rgPriority.ItemIndex of
      0: priority := 0;
      1: priority := 1;
    end;

    case rgTIUNoteOptionsAdv.ItemIndex of
      0: filterBy := 0;
      1: filterBy := 1;
      2: filterBy := 2;
      3: filterBy := 3;
    end;

    case rgSortByAdv.ItemIndex of
      0: sortBy := 0;
      1: sortBy := 1;
    end;

    IncludeAddenda := 0;
    if cbIncludeAddendaAdv.Checked then
      IncludeAddenda := 1;
                                             //FormatFMDateTimeStr('mm/dd/yyyy',ordbStartDateTIUAdv.FMDateTime)
    thisSearchTerms.Add(intToStr(priority));
    thisSearchTerms.Add(edTIUSearchTermsAdv.Text);
    thisSearchTerms.Add(intToStr(filterBy));
    thisSearchTerms.Add(intToStr(sortBy));
    thisSearchTerms.Add(intToStr(includeAddenda));
    thisSearchTerms.Add(floatToStr(seTIUMaxAdv.Value));
    thisSearchTerms.Add(intToStr(cbDocumentClassAdv.ItemIndex));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbStartDateTIUAdv.FMDateTime)));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbEndDateTIUAdv.FMDateTime)));
    thisSearchTerms.Add(edProblemTextSearchTermsAdv.Text);
    thisSearchTerms.Add(floatToStr(seProblemTextMaxAdv.Value));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbStartDateProblemTextAdv.FMDateTime)));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbEndDateProblemTextAdv.FMDateTime)));
    thisSearchTerms.Add(edConsultsSearchTermsAdv.Text);
    thisSearchTerms.Add(floatToStr(seConsultsMaxAdv.Value));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbStartDateConsultsAdv.FMDateTime)));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbEndDateConsultsAdv.FMDateTime)));
    thisSearchTerms.Add(edOrdersSearchTermsAdv.Text);
    thisSearchTerms.Add(floatToStr(seOrdersMaxAdv.Value));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbStartDateOrdersAdv.FMDateTime)));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbEndDateOrdersAdv.FMDateTime)));
    //thisSearchTerms.Add(cbOrderStatusAdv.Items[cbOrderStatusAdv.ItemIndex]);
    thisSearchTerms.Add(edReportsSearchTermsAdv.Text);
    thisSearchTerms.Add(floatToStr(seReportsMaxAdv.Value));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbStartDateReportsAdv.FMDateTime)));
    thisSearchTerms.Add(FormatFMDateTimeStr(DEFAULT_DATE_FORMAT, floatToStr(ordbEndDateReportsAdv.FMDateTime)));

    result := thisSearchTerms;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' CollectAdvancedSearchTerms()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.CollectStandardSearchTerms(var thisSearchTerms: TStringList) : TStringList;
var
  priority: integer;
  filterBy: integer;
  sortBy: integer;
  includeAddenda: integer;
begin
  try
    case rgPriority.ItemIndex of
      0: priority := 0;
      1: priority := 1;
    end;

    case rgTIUNoteOptionsStd.ItemIndex of
      0: filterBy := 0;
      1: filterBy := 1;
      2: filterBy := 2;
      3: filterBy := 3;
    end;

    case rgSortByStd.ItemIndex of
      0: sortBy := 0;
      1: sortBy := 1;
    end;

    IncludeAddenda := 0;
    if cbIncludeAddendaStd.Checked then
      IncludeAddenda := 1;

    thisSearchTerms.Add(intToStr(priority));
    thisSearchTerms.Add(edTIUSearchTermsStd.Text);
    thisSearchTerms.Add(intToStr(filterBy));
    thisSearchTerms.Add(intToStr(sortBy));
    thisSearchTerms.Add(intToStr(includeAddenda));
    thisSearchTerms.Add(floatToStr(seTIUMaxStd.Value));
    thisSearchTerms.Add(intToStr(cbDocumentClassStd.ItemIndex));
    thisSearchTerms.Add(edProblemTextSearchTermsStd.Text);
    thisSearchTerms.Add(floatToStr(seProblemTextMaxStd.Value));
    thisSearchTerms.Add(edConsultsSearchTermsStd.Text);
    thisSearchTerms.Add(floatToStr(seConsultsMaxStd.Value));
    thisSearchTerms.Add(edOrdersSearchTermsStd.Text);
    thisSearchTerms.Add(floatToStr(seOrdersMaxStd.Value));
    //thisSearchTerms.Add(cbOrderStatusStd.Items[cbOrderStatusStd.ItemIndex]);
    thisSearchTerms.Add(edReportsSearchTermsStd.Text);
    thisSearchTerms.Add(floatToStr(seReportsMaxStd.Value));

    result := thisSearchTerms;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' CollectStandardSearchTerms()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.CollectSearchTerms(var thisSearchTerms: TStringList) : TStringList;
{
 Collect all Standard Search terms into a single TStringList
}
begin
  try
    case pcSearch.TabIndex of
      STANDARD_SEARCH_PAGE: result := CollectStandardSearchTerms(thisSearchTerms);
      ADVANCED_SEARCH_PAGE: result := CollectAdvancedSearchTerms(thisSearchTerms);
    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' CollectSearchTerms()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.ParameterExists() : boolean;
begin
  try
    result := false;

    try
      if pcSearch.ActivePage = tsStandardSearch then
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName]);
        stUpdateContext(origContext);
        end
      else
        if pcSearch.ActivePage = tsAdvancedSearch then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName]);
          stUpdateContext(origContext);
          end;

      if Piece(RPCBrokerV.Results[0],'^',1) <> RPC_ERROR then
        result := true
      else
        result := false;
    except
      on E: EStringListError do
        result := false;
    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' ParameterExists()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.buSaveSearchTermsClick(Sender: TObject);
var
  searchTerms: TStringList;
begin
  try
    searchTerms := TStringList.Create();

    if pcSearch.ActivePage = tsStandardSearch then
      begin
      if InputQuery('Name of Standard search', 'Search names are case-sensitive' + CRLF + CRLF + 'Please enter a case-sensitive name for this search:', self.FSearchName) = true then
        begin
        if self.FSearchName = '' then
          begin
          MessageDlg('Blank search name not allowed.  Please name this search.', mtError, [mbOk], 0);
          Exit;
          end;
        end
      else
        Exit; //user clicked 'Cancel'

      CollectSearchTerms(searchTerms); //Load up this TStringList with all the search terms and filter criteria

      //Does the search name already exist?
      if ParameterExists() then
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName]);
        stUpdateContext(origContext);
        if Piece(RPCBroker.Results[0],'^',1) <> RPC_ERROR then
          begin
          if MessageDlg(self.FSearchName + ' already exists.' + CRLF + 'Do you want to overwrite ' + self.FSearchName + '?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
            begin
            stUpdateContext(SEARCH_TOOL_CONTEXT);
            //Delete the existing parameter
            CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName]);
            stUpdateContext(origContext);

            stUpdateContext(SEARCH_TOOL_CONTEXT);
            //Rewrite the parameter with same name, but different value
            CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName, searchTerms]);
            stUpdateContext(origContext);
            end
          end
        end
      else
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName, searchTerms]);
        stUpdateContext(origContext);
        if (Piece(RPCBroker.Results[0],'^',1) = RPC_ERROR) then
          MessageDlg(Piece(RPCBroker.Results.Text, '^', 2), mtError, [mbOk], 0);
        end;

      end
    else
      if pcSearch.ActivePage = tsAdvancedSearch then
        begin
        if InputQuery('Name of Advanced search', 'Search names are case-sensitive' + CRLF + CRLF + 'Please enter a case-sensitive name for this search:', self.FSearchName) = true then
          begin
          if self.FSearchName = '' then
            begin
            MessageDlg('Blank search name not allowed.  Please name this search.', mtError, [mbOk], 0);
            Exit;
            end;
          end
        else
          Exit; //user clicked 'Cancel'

        CollectSearchTerms(searchTerms);

        //Does the search name already exist?
        if ParameterExists() then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName]);
          stUpdateContext(origContext);
          if Piece(RPCBrokerV.Results[0],'^',1)  <> RPC_ERROR then  //= RPC_SUCCESS then
            begin
            if MessageDlg(self.FSearchName + ' already exists.' + CRLF + 'Do you want to overwrite ' + self.FSearchName + '?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
              begin
              //Delete the existing parameter
              stUpdateContext(SEARCH_TOOL_CONTEXT);
              CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName]);
              stUpdateContext(origContext);
              //Rewrite the parameter with same name, but different value
              stUpdateContext(SEARCH_TOOL_CONTEXT);
              CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName, searchTerms]);
              stUpdateContext(origContext);
              end
            end
          end
        else
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName, searchTerms]);
          stUpdateContext(origContext);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBroker.Results.Text, '^', 2), mtError, [mbOk], 0);
          end;
        end;

    FreeAndNil(searchTerms);
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buSaveSearchTermsClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;

procedure TfrmSearchCriteria.buSaveSearchTermsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  case pcSearch.ActivePageIndex of
    STANDARD_SEARCH_PAGE: buSaveSearchTerms.Hint:= 'Click to save all current Standard search terms.';
    ADVANCED_SEARCH_PAGE: buSaveSearchTerms.Hint:= 'Click to save all current Advanced search terms.';
  end;
end;
{
procedure TfrmSearchCriteria.buSaveSearchTermsORIGClick(Sender: TObject);
var
  searchTerms: TStringList;
begin
  try
    searchTerms := TStringList.Create();

    if pcSearch.ActivePage = tsStandardSearch then
      begin
      if InputQuery('Name of Standard search', 'Search names are case-sensitive' + CRLF + CRLF + 'Please enter a case-sensitive name for this search:', self.FSearchName) = true then
        begin
        if self.FSearchName = '' then
          begin
          MessageDlg('Blank search name not allowed.  Please name this search.', mtError, [mbOk], 0);
          Exit;
          end;
        end
      else
        Exit; //user clicked 'Cancel'

      CollectSearchTerms(searchTerms); //Load up this TStringList with all the search terms and filter criteria

      //Does the search name already exist?
      if ParameterExists() then
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName]);
        stUpdateContext(origContext);
        if Piece(RPCBroker.Results[0],'^',1) <> RPC_ERROR then
          begin
          if MessageDlg(self.FSearchName + ' already exists.' + CRLF + 'Do you want to overwrite ' + self.FSearchName + '?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
            begin
            stUpdateContext(SEARCH_TOOL_CONTEXT);
            //Delete the existing parameter
            CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName]);
            stUpdateContext(origContext);

            stUpdateContext(SEARCH_TOOL_CONTEXT);
            //Rewrite the parameter with same name, but different value
            CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName, searchTerms]);
            stUpdateContext(origContext);
            end
          end
        end
      else
        begin
        stUpdateContext(SEARCH_TOOL_CONTEXT);
        CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + self.FSearchName, searchTerms]);
        stUpdateContext(origContext);
        if (Piece(RPCBroker.Results[0],'^',1) = RPC_ERROR) then
          MessageDlg(Piece(RPCBroker.Results.Text, '^', 2), mtError, [mbOk], 0);
        end;

      end
    else
      if pcSearch.ActivePage = tsAdvancedSearch then
        begin
        if InputQuery('Name of Advanced search', 'Search names are case-sensitive' + CRLF + CRLF + 'Please enter a case-sensitive name for this search:', self.FSearchName) = true then
          begin
          if self.FSearchName = '' then
            begin
            MessageDlg('Blank search name not allowed.  Please name this search.', mtError, [mbOk], 0);
            Exit;
            end;
          end
        else
          Exit; //user clicked 'Cancel'

        CollectSearchTerms(searchTerms);

        //Does the search name already exist?
        if ParameterExists() then
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName]);
          stUpdateContext(origContext);
          if Piece(RPCBrokerV.Results[0],'^',1)  <> RPC_ERROR then  //= RPC_SUCCESS then
            begin
            if MessageDlg(self.FSearchName + ' already exists.' + CRLF + 'Do you want to overwrite ' + self.FSearchName + '?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
              begin
              //Delete the existing parameter
              stUpdateContext(SEARCH_TOOL_CONTEXT);
              CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName]);
              stUpdateContext(origContext);
              //Rewrite the parameter with same name, but different value
              stUpdateContext(SEARCH_TOOL_CONTEXT);
              CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName, searchTerms]);
              stUpdateContext(origContext);
              end
            end
          end
        else
          begin
          stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR ADD WP', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + self.FSearchName, searchTerms]);
          stUpdateContext(origContext);
          if (Piece(RPCBrokerV.Results[0],'^',1) = RPC_ERROR) then
            MessageDlg(Piece(RPCBroker.Results.Text, '^', 2), mtError, [mbOk], 0);
          end;
        end;

    FreeAndNil(searchTerms);
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buSaveSearchTermsClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmSearchCriteria.buSaveSearchTermsORIGMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  case pcSearch.ActivePageIndex of
    STANDARD_SEARCH_PAGE: buSaveSearchTerms.Hint:= 'Click to save all current Standard search terms.';
    ADVANCED_SEARCH_PAGE: buSaveSearchTerms.Hint:= 'Click to save all current Advanced search terms.';
  end;
end;

procedure TfrmSearchCriteria.buSearchTermsClick(Sender: TObject);
{
 We want Start/End date boxes to show, only on
 Advanced Search (not on Standard Search).
}
begin
  frmSearchTerms.Show; //orig
  frmSearchTerms.BringToFront;
end;

procedure TfrmSearchCriteria.buSelectReportsAdvancedClick(Sender: TObject);
begin
  try
    frmReportSelect.Show;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buSelectReportsClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
{
procedure TfrmSearchCriteria.buSelectReportsAdvancedORIGClick(Sender: TObject);
begin
  try
    frmReportSelect.Show;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buSelectReportsClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmSearchCriteria.buSelectReportsStandardClick(Sender: TObject);
begin
  try
    frmReportSelect.Show;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buSelectReportsClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.Button1Click(Sender: TObject);
begin
  popActions.Popup((self.Width div 2), self.Width div 2);
end;

procedure TfrmSearchCriteria.cbDocumentClassStdChange(Sender: TObject);
begin
  try
    case self.SearchType of
      STANDARD_SEARCH:  begin
                          case cbDocumentClassStd.ItemIndex of
                            0: self.TIUDocumentClass := PROGRESS_NOTES;
                            1: self.TIUDocumentClass := DISCHARGE_SUMMARIES;
                          end;
                        end;
      ADVANCED_SEARCH:  begin
                          case cbDocumentClassAdv.ItemIndex of
                            0: self.TIUDocumentClass := PROGRESS_NOTES;
                            1: self.TIUDocumentClass := DISCHARGE_SUMMARIES;
                          end;
                        end;
    end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' cbDocumentClassStdChange()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.cbOrderStatusAdvChange(Sender: TObject);
begin
  self.OrderStatus := cbOrderStatusAdv.ItemIndex + 1;
end;

procedure TfrmSearchCriteria.cbOrderStatusAdvORIGChange(Sender: TObject);
begin
  self.OrderStatus := cbOrderStatusAdv.ItemIndex + 1;
end;

procedure TfrmSearchCriteria.cbOrderStatusStdChange(Sender: TObject);
begin
  self.OrderStatus := cbOrderStatusStd.ItemIndex + 1;
end;

procedure TfrmSearchCriteria.meFindClick(Sender: TObject);
begin
  dlgFind.Position := Point(((self.Left + self.Width) div 2), (self.Height div 2)); //screen position of the Find dialog
  dlgFind.Execute;
end;

procedure TfrmSearchCriteria.dlgFindFind(Sender: TObject);
var
  FoundAt: LongInt;
  StartPos, ToEnd: Integer;
begin
  with reDetail do
  begin
    //begin the search after the current selection if there is one. Otherwise, begin at the start of the text
    if reDetail.SelLength <> 0 then
      StartPos := SelStart + reDetail.SelLength
    else
      StartPos := 0;

    //ToEnd is the length from StartPos to the end of the text in the rich edit control
    ToEnd := Length(reDetail.Text) - StartPos;

    if (frWholeWord in dlgFind.Options) and (not(frMatchCase in dlgFind.Options)) then
      FoundAt := FindText(dlgFind.FindText, StartPos, ToEnd, [stWholeWord])
    else
    if (not(frWholeWord in dlgFind.Options)) and (frMatchCase in dlgFind.Options) then
      FoundAt := FindText(dlgFind.FindText, StartPos, ToEnd, [stMatchCase])
    else
      if (frWholeWord in dlgFind.Options) and (frMatchCase in dlgFind.Options) then
        FoundAt := FindText(dlgFind.FindText, StartPos, ToEnd, [stWholeWord, stMatchCase])
    else
      FoundAt := FindText(dlgFind.FindText, StartPos, ToEnd, []);

    if FoundAt <> -1 then
    begin
      reDetail.SetFocus;
      SelStart := FoundAt;
      reDetail.SelLength := Length(dlgFind.FindText);
      reDetail.Perform(EM_SCROLLCARET, 0, 0); //scroll the Detail pane to the position of the found search term
    end;
  end;
end;

procedure TfrmSearchCriteria.FormActivate(Sender: TObject);
begin
  try
    //SaveContext(); //<<<<<<<<< BUG FIX 20121004 - commented >>>>>>>>>>>
    //LoadReportIDList();
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.FormActivate()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: longint;
  ARecord: PWordRecord;
begin
  try

    stUpdateContext(origContext);

    if Assigned(self.slSearchTerms) then
      self.slSearchTerms.Free;

    if Assigned(self.slSearchResults) then
      self.slSearchResults.Free;

    ////////////////////////////////////////////////////
    //Cleanup and Free the TList we used for Deep Search
    //for i := 0 to (self.WordList.Count - 1) do  //<-------- Memory Leak:  Arrrrrrrgh!
    for i := (self.WordList.Count - 1) downto 0 do   //<--------- Correct way
     begin
     ARecord := PWordRecord(self.WordList.Items[i]);
     Dispose(ARecord);
     end;
    self.WordList.Free;
    ////////////////////////////////////////////////////

    try
      if (vSearchTree <> nil) then
        begin
        vSearchTree.BeginUpdate;
        vSearchTree.Clear; //Delete all nodes (VirtualTreeview Tutorial pg 28, Sec. 7.9)
        vsearchTree.EndUpdate;
        end;
    except
      on E: Exception do
        MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.FormClose()' + CRLF +
          ' while attempting to clear vSearchTree.' + CRLF +
          E.Message, mtInformation, [mbOk], 0);
    end;

    Application.ProcessMessages;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.FormClose()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

function TfrmSearchCriteria.LoadReportIDList() : integer;
var
  i: integer;
  j: integer;
  debugStr: string; //debug
  slTempList: TStringList;
begin
  try
    self.ReportIDList.Clear;
    slTempList := TStringList.Create;
    
    stUpdateContext(SEARCH_TOOL_CONTEXT);
    if pcSearch.ActivePage = tsStandardSearch then
      begin
      CallV('DSIWA XPAR GET ALL FOR ENT', ['USR~DSIWA SEARCH TOOL REPORTS~B']); //according to the RPC definition, 'B' is ALWAYS used
      if RPCBrokerV.Results.Count > 0 then
        begin
        for i := 0 to RPCBrokerV.Results.Count - 1 do
        slTempList.Add(RPCBrokerV.Results[i]);
        end;

      for i := 0 to slTempList.Count - 1 do
        begin
        if Pos(STD_PREFIX, slTempList[i]) > 0 then
          begin
          CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + Piece(slTempList[i],'^',1)]);
          if RPCBrokerV.Results.Count > 0 then
            self.ReportIDList.Add(RPCBrokerV.Results[0]);
          end;
        end;
      end
    else
      if pcSearch.ActivePage = tsAdvancedSearch then
        begin
        CallV('DSIWA XPAR GET ALL FOR ENT', ['USR~DSIWA SEARCH TOOL REPORTS~B']); //according to the RPC definition, 'B' is ALWAYS used
        if RPCBrokerV.Results.Count > 0 then
          begin
          for i := 0 to RPCBrokerV.Results.Count - 1 do
          slTempList.Add(RPCBrokerV.Results[i]);
          end;

        for i := 0 to slTempList.Count - 1 do
          begin
          if Pos(ADV_PREFIX, slTempList[i]) > 0 then
            begin
            CallV('DSIWA XPAR GET WP', ['USR~DSIWA SEARCH TOOL REPORTS~' + Piece(slTempList[i],'^',1)]);
            if RPCBrokerV.Results.Count > 0 then
              self.ReportIDList.Add(RPCBrokerV.Results[0]);
            end;
          end;
        end;

    if slTempList <> nil then
      slTempList.Free;

    stUpdateContext(origContext);
    result := self.ReportIDList.Count;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.LoadReportIDList()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.FormCreate(Sender: TObject);
begin
  try
    Application.HintHidePause:=10000; //10 second hint delay 

    self.Height := FORM_MAX_HEIGHT;
    self.Width := FORM_MAX_WIDTH;
    pcSearch.ActivePage := tsStandardSearch;
    self.FBoldedSearchTermColor := DEFAULT_BOLD_SEARCH_TERM_COLOR;
    sbStatusBar.Panels[3].Text := TOTAL_FOUND;
  
    slLastBrokerCall := TStringList.Create;
    frmBrokerCallHistory := TfrmBrokerCallHistory.Create(Application);
    self.Caption := CAPTION_PATIENT_RECORD_SEARCH;
    vSearchTree.NodeDataSize := SizeOf(TTreeData);

    DSSAboutDlg := TDSSAboutDlg.Create(self);

    //User Story 36: Default the Advances Search end-dates to TODAY
    ordbStartDateTIUAdv.Format := DEFAULT_DATE_FORMAT;
    ordbStartDateProblemTextAdv.Format := DEFAULT_DATE_FORMAT;
    ordbStartDateConsultsAdv.Format := DEFAULT_DATE_FORMAT;
    ordbStartDateOrdersAdv.Format := DEFAULT_DATE_FORMAT;
    ordbStartDateReportsAdv.Format := DEFAULT_DATE_FORMAT;
    ordbEndDateTIUAdv.Format := DEFAULT_DATE_FORMAT;
    ordbEndDateProblemTextAdv.Format := DEFAULT_DATE_FORMAT;
    ordbEndDateConsultsAdv.Format := DEFAULT_DATE_FORMAT;
    ordbEndDateOrdersAdv.Format := DEFAULT_DATE_FORMAT;
    ordbEndDateReportsAdv.Format := DEFAULT_DATE_FORMAT;

    rgPriority.ItemIndex := 0; //Default the search priority to CPRS
    rgPriorityClick(nil);

    rgTIUNoteOptionsStd.ItemIndex := 0; //Default to Signed Notes (All)
    rgTIUNoteOptionsAdv.ItemIndex := 3; //Default to Signed Notes by Date Range

    rgSortByStd.ItemIndex := 0; //Default to Descending
    rgSortByAdv.ItemIndex := 0; //Default to Descending

    cbOrderStatusStd.ItemIndex := 0; //default to Active
    cbOrderStatusAdv.ItemIndex := 0; //default to Active

    self.buSearchTerms.Enabled := true;

    //Assign Standard hints to Advanced hints for visual components.
    //This way, whatever hints you hardcode into the Hint properties
    //of components on the Standard page, also gets assigned to the
    //Hint properties of components on the Advanced page.
    //Just make sure that none of the component Hints on the Standard
    //page have 'Standard'-specific terminology in their hints,
    // ...else this approach won't work correctly.
    edTIUSearchTermsAdv.Hint := edTIUSearchTermsStd.Hint;
    edProblemTextSearchTermsAdv.Hint := edProblemTextSearchTermsStd.Hint;
    edConsultsSearchTermsAdv.Hint := edConsultsSearchTermsStd.Hint;
    edOrdersSearchTermsAdv.Hint := edOrdersSearchTermsStd.Hint;
    edReportsSearchTermsAdv.Hint := edReportsSearchTermsStd.Hint;
    seTIUMaxAdv.Hint := seTIUMaxStd.Hint;
    seProblemTextMaxAdv.Hint := seProblemTextMaxStd.Hint;
    seConsultsMaxAdv.Hint := seConsultsMaxStd.Hint;
    seOrdersMaxAdv.Hint := seOrdersMaxStd.Hint;
    seReportsMaxAdv.Hint := seReportsMaxStd.Hint;
    cbOrderStatusAdv.Hint := cbOrderStatusStd.Hint;
    buSelectReportsAdvanced.Hint := buSelectReportsStandard.Hint;
    rgSortByAdv.Hint := rgSortByStd.Hint;
    cbIncludeUntranscribedAdv.Hint := cbIncludeUntranscribedStd.Hint;
    cbIncludeAddendaAdv.Hint := cbIncludeAddendaStd.Hint;
    cbDocumentClassAdv.Hint := cbDocumentClassStd.Hint;

    reDetail.PopupMenu := popActions;

    if not Assigned(frmSearchTerms) then
      frmSearchTerms := TfrmSearchTerms.Create(self);

    if not Assigned(frmQuickSearch) then
      frmQuickSearch := TfrmQuickSearch.Create(self);

    if not Assigned(frmReportSelect) then
      frmReportSelect := TfrmReportSelect.Create(self);

    if not Assigned(self.ReportIDList) then
      self.ReportIDList := TStringList.Create;

    if not Assigned(self.slReportText) then
      self.slReportText := TStringList.Create;

    if vSearchTree <> nil then
      begin
      vSearchTree.BeginUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
      vSearchTree.Clear;
      vSearchTree.EndUpdate; //see Treeview_Tutorial 7.9 Delete All Nodes, pg 28
      end;

    pbReportLoading.Visible := false;

  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.FormCreate()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.FormDeactivate(Sender: TObject);
begin
  stUpdateContext(origContext);
end;

procedure TfrmSearchCriteria.FormDestroy(Sender: TObject);
begin
  try
    if frmSearchTerms <> nil then
      frmSearchTerms.Free;
      
    if frmQuickSearch <> nil then
      frmQuickSearch.Free;

    if frmReportSelect <> nil then
      frmReportSelect.Free;

    if self.ReportIDList <> nil then
      self.ReportIDList.Free;

    if self.slReportText <> nil then
      self.slReportText.Free;

    if DSSAboutDlg <> nil then
      DSSAboutDlg.Free;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.FormDestroy', mtWarning, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if reDetail.Focused then
    case Key of
      VK_TAB:
        begin
        if not (ssShift in Shift) then
          begin
          if sbCancel.Enabled then
            //sbCancel.SetFocus //Can't do this with JEDI TJvTransparentButton
          end
        else
          vSearchTree.SetFocus;
        end;
    end;

  if vSearchTree.Focused then
    case Key of
      VK_ESCAPE:
        begin
          buLoadCancelClick(nil);
          Application.ProcessMessages;
        end;
    end;
end;

procedure TfrmSearchCriteria.FormResize(Sender: TObject);
begin
  if self.Height > FORM_MAX_HEIGHT then
    self.Height := FORM_MAX_HEIGHT;

  if self.Width > FORM_MAX_WIDTH then
    self.Width := FORM_MAX_WIDTH;

  sbStatusBar.Panels[4].Text := intToStr(self.Height) + ' x ' + intToStr(self.Width);
end;

procedure TfrmSearchCriteria.EnableAllSearchSections;
//User Story #32: If user has COR on Page 4 of Edit and Existing User (terminal) then
// they get access to all the search sections.  Note that if user
// has both COR *and* RPT, this is redundant, and they get all access.
begin
  gbTIUNotes.Enabled := true;
  gbProblemText.Enabled := true;
  gbConsults.Enabled := true;
  gbOrders.Enabled := true;
  gbReports.Enabled := true;
end;

procedure TfrmSearchCriteria.EnableReportsSearchSectionOnly;
//User Story #32: If user has only RPT on Page 4 of Edit and Existing User (terminal) then
// they get access to the Reports search section, only.
begin
  gbTIUNotes.Enabled := false;
  gbProblemText.Enabled := false;
  gbConsults.Enabled := false;
  gbOrders.Enabled := false;
  gbReports.Enabled := true;
end;

procedure TfrmSearchCriteria.FormShow(Sender: TObject);
var
  userInfo: string;
  HasCorTabs: string;
  HasRptTab: string;
begin
  try
    sbSearch.Enabled := true;

    //Initialize the document class
    cbDocumentClassStd.ItemIndex := 0;
    cbDocumentClassStdChange(nil); //force it to take an initial value
    cbDocumentClassAdv.ItemIndex := 0;
    cbDocumentClassStdChange(nil); //force it to take an initial value

    if pcSearch.ActivePage = tsStandardSearch then
      begin
      SearchType := STANDARD_SEARCH;
      meWholeWords.Enabled := true;
      meCaseSensitive.Enabled := true;
      self.OrderStatus := cbOrderStatusStd.ItemIndex + 1;
      end;

    if pcSearch.ActivePage = tsAdvancedSearch then
      begin
      SearchType := ADVANCED_SEARCH;
      meWholeWords.Enabled := true;
      meCaseSensitive.Enabled := true;
      self.OrderStatus := cbOrderStatusStd.ItemIndex + 1;
      end;

    if pcSearch.ActivePage = tsSearchResults then
      begin
      meWholeWords.Enabled := false;
      meCaseSensitive.Enabled := false;
      end;

    //User Story 36: Default the Advances Search end-dates to TODAY
    ordbEndDateTIUAdv.Text := DateToStr(Date);
    ordbEndDateProblemTextAdv.Text := DateToStr(Date);
    ordbEndDateConsultsAdv.Text := DateToStr(Date);
    ordbEndDateOrdersAdv.Text := DateToStr(Date);
    ordbEndDateReportsAdv.Text := DateToStr(Date);

    //vSearchTree.Clear; //moved to FormCreate()
    reDetail.Clear;
    //TStringList used to contain our Search Terms.
    // We'll create it here, and use it as needed, then Free it on FormClose;
    self.slSearchTerms := TStringList.Create();

    self.WordList := TList.Create;
    self.slSearchResults := TStringList.Create;

    pcSearch.ActivePage := tsStandardSearch; //default to Standard Search page
    buSearchTerms.Enabled := true;
    buQuickSearch.Enabled := true;
    sbClearAllSearchCriteria.Enabled := true;
    buSaveSearchTerms.Enabled := true;

    //User Story 32: Limit User-access according to COR and RPT params
    /// debug ///
    //showmessage('FormShow - fSearchCriteria.origContext: ' + fSearchCriteria.origContext);
    //Exit;
    /// debug ///

    stUpdateContext(SEARCH_TOOL_CONTEXT);
    userInfo := sCallV('ORWU USERINFO',[]);
    stUpdateContext(origContext);
    HasCorTabs := Piece(userInfo, '^', 22);
    HasRptTab := Piece(userInfo, '^', 23);
    if ( ((HasCorTabs = '1') and (HasRptTab <> '1')) or ((HasCorTabs = '1') and (HasRptTab = '1')) )then
      EnableAllSearchSections
    else
      if ((HasCorTabs <> '1') and (HasRptTab = '1')) then
        EnableReportsSearchSectionOnly;

    self.DeepSearch := true; //default

    //Enable TIU ORDateBox's ONLY if 'Signed Notes by Date Range' is selected
    if rgTIUNoteOptionsAdv.ItemIndex = 3 then
      begin
      ordbStartDateTIUAdv.Enabled := true;
      ordbEndDateTIUAdv.Enabled := true;
      end
    else
      begin
      ordbStartDateTIUAdv.Enabled := false;
      ordbEndDateTIUAdv.Enabled := false;
      end;

    //buSearchTerms.SetFocus; //Does not work with JEDI components
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchCriteria.FormShow' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSearchCriteria.LabeledEdit1Click(Sender: TObject);
begin
//with calApptRng do
  if calApptRng.Execute then
    TLabeledEdit(Sender).Text := calApptRng.RelativeTime
end;

procedure TfrmSearchCriteria.sbtnCloseClick(Sender: TObject);
begin
 Visible := false;
end;

end.
