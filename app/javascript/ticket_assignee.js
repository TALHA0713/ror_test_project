document.addEventListener("change", function (e) {
  if (!e.target.matches("[data-project-select='true']")) return;
  fillAssignees(false);
});

export function setupTicketAssigneeSelect() {
  fillAssignees(true);
}

function fillAssignees(preserveSelection) {
  const dataEl = document.getElementById("ticket-assignee-data");
  if (!dataEl) return;

  const projectSelect  = document.querySelector("[data-project-select='true']");
  const assigneeSelect = document.querySelector("[data-assignee-select='true']");
  if (!projectSelect || !assigneeSelect) return;

  const projectUsers    = JSON.parse(dataEl.dataset.projectUsers);
  const savedAssignee   = preserveSelection ? dataEl.dataset.selectedAssignee : null;
  const users           = projectUsers[projectSelect.value] || [];

  assigneeSelect.innerHTML = "";
  assigneeSelect.append(new Option("Select user", ""));

  users.forEach(function (userData) {
    const opt = new Option(userData[0], userData[1]);
    if (String(userData[1]) === String(savedAssignee)) opt.selected = true;
    assigneeSelect.append(opt);
  });
}
