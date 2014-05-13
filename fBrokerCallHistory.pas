unit fBrokerCallHistory;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, dssrpc, ExtCtrls;

type
  TfrmBrokerCallHistory = class(TForm)
    memCallHistory: TMemo;
    btnClose: TButton;
    btnSaveToFile: TButton;
    dlgSave: TSaveDialog;
    btnClipboard: TButton;
    Button1: TButton;
    btnFindAgain: TButton;
    chkMonitor: TCheckBox;
    tmrUpdate: TTimer;
    procedure btnCloseClick(Sender: TObject);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure btnClipboardClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnFindAgainClick(Sender: TObject);
    procedure chkMonitorClick(Sender: TObject);
    procedure tmrUpdateTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FBroker: TDSSRPCBroker;
    FSearchTerm: string;
    FSearchPos: integer;
    procedure DoFind;
  public                                         
    procedure ShowHistoryOfABroker(thisBroker: TDSSRPCBroker);
  end;

var
  frmBrokerCallHistory: TfrmBrokerCallHistory;

implementation

uses
  clipbrd;

{$R *.DFM}

{ TfrmBrokerCallHistory }

function AppDir: string;
// Returns directory of application.exename
begin
	//paramstr[0] is always the exe name, even in services.
  Result := extractfilepath(ParamStr(0));
end;

procedure TfrmBrokerCallHistory.ShowHistoryOfABroker(thisBroker: TDSSRPCBroker);
begin
  if FBroker = nil then
    FBroker := thisBroker
  else if FBroker <> thisBroker then
    FBroker := thisBroker;

  memCallHistory.Lines.Assign(thisBroker.CallHistoryList);
end;

procedure TfrmBrokerCallHistory.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBrokerCallHistory.btnSaveToFileClick(Sender: TObject);
begin
  dlgSave.InitialDir := appdir;
  if dlgSave.Execute then
    memCallHistory.Lines.SaveToFile(dlgSave.filename);
end;

procedure TfrmBrokerCallHistory.btnClipboardClick(Sender: TObject);
begin
  if memCallHistory.SelLength > 0 then
    //something is highlighted - just copy that.
    clipboard.SetTextBuf(pchar(memCallHistory.seltext))
  else
    clipboard.SetTextBuf(pchar(memCallHistory.Text));
end;

procedure TfrmBrokerCallHistory.Button1Click(Sender: TObject);
var
  sFind: string;
begin
  sFind := inputbox('Find (not case sensitive)', 'Find what ?', '');

  if sFind > '' then
    begin
      FSearchPos  := 0;
      FSearchTerm := sFind;
      btnFindAgain.hint := 'Find "' + sFind + '" again';
      DoFind;
    end;
end;

procedure TfrmBrokerCallHistory.DoFind;
var
  sSearchArea: string;
  iPos: integer;
begin
  sSearchArea := copy(memCallHistory.Text, FSearchPos, length(
      memCallHistory.Text) - FSearchPos);
  iPos := pos(ansilowercase(FSearchTerm), ansilowercase(sSearchArea));
  if iPos > 0 then
    begin
      memCallHistory.selstart  := FSearchPos - 1 + iPos;
      memCallHistory.sellength := length(FSearchTerm);

      Inc(FSearchPos, iPos + 1);
      btnFindAgain.Enabled := true;
    end
  else
    FSearchPos := 0;
end;

procedure TfrmBrokerCallHistory.btnFindAgainClick(Sender: TObject);
begin
  DoFind;
end;

procedure TfrmBrokerCallHistory.chkMonitorClick(Sender: TObject);
begin
  if chkMonitor.Checked then
    self.formstyle := fsStayOnTop
  else
    self.formstyle := fsNormal;
  tmrUpdate.Enabled := chkMonitor.Checked;
end;

procedure TfrmBrokerCallHistory.tmrUpdateTimer(Sender: TObject);
begin
  if FBroker <> nil then
    if copy(FBroker.CallHistoryList.Text, 1, 255) <> copy(memCallHistory.Text, 1, 255) then
      ShowHistoryOfABroker(FBroker);
end;

procedure TfrmBrokerCallHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmrUpdate.Enabled := FALSE;
end;

procedure TfrmBrokerCallHistory.FormShow(Sender: TObject);
begin
  tmrUpdate.Enabled := chkMonitor.Checked;
end;

end.
