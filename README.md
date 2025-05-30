# MedTimer

Desenvolvido por: Pedro Henrique Viegas da Silva

### Sistema de Lembrete Inteligente de Medicamentos

**MedTimer** é um aplicativo mobile desenvolvido em Flutter com o objetivo de auxiliar usuários no controle e lembrete da administração de medicamentos. A aplicação visa melhorar a adesão ao tratamento farmacológico, especialmente em públicos com dificuldades de memória, politratamentos ou com rotinas intensas.

## Visão Geral

O MedTimer proporciona uma interface intuitiva e moderna, com funcionalidades que incluem:

- Notificações programadas para lembrar o usuário do horário de tomar seus medicamentos.
- Cadastro personalizado de medicamentos e horários.
- Histórico local com persistência de dados.
- Integração com a API da FDA para consulta de informações sobre fármacos.
- Animações suaves com Lottie e design baseado no Material You.

## Objetivo do Projeto

Desenvolver uma solução digital multiplataforma, de fácil utilização, que ofereça funcionalidades práticas para o gerenciamento pessoal de medicamentos, contribuindo para a promoção da saúde e prevenção de falhas terapêuticas.

## Tecnologias Utilizadas

| Tecnologia               | Função principal                              |
|--------------------------|-----------------------------------------------|
| Flutter (Dart)           | Desenvolvimento mobile cross-platform         |
| Hive                     | Armazenamento local e persistência de dados   |
| flutter_local_notifications | Agendamento e exibição de notificações locais |
| Lottie                   | Animações leves e personalizadas              |
| FDA API                  | Consulta externa de dados farmacológicos      |

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                 # Arquivo principal
├── models/                   # Modelos de dados
├── services/                 # Lógicas de notificação e API
├── screens/                  # Telas e navegação
├── widgets/                  # Componentes reutilizáveis
assets/                       # Fontes, imagens e animações
```

## Como Executar Localmente

1. Certifique-se de ter o Flutter instalado: https://flutter.dev/docs/get-started/install
2. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/medtimer.git
   cd medtimer
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Execute o aplicativo:
   ```bash
   flutter run
   ```
5. Para gerar o APK:
   ```bash
   flutter build apk --release
   ```

## Funcionalidades Futuras

- Suporte a múltiplos usuários com sincronização em nuvem.
- Alertas por voz e lembretes inteligentes baseados em localização.
- Integração com wearables (relógios inteligentes).
- Histórico completo de adesão ao tratamento.

## Licença

Este projeto foi desenvolvido para fins acadêmicos, conforme os requisitos de um experimento educacional com base nas normas da Sociedade Brasileira de Computação (SBC).

**Desenvolvido com responsabilidade e propósito em tecnologia para a saúde.**
