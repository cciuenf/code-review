# CodeReview

CodeReview é uma plataforma de revisão colaborativa de código projetada para permitir que usuários submetam snippets de código, recebam feedback, participem de discussões e aprendam coletivamente. A plataforma inicialmente oferece uma interface CLI (Command Line Interface) com planos futuros para expandir para uma interface gráfica de usuário.

## Funcionalidades

- **Submissão de Código**: Usuários podem submeter snippets de código com descrições e especificações de linguagem.
- **Feedback e Comentários**: Permite que usuários postem comentários sobre os códigos submetidos e criem discussões.
- **Votação em Comentários**: Usuários podem votar em comentários para promover feedback útil.
- **Histórico de Revisões**: Visualização de todo o histórico de modificações feitas nos snippets de código.

## Instalação

Para começar a usar o CodeReview, siga os passos abaixo para configurar o ambiente localmente.

### Pré-requisitos

- Elixir 1.16 ou superior
- Erlang/OTP 26 ou superior

### Configuração

1. Clone o repositório:

   ```bash
   git clone https://github.com/zoedsoupe/code-review.git
   cd code-review
   ```

2. Instale as dependências do projeto:

   ```bash
   mix deps.get
   ```

3. Compile o projeto:

   ```bash
   mix compile
   ```

4. Compile a CLI em modo de desenvolvimento:

   ```bash
   mix release
   ```
Dessa forma vai haver um arquivo `code-review`

## Uso

Para interagir com o sistema através da CLI, use os seguintes comandos:

- Submeter novo código:

  ```bash
  code-review submit --author "author_id" --code "code_content" --lang "language" --desc "description"
  ```

- Adicionar um comentário:

  ```bash
  code-review comment --code_id "code_id" --commenter "commenter_id" --text "Your comment here"
  ```

- Votar em um comentário:

  ```bash
  code-review vote --comment_id "comment_id" --voter_id "voter_id" --type "upvote"
  ```

- Consultar o histórico de revisões:

  ```bash
  code-review history --code_id "code_id"
  ```

## Contribuindo

Contribuições são o que fazem a comunidade open source um lugar incrível para aprender, inspirar e criar. Qualquer contribuição que você fizer será **muito apreciada**.

1. Faça um Fork do projeto
2. Crie sua Feature Branch (`git switch -b feature/AmazingFeature`)
3. Faça commit de suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Faça Push para a Branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Distribuído sob a Licença MIT. Veja `LICENSE` para mais informações.

## Contato

[@zoedsoupe](https://github.com/zoedsoupe) ou me mande um email [zoey.spessanha@icloud.com](mailto:zoey.spessanha@zeetech.io)
