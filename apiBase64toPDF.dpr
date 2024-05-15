program apiBase64toPDF;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.IOUtils,
  synacode,
  Vcl.Graphics,
  Horse.HTTP,
  Horse.Jhonson,
  Horse.Exception,
  Horse.Commons;

var
  App: THorse;
  DevStack: TStack<string>;
  paramPort: string;
  aPort: Integer;

begin
  paramPort := ParamStr(1);
  aPort := 9001;

  if (StrToIntDef(paramPort, -1) = -1) and (paramPort <> EmptyStr) then
    Writeln(Format('A porta %s na passagem do parâmetro deu um erro de conversão, será usada a default 9001', [paramPort]));

  aPort := StrToIntDef(paramPort, 9001);

  WriteLn('');
  WriteLn('###                         ####     ##      ####    ######    #####   ####      ####    ##   ##   ####');
  WriteLn(' ##                        ##  ##   ####      ##     # ## #   ##   ##   ##        ##     ###  ##    ##');
  WriteLn(' ##      ##  ##           ##       ##  ##     ##       ##     ##   ##   ##        ##     #### ##    ##');
  WriteLn(' #####   ##  ##           ##       ##  ##     ##       ##     ##   ##   ##        ##     ## ####    ##');
  WriteLn(' ##  ##  ##  ##           ##  ###  ######     ##       ##     ##   ##   ##   #    ##     ##  ###    ##');
  WriteLn(' ##  ##   #####            ##  ##  ##  ##     ##       ##     ##   ##   ##  ##    ##     ##   ##    ##');
  WriteLn('######       ##             #####  ##  ##    ####     ####     #####   #######   ####    ##   ##   ####');
  WriteLn('         #####');
  WriteLn('');

  WriteLn('by Anderson Gaitolini');
  WriteLn('');

  Writeln(Format('Use o método[POST] http://localhost:%s/b64topdf', [paramPort]));
  Writeln('passando o body: ');
  Writeln('{');
  Writeln('  "b64": "Seu Base64"');
  Writeln('}');
  Writeln('');

  App := THorse.Create(aPort);
  App.Use(Jhonson);
  DevStack := TStack<string>.Create;

  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  App.Post('/b64topdf',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      JsonObj: TJSONObject;
      FOutputFile, FFileName, FB64: string;
      DecodedBytes: TBytes;
      Arquivo: TStringStream;
    begin
      Writeln('..');
      JsonObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body), 0) as TJSONObject;
      try
        try
          if Assigned(JsonObj) then
          begin

//        {
//        "outputFile": "C:\\Temp\\PDF\\",
//        "fileName": "boleto_{{$randomFileExt}}.pdf",  // Adicione ".pdf" após a função
//        "b64": "{{b64toZip}}"
//        }
            FOutputFile := JsonObj.GetValue('outputFile').Value;
            FFileName := JsonObj.GetValue('fileName').Value;
            FB64 := JsonObj.GetValue('b64').Value;

            if FFileName = EmptyStr then
              FFileName := TPath.GetRandomFileName + '.pdf'
            else if LowerCase(ExtractFileExt(FFileName)) <> '.pdf' then
              FFileName := ExtractFileName(FFileName) + '.pdf';

            if not DirectoryExists(FOutputFile) then
            begin
              ForceDirectories(FOutputFile);
              if not DirectoryExists(FOutputFile) then
              begin
                Res.Status(THTTPStatus.NoContent);
                RES.Send('{"Erro": "Diretório não Existe!"}').Status(THTTPStatus.NotAcceptable);
                Writeln('[406] Diretório não Existe');
              end;
            end;

            if (Trim(FB64) <> '') then
            begin
              Writeln('Base64 recebido!');

              Arquivo := TStringStream.Create(DecodeBase64(FB64));

              try
                Arquivo.SaveToFile(IncludeTrailingPathDelimiter(FOutputFile) + FFileName);
                RES.Send('{"OK": "PDF salvo com sucesso",' +
                         '"outputFile": '+ QuotedStr(IncludeTrailingPathDelimiter(FOutputFile) + FFileName) +
                         '}'
                ).Status(THTTPStatus.Created);
                Writeln('[201] PDF salvo com sucesso: ' + IncludeTrailingPathDelimiter(FOutputFile) + FFileName);
              finally
                Arquivo.Free;
              end;

            end
            else
            begin
              Writeln('[406] Base64 vazio!');
              RES.Send('{"Erro": "Base64 vazio!"}').Status(THTTPStatus.NotAcceptable);
            end;

          end
          else
          begin
            Res.Status(403).Send('Erro: Body da request inválido');
            Write('[403] Erro: Body da request inválido');
            RES.Send('{"Erro": "Body da request inválido!"}').Status(THTTPStatus.NotAcceptable);
          end;
        finally
          JsonObj.Free;
        end;
      except

      end;
    end);

  App.Start;

end.

