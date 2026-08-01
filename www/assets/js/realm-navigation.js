(function () {
  "use strict";
  var map = document.getElementById("realm-map");
  var leave = document.getElementById("leave-realm");

  function notify(name) {
    if (window.Shiny) Shiny.setInputValue("realm", name, { priority: "event" });
  }
  function enterRealm(name) { map.style.display = "none"; leave.style.display = "block"; notify(name); }
  function showMap() { map.style.display = "block"; leave.style.display = "none"; map.focus(); notify("world_map"); }

  document.getElementById("mushroom-swamps").addEventListener("click", function () { enterRealm("mushroom_swamps"); });
  document.getElementById("magma-hills").addEventListener("click", function () { enterRealm("magma_hills"); });
  leave.addEventListener("click", showMap);
  window.addEventListener("keydown", function (event) { if (event.key === "Enter" && map.style.display !== "none") enterRealm("mushroom_swamps"); });
  map.focus();
}());
