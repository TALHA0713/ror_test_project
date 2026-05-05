let draggedCard = null;
let sourceColumn = null;

export function setupKanban() {
  const columns = document.querySelectorAll("[data-kanban-column]");
  if (columns.length === 0) return;

  document.querySelectorAll("[data-ticket-card]").forEach(attachCardListeners);

  columns.forEach(function (col) {
    col.addEventListener("dragover", handleDragOver);
    col.addEventListener("dragleave", handleDragLeave);
    col.addEventListener("drop", handleDrop);
  });
}

function attachCardListeners(card) {
  card.addEventListener("dragstart", handleDragStart);
  card.addEventListener("dragend", handleDragEnd);
}

function handleDragStart(e) {
  draggedCard = this;
  sourceColumn = this.closest("[data-kanban-column]");
  e.dataTransfer.effectAllowed = "move";
  e.dataTransfer.setData("text/plain", this.dataset.ticketId);
  setTimeout(() => this.classList.add("opacity-40", "scale-95"), 0);
}

function handleDragEnd() {
  if (draggedCard) draggedCard.classList.remove("opacity-40", "scale-95");
  document.querySelectorAll("[data-kanban-column]").forEach(function (col) {
    col.classList.remove("ring-2", "ring-indigo-400/50", "bg-white/10");
  });
  draggedCard = null;
  sourceColumn = null;
}

function handleDragOver(e) {
  e.preventDefault();
  e.dataTransfer.dropEffect = "move";
  this.classList.add("ring-2", "ring-indigo-400/50", "bg-white/10");
}

function handleDragLeave(e) {
  if (!this.contains(e.relatedTarget)) {
    this.classList.remove("ring-2", "ring-indigo-400/50", "bg-white/10");
  }
}

function handleDrop(e) {
  e.preventDefault();
  this.classList.remove("ring-2", "ring-indigo-400/50", "bg-white/10");
  if (!draggedCard) return;

  const targetColumn = this;
  const newStatus = targetColumn.dataset.kanbanColumn;
  const oldStatus = sourceColumn ? sourceColumn.dataset.kanbanColumn : null;
  if (newStatus === oldStatus) return;

  const ticketId = draggedCard.dataset.ticketId;
  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

  targetColumn.insertBefore(draggedCard, targetColumn.querySelector("[data-empty-state]"));
  updateColumnCount(targetColumn, 1);
  updateColumnCount(sourceColumn, -1);
  updateEmptyState(targetColumn);
  updateEmptyState(sourceColumn);

  fetch("/tickets/" + ticketId + "/update_status", {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken,
      "Accept": "application/json"
    },
    body: JSON.stringify({ status: newStatus })
  })
    .then(function (res) {
      if (!res.ok) throw new Error("Server error");
      return res.json();
    })
    .then(function (data) {
      if (!data.success) revertCard(ticketId, sourceColumn, targetColumn);
    })
    .catch(function () {
      revertCard(ticketId, sourceColumn, targetColumn);
    });
}

function revertCard(ticketId, originalColumn, currentColumn) {
  const card = document.querySelector("[data-ticket-id='" + ticketId + "']");
  if (!card || !originalColumn) return;
  originalColumn.insertBefore(card, originalColumn.querySelector("[data-empty-state]"));
  updateColumnCount(currentColumn, -1);
  updateColumnCount(originalColumn, 1);
  updateEmptyState(currentColumn);
  updateEmptyState(originalColumn);
}

function updateColumnCount(column, delta) {
  if (!column) return;
  const wrapper = column.closest(".flex.flex-col.rounded-2xl");
  if (!wrapper) return;
  const countEl = wrapper.querySelector(".tabular-nums");
  if (!countEl) return;
  countEl.textContent = Math.max(0, (parseInt(countEl.textContent, 10) || 0) + delta);
}

function updateEmptyState(column) {
  if (!column) return;
  const emptyEl = column.querySelector("[data-empty-state]");
  if (!emptyEl) return;
  emptyEl.classList.toggle("hidden", column.querySelectorAll("[data-ticket-card]").length > 0);
}
