LAUDO TÉCNICO — OPERAÇÃO RESGATE: DETETIVES DE BUGS

Disciplina: Frameworks
Projeto: Central de Achados e Perdidos
Tecnologias: Flutter, Dart, Firebase Authentication e Cloud Firestore
Objetivo: Identificar, corrigir e validar 12 problemas no aplicativo.

---

1. Introdução

Este laudo apresenta os problemas identificados no código-fonte do aplicativo Central de Achados e Perdidos, desenvolvido em Flutter com integração ao Firebase.

A investigação envolveu a análise do cadastro de ocorrências, da identificação dos usuários, da consulta e filtragem dos objetos, da navegação entre telas, do envio de pistas e do controle de autorização para alterar o status das ocorrências.

As correções propostas buscam garantir a consistência dos dados, o funcionamento adequado das funcionalidades e o compartilhamento correto das informações entre usuários autenticados.

2. Registro dos bugs encontrados

Bug 01 — Identificação incorreta do responsável

Arquivo: "lib/services/central_service.dart"

Sintoma: O campo "autorId" armazenava o e-mail do usuário em vez de seu identificador único.

Causa: O cadastro utilizava "u.email" para preencher o campo destinado à identificação do usuário. Entretanto, a autorização comparava esse valor com "u.uid".

Correção: O campo "autorId" passou a armazenar "usuario.uid", mantendo "autorNome" separado para exibir o nome ou e-mail do responsável.

Teste: Registrar uma ocorrência e conferir no Firestore se "autorId" corresponde ao UID da conta autenticada e se "autorNome" contém o nome esperado.

Bug 02 — Leitura incorreta do identificador do autor

Arquivo: "lib/models/ocorrencia.dart"

Sintoma: O modelo não recuperava corretamente a identidade do responsável pela ocorrência.

Causa: A propriedade "autorId" era preenchida com o conteúdo de "autorNome".

Correção: O método "Ocorrencia.fromDoc()" passou a ler "dados['autorId']" para a identificação e "dados['autorNome']" para o nome de exibição.

Teste: Cadastrar uma ocorrência e verificar se o modelo recupera separadamente o UID e o nome do responsável.

Bug 03 — Inversão do status da ocorrência

Arquivo: "lib/models/ocorrencia.dart"

Sintoma: Ocorrências abertas podiam ser exibidas como resolvidas, e ocorrências resolvidas podiam ser interpretadas como abertas.

Causa: A leitura do campo "resolvido" utilizava uma negação lógica, invertendo o valor armazenado.

Correção: O modelo passou a utilizar diretamente o valor de "dados['resolvido']", considerando "false" como valor padrão.

Teste: Criar uma ocorrência com status "false" e verificar se aparece como “Em aberto”. Em seguida, alterar o status para "true" e confirmar que aparece como “Resolvido”.

Bug 04 — Validação incompleta do cadastro

Arquivo: "lib/pages/central_page.dart"

Sintoma: O sistema permitia tentar registrar uma ocorrência com o título vazio ou com o local vazio.

Causa: A condição de validação utilizava o operador "&&", exigindo que os dois campos estivessem vazios simultaneamente para bloquear o cadastro.

Correção: A condição passou a utilizar "||", impedindo o cadastro quando qualquer um dos campos obrigatórios estiver vazio.

Teste: Tentar cadastrar sem título, sem local e sem preencher nenhum dos dois. Depois, preencher ambos e verificar se o cadastro é permitido.

Bug 05 — Fechamento incorreto após o cadastro

Arquivo: "lib/pages/central_page.dart"

Sintoma: Após registrar uma ocorrência, o aplicativo podia fechar a tela principal em vez de fechar somente o formulário.

Causa: A navegação utilizava o contexto da página principal para executar "Navigator.pop()".

Correção: O método de cadastro passou a receber o contexto do diálogo e fechar especificamente o formulário após o registro bem-sucedido.

Teste: Abrir o formulário, cadastrar uma ocorrência e confirmar que somente o diálogo é fechado, mantendo a central aberta.

Bug 06 — Filtro de ocorrências não resolvidas invertido

Arquivo: "lib/pages/central_page.dart"

Sintoma: Ao ativar o filtro de ocorrências não resolvidas, o aplicativo selecionava os objetos já resolvidos.

Causa: A filtragem utilizava "o.resolvido", selecionando os registros com status verdadeiro.

Correção: O filtro passou a utilizar "!o.resolvido", selecionando apenas as ocorrências abertas.

Teste: Criar uma ocorrência aberta e outra resolvida. Ativar o filtro e verificar se somente a ocorrência aberta aparece.

Bug 07 — Valor incorreto no controle do filtro

Arquivo: "lib/pages/central_page.dart"

Sintoma: O estado visual e o comportamento do filtro podiam ficar inconsistentes com a opção selecionada.

Causa: O método "onChanged" ignorava o valor recebido pelo switch e invertia manualmente a variável "somenteAbertos".

Correção: O estado passou a ser atualizado diretamente com "somenteAbertos = value".

Teste: Ativar e desativar o switch várias vezes, conferindo se a filtragem acompanha corretamente o estado selecionado.

Bug 08 — Navegação sem a ocorrência selecionada

Arquivo: "lib/pages/central_page.dart"

Sintoma: Ao abrir os detalhes de um objeto, a tela não recebia os dados da ocorrência selecionada.

Causa: A navegação criava "DetalhePage()" sem fornecer o argumento obrigatório "ocorrencia".

Correção: A navegação passou a enviar a ocorrência selecionada por meio de "DetalhePage(ocorrencia: ocorrencia)".

Teste: Abrir duas ocorrências diferentes e confirmar que cada tela apresenta o título, o local, a descrição e o responsável correspondentes ao item selecionado.

