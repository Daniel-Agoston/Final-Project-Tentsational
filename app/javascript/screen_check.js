// Waits for the DOM content to be fully loaded before executing the script.
document.addEventListener('DOMContentLoaded', function () {
  // Function to check the current screen width and adjust the display of elements accordingly.
  function checkScreenWidth() {
    const mainContent = document.getElementById('main-content'); // Selects the main content element by its ID.
    const smallScreenMessage = document.getElementById('small-screen-message'); // Selects the small screen message element by its ID.

    // If the screen width is less than 1020 pixels, hide the main content and show the small screen message.
    if (window.innerWidth < 1020) {
      mainContent.style.display = 'none'; // Hides the main content.
      smallScreenMessage.style.display = 'flex'; // Displays the small screen message.
    } else {
      // If the screen width is 1020 pixels or more, show the main content and hide the small screen message.
      mainContent.style.display = 'block'; // Shows the main content.
      smallScreenMessage.style.display = 'none'; // Hides the small screen message.
    }
  }

  checkScreenWidth(); // Initial check of the screen width when the page loads.
  // Adds an event listener to the window to check the screen width whenever the window is resized.
  window.addEventListener('resize', checkScreenWidth);
});
