unit fQuickSearch;
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
  Dialogs, StdCtrls, ORDtTm, ExtCtrls, ComCtrls,
  JvExControls, JvButton, JvTransparentButton;

type
  TfrmQuickSearch = class(TForm)
    Panel1: TPanel;
    Image2: TImage;
    ordbStartDate: TORDateBox;
    Panel2: TPanel;
    Image3: TImage;
    meSearchTerms: TRichEdit;
    laInstructions: TMemo;
    laStartDate: TStaticText;
    lammddyy: TStaticText;
    StaticText3: TStaticText;
    ordbEndDate: TORDateBox;
    buClear: TJvTransparentButton;
    buSearch: TJvTransparentButton;
    buClose: TJvTransparentButton;
    //procedure buSearchORIGClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    //procedure buClearORIGClick(Sender: TObject);
    //procedure buCloseORIGClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure buClearClick(Sender: TObject);
    procedure buSearchClick(Sender: TObject);
    procedure buCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    function StripCRLF(thisSearchTermString: TCaption) : string;
  end;

const
  CRLF = #13#10;
  INSTRUCTIONS = ' Quick Search allows you to search all document types from the specified Start Date, until Today.' + CRLF +
                 ' The search term(s) you enter will be applied to All document types.' + CRLF + CRLF +
                 ' Enter all desired search terms in the ''Search Terms'' box below, with each term separated from' + CRLF +
                 '  adjacent terms by one or more spaces.'; // + CRLF +
                 //' 3) Indicate the search area(s) of interest by checking one or more checkboxes in the ''Apply To'' box.' + CRLF +
                 //' 4) Click the ''Apply Search Terms'' button.';

  DEFAULT_DATE_FORMAT = '(mm/dd/yyyy)';
  DATE_FORMAT = 'mm/dd/yyyy';
  SEARCH_CANCELLED = 'Search Cancelled.';
  NO_SEARCH_TERMS = 'Search terms are missing.';
  INVALID_START_DATE = 'The Start Date is invalid.';

var
  frmQuickSearch: TfrmQuickSearch;

implementation

uses fSearchCriteria, ORFn;

{$R *.dfm}

var
  thisfrmSearchCriteria: fSearchCriteria.TfrmSearchCriteria;

procedure TfrmQuickSearch.buClearClick(Sender: TObject);
begin
  meSearchTerms.Clear;
end;
{
procedure TfrmQuickSearch.buClearORIGClick(Sender: TObject);
begin
  meSearchTerms.Clear;
end;
}
procedure TfrmQuickSearch.buCloseClick(Sender: TObject);
begin
  Close;
  Application.ProcessMessages;
end;
{
procedure TfrmQuickSearch.buCloseORIGClick(Sender: TObject);
begin
  Close;
  Application.ProcessMessages;
end;
}
function TfrmQuickSearch.StripCRLF(thisSearchTermString: TCaption) : string;
var
  i: integer;
begin
  for i := 0 to Length(thisSearchTermString) do
    begin
    //replace any carriage returns with space
    if thisSearchTermString[i] = #13 then
      thisSearchTermString[i] := #32;
    //replace any line feeds with space
    if thisSearchTermString[i] = #10 then
      thisSearchTermString[i] := #32;
    end;
  result := thisSearchTermString;
end;

function IsValidDate(thisDateString : string; var thisDateTime : TDateTime): boolean;
var
  thisFMDateTime: TFMDateTime;
begin
  result := true;
    try
      thisDateTime := StrToDateTime(thisDateString);
      thisFMDateTime := DateTimeToFMDateTime(thisDateTime);
      if ((not (thisFMDateTime >= 1900101)) and (not (thisFMDateTime <= DateTimeToFMDateTime(Now)))) then
        result := false;
    except
      on EConvertError do
        begin
        thisDateTime := 0;
        result := false;
        end;
    end;
end;

procedure TfrmQuickSearch.buSearchClick(Sender: TObject);
var
  thisDateTime: TDateTime;
