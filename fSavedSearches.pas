unit fSavedSearches;
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
  JvExControls, JvButton, JvTransparentButton;

type
  TfrmSavedSearches = class(TForm)
    Image3: TImage;
    lbSavedSearches: TListBox;
    Image1: TImage;
    Bevel1: TBevel;
    buDeleteAllSearches: TJvTransparentButton;
    buCancel: TJvTransparentButton;
    buDeleteAllType: TJvTransparentButton;
    buDeleteSelectedSearch: TJvTransparentButton;
    buOpenSelectedSearch: TJvTransparentButton;
    //procedure buOpenSelectedSearchORIGClick(Sender: TObject);
    procedure lbSavedSearchesDblClick(Sender: TObject);
    //procedure buCancelORIGClick(Sender: TObject);
    //procedure buDeleteSelectedSearchORIGClick(Sender: TObject);
    //procedure buDeleteAllSearchesORIGClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    //procedure buDeleteAllTypeORIGClick(Sender: TObject);
    procedure buDeleteAllTypeORIGMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure buDeleteAllSearchesClick(Sender: TObject);
    procedure buCancelClick(Sender: TObject);
    procedure buDeleteAllTypeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure buDeleteAllTypeClick(Sender: TObject);
    procedure buDeleteSelectedSearchClick(Sender: TObject);
    procedure buOpenSelectedSearchClick(Sender: TObject);
  private
    FSelectedSearchName: string;
  public
    property SelectedSearchName: string read FSelectedSearchName write FSelectedSearchName;
    procedure DisplaySavedSearches(Sender: TObject);
  end;

const
  CRLF = #13#10;

var
  frmSavedSearches: TfrmSavedSearches;

implementation

uses fSearchCriteria;

{$R *.dfm}

var
  thisfrmSearchCriteria: fSearchCriteria.TfrmSearchCriteria;

procedure TfrmSavedSearches.DisplaySavedSearches(Sender: TObject);
var
  i: integer;
begin
  try
    lbSavedSearches.Clear;
    thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
    CallV('DSIWA XPAR GET ALL FOR ENT', ['USR~DSIWA SEARCH TOOL TERMS~B']); //according to the RPC definition, 'B' is ALWAYS used
    thisfrmSearchCriteria.stUpdateContext(origContext);
    for i := 0 to thisfrmSearchCriteria.RPCBroker.Results.Count - 1 do
      begin
      //Load up the list box, eliminating the search name prefix for display purposes
        case thisfrmSearchCriteria.pcSearch.TabIndex of
          STANDARD_SEARCH_PAGE: begin
                                frmSavedSearches.Caption := 'Standard Searches';
                                if Piece(thisfrmSearchCriteria.RPCBroker.Results[i], PREFIX_DELIM, 1) = STD then
                                  frmSavedSearches.lbSavedSearches.AddItem(Piece(Piece(thisfrmSearchCriteria.RPCBroker.Results[i],'^',1), PREFIX_DELIM, 2),nil);
                                end;
          ADVANCED_SEARCH_PAGE: begin
                                frmSavedSearches.Caption := 'Advanced Searches';
                                if Piece(thisfrmSearchCriteria.RPCBroker.Results[i], PREFIX_DELIM, 1) = ADV then
                                  frmSavedSearches.lbSavedSearches.AddItem(Piece(Piece(thisfrmSearchCriteria.RPCBroker.Results[i],'^',1), PREFIX_DELIM, 2),nil);
                                end;
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' DisplaySavedSearches()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSavedSearches.buCancelClick(Sender: TObject);
begin
  Close;
