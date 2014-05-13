unit fSearchTerms;
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
  Dialogs, StdCtrls, ExtCtrls, ORDtTm, ComCtrls, JvExStdCtrls, JvCheckBox, JvExControls,
  JvButton, JvTransparentButton, JvExExtCtrls, JvBevel;

type
  TfrmSearchTerms = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    ordbStartDate: TORDateBox;
    ordbEndDate: TORDateBox;
    Image3: TImage;
    Image2: TImage;
    meSearchTerms: TRichEdit;
    lammddyy: TStaticText;
    laInstructions: TMemo;
    laStartDate: TStaticText;
    laEndDate: TStaticText;
    StaticText1: TStaticText;
    buClear: TJvTransparentButton;
    buApply: TJvTransparentButton;
    buClose: TJvTransparentButton;
    JvBevel1: TJvBevel;
    cbTIUNotes: TJvCheckBox;
    cbProblemText: TJvCheckBox;
    cbConsults: TJvCheckBox;
    cbOrders: TJvCheckBox;
    cbReports: TJvCheckBox;
    cbALL: TJvCheckBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure buCloseClick(Sender: TObject);
    //procedure cbALLORIGClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    //procedure buApplyORIGClick(Sender: TObject);
    //procedure buClearORIGClick(Sender: TObject);
    //procedure AdvGlassButton2Click(Sender: TObject);
    procedure cbALLClick(Sender: TObject);
    procedure buClearClick(Sender: TObject);
    procedure buApplyClick(Sender: TObject);
  private
    { Private declarations }
  public
    function StripCRLF(thisSearchTermString: TCaption) : string;
  end;

const
  CRLF = #13#10;
  INSTRUCTIONS = ' 1) Enter all desired search terms in the ''Search Terms'' box below, with each term separated from' + CRLF +
                 '     adjacent terms by one or more spaces.' + CRLF +
                 ' 2) If on Advanced search tab, enter Start Date and End Date.' + CRLF +
                 ' 3) Indicate the search area(s) of interest by checking one or more checkboxes in the ''Apply To'' box.' + CRLF +
                 ' 4) Click the ''Apply Search Terms'' button.';
                 
  DEFAULT_DATE_FORMAT = '(mm/dd/yyyy)';
  DATE_FORMAT = 'mm/dd/yyyy';

var
  frmSearchTerms: TfrmSearchTerms;

implementation

uses fSearchCriteria, ORFn;

{$R *.dfm}

var
  thisfrmSearchCriteria: fSearchCriteria.TfrmSearchCriteria;

procedure TfrmSearchTerms.buClearClick(Sender: TObject);
begin
  meSearchTerms.Clear;
end;
{
procedure TfrmSearchTerms.buClearORIGClick(Sender: TObject);
begin
  meSearchTerms.Clear;
end;
}
{
procedure TfrmSearchTerms.AdvGlassButton2Click(Sender: TObject);
begin
  Close;
end;
}
function TfrmSearchTerms.StripCRLF(thisSearchTermString: TCaption) : string;
var
  i: integer;
  thisLength: integer;
begin
  thisLength := Length(thisSearchTermString);
  if thisLength > 0 then
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
    end;
  result := thisSearchTermString;
end;

procedure TfrmSearchTerms.buApplyClick(Sender: TObject);
begin
//Get a pointer to the main form
//thisfrmSearchCriteria := (self.Owner as TfrmSearchCriteria);

