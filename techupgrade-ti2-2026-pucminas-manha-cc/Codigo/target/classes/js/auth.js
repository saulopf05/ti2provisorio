
(function () {
  const mode = document.body.dataset.authMode;
  if (!mode) return;

  const form = document.getElementById('auth-form');
  const showPasswordBtn = document.getElementById('toggle-password');
  const passwordInput = document.getElementById('senha');
  const submitBtn = document.getElementById('auth-submit');

  const fields = {
    nome: document.getElementById('nome'),
    email: document.getElementById('email'),
    senha: document.getElementById('senha'),
    confirmarSenha: document.getElementById('confirmarSenha')
  };

  const errors = {
    nome: document.getElementById('error-nome'),
    email: document.getElementById('error-email'),
    senha: document.getElementById('error-senha'),
    confirmarSenha: document.getElementById('error-confirmarSenha'),
    geral: document.getElementById('error-geral')
  };

  function clearError(name) {
    if (errors[name]) {
      errors[name].textContent = '';
      errors[name].classList.remove('show');
    }
  }

  function setError(name, message) {
    if (errors[name]) {
      errors[name].textContent = message;
      errors[name].classList.add('show');
    }
  }

  function clearAllErrors() {
    Object.keys(errors).forEach(clearError);
  }

  function validate() {
    clearAllErrors();
    let ok = true;
    const isLogin = mode === 'login';

    if (!isLogin) {
      const nome = fields.nome.value.trim();
      if (!nome) {
        setError('nome', 'Nome é obrigatório.');
        ok = false;
      }
    }

    const email = fields.email.value.trim();
    if (!email) {
      setError('email', 'E-mail é obrigatório.');
      ok = false;
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('email', 'E-mail inválido.');
      ok = false;
    }

    const senha = fields.senha.value;
    if (!senha) {
      setError('senha', 'Senha é obrigatória.');
      ok = false;
    } else if (senha.length < 6) {
      setError('senha', 'Senha deve ter pelo menos 6 caracteres.');
      ok = false;
    }

    if (!isLogin && fields.confirmarSenha.value !== senha) {
      setError('confirmarSenha', 'As senhas não coincidem.');
      ok = false;
    }

    return ok;
  }

  if (showPasswordBtn && passwordInput) {
    showPasswordBtn.addEventListener('click', function () {
      const isPassword = passwordInput.getAttribute('type') === 'password';
      passwordInput.setAttribute('type', isPassword ? 'text' : 'password');
      showPasswordBtn.textContent = isPassword ? 'Ocultar' : 'Mostrar';
    });
  }

  ['nome', 'email', 'senha', 'confirmarSenha'].forEach(function (name) {
    if (fields[name]) {
      fields[name].addEventListener('input', function () {
        clearError(name);
        clearError('geral');
      });
    }
  });

  form.addEventListener('submit', async function (event) {
    event.preventDefault();
    if (!validate()) return;

    const isLogin = mode === 'login';
    submitBtn.disabled = true;
    submitBtn.textContent = isLogin ? 'Entrando...' : 'Criando conta...';

    try {
      if (isLogin) {
        const response = await fetch(window.TechUpgrade.API_URL + '/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            email: fields.email.value.trim(),
            senha: fields.senha.value
          })
        });

        if (!response.ok) {
          throw new Error('Erro ao fazer login.');
        }

        const data = await response.json();
        if (data.token) {
          localStorage.setItem('token', data.token);
        }
        const stored = window.TechUpgrade.getStoredUser() || {};
        window.TechUpgrade.setStoredUser({
          nome: stored.nome || (fields.email.value.trim().split('@')[0]),
          email: fields.email.value.trim(),
          dataCadastro: stored.dataCadastro || new Date().toISOString().slice(0, 10)
        });
        window.location.href = 'analisar.html';
      } else {
        const response = await fetch(window.TechUpgrade.API_URL + '/auth/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            nome: fields.nome.value.trim(),
            email: fields.email.value.trim(),
            senha: fields.senha.value
          })
        });

        if (!response.ok) {
          throw new Error('Erro ao criar conta.');
        }

        window.TechUpgrade.setStoredUser({
          nome: fields.nome.value.trim(),
          email: fields.email.value.trim(),
          dataCadastro: new Date().toISOString().slice(0, 10)
        });
        window.location.href = 'login.html';
      }
    } catch (error) {
      setError('geral', error.message || 'Não foi possível concluir a operação.');
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = isLogin ? 'Entrar' : 'Criar conta';
    }
  });
})();
