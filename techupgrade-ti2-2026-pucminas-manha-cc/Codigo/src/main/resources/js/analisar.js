
(function () {
  const page = document.body.dataset.page;
  if (page !== 'analisar') return;

  const objectives = [
    { id: 'gaming', label: 'Gaming', description: 'Jogar jogos pesados com alta qualidade gráfica', icon: '🎮' },
    { id: 'design', label: 'Design Gráfico', description: 'Photoshop, Illustrator, After Effects, Figma', icon: '🎨' },
    { id: 'trabalho', label: 'Trabalho/Escritório', description: 'Navegação, planilhas, videochamadas e e-mails', icon: '💼' },
    { id: 'streaming', label: 'Streaming/Criação', description: 'Lives, edição de vídeo e criação de conteúdo', icon: '🖥️' },
    { id: 'programacao', label: 'Programação', description: 'Desenvolvimento de software, IDEs e compilação', icon: '💻' },
    { id: 'estudos', label: 'Estudos', description: 'Aulas online, pesquisas e trabalhos acadêmicos', icon: '🎓' }
  ];

  let step = 1;
  let uploadedFile = null;
  let imagePreview = null;
  let selectedObjective = null;

  const uploadInput = document.getElementById('analysis-image');
  const uploadBox = document.getElementById('upload-box');
  const uploadStateEmpty = document.getElementById('upload-state-empty');
  const uploadStatePreview = document.getElementById('upload-state-preview');
  const previewImg = document.getElementById('analysis-image-preview');
  const previewName = document.getElementById('analysis-image-name');
  const removeBtn = document.getElementById('remove-image-btn');
  const miniPreview = document.getElementById('selected-image-mini-preview');
  const objectiveGrid = document.getElementById('objective-grid');
  const goStep2Btn = document.getElementById('go-step-2');
  const backStep1Btn = document.getElementById('back-step-1');
  const submitBtn = document.getElementById('submit-analysis');
  const step1Card = document.getElementById('step-1-card');
  const step2Card = document.getElementById('step-2-card');

  function updateProgress() {
    document.getElementById('progress-step-1').classList.toggle('active', step >= 1);
    document.getElementById('progress-step-2').classList.toggle('active', step >= 2);
    document.getElementById('progress-line-1').classList.toggle('active', step >= 2);
    document.getElementById('label-step-1').classList.toggle('active', step >= 1);
    document.getElementById('label-step-2').classList.toggle('active', step >= 2);
    step1Card.classList.toggle('hidden', step !== 1);
    step2Card.classList.toggle('hidden', step !== 2);
  }

  function updateButtons() {
    goStep2Btn.disabled = !uploadedFile;
    submitBtn.disabled = !(uploadedFile && selectedObjective);
  }

  function renderObjectives() {
    objectiveGrid.innerHTML = objectives.map(function (objective) {
      return [
        '<button class="objective-card' + (selectedObjective === objective.id ? ' selected' : '') + '" type="button" data-objective="' + objective.id + '">',
        '  <div class="objective-icon">' + objective.icon + '</div>',
        '  <h3>' + objective.label + '</h3>',
        '  <p>' + objective.description + '</p>',
        '</button>'
      ].join('');
    }).join('');

    Array.prototype.slice.call(objectiveGrid.querySelectorAll('[data-objective]')).forEach(function (button) {
      button.addEventListener('click', function () {
        selectedObjective = button.getAttribute('data-objective');
        renderObjectives();
        updateButtons();
      });
    });
  }

  function renderMiniPreview() {
    if (!imagePreview || !uploadedFile) {
      miniPreview.innerHTML = '';
      miniPreview.classList.add('hidden');
      return;
    }

    miniPreview.classList.remove('hidden');
    miniPreview.innerHTML = [
      '<img src="' + imagePreview + '" alt="Preview" style="width:72px;height:auto;border-radius:12px;object-fit:contain;">',
      '<div>',
      '  <strong>Imagem enviada</strong>',
      '  <p class="muted-text mt-1">' + window.TechUpgrade.escapeHtml(uploadedFile.name) + '</p>',
      '</div>'
    ].join('');
  }

  function renderUploadState() {
    if (!uploadedFile || !imagePreview) {
      uploadStateEmpty.classList.remove('hidden');
      uploadStatePreview.classList.add('hidden');
      previewImg.removeAttribute('src');
      previewName.textContent = '';
    } else {
      uploadStateEmpty.classList.add('hidden');
      uploadStatePreview.classList.remove('hidden');
      previewImg.src = imagePreview;
      previewName.textContent = uploadedFile.name;
    }
    renderMiniPreview();
    updateButtons();
  }

  function loadPreview(file) {
    if (!file || !file.type.startsWith('image/')) {
      alert('Selecione uma imagem válida.');
      return;
    }
    if (file.size > 10 * 1024 * 1024) {
      alert('A imagem deve ter no máximo 10MB.');
      return;
    }
    uploadedFile = file;
    const reader = new FileReader();
    reader.onload = function (event) {
      imagePreview = event.target.result;
      renderUploadState();
    };
    reader.readAsDataURL(file);
  }

  uploadInput.addEventListener('change', function (event) {
    const file = event.target.files && event.target.files[0];
    if (file) loadPreview(file);
  });

  ['dragenter', 'dragover'].forEach(function (name) {
    uploadBox.addEventListener(name, function (event) {
      event.preventDefault();
      uploadBox.classList.add('dragging');
    });
  });

  ['dragleave', 'drop'].forEach(function (name) {
    uploadBox.addEventListener(name, function (event) {
      event.preventDefault();
      uploadBox.classList.remove('dragging');
    });
  });

  uploadBox.addEventListener('drop', function (event) {
    const file = event.dataTransfer.files && event.dataTransfer.files[0];
    if (file) loadPreview(file);
  });

  removeBtn.addEventListener('click', function () {
    uploadedFile = null;
    imagePreview = null;
    uploadInput.value = '';
    renderUploadState();
  });

  goStep2Btn.addEventListener('click', function () {
    if (!uploadedFile) return;
    step = 2;
    updateProgress();
  });

  backStep1Btn.addEventListener('click', function () {
    step = 1;
    updateProgress();
  });

  function saveHistory(analysisResponse) {
    const raw = localStorage.getItem('historicoAnalises');
    let history = [];
    try { history = JSON.parse(raw || '[]'); } catch (e) { history = []; }
    const componentes = Array.isArray(analysisResponse.componentes) ? analysisResponse.componentes : [];
    history.unshift({
      id: String(Date.now()),
      data: new Date().toISOString().slice(0, 10),
      tipo: 'objetivo-especifico',
      objetivo: selectedObjective,
      componentes: componentes.length,
      upgrades: componentes.filter(function (item) { return item.status !== 'adequado'; }).length
    });
    localStorage.setItem('historicoAnalises', JSON.stringify(history.slice(0, 20)));
  }

  submitBtn.addEventListener('click', async function () {
    if (!uploadedFile || !selectedObjective) return;
    submitBtn.disabled = true;
    submitBtn.textContent = 'Analisando...';

    try {
      const formData = new FormData();
      formData.append('imagem', uploadedFile);
      formData.append('objetivo', selectedObjective);

      const headers = {};
      const token = window.TechUpgrade.getToken();
      if (token) headers.Authorization = 'Bearer ' + token;

      const response = await fetch(window.TechUpgrade.API_URL + '/analysis', {
        method: 'POST',
        headers: headers,
        body: formData
      });

      if (!response.ok) {
        throw new Error('Erro ao analisar imagem.');
      }

      const result = await response.json();
      localStorage.setItem('ultimaAnalise', JSON.stringify(result));
      saveHistory(result);
      window.location.href = 'recomendacoes.html?objetivo=' + encodeURIComponent(selectedObjective);
    } catch (error) {
      alert(error.message || 'Não foi possível concluir a análise.');
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Analisar meu PC →';
    }
  });

  renderObjectives();
  renderUploadState();
  updateProgress();
})();