if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSEarchCriteria.tsAdvancedSearch then
  begin
  //Apply Start Dates - Advanced search
  if self.ordbStartDate.Text <> '' then
    begin
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.ordbStartDateTIUAdv.FMDateTime := self.ordbStartDate.FMDateTime;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.ordbStartDateProblemTextAdv.Text := self.ordbStartDate.Text;
    if cbConsults.Checked then
      thisfrmSearchCriteria.ordbStartDateConsultsAdv.Text := self.ordbStartDate.Text;
    if cbOrders.Checked then
      thisfrmSearchCriteria.ordbStartDateOrdersAdv.Text := self.ordbStartDate.Text;
    if cbReports.Checked then
      thisfrmSearchCriteria.ordbStartDateReportsAdv.Text := self.ordbStartDate.Text;
    end;

  //Apply End Dates - Advanced search
  if self.ordbEndDate.Text <> '' then
    begin
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.ordbEndDateTIUAdv.Text := self.ordbEndDate.Text;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.ordbEndDateProblemTextAdv.Text := self.ordbEndDate.Text;
    if cbConsults.Checked then
      thisfrmSearchCriteria.ordbEndDateConsultsAdv.Text := self.ordbEndDate.Text;
    if cbOrders.Checked then
      thisfrmSearchCriteria.ordbEndDateOrdersAdv.Text := self.ordbEndDate.Text;
    if cbReports.Checked then
      thisfrmSearchCriteria.ordbEndDateReportsAdv.Text := self.ordbEndDate.Text;
    end;
  end;

  //Apply Standard Search Terms
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
    begin
    //apply search terms to Standard Search edit boxes
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.edTIUSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edTIUSearchTermsStd.Clear;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.edProblemTextSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edProblemTextSearchTermsStd.Clear;
    if cbConsults.Checked then
      thisfrmSearchCriteria.edConsultsSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edConsultsSearchTermsStd.Clear;
    if cbOrders.Checked then
      thisfrmSearchCriteria.edOrdersSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edOrdersSearchTermsStd.Clear;
    if cbReports.Checked then
      thisfrmSearchCriteria.edReportsSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edReportsSearchTermsStd.Clear;
    end;

  //Apply Advanced Search Terms
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsAdvancedSearch then
    begin
    //apply search terms to Advanced Search edit boxes
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.edTIUSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edTIUSearchTermsAdv.Clear;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.edProblemTextSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edProblemTextSearchTermsAdv.Clear;
    if cbConsults.Checked then
      thisfrmSearchCriteria.edConsultsSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edConsultsSearchTermsAdv.Clear;
    if cbOrders.Checked then
      thisfrmSearchCriteria.edOrdersSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edOrdersSearchTermsAdv.Clear;
    if cbReports.Checked then
      thisfrmSearchCriteria.edReportsSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edReportsSearchTermsAdv.Clear;
    end;

  Close;
end;
{
procedure TfrmSearchTerms.buApplyORIGClick(Sender: TObject);
begin
//Get a pointer to the main form
//thisfrmSearchCriteria := (self.Owner as TfrmSearchCriteria);

if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSEarchCriteria.tsAdvancedSearch then
  begin
  //Apply Start Dates - Advanced search
  if self.ordbStartDate.Text <> '' then
    begin
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.ordbStartDateTIUAdv.FMDateTime := self.ordbStartDate.FMDateTime;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.ordbStartDateProblemTextAdv.Text := self.ordbStartDate.Text;
    if cbConsults.Checked then
      thisfrmSearchCriteria.ordbStartDateConsultsAdv.Text := self.ordbStartDate.Text;
    if cbOrders.Checked then
      thisfrmSearchCriteria.ordbStartDateOrdersAdv.Text := self.ordbStartDate.Text;
    if cbReports.Checked then
      thisfrmSearchCriteria.ordbStartDateReportsAdv.Text := self.ordbStartDate.Text;
    end;

  //Apply End Dates - Advanced search
  if self.ordbEndDate.Text <> '' then
    begin
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.ordbEndDateTIUAdv.Text := self.ordbEndDate.Text;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.ordbEndDateProblemTextAdv.Text := self.ordbEndDate.Text;
    if cbConsults.Checked then
      thisfrmSearchCriteria.ordbEndDateConsultsAdv.Text := self.ordbEndDate.Text;
    if cbOrders.Checked then
      thisfrmSearchCriteria.ordbEndDateOrdersAdv.Text := self.ordbEndDate.Text;
    if cbReports.Checked then
      thisfrmSearchCriteria.ordbEndDateReportsAdv.Text := self.ordbEndDate.Text;
    end;
  end;

  //Apply Standard Search Terms
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
    begin
    //apply search terms to Standard Search edit boxes
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.edTIUSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edTIUSearchTermsStd.Clear;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.edProblemTextSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edProblemTextSearchTermsStd.Clear;
    if cbConsults.Checked then
      thisfrmSearchCriteria.edConsultsSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edConsultsSearchTermsStd.Clear;
    if cbOrders.Checked then
      thisfrmSearchCriteria.edOrdersSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edOrdersSearchTermsStd.Clear;
    if cbReports.Checked then
      thisfrmSearchCriteria.edReportsSearchTermsStd.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edReportsSearchTermsStd.Clear;
    end;

  //Apply Advanced Search Terms
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsAdvancedSearch then
    begin
    //apply search terms to Advanced Search edit boxes
    if cbTIUNotes.Checked then
      thisfrmSearchCriteria.edTIUSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edTIUSearchTermsAdv.Clear;
    if cbProblemText.Checked then
      thisfrmSearchCriteria.edProblemTextSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edProblemTextSearchTermsAdv.Clear;
    if cbConsults.Checked then
      thisfrmSearchCriteria.edConsultsSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edConsultsSearchTermsAdv.Clear;
    if cbOrders.Checked then
      thisfrmSearchCriteria.edOrdersSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edOrdersSearchTermsAdv.Clear;
    if cbReports.Checked then
      thisfrmSearchCriteria.edReportsSearchTermsAdv.Text := self.StripCRLF(meSearchTerms.Text)
    else thisfrmSearchCriteria.edReportsSearchTermsAdv.Clear;
    end;

  Close;
end;
}
procedure TfrmSearchTerms.buCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSearchTerms.cbALLClick(Sender: TObject);
begin
  if cbALL.Checked then
    begin
    cbTIUNotes.Checked := true;
    cbProblemText.Checked := true;
    cbConsults.Checked := true;
    cbOrders.Checked := true;
    cbReports.Checked := true;
    end
  else
    begin
    cbTIUNotes.Checked := false;
    cbProblemText.Checked := false;
    cbConsults.Checked := false;
    cbOrders.Checked := false;
    cbReports.Checked := false;
    end;
