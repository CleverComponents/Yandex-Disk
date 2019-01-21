unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, clTcpClient, clHttp, clSocketUtils, System.UITypes,
  clWebDav, clHttpRequest, clSspiTls, clTcpClientTls, clOAuth, Vcl.ComCtrls, clUriUtils;

type
  TForm1 = class(TForm)
    btnListDir: TButton;
    clWebDav1: TclWebDav;
    btnUpload: TButton;
    btnDownload: TButton;
    btnDelete: TButton;
    clOAuth1: TclOAuth;
    ListBox1: TListBox;
    SaveDialog1: TSaveDialog;
    ProgressBar1: TProgressBar;
    OpenDialog1: TOpenDialog;
    procedure btnListDirClick(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
    procedure clWebDav1SendProgress(Sender: TObject; ABytesProceed,
      ATotalBytes: Int64);
    procedure clWebDav1ReceiveProgress(Sender: TObject; ABytesProceed,
      ATotalBytes: Int64);
    procedure btnDownloadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  private
    FDirList: TStrings;
    FCurrentResSize: Int64;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnListDirClick(Sender: TObject);
var
  i: Integer;
  uri: string;
begin
  clWebDav1.Authorization := clOAuth1.GetAuthorization();
  clWebDav1.GetProperties('https://webdav.yandex.ru/', ['displayname']);
  ListBox1.Clear();
  FDirList.Clear();

  for i := 0 to clWebDav1.ResourceProperties.Count - 1 do
  begin
    ListBox1.Items.Add(clWebDav1.ResourceProperties[i].Value);

    uri := clWebDav1.ResourceProperties[i].Uri;
    if (Pos('http', LowerCase(uri)) <> 1) then
    begin
      uri := TclUrlParser.CombineUrl(uri, 'https://webdav.yandex.ru/');
    end;

    FDirList.Add(uri);
  end;
end;

procedure TForm1.btnUploadClick(Sender: TObject);
var
  stream: TStream;
  uri: string;
begin
  if not OpenDialog1.Execute() then Exit;

  clWebDav1.Authorization := clOAuth1.GetAuthorization();

  ProgressBar1.Max := 100;
  ProgressBar1.Position := 0;

  stream := TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
  try
    uri := ExtractFileName(OpenDialog1.FileName);
    uri := TclUrlParser.EncodeUrl(uri, 'utf-8');
    uri := TclUrlParser.CombineUrl(uri, 'https://webdav.yandex.ru/');
    clWebDav1.Put(uri, stream);
  finally
    stream.Free();
  end;

  ShowMessage('Done');

  btnListDirClick(nil);
end;

procedure TForm1.btnDeleteClick(Sender: TObject);
begin
  if ListBox1.ItemIndex < 0 then Exit;

  if (MessageDlg('Do you wish to delete the ' + ListBox1.Items[ListBox1.ItemIndex] + ' file ?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;

  clWebDav1.Authorization := clOAuth1.GetAuthorization();

  clWebDav1.Delete(FDirList[ListBox1.ItemIndex]);

  btnListDirClick(nil);
end;

procedure TForm1.btnDownloadClick(Sender: TObject);
var
  stream: TStream;
  url: string;
begin
  if ListBox1.ItemIndex < 0 then Exit;

  SaveDialog1.FileName := ListBox1.Items[ListBox1.ItemIndex];
  if not SaveDialog1.Execute() then Exit;

  clWebDav1.Authorization := clOAuth1.GetAuthorization();

  url := FDirList[ListBox1.ItemIndex];

  ProgressBar1.Max := 100;
  ProgressBar1.Position := 0;

  clWebDav1.GetProperties(url, ['getcontentlength']);
  if (clWebDav1.ResourceProperties.Count = 1) then
  begin
    FCurrentResSize := StrToInt64Def(clWebDav1.ResourceProperties[0].Value, 0);
  end;

  stream := TFileStream.Create(SaveDialog1.FileName, fmCreate);
  try
    clWebDav1.Get(url, stream);
  finally
    stream.Free();
  end;

  ShowMessage('Done');
end;

procedure TForm1.clWebDav1ReceiveProgress(Sender: TObject; ABytesProceed, ATotalBytes: Int64);
var
  total: Int64;
begin
  total := ATotalBytes;
  if (total <= 0) then
  begin
    total := FCurrentResSize;
  end;

  if (total > 0) then
  begin
    ProgressBar1.Position := Integer(ABytesProceed * 100 div total);
  end;

  Caption := Format('Yandex Disk - Receiving...%d bytes done.', [ABytesProceed]);
end;

procedure TForm1.clWebDav1SendProgress(Sender: TObject; ABytesProceed, ATotalBytes: Int64);
begin
  Caption := Format('Yandex Disk - Sending...%d bytes done.', [ABytesProceed]);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  clOAuth1.Close();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDirList := TStringList.Create();

  clOAuth1.AuthorizationFlow := afAuthCodeFlow;
  clOAuth1.AuthorizationEndPoint := apLocalWebServer;
  clOAuth1.EscapeRedirectURL := False;

  clOAuth1.AuthURL := 'https://oauth.yandex.ru/authorize';
  clOAuth1.TokenURL := 'https://oauth.yandex.ru/token';
  clOAuth1.RedirectURL := 'http://localhost';
  clOAuth1.LocalWebServerPort := 55896;
  clOAuth1.ClientID := '1335c5e0cf6d4c2f96661d5d76a86117';
  clOAuth1.ClientSecret := '5e0689f4ce86415c856f113fa75eb98b';
  clOAuth1.Scope := 'unit_test';

  clWebDav1.CharSet := 'UTF-8';
  clWebDav1.Depth := wdResourceAndChildren;
  clWebDav1.SilentHTTP := True;
  clWebDav1.Expect100Continue := True;
  clWebDav1.TLSFlags := [tfUseTLS, tfUseTLS11];
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FDirList.Free();
end;

end.
