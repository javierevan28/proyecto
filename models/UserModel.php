<?php
// models/UserModel.php

class UserModel {

    private mysqli $db;

    public function __construct(mysqli $db) {
        $this->db = $db;
    }

    // ----------------------------------------------------------
    // Limpieza y normalización
    // ----------------------------------------------------------
    private function limpiar(string $texto): string {
        $texto = trim($texto);
        $texto = strtolower($texto);
        $texto = preg_replace('/[^a-záéíóúüñ ]/', '', $texto);
        $texto = preg_replace('/\s+/', ' ', $texto);
        return trim($texto);
    }

    private function normalizar(string $texto): string {
        $mapeo = [
            'á'=>'a','é'=>'e','í'=>'i','ó'=>'o','ú'=>'u','ü'=>'u',
            'Á'=>'a','É'=>'e','Í'=>'i','Ó'=>'o','Ú'=>'u','Ü'=>'u',
            'ñ'=>'n','Ñ'=>'n',
        ];
        return strtr($texto, $mapeo);
    }

    // ----------------------------------------------------------
    // Genera base del username
    //
    //  Con 2 apellidos:  3 letras ap1 + 3 letras ap2 + nombre completo
    //  Con 1 apellido:   4 letras ap1 + nombre completo
    //
    //  Los parámetros ya vienen separados (no del nombre completo)
    // ----------------------------------------------------------
    public function generarBaseUsername(
        string $apellidoPaterno,
        string $apellidoMaterno,   // puede ser vacío
        string $nombre
    ): ?string {

        $ap1    = $this->normalizar($this->limpiar($apellidoPaterno));
        $ap2    = $this->normalizar($this->limpiar($apellidoMaterno));
        $nom    = $this->normalizar($this->limpiar($nombre));

        // Validaciones mínimas
        if (strlen($ap1) < 1 || strlen($nom) < 1) {
            return null;
        }

        if ($ap2 !== '') {
            // Caso normal: 3 + 3 + nombre
            $base = substr($ap1, 0, 3) . substr($ap2, 0, 3) . $nom;
        } else {
            // Solo un apellido: 4 letras + nombre
            $base = substr($ap1, 0, 4) . $nom;
        }

        // Solo alfanumérico, máx 50 chars
        $base = preg_replace('/[^a-z0-9]/', '', $base);
        return substr($base, 0, 50) ?: null;
    }

    // ----------------------------------------------------------
    // Palabras prohibidas (solo longitud 4 según lógica original,
    // pero en BD puedes poner cualquier longitud)
    // ----------------------------------------------------------
    private function obtenerPalabrasProhibidas(): array {
        $sql = "SELECT word FROM banned_words";
        $res = $this->db->query($sql);
        $palabras = [];
        if ($res && $res->num_rows > 0) {
            while ($row = $res->fetch_assoc()) {
                $palabras[] = $row['word'];
            }
        }
        return $palabras;
    }

    private function tienePalabraProhibida(string $username): bool {
        foreach ($this->obtenerPalabrasProhibidas() as $palabra) {
            if (strpos($username, $palabra) !== false) {
                return true;
            }
        }
        return false;
    }

    // ----------------------------------------------------------
    // Verifica si el username ya existe
    // ----------------------------------------------------------
    private function existeUsername(string $username): bool {
        $stmt = $this->db->prepare("SELECT id FROM users WHERE username = ? LIMIT 1");
        $stmt->bind_param('s', $username);
        $stmt->execute();
        return $stmt->get_result()->num_rows > 0;
    }

    // ----------------------------------------------------------
    // Genera username único (agrega sufijo numérico si hay colisión)
    // ----------------------------------------------------------
    public function generarUsernameUnico(
        string $apellidoPaterno,
        string $apellidoMaterno,
        string $nombre
    ): ?string {

        $base = $this->generarBaseUsername($apellidoPaterno, $apellidoMaterno, $nombre);
        if (!$base) return null;

        if ($this->tienePalabraProhibida($base)) return null;

        $username  = $base;
        $contador  = 1;
        while ($this->existeUsername($username)) {
            $username = $base . $contador;
            $contador++;
            if ($contador > 100) return null;
        }

        return $username;
    }

    // ----------------------------------------------------------
    // Crea un registro en users y devuelve el nuevo id
    // La contraseña es el mismo username (según requerimiento)
    // ----------------------------------------------------------
    public function crearUserLogin(string $username, int $rolId): ?int {
        $hash = password_hash($username, PASSWORD_DEFAULT);
        $stmt = $this->db->prepare(
            "INSERT INTO users (username, password_hash, rol_id) VALUES (?, ?, ?)"
        );
        $stmt->bind_param('ssi', $username, $hash, $rolId);
        if ($stmt->execute()) {
            return (int) $this->db->insert_id;
        }
        return null;
    }
}