end;
{
procedure TfrmSearchTerms.cbALLORIGClick(Sender: TObject);
begin
  if cbALL.Checked then
    begin
    cbTIUNotes.Checked := true;
    cbProblemText.Checked := true;
    cbConsults.Checked := true;
    cbOrders.Checked := true;
    cbReports.Checked := true;
    end
  else
    begin
    cbTIUNotes.Checked := false;
    cbProblemText.Checked := false;
    cbConsults.Checked := false;
    cbOrders.Checked := false;
    cbReports.Checked := false;
    end;
end;
}
procedure TfrmSearchTerms.FormCreate(Sender: TObject);
begin
  try
    thisfrmSearchCriteria := (self.Owner as TfrmSearchCriteria); //Get a pointer to the main form
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSearchTerms.FormCreate()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

  //laInstructions.Caption := INSTRUCTIONS;
  ordbStartDate.Format := DATE_FORMAT;
  ordbEndDate.Format := DATE_FORMAT;
  ordbEndDate.Text := DateToStr(Date);
end;

procedure TfrmSearchTerms.FormShow(Sender: TObject);
begin
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsSearchResults then
    begin
    //thisfrmSearchCriteria.buSearchTerms.Enabled := false;
    //thisfrmSearchCriteria.Enabled := false;
    end
  else
    begin
    if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
      begin
      laInstructions.SetFocus; //Jaws
      frmSearchTerms.laStartDate.Visible := false;
      frmSearchTerms.laEndDate.Visible := false;
      frmSearchTerms.ordbStartDate.Visible := false;
      frmSearchTerms.ordbEndDate.Visible := false;
      lammddyy.Visible := false;
      end;

    if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsAdvancedSearch then
      begin
      laInstructions.SetFocus; //Jaws
      frmSearchTerms.laStartDate.Visible := true;
      frmSearchTerms.laEndDate.Visible := true;
      frmSearchTerms.ordbStartDate.Visible := true;
      frmSearchTerms.ordbEndDate.Visible := true;
      frmSearchTerms.ordbStartDate.FMDateTime := DateTimeToFMDateTime(Date);
      frmSearchTerms.ordbEndDate.FMDateTime := DateTimeToFMDateTime(Date);
      lammddyy.Visible := true;
      lammddyy.Caption := DEFAULT_DATE_FORMAT;
      end;

    laInstructions.SetFocus;
    end;
end;

end.
