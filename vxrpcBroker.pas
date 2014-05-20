unit vxrpcBroker;

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
  SysUtils, Classes, Windows, Forms, StdCtrls, Trpcb, Xwbut1, Dialogs, Wsockc, MFunStr;

type
  TvxVistaLogin = class(TVistaLogin)
end;

type
  TVistAType = (cnAuto, cnVA, cnVX);

type
  TvxrpcBroker = class(TRPCBroker)
  private
    { Private declarations }
    FSecurityPhrase: String;     // BSE JLI 060130
  protected
    { Protected declarations }
    FConnected: Boolean;
    FUseUpperCase : boolean;                       { JAC 01/31/07 }
    FTypeOfVistA : TVistAType;
    FVistALanguage : string;
    FVistAVersion : string;
    CanConnect : boolean;
    procedure SetConnected(Value: Boolean); override;
    function GetVersion(): string;
    procedure SetVersion(const Value: string);
    procedure SetTypeOfVistA(const Value: TVistAType);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy(); override;
    property    SecurityPhrase: String read FSecurityPhrase write FSecurityPhrase;  // BSE JLI 060130
    property    VistALanguage: string read FVistALanguage write FVistALanguage;
    property    VistAVersion: string read FVistAVersion write FVistAVersion;
  published
    { Published declarations }
    property Connected: boolean read FConnected write SetConnected;
    property UseUpperCase: Boolean read FUseUpperCase write FUseUpperCase default True;  { JAC 01/31/07 }
    property Version : string read GetVersion  write SetVersion stored false;
    property TypeOfVistA: TVistAType read FTypeOfVistA write SetTypeOfVistA default cnAuto;
  end;

procedure vxAuthenticateUser(ConnectingBroker: TvxRPCBroker);

procedure Register;

implementation

uses
 vxLoginFrm, fRPCBErrMsg, SelDiv, RpcSLogin;

procedure Register;
begin
  RegisterComponents('VistA3', [TvxrpcBroker]);
end;

constructor TvxRPCBroker.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);
 FUseUpperCase := True;
 FTypeOfVistA := cnAuto;
end;

destructor TvxRPCBroker.Destroy();
begin
 inherited Destroy;
end;

function TvxRPCBroker.GetVersion(): string;
begin
 Result := '2.2.0.0';
end;

procedure TvxRPCBroker.SetVersion(const Value: string);
begin
//
end;

procedure TvxRPCBroker.SetTypeOfVistA(const Value: TVistAType);
begin
  FTypeOfVistA := Value;
end;


{--------------------- TvxRpcBroker.SetConnected --------------------
------------------------------------------------------------------}
procedure TvxRPCBroker.SetConnected(Value: Boolean);
var
  BrokerDir, Str1, Str2, Str3 :string;
begin
//  inherited;
  RPCBError := '';
  Login.ErrorText := '';
  if (Connected <> Value) and not(csReading in ComponentState) then begin
    if Value and (FConnecting <> Value) then begin                 {connect}
      FSocket := ExistingSocket(Self);
      FConnecting := True; // FConnected := True;
      try
        if FSocket = 0  then
        begin
          {Execute Client Agent from directory in Registry.}
          BrokerDir := ReadRegData(HKLM, REG_BROKER, 'BrokerDr');
          if BrokerDir <> '' then
            ProcessExecute(BrokerDir + '\ClAgent.Exe', sw_ShowNoActivate)
          else
            ProcessExecute('ClAgent.Exe', sw_ShowNoActivate);
          if DebugMode and (not OldConnectionOnly) then
          begin
            Str1 := 'Control of debugging has been moved from the client to the server. To start a Debug session, do the following:'+#13#10#13#10;
            Str2 := '1. On the server, set initial breakpoints where desired.'+#13#10+'2. DO DEBUG^XWBTCPM.'+#13#10+'3. Enter a unique Listener port number (i.e., a port number not in general use).'+#13#10;
            Str3 := '4. Connect the client application using the port number entered in Step #3.';
            ShowMessage(Str1 + Str2 + Str3);
          end;
          TXWBWinsock(XWBWinsock).IsBackwardsCompatible := IsBackwardCompatibleConnection;
          TXWBWinsock(XWBWinsock).OldConnectionOnly := OldConnectionOnly;
          FSocket := TXWBWinsock(XWBWinsock).NetworkConnect(DebugMode, FServer,
                                    ListenerPort, FRPCTimeLimit);
          vxAuthenticateUser(Self);
          FPulse.Enabled := True; //P6 Start heartbeat.
          StoreConnection(Self);  //MUST store connection before CreateContext()
          CreateContext('');      //Closes XUS SIGNON context.
        end
        else
        begin                     //p13
          StoreConnection(Self);
          FPulse.Enabled := True; //p13
        end;                      //p13
        FConnected := True;         // jli mod 12/17/01
        FConnecting := False;
      except
        on E: EBrokerError do begin
          if E.Code = XWB_BadSignOn then
            TXWBWinsock(XWBWinsock).NetworkDisconnect(FSocket);
          FSocket := 0;
          FConnected := False;
          FConnecting := False;
          FRPCBError := E.Message;               // p13  handle errors as specified
          if Login.ErrorText <> '' then
            FRPCBError := E.Message + chr(10) + Login.ErrorText;
          if Assigned(FOnRPCBFailure) then       // p13
            FOnRPCBFailure(Self)                 // p13
          else if ShowErrorMsgs = semRaise then
