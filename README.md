# ![Lodestone Compass](https://static.wikia.nocookie.net/minecraft_gamepedia/images/9/9e/Lodestone_Compass_JE2_BE2.gif/revision/latest/scale-to-width/40?cb=20201204210510) Quebra-Galho

## 📌 O que o projeto faz?

O **Quebra-Galho** é um aplicativo Flutter focado em auxiliar pessoas em medições de campo. Ele permite marcar pontos via GPS, calcular áreas geográficas e distâncias com facilidade e armazenar esses dados localmente ou compartilhar com outros usuários via nuvem (Firebase).

O app é voltado principalmente para pequenos produtores rurais, estudantes de geografia ou qualquer pessoa que deseje realizar medições simples e precisas em campo.

---

## 🧠 Tecnologias Utilizadas

- Flutter 💙  
- Dart ⚙️  
- SQLite 🗃️ (persistência local)  
- Firebase 🔥 (autenticação e Firestore para compartilhamento)  
- Geolocator 📍 (geolocalização via GPS)  

---

## 🗂️ Banco de Dados

O projeto utiliza dois tipos de persistência:

### 🔹 Local — SQLite
- **Tabela de Usuários**: login e senha (offline)
- **Tabela de Áreas Salvas**: coordenadas, título, área calculada
- Suporte completo a **CRUD** (criar, ler, atualizar, deletar)

### 🔸 Nuvem — Firebase Firestore
- Compartilhamento de áreas salvas entre usuários
- Estrutura segura e escalável baseada em autenticação

---

## 🧪 Funcionalidades

- 📍 Marcação de pontos via GPS em tempo real  
- 📐 Cálculo automático de área entre pontos (polígonos)  
- 💾 Salvamento local das medições  
- ✏️ Edição e exclusão de áreas salvas  
- 📤 Compartilhamento de áreas com outros usuários logados  
- 🌙 Tema escuro/claro dinâmico  
- 🧭 Bússola digital integrada  
- 🔎 Busca responsiva com animações fluídas  

---

## 👨‍👩‍👧‍👦 Equipe

| Nome                          | Função                                                          |
|------------------------------|------------------------------------------------------------------|
| Bruna Cristine Pereira       | Desenvolvedora Front-end • Design                                |
| Bruno Rafael Santos Oliveira | Desenvolvedor Front-end • Back-end • Firebase • Documentação • Design    |
| Daniel Felipe C. de Freitas  | Scrum Master                                                     |
| Thiago Pereira de Oliveira   | Desenvolvedor Back-end • Firebase                                |

---

## 🔍 Sprint 4 — Documentação

### ✅ Funcionalidades implementadas:
- Integração com Firebase Auth e Firestore  
- Compartilhamento funcional de áreas salvas  
- Tela de bússola e troca dinâmica de tema  
- Busca responsiva e refinamento de usabilidade  
- Persistência local e sincronização básica  

### 🐞 Desafios encontrados:
- Problemas na inicialização e configuração do Firebase  
- Integração entre SQLite e Firebase exigindo reestruturação da lógica  
- Gerenciamento do tema escuro/claro em tempo real com Provider  

### 📈 Próximos passos:
- Implementar notificações de recebimento de áreas  
- Adicionar login com conta Google  
- Melhorar a usabilidade da tela de compartilhamento  
- Publicar versão beta na Play Store  
- Finalizar documentação e vídeo de apresentação  

---

## ✅ Checklist Final

- [✅] Funcionalidades principais implementadas  
- [✅] Banco de dados local com persistência  
- [✅] Compartilhamento entre usuários via Firebase  
- [✅] Interface amigável e responsiva  
- [✅] Código modular e comentado  
- [✅] Otimização de desempenho  

---

## 📎 Apêndice

Esse projeto nos ajudou a compreender:

- Integração de **Flutter com sensores nativos** (GPS, bússola)  
- Comunicação entre **dados locais e em nuvem**  
- **Firebase Auth** e Firestore com controle de acesso  
- Gerenciamento de estado com **Provider**  
- Boas práticas de **design responsivo** e experiência do usuário  

---

🔗 Repositório: [📎 Acessar no GitHub](https://github.com/theE008/LDDM_Quebra-Galho)

🎬 Trailer: https://youtube.com/shorts/WX3XC44-AuQ?si=o_tJ2c4-V9jqWfbp
