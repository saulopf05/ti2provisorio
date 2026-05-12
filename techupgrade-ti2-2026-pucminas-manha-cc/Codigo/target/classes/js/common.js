
(function () {
  const body = document.body;
  const currentPage = body.dataset.page || 'home';
  const pageMap = {
    home: 'index.html',
    analisar: 'analisar.html',
    'como-funciona': 'como-funciona.html',
    login: 'login.html',
    cadastro: 'cadastro.html',
    perfil: 'perfil.html',
    recomendacoes: 'recomendacoes.html'
  };

  function getToken() {
    return localStorage.getItem('token') || '';
  }

  function isLoggedIn() {
    return !!getToken();
  }

  function getStoredUser() {
    try {
      return JSON.parse(localStorage.getItem('techupgrade_user') || 'null');
    } catch (e) {
      return null;
    }
  }

  function setStoredUser(user) {
    localStorage.setItem('techupgrade_user', JSON.stringify(user));
  }

  function clearSession() {
    localStorage.removeItem('token');
    localStorage.removeItem('techupgrade_user');
  }

  function currentYear() {
    return new Date().getFullYear();
  }

  function navLink(href, label, key) {
    const active = currentPage === key ? 'active' : '';
    return '<a class="' + active + '" href="' + href + '">' + label + '</a>';
  }

  function renderHeader() {
    const headerMount = document.getElementById('site-header');
    if (!headerMount) return;

    const logged = isLoggedIn();
    let desktopAuth = '';
    let mobileAuth = '';

    if (logged) {
      desktopAuth = [
        '<a class="btn btn-secondary" href="perfil.html">Meu Perfil</a>',
        '<button class="btn btn-ghost" type="button" id="logout-btn-header">Sair</button>'
      ].join('');
      mobileAuth = [
        '<a href="perfil.html">Meu Perfil</a>',
        '<button class="link-btn" type="button" id="logout-btn-mobile">Sair</button>'
      ].join('');
    } else {
      desktopAuth = [
        '<a class="btn btn-ghost" href="login.html">Entrar</a>',
        '<a class="btn btn-primary" href="cadastro.html">Criar Conta</a>'
      ].join('');
      mobileAuth = [
        '<a href="login.html">Entrar</a>',
        '<a href="cadastro.html">Criar Conta</a>'
      ].join('');
    }

    headerMount.innerHTML = [
      '<header class="site-header">',
      '  <div class="container">',
      '    <div class="header-inner">',
      '      <a class="brand" href="index.html">',
      '        <span class="brand-mark">TU</span>',
      '        <span>TechUpgrade</span>',
      '      </a>',
      '      <nav class="nav-links">',
               navLink('index.html', 'Início', 'home'),
               navLink('analisar.html', 'Analisar PC', 'analisar'),
               navLink('como-funciona.html', 'Como Funciona', 'como-funciona'),
      '      </nav>',
      '      <div class="auth-links">' + desktopAuth + '</div>',
      '      <button class="mobile-menu-btn" type="button" id="mobile-menu-btn" aria-label="Abrir menu">☰</button>',
      '    </div>',
      '    <div class="mobile-menu" id="mobile-menu">',
      '      <div class="mobile-panel">',
               navLink('index.html', 'Início', 'home'),
               navLink('analisar.html', 'Analisar PC', 'analisar'),
               navLink('como-funciona.html', 'Como Funciona', 'como-funciona'),
      '        <div class="mobile-actions">' + mobileAuth + '</div>',
      '      </div>',
      '    </div>',
      '  </div>',
      '</header>'
    ].join('');

    const menuBtn = document.getElementById('mobile-menu-btn');
    const menu = document.getElementById('mobile-menu');
    if (menuBtn && menu) {
      menuBtn.addEventListener('click', function () {
        menu.classList.toggle('open');
        menuBtn.textContent = menu.classList.contains('open') ? '✕' : '☰';
      });
    }

    const logoutDesktop = document.getElementById('logout-btn-header');
    const logoutMobile = document.getElementById('logout-btn-mobile');
    function handleLogout() {
      clearSession();
      window.location.href = 'index.html';
    }
    if (logoutDesktop) logoutDesktop.addEventListener('click', handleLogout);
    if (logoutMobile) logoutMobile.addEventListener('click', handleLogout);
  }

  function renderFooter() {
    const footerMount = document.getElementById('site-footer');
    if (!footerMount) return;

    footerMount.innerHTML = [
      '<footer class="site-footer">',
      '  <div class="container">',
      '    <div class="footer-grid">',
      '      <div class="footer-col">',
      '        <a class="brand" href="index.html"><span class="brand-mark">TU</span><span>TechUpgrade</span></a>',
      '        <p class="mt-2">Recomendações inteligentes de hardware para melhorar o desempenho do seu PC.</p>',
      '      </div>',
      '      <div class="footer-col">',
      '        <h4>Navegação</h4>',
      '        <ul>',
      '          <li><a href="index.html">Início</a></li>',
      '          <li><a href="analisar.html">Analisar PC</a></li>',
      '          <li><a href="como-funciona.html">Como Funciona</a></li>',
      '        </ul>',
      '      </div>',
      '      <div class="footer-col">',
      '        <h4>Conta</h4>',
      '        <ul>',
      '          <li><a href="login.html">Entrar</a></li>',
      '          <li><a href="cadastro.html">Criar Conta</a></li>',
      '          <li><a href="perfil.html">Meu Perfil</a></li>',
      '        </ul>',
      '      </div>',
      '      <div class="footer-col">',
      '        <h4>Suporte</h4>',
      '        <ul>',
      '          <li><a href="#">Ajuda</a></li>',
      '          <li><a href="#">Contato</a></li>',
      '          <li><a href="#">Termos de Uso</a></li>',
      '        </ul>',
      '      </div>',
      '    </div>',
      '    <div class="footer-bottom">' + currentYear() + ' TechUpgrade. Todos os direitos reservados.</div>',
      '  </div>',
      '</footer>'
    ].join('');
  }

  function setPageTitle(defaultTitle) {
    if (document.title) return;
    document.title = defaultTitle;
  }

  function escapeHtml(value) {
    return String(value == null ? '' : value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  window.TechUpgrade = {
    API_URL: window.TechUpgradeConfig.API_URL,
    getToken,
    isLoggedIn,
    getStoredUser,
    setStoredUser,
    clearSession,
    escapeHtml,
    renderHeader,
    renderFooter,
    setPageTitle,
    pageMap,
    currentPage
  };

  if (body.dataset.layout !== 'none') {
    renderHeader();
    renderFooter();
  }
})();
