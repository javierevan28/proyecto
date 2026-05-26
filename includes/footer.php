<?php
// includes/footer.php
// Siempre incluirlo al FINAL de cada página:
//   include __DIR__ . '/../includes/footer.php';
?>
  <?php if (!empty($scripts)): ?>
    <?php foreach ($scripts as $src): ?>
      <script src="<?= htmlspecialchars($src) ?>"></script>
    <?php endforeach; ?>
  <?php endif; ?>
</body>
</html>