# Guia de Publicação no TestFlight (Via GitHub Actions)

Este pacote contém o projeto nativo completo em SwiftUI e a automação de CI/CD para compilar e enviar o build para o Apple TestFlight usando os servidores macOS do GitHub Actions.

## 📁 Estrutura de Arquivos Criada
- `ParceiroAutonomo/`: Todo o código SwiftUI nativo (`.swift`) e `Info.plist`.
- `project.yml`: Arquivo de especificação para gerar o projeto Xcode automaticamente (`.xcodeproj`).
- `ExportOptions.plist`: Configuração de assinatura e empacotamento App Store / TestFlight.
- `.github/workflows/deploy_testflight.yml`: Pipeline automatizada no GitHub Actions que roda em máquina macOS runner oficial com Xcode.

---

## 🔑 Configuração dos Secrets no seu Repositório GitHub
Para que o GitHub Actions consiga assinar o app e enviar para a sua conta da Apple Developer / TestFlight, acesse:
**GitHub ➔ Seu Repositório ➔ Settings ➔ Secrets and variables ➔ Actions ➔ New repository secret**

Cadastre as seguintes 5 chaves:

1. `BUILD_CERTIFICATE_BASE64`: Seu certificado de distribuição da Apple (`.p12`) convertido em Base64.
2. `P12_PASSWORD`: A senha que você definiu ao exportar o arquivo `.p12`.
3. `BUILD_PROVISION_PROFILE_BASE64`: Seu perfil de provisionamento da App Store (`.mobileprovision`) em Base64.
4. `KEYCHAIN_PASSWORD`: Qualquer senha segura para a keychain temporária do runner (ex: `temp123456`).
5. `APP_STORE_CONNECT_PRIVATE_KEY`: Conteúdo da chave de API (`AuthKey_XXXX.p8`) gerada no App Store Connect.
6. `APP_STORE_CONNECT_KEY_ID`: O ID da Chave da API (Key ID).
7. `APP_STORE_CONNECT_ISSUER_ID`: O Issuer ID do App Store Connect.

---

## 🚀 Como Disparar o Build
1. Faça o commit e push dos arquivos desta pasta para o seu repositório no GitHub:
   ```bash
   git add .
   git commit -m "Adiciona projeto iOS e pipeline do TestFlight"
   git push origin main
   ```
2. O GitHub Actions detectará o push e executará o workflow em uma máquina Mac na nuvem.
3. Ao finalizar, o app aparecerá automaticamente no painel do **App Store Connect ➔ TestFlight** pronto para você e seus testadores instalarem no iPhone!
