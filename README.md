# 🎊🎉 API-base64-to-pdf: Sua Solução Mágica para PDFs em Base64! 🎊🎉

## ✨ Cansado de ficar copiando e colando base64 para ter seus PDFs? Relaxa, a API-base64-to-pdf chegou para facilitar sua vida! ✨

###🚀 Com esta API LOCAL, você salva arquivos em base64 como PDFs direto no Postman (ou onde preferir)! 🚀
![2024-05-20_16h57_11](https://github.com/gaitolini/API-base64-to-pdf/assets/24495176/9685fb5d-a0ce-48b8-a711-b490b0276aa2)

🤔 Como funciona? 🤔

Recebe uma string base64 com seu PDF.
Chama a API com o base64, nome do arquivo e local para salvar.
✨ Mágica! ✨ Seu PDF está pronto!
💪 Por que usar a API-base64-to-pdf? 💪

- 💻 Desenvolvida com Delphi e Horse Framework: Robusta e eficiente! 🏛️🐎
- ⚡ Rápida e fácil: Converta seus base64 em PDFs em um piscar de olhos! ⚡
- 💾 Salva localmente: Escolha onde quer seus PDFs! 💾
- 😎 Integração com Postman: Use scripts para automatizar tudo! 😎
- 🤓 Código aberto: Contribua e personalize! 🤓

### 🤖 Dica de mestre: Use o script abaixo para chamar a API no Postman! 🤖

JavaScript
```javascript
if (pm.response.code === 200) {
const dataAtual = new Date();

const dia = String(dataAtual.getDate()).padStart(2, '0');
const mes = String(dataAtual.getMonth() + 1).padStart(2, '0');
const ano = dataAtual.getFullYear();

const hora = String(dataAtual.getHours()).padStart(2, '0');
const minuto = String(dataAtual.getMinutes()).padStart(2, '0');
const segundo = String(dataAtual.getSeconds()).padStart(2, '0');

const dataHoraFormatada = `${dia}-${mes}-${ano}_${hora}-${minuto}-${segundo}`;
const nomeArquivo = `guiaUnica${dataHoraFormatada}.pdf`;

   console.log(nomeArquivo);


    const jsonData = pm.response.json();

    // Extrair "Base64" (ajuste a estrutura se necessário)
    var b64 = jsonData.documentoImpressao;
    pm.environment.set("b64", b64);
    console.log("b64", b64);

    const pdfRequest = {
        url: 'localhost:9001/b64topdf',
        method: 'POST',
        header: {
            'Content-Type': 'application/json'
        },
        body: {
            mode: 'raw',
            raw: JSON.stringify({ // Construir o JSON diretamente
                "outputFile": "C:\\Temp\\PDF\\",
                "fileName": nomeArquivo,
                "b64": b64
            })
        }
    };

    pm.sendRequest(pdfRequest, (err, res) => {
        if (err) {
            console.error("Erro ao enviar requisição PDF:", err);
        } else {
            console.log("Resposta da requisição PDF:", res);
            // Lidar com a resposta da sua API Delphi aqui
        }
    });
}

```
![image](https://github.com/gaitolini/API-base64-to-pdf/assets/24495176/8b313f19-612b-48e2-9798-4bd6fad0fcc6)


## Chamada da API no Postman  
### URL: localhost:9001\b64topdf
### Body: 

```json
{
    "outputFile": "C:\\Temp\\PDF\\",
    "fileName": "boleto_{{$randomFirstName}}.pdf",  // Adicione ".pdf" após a função
    "b64": "{{b64}}"
}
```

![image](https://github.com/gaitolini/API-base64-to-pdf/assets/24495176/db925f4a-eb1d-4ad1-8c6d-211aeb21cb63)

# Run na aplicação console API-base64-to-PDF

 E seja feliz executando os seus teste com Postman..😊
![image](https://github.com/gaitolini/API-base64-to-pdf/assets/24495176/8c05f0ea-6e7b-43de-80ff-31ae646fe24d)

![image](https://github.com/gaitolini/API-base64-to-pdf/assets/24495176/0eb4c083-560d-4942-bb61-20b502b38bfe)

content_copy
🎉 Pronto para a mágica? 🎉

## Rode a aplicação console API-base64-to-pdf.
Chame a API no Postman com seus dados.
Seu PDF está pronto! 🎉
👉 Quer mais? 👉

Em breve, teremos uma versão em Go para ainda mais performance! 🚀

🙌 Contribua e faça a mágica acontecer! 🙌

Gostou? Deixe sua estrelinha ⭐ e ajude a espalhar a magia! ✨