end;
{
procedure TfrmSavedSearches.buCancelORIGClick(Sender: TObject);
begin
  Close;
end;
}
procedure TfrmSavedSearches.buDeleteAllSearchesClick(Sender: TObject);
begin
  try
    if MessageDlg('You are about to permanently delete ALL your saved STANDARD and ADVANCED searches.' + CRLF +
                  'Once done, this action cannot be reversed.' + CRLF + CRLF +
                  'Are you sure?', mtWarning, [mbYes,mbNo], 0) = mrYes then
      begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      CallV('DSIWA XPAR DEL ALL', ['USR~DSIWA SEARCH TOOL TERMS']);
      thisfrmSearchCriteria.stUpdateContext(origContext);
      DisplaySavedSearches(nil);
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buDeleteAllSearchesClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
{
procedure TfrmSavedSearches.buDeleteAllSearchesORIGClick(Sender: TObject);
begin
  try
    if MessageDlg('You are about to permanently delete ALL your saved STANDARD and ADVANCED searches.' + CRLF +
                  'Once done, this action cannot be reversed.' + CRLF + CRLF +
                  'Are you sure?', mtWarning, [mbYes,mbNo], 0) = mrYes then
      begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      CallV('DSIWA XPAR DEL ALL', ['USR~DSIWA SEARCH TOOL TERMS']);
      thisfrmSearchCriteria.stUpdateContext(origContext);
      DisplaySavedSearches(nil);
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buDeleteAllSearchesClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmSavedSearches.buDeleteAllTypeClick(Sender: TObject);
{
  Delete all the saved searches depending on the selected tab page
}
var
  i: integer;
begin
  try
    //Loop thru lbSavedSearches and call DSIWA XPAR DEL for each one
    if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 0 then //Standard Search page
      begin
      if MessageDlg('This action will delete ALL your Standard Searches.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
        begin
        for i := lbSavedSearches.Items.Count - 1 downto 0 do
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + lbSavedSearches.Items[i]]);
          if Piece(thisfrmSearchCriteria.RPCBroker.Results[0],'^',1) = RPC_SUCCESS then
            begin
            thisfrmSearchCriteria.stUpdateContext(origContext);
            lbSavedSearches.ItemIndex := i; //Update the list one item at a time
            lbSavedSearches.DeleteSelected; // so that the list of saved searches does not lie to us if RPC Error
            end
          else
            begin
            MessageDlg('RPC Error while attempting to delete all Standard searches', mtError, [mbOk], 0);
            Break;
            end;
          end;
        end;
      end
    else
      begin
      if MessageDlg('This action will delete ALL your Advanced Searches.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
        begin
        for i := lbSavedSearches.Items.Count - 1 downto 0 do
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + lbSavedSearches.Items[i]]);
          if Piece(thisfrmSearchCriteria.RPCBroker.Results[0],'^',1) = RPC_SUCCESS then
            begin
            thisfrmSearchCriteria.stUpdateContext(origContext);
            lbSavedSearches.ItemIndex := i; //Update the list one item at a time
            lbSavedSearches.DeleteSelected; // so that the list of saved searches does not lie to us if RPC Error
            end
          else
            begin
            MessageDlg('RPC Error while attempting to delete all Advanced searches', mtError, [mbOk], 0);
            Break;
            end;
          end;
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buDeleteAllTypeClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSavedSearches.buDeleteAllTypeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
    buDeleteAllType.Hint:= 'Delete all previously saved Standard searches.'
  else
    buDeleteAllType.Hint:= 'Delete all previously saved Advanced searches.';
end;
{
procedure TfrmSavedSearches.buDeleteAllTypeORIGClick(Sender: TObject);
  //Delete all the saved searches depending on the selected tab page
var
  i: integer;
begin
  try
    //Loop thru lbSavedSearches and call DSIWA XPAR DEL for each one
    if thisfrmSearchCriteria.pcSearch.ActivePageIndex = 0 then //Standard Search page
      begin
      if MessageDlg('This action will delete ALL your Standard Searches.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
        begin
        for i := lbSavedSearches.Items.Count - 1 downto 0 do
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + lbSavedSearches.Items[i]]);
          if Piece(thisfrmSearchCriteria.RPCBroker.Results[0],'^',1) = RPC_SUCCESS then
            begin
            thisfrmSearchCriteria.stUpdateContext(origContext);
            lbSavedSearches.ItemIndex := i; //Update the list one item at a time
            lbSavedSearches.DeleteSelected; // so that the list of saved searches does not lie to us if RPC Error
            end
          else
            begin
            MessageDlg('RPC Error while attempting to delete all Standard searches', mtError, [mbOk], 0);
            Break;
            end;
          end;
        end;
      end
    else
      begin
      if MessageDlg('This action will delete ALL your Advanced Searches.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
        begin
        for i := lbSavedSearches.Items.Count - 1 downto 0 do
          begin
          thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
          CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + lbSavedSearches.Items[i]]);
          if Piece(thisfrmSearchCriteria.RPCBroker.Results[0],'^',1) = RPC_SUCCESS then
            begin
            thisfrmSearchCriteria.stUpdateContext(origContext);
            lbSavedSearches.ItemIndex := i; //Update the list one item at a time
            lbSavedSearches.DeleteSelected; // so that the list of saved searches does not lie to us if RPC Error
            end
          else
            begin
            MessageDlg('RPC Error while attempting to delete all Advanced searches', mtError, [mbOk], 0);
            Break;
            end;
          end;
        end;
      end;
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buDeleteAllTypeClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmSavedSearches.buDeleteAllTypeORIGMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
    buDeleteAllType.Hint:= 'Delete all previously saved Standard searches.'
  else
    buDeleteAllType.Hint:= 'Delete all previously saved Advanced searches.';
