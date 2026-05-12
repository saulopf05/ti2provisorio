
(function () {
  if (document.body.dataset.page !== 'recomendacoes') return;

  const root = document.getElementById('recommendations-root');
  const params = new URLSearchParams(window.location.search);
  const objetivo = params.get('objetivo') || 'gaming';
  const objectiveLabels = {
    gaming: 'Gaming',
    design: 'Design Gráfico',
    trabalho: 'Trabalho/Escritório',
    streaming: 'Streaming/Criação',
    programacao: 'Programação',
    estudos: 'Estudos'
  };

  const iconById = {
    gpu: '🖥️',
    ram: '🧠',
    storage: '💾',
    cpu: '⚙️',
    placaMae: '🔌',
    default: '⚙️'
  };

  function parseAnalysis() {
    try {
      return JSON.parse(localStorage.getItem('ultimaAnalise') || 'null');
    } catch (e) {
      return null;
    }
  }

  function normalizeComponents(analysis) {
    if (!analysis) return [];
    const source = Array.isArray(analysis.componentes)
      ? analysis.componentes
      : Array.isArray(analysis.components)
      ? analysis.components
      : [];

    return source.map(function (item, index) {
      const id = item.id || item.tipo || item.nome || ('component-' + index);
      const status = item.status === 'adequado' ? 'adequado' : 'inadequado';
      return {
        id: id,
        name: item.nome || item.name || ('Componente ' + (index + 1)),
        currentSpec: item.specAtual || item.currentSpec || 'Especificação não informada',
        status: status,
        message: item.mensagem || item.message || 'Sem observações detalhadas.',
        recommendedSpec: item.recomendacao || item.recommendedSpec || '',
        price: item.precoMedio || item.price || '',
        kabumLink: item.linkCompra || item.kabumLink || '',
        icon: iconById[id] || iconById.default
      };
    });
  }

  function renderNoAnalysis() {
    root.innerHTML = [
      '<div style="max-width: 760px;">',
      '  <a class="text-primary" style="font-weight:700;" href="analisar.html">← Voltar para análise</a>',
      '  <div class="section-title mt-3">',
      '    <h2>Nenhuma análise encontrada</h2>',
      '    <p>Faça uma nova análise para visualizar as recomendações do seu PC.</p>',
      '  </div>',
      '  <div class="card full empty-state">',
      '    <div class="empty-icon">🧩</div>',
      '    <p class="muted-text">Não encontramos dados salvos da análise no navegador.</p>',
      '    <div class="inline-actions mt-3" style="justify-content:center;">',
      '      <a class="btn btn-primary" href="analisar.html">Fazer nova análise</a>',
      '    </div>',
      '  </div>',
      '</div>'
    ].join('');
  }

  function renderAnalysis(components) {
    const adequados = components.filter(function (item) { return item.status === 'adequado'; }).length;
    const inadequados = components.filter(function (item) { return item.status === 'inadequado'; }).length;
    const total = components.length;
    const pcAdequado = inadequados === 0 && total > 0;

    const summaryCardClass = pcAdequado ? 'summary-card good' : 'summary-card bad';
    const summaryIcon = pcAdequado ? '👍' : '👎';
    const summaryTitle = pcAdequado
      ? 'Seu PC é adequado para ' + (objectiveLabels[objetivo] || objetivo) + '!'
      : 'Seu PC precisa de melhorias para ' + (objectiveLabels[objetivo] || objetivo);
    const summaryText = pcAdequado
      ? 'Sua configuração atende aos requisitos necessários. Aproveite!'
      : 'Identificamos ' + inadequados + ' componente(s) que precisam de upgrade. Veja abaixo as recomendações com links para compra.';

    const componentCards = components.map(function (component) {
      const good = component.status === 'adequado';
      return [
        '<article class="component-card ' + (good ? 'good' : 'bad') + '">',
        '  <div class="component-card-header">',
        '    <div class="component-card-main">',
        '      <div class="component-icon ' + (good ? 'good' : 'bad') + '">' + component.icon + '</div>',
        '      <div>',
        '        <h3>' + window.TechUpgrade.escapeHtml(component.name) + '</h3>',
        '        <p>' + window.TechUpgrade.escapeHtml(component.currentSpec) + '</p>',
        '      </div>',
        '    </div>',
        '    <span class="status-badge ' + (good ? 'good' : 'bad') + '">' + (good ? '✅ Adequado' : '❌ Inadequado') + '</span>',
        '  </div>',
        '  <div class="component-card-body">',
        '    <p>' + window.TechUpgrade.escapeHtml(component.message) + '</p>',
             !good && component.recommendedSpec ? [
        '    <div class="upgrade-box">',
        '      <div><strong>Recomendação de upgrade:</strong></div>',
        '      <div style="font-size:1.15rem;font-weight:800;">' + window.TechUpgrade.escapeHtml(component.recommendedSpec) + '</div>',
        '      <div style="display:flex;flex-wrap:wrap;gap:16px;justify-content:space-between;align-items:center;">',
        '        <div>',
        '          <div class="muted-text">Preço médio:</div>',
        '          <div class="upgrade-price">' + window.TechUpgrade.escapeHtml(component.price || 'Preço não informado') + '</div>',
        '        </div>',
                 component.kabumLink ? '<a class="btn btn-kabum" target="_blank" rel="noopener noreferrer" href="' + component.kabumLink + '">Ver na KaBuM!</a>' : '',
        '      </div>',
        '    </div>'
             ].join('') : '',
        '  </div>',
        '</article>'
      ].join('');
    }).join('');

    root.innerHTML = [
      '<div class="section-title">',
      '  <a class="text-primary" style="font-weight:700;" href="analisar.html">← Fazer nova análise</a>',
      '  <div>',
      '    <h2>Resultado da Análise</h2>',
      '    <p>Objetivo selecionado: <strong>' + (objectiveLabels[objetivo] || window.TechUpgrade.escapeHtml(objetivo)) + '</strong></p>',
      '  </div>',
      '</div>',
      '<section class="' + summaryCardClass + '">',
      '  <div class="summary-icon">' + summaryIcon + '</div>',
      '  <h2>' + summaryTitle + '</h2>',
      '  <p class="muted-text mt-2">' + summaryText + '</p>',
      '  <div class="summary-counts">',
      '    <span><i class="status-dot good"></i> ' + adequados + ' adequados</span>',
      '    <span><i class="status-dot bad"></i> ' + inadequados + ' inadequados</span>',
      '  </div>',
      '</section>',
      '<section class="section-title mt-4">',
      '  <h2>Detalhes por Componente</h2>',
      '  <p>Veja o status de cada peça e, quando necessário, a recomendação de upgrade.</p>',
      '</section>',
      '<div class="component-list">' + componentCards + '</div>',
      '<div class="final-actions mt-4">',
      '  <button class="btn btn-secondary" type="button" id="share-result-btn">Compartilhar resultado</button>',
      '  <a class="btn btn-primary" href="analisar.html">Nova análise</a>',
      '</div>',
      '<p class="muted-text text-center mt-4">Os preços exibidos são estimativas e podem variar. Verifique diretamente no site da loja antes de comprar.</p>'
    ].join('');

    const shareBtn = document.getElementById('share-result-btn');
    if (shareBtn) {
      shareBtn.addEventListener('click', async function () {
        const text = 'Resultado da minha análise no TechUpgrade para ' + (objectiveLabels[objetivo] || objetivo) + '.';
        if (navigator.share) {
          try {
            await navigator.share({ title: 'TechUpgrade', text: text, url: window.location.href });
          } catch (e) {}
        } else if (navigator.clipboard) {
          try {
            await navigator.clipboard.writeText(window.location.href);
            alert('Link copiado para a área de transferência.');
          } catch (e) {
            alert(text);
          }
        } else {
          alert(text);
        }
      });
    }
  }

  const analysis = parseAnalysis();
  const components = normalizeComponents(analysis);
  if (!analysis || !components.length) {
    renderNoAnalysis();
  } else {
    renderAnalysis(components);
  }
})();
