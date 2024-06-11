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
  System.NetEncoding,
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

  App.Post('/b64topdf',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      JsonObj, JsonResult: TJSONObject;
      aOutputFile, aFileName, FB64: string;
      Arquivo: TStringStream;
    begin
      Writeln('..');
      JsonObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body), 0) as TJSONObject;
      JsonResult := TJSONObject.Create;
      try
        try
          if Assigned(JsonObj) then
          begin
            aOutputFile := JsonObj.GetValue('outputFile').Value;
            aFileName := JsonObj.GetValue('fileName').Value;
            FB64 := JsonObj.GetValue('b64').Value;

            if aFileName = EmptyStr then
              aFileName := TPath.GetRandomFileName + '.pdf'
            else if LowerCase(ExtractFileExt(aFileName)) <> '.pdf' then
              aFileName := ExtractFileName(aFileName) + '.pdf';

            if not DirectoryExists(aOutputFile) then
            begin
              ForceDirectories(aOutputFile);
              if not DirectoryExists(aOutputFile) then
              begin
                JsonResult.
                AddPair('outputFile', aOutputFile).
                AddPair('fileName', aFileName).
                AddPair('b64', Copy(FB64,1,15)+'..').
                AddPair('erro', 'true').
                AddPair('mensagem', 'Diretório não Existe!');

                Res.
                Send(JsonResult.ToString).
                Status(THTTPStatus.NotAcceptable);
              
                Writeln('');
                Writeln('Diretório não Existe!');                
              end;
            end;

            if (Trim(FB64) <> '') then
            begin
              Arquivo := TStringStream.Create(DecodeBase64(FB64));

              try
                if not TPath.IsPathRooted(aFileName) then
                   aFileName := TPath.Combine(aOutputFile, aFileName);

                Arquivo.SaveToFile(aFileName);
              
                JsonResult.
                AddPair('outputFile', aOutputFile).
                AddPair('fileName', aFileName).
                AddPair('b64', Copy(FB64,1,15)+'..').
                AddPair('erro', 'false').
                AddPair('mensagem', 'PDF Salvo com sucesso!');

                Res.
                Send(JsonResult.ToString).
                Status(THTTPStatus.Created);
              
                Writeln('');
                Writeln('PDF Salvo com sucesso!'); 
              finally
                Arquivo.Free;
              end;

            end
            else
            begin
                JsonResult.
                AddPair('outputFile', aOutputFile).
                AddPair('fileName', aFileName).
                AddPair('b64', Copy(FB64,1,15)+'..').
                AddPair('erro', 'true').
                AddPair('mensagem', 'Base64 não informada!');

                Res.
                Send(JsonResult.ToString).
                Status(THTTPStatus.NotAcceptable);
              
                Writeln('');
                Writeln('Base64 não informada!'); 
            end;

          end
          else
          begin
            JsonResult.
            AddPair('outputFile', aOutputFile).
            AddPair('fileName', aFileName).
            AddPair('b64', Copy(FB64,1,15)+'..').
            AddPair('erro', 'true').
            AddPair('mensagem', 'Request inválida!');

            Res.
            Send(JsonResult.ToString).
            Status(THTTPStatus.NotAcceptable);
              
            Writeln('');
            Writeln('Request inválida!'); 
          end;
        finally
          JsonObj.Free;
          JsonResult.Free;          
        end;
      except
        on E: Exception do
        begin
            JsonResult.
            AddPair('outputFile', aOutputFile).
            AddPair('fileName', aFileName).
            AddPair('b64', Copy(FB64,1,15)+'..').
            AddPair('erro', 'true').
            AddPair('mensagem', 'Exception! '+ E.Message);

            Res.
            Send(JsonResult.ToString).
            Status(THTTPStatus.InternalServerError);
              
            Writeln('');
            Writeln('Exception! '+ E.Message);
        end;
      end;
    end);

  App.Post('/b64toZIP',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var
    JsonObj, JsonResObj: TJSONObject;
    aOutputFile, aFileName, FB64: string;
    DecodedBytes: TBytes;
    Arquivo: TStringStream;
  begin
    JsonObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body), 0) as TJSONObject;
    JsonResObj := TJSONObject.Create;
    try

      if Assigned(JsonObj) then
      begin
        aOutputFile := JsonObj.GetValue('directory').Value;
        aFileName := JsonObj.GetValue('fileName').Value;
        FB64 := JsonObj.GetValue('b64').Value;

        if aFileName = EmptyStr then
          aFileName := TPath.GetRandomFileName + '.zip'
        else 
        if LowerCase(ExtractFileExt(aFileName)) <> '.zip' then
          aFileName := ExtractFileName(aFileName) + '.zip';


        if not DirectoryExists(aOutputFile) then
        begin
          ForceDirectories(aOutputFile);
          if not DirectoryExists(aOutputFile) then
          begin
            JsonResObj.
            AddPair('directory', aOutputFile).
            AddPair('fileName', aFileName).
            AddPair('b64', '').
            AddPair('erro', 'true').
            AddPair('mensagem', 'Diretório informado não Existe!');

            Res.Send(JsonResObj.ToJSON).
            Status(THTTPStatus.NotAcceptable);

            Writeln('');
            Writeln('Diretório informado não Existe!');
            Exit;
          end;
        end;

        if not TPath.IsPathRooted(aFileName) then
          aFileName := TPath.Combine(aOutputFile, aFileName);

        if (Trim(FB64) <> '') then
        begin
          DecodedBytes := TNetEncoding.Base64.DecodeStringToBytes(FB64);
          Arquivo := TStringStream.Create(DecodedBytes);
          try

            Arquivo.SaveToFile(aFileName);

            JsonResObj.
            AddPair('directory', aOutputFile).
            AddPair('fileName', QuotedStr(aFileName)).
            AddPair('b64', Copy(FB64,1,15)+'..').
            AddPair('erro', 'false').
            AddPair('mensagem', 'Arquivo ZIP salvo com sucesso!');

            Res.Send(JsonResObj.ToJSON).
            Status(THTTPStatus.Created);

            Writeln('');
            Writeln('Arquivo ZIP salvo com sucesso!');
          finally
            Arquivo.Free;
          end;
        end
        else
        begin
            JsonResObj.
            AddPair('directory', aOutputFile).
            AddPair('fileName', QuotedStr(aFileName)).
            AddPair('b64', '').
            AddPair('erro', 'true').
            AddPair('mensagem', 'Base64 não encontrado!');

            Res.Send(JsonResObj.ToJSON).
            Status(THTTPStatus.NoContent);

          Writeln('');
          Writeln('Base64 não encontrado!');
        end;
      end
      else
      begin
        JsonResObj.
        AddPair('directory', aOutputFile).
        AddPair('fileName', QuotedStr(aFileName)).
        AddPair('b64', '').
        AddPair('erro', 'true').
        AddPair('mensagem', 'Body da request inválido!');

        Res.Send(JsonResObj.ToJSON).
        Status(THTTPStatus.NotFound);
        Writeln('');
        Writeln('Body da request inválido!');
      end;
    finally
      JsonObj.Free;
    end;
  end);

  App.Post('/imgTob64',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var
    JsonObj, ImageObj,ResultItemObj, ResultObj: TJSONObject;
    Directory, FileName, ImagePath, Base64Str: string;
    ImagesArray, OutputArray: TJSONArray;
    DecodedBytes: TBytes;
    ImageStream: TMemoryStream;
    I : Integer;
    HttpStatus: THTTPStatus;
    ErroItem: Boolean;
  begin
    JsonObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Req.Body), 0) as TJSONObject;
    try
      if Assigned(JsonObj) then
      begin
        Directory := JsonObj.GetValue('directory').Value;
        ImagesArray := JsonObj.GetValue('images') as TJSONArray;
        OutputArray := TJSONArray.Create;
        ErroItem := False;

        for I := 0 to ImagesArray.Count - 1 do
        begin
          ImageObj := ImagesArray.Items[I] as TJSONObject;
          FileName := ImageObj.GetValue('filename').Value;
          ImagePath := FileName;

          if not TPath.IsPathRooted(FileName) then
            ImagePath := TPath.Combine(Directory, FileName);

          ResultItemObj := TJSONObject.Create;
          try

            if FileExists(ImagePath) then
            begin
              ImageStream := TMemoryStream.Create;
              try
                ImageStream.LoadFromFile(ImagePath);
                ImageStream.Position := 0;
                Base64Str := TNetEncoding.Base64.EncodeBytesToString(ImageStream.Memory, ImageStream.Size);


                ResultItemObj.AddPair('erro', 'false');
                ResultItemObj.AddPair('erroMsg', '');
                ResultItemObj.AddPair('b64', Base64Str);
              except
                on E: Exception do
                begin

                  ResultItemObj.AddPair('erro', 'true');
                  ResultItemObj.AddPair('b64', 'Exception: '+E.Message);
                  ErroItem := True;
                  Write('Imagem '+ IntToStr(I+1));
                  Writeln(' Exception: '+ E.Message);
                end;
              end;

              Write('Imagem '+ IntToStr(I+1));
              Writeln(' Base64 gerado com sucesso!');

              ImageStream.Free;
            end
            else
            begin
              ResultItemObj.AddPair('erro', 'true');
              ResultItemObj.AddPair('erroMsg', 'Imagem não encontrada!');
              ResultItemObj.AddPair('b64', '');

              Writeln('');
              Write('Imagem '+ IntToStr(I+1));
              Writeln('File not Exists!');
              ErroItem := True;
            end;

            OutputArray.AddElement(ResultItemObj.Clone as TJSONObject);

          finally
            ResultItemObj.Free;
          end;
        end;

        ResultObj := TJSONObject.Create;
        ResultObj.AddPair('directory',Directory);
        ResultObj.AddPair('images',OutputArray);

        HttpStatus := THTTPStatus.Created;

        if ErroItem then
          if ImagesArray.Count = 1 then
            HttpStatus := THTTPStatus.PartialContent
          else
            HttpStatus := THTTPStatus.NoContent;

        Res.Send(ResultObj.ToString).Status(HttpStatus);
      end
      else
      begin
        Res.Send('Erro: Body da request inválido').Status(THTTPStatus.Forbidden);
        Writeln('');
        Writeln('Body da request inválido!');
      end;
    finally
      Writeln('');
      JsonObj.Free;
      ResultObj.Free;
    end;
  end);



  App.Start;


end.

