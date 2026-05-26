// js/asignaciones.js

(function () {

  const selSeccion    = document.getElementById('seccion');
  const selGrado      = document.getElementById('grado');
  const selGrupo      = document.getElementById('grupo');
  const wrapMaterias  = document.getElementById('wrap-materias');
  const listaMaterias = document.getElementById('lista-materias');
  const btnGuardar    = document.getElementById('btn-guardar');

  if (!selSeccion) return;

  [selSeccion, selGrado, selGrupo].forEach(function (sel) {
    sel.addEventListener('change', renderizarMaterias);
  });

  function renderizarMaterias() {
    const seccion = selSeccion.value;
    const grado   = selGrado.value;
    const grupo   = selGrupo.value;

    if (!seccion || !grado || !grupo) {
      wrapMaterias.hidden     = true;
      btnGuardar.hidden       = true;
      listaMaterias.innerHTML = '';
      return;
    }

    const materiasFiltradas = MATERIAS.filter(function (m) {
      if (parseInt(m.es_higiene) && seccion !== 'secundaria') return false;
      return true;
    });

    listaMaterias.innerHTML = '';
    materiasFiltradas.forEach(function (m) {
      listaMaterias.appendChild(crearBloqueMateria(m, seccion));
    });

    wrapMaterias.hidden = false;
    btnGuardar.hidden   = false;
  }

  function crearBloqueMateria(m, seccion) {
    const div = document.createElement('div');
    div.className = 'materia-bloque';
    div.style.cssText = 'border:1px solid var(--color-border); border-radius:var(--radius-sm); padding:.8rem; margin-bottom:.8rem;';

    const esIngles  = parseInt(m.es_ingles)  === 1;
    const esArtes   = parseInt(m.es_artes)   === 1;
    const esHigiene = parseInt(m.es_higiene) === 1;
    const esTitularMat = (!esArtes && !esHigiene) || esIngles;

    // Profesores según tipo de materia
    let profesores = [];
    if (esArtes || esHigiene) {
      profesores = COCURRICULARES;
    } else if (esIngles) {
      profesores = TITULARES;
    } else if (m.nombre && m.nombre.toLowerCase().includes('franc')) {
      profesores = FRANCES;
    } else {
      profesores = TITULARES;
    }

    // Options campo formativo
    let opsCampo = '<option value="">Sin campo formativo</option>';
    CAMPOS.forEach(function (cf) {
      const sel = parseInt(m.campo_formativo_id) === parseInt(cf.id) ? 'selected' : '';
      opsCampo += `<option value="${cf.id}" ${sel}>${cf.nombre}</option>`;
    });

    // Options maestros
    let opsMaestro = '<option value="">Sin asignar</option>';
    profesores.forEach(function (p) {
      opsMaestro += `<option value="${p.id}">${p.apellido_paterno} ${p.apellido_materno || ''}, ${p.nombre}</option>`;
    });

    // Subcomponente Artes
    let htmlSubcomp = '';
    if (esArtes) {
      let opsSubcomp = '<option value="">Selecciona subcomponente…</option>';
      SUBCOMPS.forEach(function (s) {
        opsSubcomp += `<option value="${s.id}">${s.nombre}</option>`;
      });
      htmlSubcomp = `
        <div style="margin-top:.5rem;">
          <label style="font-size:.78rem;color:var(--color-muted);">Subcomponente *</label>
          <select name="materia[${m.id}][subcomponente_id]"
                  style="width:100%;margin-top:.2rem;padding:.4rem;border:1px solid #ccd3db;border-radius:4px;font-size:.85rem;">
            ${opsSubcomp}
          </select>
        </div>`;
    }

    // Aspectos Inglés
    let htmlAspectos = '';
    if (esIngles) {
      htmlAspectos = `
        <div style="margin-top:.5rem;">
          <label style="font-size:.78rem;color:var(--color-muted);">Aspectos de Inglés *</label>
          <div class="aspectos-lista-${m.id}" style="margin-top:.3rem;"></div>
          <button type="button"
                  class="btn btn--sm btn--accent btn-add-aspecto"
                  data-materia="${m.id}"
                  style="margin-top:.4rem;">
            + Agregar aspecto
          </button>
        </div>`;
    }

    // Checkbox titular
    let htmlTitular = '';
    if (esTitularMat) {
      htmlTitular = `
        <div class="check-option" style="margin-top:.5rem;">
          <input type="checkbox" id="titular_${m.id}"
                 name="materia[${m.id}][es_titular]" value="1">
          <label for="titular_${m.id}" style="font-size:.82rem;">
            Es titular de este grupo
          </label>
        </div>`;
    }

    div.innerHTML = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:.5rem;">
        <strong style="font-size:.9rem;color:var(--color-primary);">${m.nombre}</strong>
        <span>
          ${esIngles  ? '<span class="badge">Inglés</span>'             : ''}
          ${esArtes   ? '<span class="badge">Artes</span>'              : ''}
          ${esHigiene ? '<span class="badge badge--warn">Higiene</span>' : ''}
        </span>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem;">
        <div>
          <label style="font-size:.78rem;color:var(--color-muted);">Campo formativo</label>
          <select name="materia[${m.id}][campo_formativo_id]"
                  style="width:100%;margin-top:.2rem;padding:.4rem;border:1px solid #ccd3db;border-radius:4px;font-size:.85rem;">
            ${opsCampo}
          </select>
        </div>
        <div>
          <label style="font-size:.78rem;color:var(--color-muted);">Orden en boleta</label>
          <input type="number" name="materia[${m.id}][orden]" value="0" min="0"
                 style="width:100%;margin-top:.2rem;padding:.4rem;border:1px solid #ccd3db;border-radius:4px;font-size:.85rem;">
        </div>
      </div>
      <div style="margin-top:.5rem;">
        <label style="font-size:.78rem;color:var(--color-muted);">Maestro</label>
        <select name="materia[${m.id}][profesor_id]"
                style="width:100%;margin-top:.2rem;padding:.4rem;border:1px solid #ccd3db;border-radius:4px;font-size:.85rem;">
          ${opsMaestro}
        </select>
      </div>
      ${htmlTitular}
      ${htmlSubcomp}
      ${htmlAspectos}
    `;

    // Evento agregar aspecto Inglés
    if (esIngles) {
      const btnAdd   = div.querySelector('.btn-add-aspecto');
      const listaAsp = div.querySelector(`.aspectos-lista-${m.id}`);

      btnAdd.addEventListener('click', function () {
        const row = document.createElement('div');
        row.style.cssText = 'display:flex;gap:.4rem;align-items:center;margin-bottom:.3rem;';
        row.innerHTML = `
          <input type="text"
                 name="materia[${m.id}][aspectos][]"
                 placeholder="ej. Listening" maxlength="100"
                 style="flex:1;padding:.35rem .5rem;border:1px solid #ccd3db;border-radius:4px;font-size:.82rem;">
          <button type="button" class="btn btn--sm btn--danger"
                  style="margin-top:0;">✕</button>
        `;
        row.querySelector('button').addEventListener('click', function () {
          row.remove();
        });
        listaAsp.appendChild(row);
      });
    }

    return div;
  }

})();