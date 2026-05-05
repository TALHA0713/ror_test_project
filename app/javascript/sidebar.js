export function initSidebarProjects() {
  const container = document.getElementById("sidebar-projects");
  if (!container) return;
  container.style.maxHeight = container.scrollHeight + "px";
  container.style.opacity = "1";
}

export function toggleSidebarProjects() {
  const container = document.getElementById("sidebar-projects");
  const chevron = document.getElementById("projects-chevron");
  if (!container || !chevron) return;

  const isOpen = container.style.maxHeight !== "0px";
  if (isOpen) {
    chevron.classList.add("-rotate-180");
    container.style.maxHeight = "0px";
    container.style.opacity = "0";
  } else {
    chevron.classList.remove("-rotate-180");
    container.style.maxHeight = container.scrollHeight + "px";
    container.style.opacity = "1";
  }
}
