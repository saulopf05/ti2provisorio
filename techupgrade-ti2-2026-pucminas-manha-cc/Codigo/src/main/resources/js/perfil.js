
(function () {
  if (document.body.dataset.page !== 'perfil') return;

  const root = document.getElementById('profile-root');
  const fallbackUser = {
    nome: 'João Silva',
    email: 'joao.silva@email.com',
    dataCadastro: '2024-01-15'
  };

  function loadUser() {
    const stored = window.TechUpgrade.getStoredUser();
    return Object.assign({}, fallbackUser, stored || {});
  }

  function loadHistory() {
    try {
      const raw = JSON.parse(localStorage.getItem('historicoAnalises') || '[]');
      return Array.isArray(raw) ? raw : [];
    } catch (e) {
      return [];
    }
  }

  function formatDate(value) {
    const date = new Date(value + 'T00:00:00');
    return date.toLocaleDateString('pt-BR', { day: '2-digit', month: 'long', year: 'numeric' });
  }

  function objectiveLabel(value) {
    const labels = {
      gaming: 'Gaming',
      design: 'Design Gráfico',
      trabalho: 'Trabalho/Escritório',
      streaming: 'Streaming/Criação',
      programacao: 'Programação',
      estudos: 'Estudos'
    };
    return labels[value] || 'Upgrade Geral';
  }

  function render() {
    const user = loadUser();
    const history = loadHistory();
    root.innerHTML = [
      '<div class="profile-header">',
      '  <div class="profile-user">',
      '    <div class="profile-avatar">' + window.TechUpgrade.escapeHtml((user.nome || 'U').charAt(0).toUpperCase()) + '</div>',
      '    <div>',
      '      <h1 class="mt-0 mb-0">' + window.TechUpgrade.escapeHtml(user.nome) + '</h1>',
      '      <p class="muted-text mt-1">' + window.TechUpgrade.escapeHtml(user.email) + '</p>',
      '    </div>',
      '  </div>',
      '  <button class="btn btn-secondary" type="button" id="profile-logout-btn">Sair</button>',
      '</div>',
      '<div class="tabs">',
      '  <button class="tab-btn active" type="button" data-tab="perfil">Perfil</button>',
      '  <button class="tab-btn" type="button" data-tab="historico">Histórico</button>',
      '  <button class="tab-btn" type="button" data-tab="configuracoes">Configurações</button>',
      '</div>',
      '<section class="tab-panel active" data-panel="perfil">',
      '  <div class="card tab-card">',
      '    <div class="tab-card-header">',
      '      <div><h2>Informações Pessoais</h2><p class="muted-text mt-1">Gerencie seus dados de perfil.</p></div>',
      '      <div>',
      '        <button class="btn btn-secondary" type="button" id="edit-profile-btn">Editar</button>',
      '        <button class="btn btn-secondary hidden" type="button" id="cancel-profile-btn">Cancelar</button>',
      '        <button class="btn btn-primary hidden" type="button" id="save-profile-btn">Salvar</button>',
      '      </div>',
      '    </div>',
      '    <div class="form-grid">',
      '      <div class="field"><label for="profile-name">Nome completo</label><input id="profile-name" type="text" value="' + window.TechUpgrade.escapeHtml(user.nome) + '" disabled></div>',
      '      <div class="field"><label for="profile-email">E-mail</label><input id="profile-email" type="email" value="' + window.TechUpgrade.escapeHtml(user.email) + '" disabled></div>',
      '      <div class="subdued-box">Membro desde: <strong>' + formatDate(user.dataCadastro) + '</strong></div>',
      '    </div>',
      '  </div>',
      '</section>',
      '<section class="tab-panel" data-panel="historico">',
      '  <div class="card tab-card">',
      '    <div class="tab-card-header"><div><h2>Histórico de Análises</h2><p class="muted-text mt-1">Veja todas as análises que você já fez.</p></div></div>',
      '    <div id="history-container">' + renderHistory(history) + '</div>',
      '  </div>',
      '</section>',
      '<section class="tab-panel" data-panel="configuracoes">',
      '  <div class="card tab-card">',
      '    <div class="tab-card-header"><div><h2>Alterar Senha</h2><p class="muted-text mt-1">Atualize sua senha de acesso.</p></div></div>',
      '    <div class="form-grid">',
      '      <div class="field"><label for="current-password">Senha atual</label><input id="current-password" type="password" placeholder="••••••••"></div>',
      '      <div class="field"><label for="new-password">Nova senha</label><input id="new-password" type="password" placeholder="••••••••"></div>',
      '      <div class="field"><label for="confirm-password">Confirmar nova senha</label><input id="confirm-password" type="password" placeholder="••••••••"></div>',
      '      <div><button class="btn btn-primary" type="button" id="change-password-btn">Alterar senha</button></div>',
      '    </div>',
      '  </div>',
      '  <div class="card tab-card danger-card mt-4">',
      '    <div class="tab-card-header"><div><h2>⚠️ Zona de Perigo</h2><p class="muted-text mt-1">Ações irreversíveis para sua conta.</p></div></div>',
      '    <button class="btn btn-danger" type="button" id="show-delete-confirm">Excluir minha conta</button>',
      '    <div class="confirm-box" id="delete-confirm-box">',
      '      <p class="mt-0">Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.</p>',
      '      <div class="inline-actions"><button class="btn btn-secondary" type="button" id="cancel-delete-btn">Cancelar</button><button class="btn btn-danger" type="button" id="confirm-delete-btn">Sim, excluir conta</button></div>',
      '    </div>',
      '  </div>',
      '</section>'
    ].join('');

    bind();
  }

  function renderHistory(history) {
    if (!history.length) {
      return [
        '<div class="empty-state">',
        '  <div class="empty-icon">🖥️</div>',
        '  <p class="muted-text">Você ainda não fez nenhuma análise.</p>',
        '  <div class="inline-actions mt-3" style="justify-content:center;">',
        '    <a class="btn btn-primary" href="analisar.html">Fazer primeira análise</a>',
        '  </div>',
        '</div>'
      ].join('');
    }

    return '<div class="history-list">' + history.map(function (analysis) {
      return [
        '<article class="history-card">',
        '  <div class="history-main">',
        '    <div class="feature-icon">🖥️</div>',
        '    <div>',
        '      <h3 class="mt-0 mb-0">' + (analysis.tipo === 'objetivo-especifico' ? 'Análise para ' + objectiveLabel(analysis.objetivo) : 'Análise de Upgrade Geral') + '</h3>',
        '      <div class="history-meta mt-1">',
        '        <span>📅 ' + new Date(analysis.data + 'T00:00:00').toLocaleDateString('pt-BR') + '</span>',
        '        <span class="small-badge">' + analysis.upgrades + ' upgrade(s) sugerido(s)</span>',
        '      </div>',
        '    </div>',
        '  </div>',
        '  <a class="btn btn-secondary" href="recomendacoes.html?objetivo=' + encodeURIComponent(analysis.objetivo || 'gaming') + '">Ver detalhes</a>',
        '</article>'
      ].join('');
    }).join('') + '</div>';
  }

  function bind() {
    Array.prototype.slice.call(document.querySelectorAll('[data-tab]')).forEach(function (button) {
      button.addEventListener('click', function () {
        const target = button.getAttribute('data-tab');
        Array.prototype.slice.call(document.querySelectorAll('[data-tab]')).forEach(function (item) { item.classList.remove('active'); });
        Array.prototype.slice.call(document.querySelectorAll('[data-panel]')).forEach(function (panel) { panel.classList.remove('active'); });
        button.classList.add('active');
        document.querySelector('[data-panel="' + target + '"]').classList.add('active');
      });
    });

    const logoutBtn = document.getElementById('profile-logout-btn');
    logoutBtn.addEventListener('click', function () {
      window.TechUpgrade.clearSession();
      window.location.href = 'index.html';
    });

    const editBtn = document.getElementById('edit-profile-btn');
    const cancelBtn = document.getElementById('cancel-profile-btn');
    const saveBtn = document.getElementById('save-profile-btn');
    const nameInput = document.getElementById('profile-name');
    const emailInput = document.getElementById('profile-email');
    const originalUser = loadUser();

    function setEditing(editing) {
      nameInput.disabled = !editing;
      emailInput.disabled = !editing;
      editBtn.classList.toggle('hidden', editing);
      cancelBtn.classList.toggle('hidden', !editing);
      saveBtn.classList.toggle('hidden', !editing);
    }

    editBtn.addEventListener('click', function () { setEditing(true); });
    cancelBtn.addEventListener('click', function () {
      nameInput.value = originalUser.nome;
      emailInput.value = originalUser.email;
      setEditing(false);
    });
    saveBtn.addEventListener('click', function () {
      window.TechUpgrade.setStoredUser({
        nome: nameInput.value.trim() || originalUser.nome,
        email: emailInput.value.trim() || originalUser.email,
        dataCadastro: originalUser.dataCadastro
      });
      alert('Dados salvos no navegador.');
      render();
    });

    const changePasswordBtn = document.getElementById('change-password-btn');
    changePasswordBtn.addEventListener('click', function () {
      const current = document.getElementById('current-password').value;
      const next = document.getElementById('new-password').value;
      const confirm = document.getElementById('confirm-password').value;
      if (!current || !next || !confirm) {
        alert('Preencha todos os campos de senha.');
        return;
      }
      if (next !== confirm) {
        alert('As novas senhas não coincidem.');
        return;
      }
      alert('Fluxo visual pronto. Integre este botão ao endpoint real de troca de senha quando o backend estiver disponível.');
    });

    const showDelete = document.getElementById('show-delete-confirm');
    const cancelDelete = document.getElementById('cancel-delete-btn');
    const confirmDelete = document.getElementById('confirm-delete-btn');
    const confirmBox = document.getElementById('delete-confirm-box');
    showDelete.addEventListener('click', function () { confirmBox.classList.add('show'); });
    cancelDelete.addEventListener('click', function () { confirmBox.classList.remove('show'); });
    confirmDelete.addEventListener('click', function () {
      localStorage.removeItem('historicoAnalises');
      localStorage.removeItem('ultimaAnalise');
      window.TechUpgrade.clearSession();
      alert('Conta removida localmente.');
      window.location.href = 'index.html';
    });
  }

  render();
})();
