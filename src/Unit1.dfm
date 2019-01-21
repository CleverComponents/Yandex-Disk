object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Yandex Disk'
  ClientHeight = 372
  ClientWidth = 479
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnListDir: TButton
    Left = 24
    Top = 24
    Width = 75
    Height = 25
    Caption = 'List Dir'
    TabOrder = 0
    OnClick = btnListDirClick
  end
  object btnUpload: TButton
    Left = 144
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Upload'
    TabOrder = 1
    OnClick = btnUploadClick
  end
  object btnDownload: TButton
    Left = 264
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Download'
    TabOrder = 2
    OnClick = btnDownloadClick
  end
  object btnDelete: TButton
    Left = 376
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Delete'
    TabOrder = 3
    OnClick = btnDeleteClick
  end
  object ListBox1: TListBox
    Left = 0
    Top = 72
    Width = 479
    Height = 283
    Align = alBottom
    ItemHeight = 13
    TabOrder = 4
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 355
    Width = 479
    Height = 17
    Align = alBottom
    TabOrder = 5
  end
  object clWebDav1: TclWebDav
    UserAgent = 'Mozilla/4.0 (compatible; Clever Internet Suite)'
    OnSendProgress = clWebDav1SendProgress
    OnReceiveProgress = clWebDav1ReceiveProgress
    LockTimeOut = 'Infinite, Second-86400'
    NameSpaces = <
      item
        Prefix = 'D'
        NameSpace = 'DAV:'
      end>
    Left = 216
    Top = 136
  end
  object clOAuth1: TclOAuth
    UserAgent = 'CleverComponents OAUTH 2.0'
    EnterCodeFormCaption = 'Enter Authorization Code'
    SuccessHtmlResponse = 
      '<html><body><h3 style="color:green;margin:30px">OAuth Authorizat' +
      'ion Successful!</h3></body></html>'
    FailedHtmlResponse = 
      '<html><body><h3 style="color:red;margin:30px">OAuth Authorizatio' +
      'n Failed!</h3></body></html>'
    Left = 152
    Top = 136
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 264
    Top = 136
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 312
    Top = 136
  end
end
