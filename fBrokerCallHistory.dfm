object frmBrokerCallHistory: TfrmBrokerCallHistory
  Left = 599
  Top = 113
  Caption = 'Broker Call History'
  ClientHeight = 456
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    425
    456)
  PixelsPerInch = 96
  TextHeight = 13
  object memCallHistory: TMemo
    Left = 8
    Top = 25
    Width = 406
    Height = 390
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Lines.Strings = (
      'memCallHistory')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object btnClose: TButton
    Left = 341
    Top = 425
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Close'
    Default = True
    TabOrder = 3
    OnClick = btnCloseClick
  end
  object btnSaveToFile: TButton
    Left = 8
    Top = 425
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Save To File'
    TabOrder = 1
    OnClick = btnSaveToFileClick
  end
  object btnClipboard: TButton
    Left = 100
    Top = 425
    Width = 103
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'C&opy To Clipboard'
    TabOrder = 2
    OnClick = btnClipboardClick
  end
  object Button1: TButton
    Left = 216
    Top = 425
    Width = 41
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Find'
    TabOrder = 4
    OnClick = Button1Click
  end
  object btnFindAgain: TButton
    Left = 260
    Top = 425
    Width = 41
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Again'
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = btnFindAgainClick
  end
  object chkMonitor: TCheckBox
    Left = 320
    Top = 3
    Width = 92
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Always on &Top'
    TabOrder = 6
    OnClick = chkMonitorClick
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'txt'
    Filter = 'Text|*.txt|All|*.*'
    Left = 92
    Top = 401
  end
  object tmrUpdate: TTimer
    Enabled = False
    OnTimer = tmrUpdateTimer
    Left = 248
    Top = 8
  end
end
