// js/modal.js

(function () {
  const overlay = document.getElementById('modalOverlay');
  const title   = document.getElementById('modalTitle');
  const body    = document.getElementById('modalBody');
  const confirm = document.getElementById('modalConfirm');
  const cancel  = document.getElementById('modalCancel');

  // Abre el modal con los datos del botón pulsado
  function openModal(trigger) {
    title.textContent = trigger.dataset.title;
    body.innerHTML    = trigger.dataset.body;
    confirm.href      = trigger.dataset.href;
    overlay.removeAttribute('hidden');
    cancel.focus();
  }

  // Cierra el modal
  function closeModal() {
    overlay.setAttribute('hidden', '');
    confirm.href = '#';
  }

  // Clic en cualquier botón con clase .js-modal-trigger
  document.addEventListener('click', function (e) {
    const trigger = e.target.closest('.js-modal-trigger');
    if (trigger) openModal(trigger);
  });

  // Cerrar con el botón Cancelar
  cancel.addEventListener('click', closeModal);

  // Cerrar al hacer clic fuera del modal (en el overlay)
  overlay.addEventListener('click', function (e) {
    if (e.target === overlay) closeModal();
  });

  // Cerrar con la tecla Escape
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeModal();
  });

})();

// ----------------------------------------------------------
// Garantiza que solo un tipo especial esté marcado a la vez
// Se llama desde onchange="soloUno(this)" en materias.php
// Debe estar fuera del IIFE para ser accesible desde el HTML
// ----------------------------------------------------------
function soloUno(checkbox) {
  const checkboxes = document.querySelectorAll(
    'input[name="es_ingles"], input[name="es_artes"], input[name="es_higiene"]'
  );
  checkboxes.forEach(function (cb) {
    if (cb !== checkbox) cb.checked = false;
  });
}