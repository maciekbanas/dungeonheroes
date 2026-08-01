(function () {
  "use strict";

  function openRealm(name) {
    window.location.search = "?realm=" + encodeURIComponent(name);
  }

  document.getElementById("mushroom-swamps").addEventListener("click", function () {
    openRealm("mushroom_swamps");
  });
  document.getElementById("magma-hills").addEventListener("click", function () {
    openRealm("magma_hills");
  });
  window.addEventListener("keydown", function (event) {
    if (event.key === "Enter") openRealm("mushroom_swamps");
  });
  document.getElementById("realm-map").focus();
}());