end;

procedure TfrmSavedSearches.buDeleteSelectedSearchClick(Sender: TObject);
var
  i: integer;
begin
  try
    if lbSavedSearches.ItemIndex = -1 then
      begin
      MessageDlg('No search selected.' + CRLF + 'Please select a search to delete.', mtInformation, [mbOk], 0);
      Exit;
      end;

    if MessageDlg('Delete the selected search.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
      begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
        CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + lbSavedSearches.Items[lbSavedSearches.ItemIndex]]);

      if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsAdvancedSearch then
        CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + lbSavedSearches.Items[lbSavedSearches.ItemIndex]]);

      thisfrmSearchCriteria.stUpdateContext(origContext);
      end;

    lbSavedSearches.Clear;
    DisplaySavedSearches(nil);
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buDeleteSelectedSearchClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;

end;
{
procedure TfrmSavedSearches.buDeleteSelectedSearchORIGClick(Sender: TObject);
var
  i: integer;
begin
  try
    if lbSavedSearches.ItemIndex = -1 then
      begin
      MessageDlg('No search selected.' + CRLF + 'Please select a search to delete.', mtInformation, [mbOk], 0);
      Exit;
      end;

    if MessageDlg('Delete the selected search.' + CRLF + 'Are you sure?', mtConfirmation, [mbYes,mbNo], 0) = mrYes then
      begin
      thisfrmSearchCriteria.stUpdateContext(SEARCH_TOOL_CONTEXT);
      if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
        CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + STD_PREFIX + lbSavedSearches.Items[lbSavedSearches.ItemIndex]]);

      if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsAdvancedSearch then
        CallV('DSIWA XPAR DEL', ['USR~DSIWA SEARCH TOOL TERMS~' + ADV_PREFIX + lbSavedSearches.Items[lbSavedSearches.ItemIndex]]);

      thisfrmSearchCriteria.stUpdateContext(origContext);
      end;

    lbSavedSearches.Clear;
    DisplaySavedSearches(nil);
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' buDeleteSelectedSearchClick()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;
}
procedure TfrmSavedSearches.buOpenSelectedSearchClick(Sender: TObject);
begin
  if lbSavedSearches.ItemIndex = -1 then
    begin
    MessageDlg('No search selected.' + CRLF + 'Please select a search to open.', mtInformation, [mbOk], 0);
    Exit;
    end;

  //We'll use this value in frmSearchCriteria
  self.SelectedSearchName := lbSavedSearches.Items[lbSavedSearches.ItemIndex];
  thisfrmSearchCriteria.sbStatusBar.Panels[2].Text := 'Current Search: ' + self.SelectedSearchName;
  Close;
end;
{
procedure TfrmSavedSearches.buOpenSelectedSearchORIGClick(Sender: TObject);
begin
  if lbSavedSearches.ItemIndex = -1 then
    begin
    MessageDlg('No search selected.' + CRLF + 'Please select a search to open.', mtInformation, [mbOk], 0);
    Exit;
    end;

  //We'll use this value in frmSearchCriteria
  self.SelectedSearchName := lbSavedSearches.Items[lbSavedSearches.ItemIndex];
  thisfrmSearchCriteria.sbStatusBar.Panels[2].Text := 'Current Search: ' + self.SelectedSearchName;
  Close;
end;
}
procedure TfrmSavedSearches.FormCreate(Sender: TObject);
begin
  try
    thisfrmSearchCriteria := (self.Owner as TfrmSearchCriteria); //Get a pointer to the main form
  except
    on E: Exception do
      MessageDlg(GENERAL_EXCEPTION_MSG + ' frmSavedSearches.FormCreate()' + CRLF +
        E.Message, mtInformation, [mbOk], 0);
  end;
end;

procedure TfrmSavedSearches.FormShow(Sender: TObject);
begin
  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsStandardSearch then
    begin
    self.Caption := ' Standard Searches';
    buDeleteAllType.Caption := 'Delete All &Std Searches';
    end;

  if thisfrmSearchCriteria.pcSearch.ActivePage = thisfrmSearchCriteria.tsAdvancedSearch then
    begin
    self.Caption := ' Advanced Searches';
    buDeleteAllType.Caption := 'Delete All Ad&v Searches';
    end;
end;

procedure TfrmSavedSearches.lbSavedSearchesDblClick(Sender: TObject);
begin
  //self.FSelectedSearchName := lbSavedSearches.Items[lbSavedSearches.ItemIndex]; //This is the user-selected search
  //self.SelectedSearchName := lbSavedSearches.Items[lbSavedSearches.ItemIndex];
  buOpenSelectedSearchClick(nil);
end;

end.