begin
  //QuickSearch - Standard Tab
  if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 0 then
    begin
    if meSearchTerms.Text = '' then
      begin
      MessageDlg(SEARCH_CANCELLED + CRLF + NO_SEARCH_TERMS, mtInformation, [mbOk], 0);
      meSearchTerms.SetFocus;
      Exit;
      end;

    thisfrmSearchCriteria.SearchType := STANDARD_SEARCH;
    thisfrmSearchCriteria.pcSearch.ActivePage := thisfrmSearchCriteria.tsStandardSearch;

    //Apply search terms to Standard Search edit boxes
    thisfrmSearchCriteria.edTIUSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text);
    thisfrmSearchCriteria.edProblemTextSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text);
    thisfrmSearchCriteria.edConsultsSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text);
    thisfrmSearchCriteria.edOrdersSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text);
    thisfrmSearchCriteria.edReportsSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text);
    end
  else
    //QuickSearch - Advanced Tab
    if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 1 then
      begin
      if meSearchTerms.Text = '' then
        begin
        MessageDlg(SEARCH_CANCELLED + CRLF + NO_SEARCH_TERMS, mtInformation, [mbOk], 0);
        meSearchTerms.SetFocus;
        Exit;
        end;

      if (not IsValidDate(ordbStartDate.Text, thisDateTime)) then
        begin
        MessageDlg(SEARCH_CANCELLED + CRLF + INVALID_START_DATE, mtInformation, [mbOk], 0);
        meSearchTerms.SetFocus;
        Exit;
        end;

      thisfrmSearchCriteria.SearchType := ADVANCED_SEARCH;
      thisfrmSearchCriteria.pcSearch.ActivePage := thisfrmSearchCriteria.tsAdvancedSearch;

      if self.ordbStartDate.Text <> '' then
        begin
        thisfrmSearchCriteria.rgTIUNoteOptionsAdv.ItemIndex := 3; //TIU Signed Notes by Date Range, checked
        thisfrmSearchCriteria.rgSortByAdv.ItemIndex := 1; //Descending
        thisfrmSearchCriteria.cbIncludeAddendaAdv.Checked := true; //Include Addenda

        //Apply Start Dates - Advanced search
        thisfrmSearchCriteria.ordbStartDateTIUAdv.Text := self.ordbStartDate.Text;
        thisfrmSearchCriteria.ordbStartDateProblemTextAdv.Text := self.ordbStartDate.Text;
        thisfrmSearchCriteria.ordbStartDateConsultsAdv.Text := self.ordbStartDate.Text;
        thisfrmSearchCriteria.ordbStartDateOrdersAdv.Text := self.ordbStartDate.Text;
        thisfrmSearchCriteria.ordbStartDateReportsAdv.Text := self.ordbStartDate.Text;
        //Apply End Dates - Advanced search
        thisfrmSearchCriteria.ordbEndDateTIUAdv.Text := self.ordbEndDate.Text;
        thisfrmSearchCriteria.ordbEndDateProblemTextAdv.Text := self.ordbEndDate.Text;
        thisfrmSearchCriteria.ordbEndDateConsultsAdv.Text := self.ordbEndDate.Text;
        thisfrmSearchCriteria.ordbEndDateOrdersAdv.Text := self.ordbEndDate.Text;
        thisfrmSearchCriteria.ordbEndDateReportsAdv.Text := self.ordbEndDate.Text;
        //Apply search terms to Advanced Search edit boxes
        thisfrmSearchCriteria.edTIUSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text);
        thisfrmSearchCriteria.edProblemTextSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text);
        thisfrmSearchCriteria.edConsultsSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text);
        thisfrmSearchCriteria.edOrdersSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text);
        thisfrmSearchCriteria.edReportsSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text);
        end;
      end;

  //self.buCloseClick(Sender);

  ///// Run the search
  thisfrmSearchCriteria.sbSearchClick(nil);

end;

procedure TfrmQuickSearch.FormCreate(Sender: TObject);
begin
  try
    thisfrmSearchCriteria := (self.Owner as TfrmSearchCriteria); //Get a pointer to the main form
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmQuickSearch.FormCreate()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

  //laInstructions.Caption := INSTRUCTIONS;
  ordbStartDate.Format := DATE_FORMAT;
  ordbEndDate.Format := DATE_FORMAT;
  ordbEndDate.Text := DateToStr(Date); //Today's date
end;

procedure TfrmQuickSearch.FormShow(Sender: TObject);
begin
  //Enable the date box only if we're on the Advanced tab
  if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 1 then
    begin
    laInstructions.SetFocus; //Jaws
    ordbStartDate.Clear;
    laStartDate.Visible := true;
    laStartDate.Enabled := true;
    lammddyy.Visible := true;
    lammddyy.Caption := DEFAULT_DATE_FORMAT;
    ordbStartDate.Visible := true;
    ordbStartDate.Enabled := true;
    end
  else
    begin
    laInstructions.SetFocus; //Jaws
    laStartDate.Visible := false;
    lammddyy.Visible := false;
    ordbStartDate.Visible := false;
    ordbStartDate.Clear;
    ordbStartDate.FMDateTime := DateTimeToFMDateTime(Date);
    //ordbStartDate.Enabled := false;
    end;
  laInstructions.SetFocus;
end;

end.
