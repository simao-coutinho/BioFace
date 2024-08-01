# Facing
## Desenvolvimento de um Serviço de Autenticação Pessoal baseado em Reconhecimento Facial


[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://github.com/simao-coutinho/BioFace)

Este é um projeto de desenvolvimento de um serviço de autenticação pessoal utilizando reconhecimento facial como método de identificação. Este sistema visa fornecer uma maneira segura e conveniente de autenticar utilizadores em diversas aplicações, substituindo ou complementando métodos tradicionais de autenticação, como senhas. Também faz a validação de cartões pessoais.

## Visão Geral

O objetivo deste projeto é criar um serviço de autenticação pessoal baseado em reconhecimento facial, que permitirá aos usuários acessar sistemas ou dispositivos usando a câmera de um dispositivo compatível. O serviço consistirá em duas partes principais:

1. **Captura e Armazenamento de Dados Faciais:** Esta etapa envolve a captura de imagens faciais dos usuários durante o registro e o armazenamento seguro desses dados para uso futuro.

2. **Reconhecimento e Autenticação:** Durante o processo de autenticação, o sistema comparará a imagem facial capturada do usuário com os dados armazenados para verificar a identidade.

3. **Reconhecimento e Autenticação de cartões pessoais:** Durante o processo de autenticação, o sistema comparará a imagem facial capturada do utilizador com os dados armazenados para verificar a identidade.

## Instalação e Uso

1. **Clonar o Repositório:** 

Use o Swift Package Manager para instalar e gerenciar dependências da Facing.
No Xcode, com o projeto do seu aplicativo aberto, navegue até File > Add Packages .
Quando solicitado, adicione o repositório SDK das plataformas Apple do Facing:
```swift
  https://github.com/facing/facing-ios-sdk
```
Selecione a versão major do SDK que você deseja usar.
Escolha a biblioteca da Facing.
Quando terminar, o Xcode começará automaticamente a resolver e baixar suas dependências em segundo plano.

2. **Inicialize o SDK na sua aplicação:**

Adicione na info.plist a permissão de acesso á camera:

Privacy - Camera Usage Description: Coloque a descrição que achar mais apropriada


No AppDelagate na funcção ``didFinishLaunchingWithOptions`` adicione o inicio do SDK da Facing

```swift
import Facing

Facing.apiToken = token
```


3. **Utilizar as funcionalidades:**
```swift
Facing().makeRegistration(viewController: self, icaoOptions: icaoOptions, endpoints: endpoints, timerCountdown: countdownTimer) { status, response, error in
    switch status {
        case .succeeded:
            // The registration was made successfully
        case .canceled:
            // The User canceled the operation
        case .failed:
            // There is an error you can check the error variable to see the message
        }
    }
}
```

There are three methods:
1. Facing().makeRegistration(viewController: self, icaoOptions: icaoOptions, endpoints: endpoints, timerCountdown: countdownTimer)
In this method you make the registration of the user biometry

2. Facing().addCard(viewController: self, endpoints: endpointsAddCard)
In this method you verify if the card photo is compatible with the registration biometry

3. Facing().verifyUser(viewController: self, icaoOptions: icaoOptions, endpoints: endpoints)
In This method you verify if the current user biometry is the same of the registration biometry

## License

MIT
