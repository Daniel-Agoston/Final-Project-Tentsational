
document.addEventListener('DOMContentLoaded', function () {
  function checkScreenWidth() {
    const mainContent = document.getElementById('main-content');
    const smallScreenMessage = document.getElementById('small-screen-message');

    if (window.innerWidth < 1020) {
      mainContent.style.display = 'none';
      smallScreenMessage.style.display = 'flex';
    } else {
      mainContent.style.display = 'block';
      smallScreenMessage.style.display = 'none';
    }
  }

  checkScreenWidth();
  window.addEventListener('resize', checkScreenWidth);
});
