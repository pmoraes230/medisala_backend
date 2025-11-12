# MediSala Backend

API RESTful para o sistema **MediSala** – gerenciamento de salas, reservas e usuários no SENAC PA.

> **Sem JWT** – Autenticação por **sessão do Django** (login no frontend)  
> **API pública** – Dados visíveis sem credenciais (proteção no frontend)  
> **Procedures MySQL** – CRUD via `CALL insert_usuario(...)`

---

## Tecnologias

| Tecnologia | Versão |
|----------|--------|
| Python | 3.13 |
| Django | 5.2+ |
| Django REST Framework | 3.14+ |
| MySQL | 8.0+ |
| django-cors-headers | 4.3+ |

---


---

## Instalação

```bash
# 1. Clone o projeto
git clone https://github.com/seu-usuario/medisala-backend.git
cd medisala-backend

# 2. Crie ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# 3. Instale dependências
pip install -r requirements.txt

# 4. Configure .env
cp .env.example .env
# Edite com suas credenciais MySQL

# 5. Rode migrações (cria auth_user, session, etc.)
python manage.py makemigrations
python manage.py migrate

# 6. Inicie o servidor
python manage.py runserver