//            if CanConnect then
              Raise;                               // p13
//          raise;   {this is where I would do OnNetError}
        end{on};
      end{try};
    end{if}
    else if not Value then
    begin                           //p13
      FConnected := False;          //p13
      FPulse.Enabled := False;      //p13
      if RemoveConnection(Self) = NoMore then begin
        {FPulse.Enabled := False;  ///P6;p13 }
        TXWBWinsock(XWBWinsock).NetworkDisconnect(Socket);   {actually disconnect from server}
        FSocket := 0;                {store internal}
        //FConnected := False;      //p13
      end{if};
    end; {else}
  end{if};
  inherited;
end;

{------------------------ vxAuthenticateUser ------------------------
------------------------------------------------------------------}
procedure vxAuthenticateUser(ConnectingBroker: TvxRPCBroker);
var
  SaveClearParmeters, SaveClearResults: boolean;
  SaveParam: TParams;
  SaveRemoteProcedure, SaveRpcVersion: string;
  SaveResults: TStrings;
  blnSignedOn: boolean;
  SaveKernelLogin: boolean;
  SaveVistaLogin: TVistaLogin;
  OldExceptionHandler: TExceptionEvent;
  OldHandle: THandle;
begin
  ConnectingBroker.CanConnect := true;
  With ConnectingBroker do
  begin
    SaveParam := TParams.Create(nil);
    SaveParam.Assign(Param);                  //save off settings
    SaveRemoteProcedure := RemoteProcedure;
    SaveRpcVersion := RpcVersion;
    SaveResults := Results;
    SaveClearParmeters := ClearParameters;
    SaveClearResults := ClearResults;
    ClearParameters := True;                  //set'em as I need'em
    ClearResults := True;
    SaveKernelLogin := KernelLogin;     //  p13
    SaveVistaLogin := Login;            //  p13
  end;

  blnSignedOn := False;                       //initialize to bad sign-on

  if ConnectingBroker.AccessVerifyCodes <> '' then   // p13 handle as AVCode single signon
  begin
    ConnectingBroker.Login.AccessCode := Piece(ConnectingBroker.AccessVerifyCodes, ';', 1);
    ConnectingBroker.Login.VerifyCode := Piece(ConnectingBroker.AccessVerifyCodes, ';', 2);
    ConnectingBroker.Login.Mode := lmAVCodes;
    ConnectingBroker.FKernelLogIn := False;
  end;

  if ConnectingBroker.FKernelLogIn then
  begin   //p13
    if Assigned(Application.OnException) then
      OldExceptionHandler := Application.OnException
    else
      OldExceptionHandler := nil;
    Application.OnException := TfrmErrMsg.RPCBShowException;
    vxfrmSignon := TvxfrmSignon.Create(Application);
    try
      if ConnectingBroker.FUseUpperCase = TRUE then { JAC 01/31/07 }
        begin
          vxFrmSignOn.accessCode.CharCase := ecUpperCase;
          vxFrmSignOn.verifyCode.CharCase := ecUpperCase;
        end
      else
        begin
          vxFrmSignOn.accessCode.CharCase := ecNormal;
          vxFrmSignOn.verifyCode.CharCase := ecNormal;
        end;

  //    ShowApplicationAndFocusOK(Application);
      OldHandle := GetForegroundWindow;
      SetForegroundWindow(vxfrmSignon.Handle);
      PrepareSignonForm(ConnectingBroker);
      if SetUpSignOn then                       //SetUpSignOn in loginfrm unit.
      begin                                     //True if signon needed
  {                                               // p13 handle as AVCode single signon
        if ConnectingBroker.AccessVerifyCodes <> '' then
        begin {do non interactive logon
          vxfrmSignon.accessCode.Text := Piece(ConnectingBroker.AccessVerifyCodes, ';', 1);
          vxfrmSignon.verifyCode.Text := Piece(ConnectingBroker.AccessVerifyCodes, ';', 2);
          //Application.ProcessMessages;
          vxfrmSignon.btnOk.Click;
        end
        else vxfrmSignOn.ShowModal;               //do interactive logon
  }
  //      ShowApplicationAndFocusOK(Application);
  //      SetForegroundWindow(vxfrmSignOn.Handle);
        ConnectingBroker.CanConnect := vxFrmSignOn.OKToLogOn;
        if ConnectingBroker.CanConnect then
        begin
         if vxfrmSignOn.lblServer.Caption <> '' then
         begin
           vxfrmSignOn.ShowModal;                    //do interactive logon   // p13
           if vxfrmSignOn.Tag = 1 then               //Tag=1 for good logon
             blnSignedOn := True;                   //Successfull logon
         end;
        end
        else
        begin
          if ConnectingBroker.TypeOfVistA = cnVA then
           ShowMessage('This application is not authorized to connect to a Commercial VistA System')
          else
           ShowMessage('This application is not authorized to connect to a VA VistA System');
        end;
      end
      else                                      //False when no logon needed
        blnSignedOn := NoSignOnNeeded;          //Returns True always (for now!)
      if blnSignedOn then                       //P6 If logged on, retrieve user info.
      begin
        GetBrokerInfo(ConnectingBroker);
        if not SelDiv.ChooseDiv('',ConnectingBroker) then
        begin
          blnSignedOn := False;//P8
          {Select division if multi-division user.  First parameter is 'userid'
          (DUZ or username) for future use. (P8)}
          ConnectingBroker.Login.ErrorText := 'Failed to select Division';  // p13 set some text indicating problem
        end;
      end;
      SetForegroundWindow(OldHandle);
    finally
      vxfrmSignon.Free;
//      vxfrmSignon.Release;                        //get rid of signon form

//      if ConnectingBroker.Owner is TForm then
//        SetForegroundWindow(TForm(ConnectingBroker.Owner).Handle)
//      else
//        SetForegroundWindow(ActiveWindow);
        ShowApplicationAndFocusOK(Application);
    end ; //try
    if Assigned(OldExceptionHandler) then
      Application.OnException := OldExceptionHandler;
   end;   //if kernellogin
                                                 // p13  following section for silent signon
  if not ConnectingBroker.FKernelLogIn then
    if ConnectingBroker.Login <> nil then     //the user.  vistalogin contains login info
      blnsignedon := SilentLogin(ConnectingBroker);    // RpcSLogin unit
//  if ConnectingBroker.CanConnect then
//  begin
   if (not blnsignedon) then
   begin
     TvxVistaLogin(ConnectingBroker.Login).FailedLogin(ConnectingBroker.Login);
     TXWBWinsock(ConnectingBroker.XWBWinsock).NetworkDisconnect(ConnectingBroker.FSocket);
   end
   else
     GetBrokerInfo(ConnectingBroker);

   //reset the Broker
   with ConnectingBroker do
   begin
     ClearParameters := SaveClearParmeters;
     ClearResults := SaveClearResults;
     Param.Assign(SaveParam);                  //restore settings
     SaveParam.Free;
     RemoteProcedure := SaveRemoteProcedure;
     RpcVersion := SaveRpcVersion;
     Results := SaveResults;
     KernelLogin := SaveKernelLogin;         // p13
     Login := SaveVistaLogin;                // p13
   end;

   if not blnSignedOn then                     //Flag for unsuccessful signon.
     TXWBWinsock(ConnectingBroker.XWBWinsock).NetError('',XWB_BadSignOn);               //Will raise error.
// end;
end;

end.
