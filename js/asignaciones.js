// js/asignaciones.js
(function() {

    const MATERIAS = window.MATERIAS || [];
    const CAMPOS = window.CAMPOS || [];
    const SUBCOMPS = window.SUBCOMPS || [];
    const TITULARES = window.TITULARES || [];
    const FRANCES = window.FRANCES || [];
    const COCURRICULARES = window.COCURRICULARES || [];

    function getProfesoresPorMateria(materia) {
        const esIngles = parseInt(materia.es_ingles);
        const esArtes = parseInt(materia.es_artes);
        const esHigiene = parseInt(materia.es_higiene);
        const nombre = materia.nombre.toLowerCase();
        
        if (esArtes || esHigiene) {
            return COCURRICULARES;
        } else if (esIngles) {
            return TITULARES;
        } else if (nombre.includes('franc')) {
            return FRANCES;
        } else {
            return TITULARES;
        }
    }

    window.agregarFilaMaestro = function(container, materiaId, profesores, profesorId = '', esTitular = false) {
        const row = document.createElement('div');
        row.className = 'maestro-row';
        
        const select = document.createElement('select');
        select.name = `materia[${materiaId}][maestros][][profesor_id]`;
        select.required = true;
        select.className = 'form-control';
        
        let options = '<option value="">Seleccionar maestro...</option>';
        profesores.forEach(p => {
            options += `<option value="${p.id}" ${profesorId == p.id ? 'selected' : ''}>
                ${p.apellido_paterno} ${p.apellido_materno || ''}, ${p.nombre}
            </option>`;
        });
        select.innerHTML = options;
        row.appendChild(select);
        
        const labelTitular = document.createElement('label');
        labelTitular.className = 'checkbox-titular';
        const chkTitular = document.createElement('input');
        chkTitular.type = 'checkbox';
        chkTitular.name = `materia[${materiaId}][maestros][][es_titular]`;
        chkTitular.value = '1';
        chkTitular.checked = esTitular;
        labelTitular.appendChild(chkTitular);
        labelTitular.appendChild(document.createTextNode('Titular'));
        row.appendChild(labelTitular);
        
        const btnRemove = document.createElement('button');
        btnRemove.type = 'button';
        btnRemove.textContent = '✕ Eliminar';
        btnRemove.className = 'btn btn--sm btn--danger';
        btnRemove.onclick = () => row.remove();
        row.appendChild(btnRemove);
        
        container.appendChild(row);
    };

    window.crearBloqueMateria = function(materia, profesores) {
        const div = document.createElement('div');
        div.className = 'materia-bloque';
        div.setAttribute('data-materia-id', materia.id);
        
        const esIngles = parseInt(materia.es_ingles) === 1;
        const esArtes = parseInt(materia.es_artes) === 1;
        const esHigiene = parseInt(materia.es_higiene) === 1;
        
        const header = document.createElement('div');
        header.className = 'materia-header';
        header.innerHTML = `
            <strong>${materia.nombre}</strong>
            <span>
                ${esIngles ? '<span class="badge">Inglés</span>' : ''}
                ${esArtes ? '<span class="badge">Artes</span>' : ''}
                ${esHigiene ? '<span class="badge badge--warn">Higiene</span>' : ''}
            </span>
        `;
        div.appendChild(header);
        
        const fieldsDiv = document.createElement('div');
        fieldsDiv.className = 'form-grid';
        fieldsDiv.style.marginBottom = '0.8rem';
        
        let campoOptions = '<option value="">Sin campo formativo</option>';
        CAMPOS.forEach(cf => {
            const selected = parseInt(materia.campo_formativo_id) === parseInt(cf.id) ? 'selected' : '';
            campoOptions += `<option value="${cf.id}" ${selected}>${cf.nombre}</option>`;
        });
        
        fieldsDiv.innerHTML = `
            <div class="form-group">
                <label class="form-hint">Campo formativo</label>
                <select name="materia[${materia.id}][campo_formativo_id]" class="form-control">${campoOptions}</select>
            </div>
            <div class="form-group">
                <label class="form-hint">Orden en boleta</label>
                <input type="number" name="materia[${materia.id}][orden]" value="0" min="0" class="form-control">
            </div>
        `;
        div.appendChild(fieldsDiv);
        
        if (esArtes) {
            const subcompDiv = document.createElement('div');
            subcompDiv.className = 'form-group';
            subcompDiv.style.marginBottom = '0.8rem';
            let subcompOptions = '<option value="">Selecciona subcomponente…</option>';
            SUBCOMPS.forEach(s => {
                subcompOptions += `<option value="${s.id}">${s.nombre}</option>`;
            });
            subcompDiv.innerHTML = `
                <label class="form-hint">Subcomponente *</label>
                <select name="materia[${materia.id}][subcomponente_id]" class="form-control">${subcompOptions}</select>
            `;
            div.appendChild(subcompDiv);
        }
        
        if (esIngles) {
            const aspectosDiv = document.createElement('div');
            aspectosDiv.className = 'form-group';
            aspectosDiv.style.marginBottom = '0.8rem';
            aspectosDiv.innerHTML = `
                <label class="form-hint">Aspectos de Inglés</label>
                <div class="aspectos-lista-${materia.id}"></div>
                <button type="button" class="btn btn--sm btn--accent btn-add-aspecto" data-materia="${materia.id}">+ Agregar aspecto</button>
            `;
            div.appendChild(aspectosDiv);
        }
        
        const maestrosDiv = document.createElement('div');
        maestrosDiv.style.marginTop = '0.8rem';
        maestrosDiv.style.borderTop = '1px solid var(--color-border)';
        maestrosDiv.style.paddingTop = '0.8rem';
        maestrosDiv.innerHTML = `
            <label class="form-hint" style="font-weight:600;">Maestros asignados</label>
            <div class="maestros-lista-${materia.id}"></div>
            <button type="button" class="btn-add-maestro" data-materia="${materia.id}">+ Agregar otro maestro</button>
        `;
        div.appendChild(maestrosDiv);
        
        const maestrosLista = div.querySelector(`.maestros-lista-${materia.id}`);
        window.agregarFilaMaestro(maestrosLista, materia.id, profesores);
        
        const btnAddMaestro = div.querySelector('.btn-add-maestro');
        btnAddMaestro.addEventListener('click', () => {
            window.agregarFilaMaestro(maestrosLista, materia.id, profesores);
        });
        
        if (esIngles) {
            const btnAddAspecto = div.querySelector('.btn-add-aspecto');
            const listaAsp = div.querySelector(`.aspectos-lista-${materia.id}`);
            btnAddAspecto.addEventListener('click', () => {
                const row = document.createElement('div');
                row.className = 'maestro-row';
                row.style.marginBottom = '0.3rem';
                row.innerHTML = `
                    <input type="text" name="materia[${materia.id}][aspectos][]" placeholder="ej. Listening" maxlength="100" class="form-control" style="flex:1;">
                    <button type="button" class="btn btn--sm btn--danger">✕</button>
                `;
                row.querySelector('button').addEventListener('click', () => row.remove());
                listaAsp.appendChild(row);
            });
        }
        
        return div;
    };

    window.renderizarMaterias = function() {
        const selSeccion = document.getElementById('seccion');
        const selGrado = document.getElementById('grado');
        const selGrupo = document.getElementById('grupo');
        const wrapMaterias = document.getElementById('wrap-materias');
        const listaMaterias = document.getElementById('lista-materias');
        const btnGuardar = document.getElementById('btn-guardar');
        
        if (!selSeccion) return;
        
        const seccion = selSeccion.value;
        const grado = selGrado.value;
        const grupo = selGrupo.value;
        
        if (!seccion || !grado || !grupo) {
            if (wrapMaterias) wrapMaterias.hidden = true;
            if (btnGuardar) btnGuardar.hidden = true;
            if (listaMaterias) listaMaterias.innerHTML = '';
            return;
        }
        
        const materiasFiltradas = MATERIAS.filter(m => {
            if (parseInt(m.es_higiene) && seccion !== 'secundaria') return false;
            return true;
        });
        
        if (listaMaterias) {
            listaMaterias.innerHTML = '';
            materiasFiltradas.forEach(materia => {
                const profesores = getProfesoresPorMateria(materia);
                const bloque = window.crearBloqueMateria(materia, profesores);
                listaMaterias.appendChild(bloque);
            });
        }
        
        if (wrapMaterias) wrapMaterias.hidden = false;
        if (btnGuardar) btnGuardar.hidden = false;
    };

})();

document.addEventListener('DOMContentLoaded', function() {
    const selSeccion = document.getElementById('seccion');
    const selGrado = document.getElementById('grado');
    const selGrupo = document.getElementById('grupo');
    
    if (selSeccion) {
        selSeccion.addEventListener('change', window.renderizarMaterias);
        selGrado.addEventListener('change', window.renderizarMaterias);
        selGrupo.addEventListener('change', window.renderizarMaterias);
    }
});