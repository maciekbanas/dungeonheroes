(function () {
  "use strict";
  var map = document.getElementById("realm-map");
  var magma = document.getElementById("magma-realm");
  var leave = document.getElementById("leave-realm");
  var field = document.getElementById("magma-field");
  var hero = document.getElementById("magma-hero");

  function notify(name) {
    if (window.Shiny) Shiny.setInputValue("realm", name, { priority: "event" });
  }
  function enterSwamps() { map.style.display = "none"; magma.style.display = "none"; leave.style.display = "block"; notify("mushroom_swamps"); }
  function enterMagma() { map.style.display = "none"; magma.style.display = "block"; leave.style.display = "block"; notify("magma_hills"); }
  function showMap() { map.style.display = "block"; magma.style.display = "none"; leave.style.display = "none"; map.focus(); notify("world_map"); }

  document.getElementById("mushroom-swamps").addEventListener("click", enterSwamps);
  document.getElementById("magma-hills").addEventListener("click", enterMagma);
  leave.addEventListener("click", showMap);
  window.addEventListener("keydown", function (event) { if (event.key === "Enter" && map.style.display !== "none") enterSwamps(); });
  field.addEventListener("click", function (event) {
    var box = field.getBoundingClientRect();
    var x = event.clientX - box.left, y = event.clientY - box.top;
    var relativeX = x / box.width;
    // The central lava river is intentionally impassable.
    if (relativeX > 0.32 && relativeX < 0.54) return;
    hero.style.left = Math.max(0, Math.min(box.width - 100, x - 50)) + "px";
    hero.style.top = Math.max(0, Math.min(box.height - 100, y - 50)) + "px";
  });
  map.focus();
}());