Bug 09 — Pistas salvas na ocorrência errada

Arquivo: "lib/services/central_service.dart"

Sintoma: As pistas podiam ficar armazenadas em um documento diferente daquele que o usuário estava consultando.

Causa: O método "enviarPista()" utilizava o identificador fixo "pistas" no lugar do parâmetro "ocorrenciaId".

Correção: As pistas passaram a ser gravadas na subcoleção "pistas" do documento correspondente à ocorrência recebida.

Teste: Registrar duas ocorrências, enviar uma pista para cada uma e verificar no Firestore se cada mensagem está armazenada na subcoleção correta.

Bug 10 — Validação e envio incorretos das pistas

Arquivo: "lib/pages/detalhe_page.dart"

Sintoma: O aplicativo impedia o envio de pistas preenchidas e não encaminhava o conteúdo digitado pelo usuário.

Causa: A validação retornava quando o texto não estava vazio, invertendo a condição esperada. Além disso, o serviço era chamado com uma mensagem vazia.

Correção: O envio passou a ser bloqueado somente quando o texto está vazio, utilizando "pista.text.trim()". O conteúdo digitado é enviado ao serviço.

Teste: Tentar enviar uma pista vazia e verificar o aviso. Depois, enviar uma mensagem válida e confirmar que ela aparece na lista de pistas.

Bug 11 — Alteração incorreta do status

Arquivos: "lib/pages/detalhe_page.dart" e "lib/services/central_service.dart"

Sintoma: A ação de marcar uma ocorrência como resolvida ou reabri-la não definia explicitamente o novo estado desejado.

Causa: O serviço utilizava o valor de "item.resolvido" sem receber o estado pretendido pela interface. Isso não garantia a alternância do status.

Correção: O método "alterarStatus()" passou a receber "novoStatus", e a tela envia o valor oposto ao estado atual. A operação também verifica se o UID do usuário corresponde ao autor.

Teste: Como proprietário, marcar uma ocorrência como resolvida e depois reabri-la. Conferir a atualização no Firestore e na listagem. Como outro usuário, tentar realizar a mesma ação e confirmar que o aplicativo apresenta um erro de autorização.

Observação de segurança: A validação no aplicativo deve ser complementada por regras de segurança do Cloud Firestore, impedindo alterações não autorizadas diretamente no banco.

Bug 12 — Fluxo de autenticação inadequado para dispositivos móveis

Arquivo: "lib/pages/gate_page.dart"

Sintoma: O login por Google podia falhar em dispositivos móveis por utilizar um fluxo de autenticação voltado à Web.

Causa: O método "signInWithPopup()" era utilizado sem distinguir a plataforma de execução.

Correção: O código passou a utilizar "signInWithPopup()" na Web e o fluxo nativo com "GoogleSignIn" e "signInWithCredential()" nas plataformas móveis.

Teste: Executar o aplicativo na Web e em um dispositivo móvel devidamente configurado, autenticar com uma conta Google e verificar se a tela principal é exibida. Sair e repetir com outra conta.

3. Investigação multiusuário

Para validar o compartilhamento de dados, devem ser utilizadas duas contas Google distintas.

Cenário A — Cadastro e sincronização

1. Entrar com a conta A.
2. Registrar uma ocorrência.
3. Entrar com a conta B em outra sessão ou dispositivo.
4. Verificar se a ocorrência aparece na listagem da conta B.

Resultado esperado: As duas contas visualizam a mesma ocorrência, pois os dados estão na coleção compartilhada "ocorrencias".

Cenário B — Envio de pistas

1. Selecionar uma ocorrência criada pela conta A.
2. Entrar com a conta B.
3. Enviar uma pista.
4. Conferir a pista na tela de detalhes da mesma ocorrência.
5. Verificar no Firestore se a mensagem foi salva em "ocorrencias/{id}/pistas".

Resultado esperado: A pista aparece associada à ocorrência correta e identifica a conta que a enviou.

Cenário C — Controle de autorização

1. Criar uma ocorrência com a conta A.
2. Confirmar que a conta A pode alterar seu status.
3. Entrar com a conta B e abrir a mesma ocorrência.
4. Verificar se a conta B não recebe o botão para alterar o status.
5. Testar também a autorização diretamente contra o Firestore, utilizando as regras de segurança configuradas.

Resultado esperado: Somente o proprietário pode alterar o status, inclusive quando a tentativa é realizada fora da interface do aplicativo.

4. Considerações sobre segurança

O aplicativo utiliza Firebase Authentication para identificar os usuários e Cloud Firestore para armazenar as ocorrências e as pistas.

A identificação do proprietário deve ser feita pelo UID, pois o nome e o e-mail são informações de exibição e não devem ser utilizados como identificadores de autorização.

As regras do Firestore devem garantir que:

- Apenas usuários autenticados possam criar ocorrências.
- O UID registrado como autor não possa ser falsificado.
- Apenas o proprietário possa alterar o status de sua ocorrência.
- As pistas sejam armazenadas e consultadas na ocorrência correta.
- Campos protegidos, como o autor e o identificador da ocorrência, não possam ser alterados indevidamente.

5. Conclusão

A investigação identificou 12 problemas relacionados à validação de dados, à leitura do modelo, à navegação, à filtragem, ao envio de pistas, à alteração do status e à autenticação.

As correções propostas restabelecem a lógica esperada das funcionalidades e melhoram a consistência dos dados compartilhados entre diferentes usuários.

A validação final deve ser realizada com o aplicativo em execução, utilizando duas contas Google e conferindo os documentos armazenados no Cloud Firestore. Os testes descritos neste laudo representam os procedimentos necessários para comprovar o funcionamento após a aplicação das correções.

Status do laudo: Correções documentadas; validação prática pendente de execução no ambiente Firebase do projeto.