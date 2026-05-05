export function setupFileAttachments(inputSelector, buttonSelector, listSelector) {
  const fileInput = document.querySelector(inputSelector);
  const addButton = document.querySelector(buttonSelector);
  const filesList = document.querySelector(listSelector);

  if (!fileInput || !addButton || !filesList) return;
  if (addButton.dataset.initialized === "true") return;
  addButton.dataset.initialized = "true";

  let selectedFiles = [];

  addButton.addEventListener("click", function () {
    fileInput.click();
  });

  fileInput.addEventListener("change", function () {
    selectedFiles = selectedFiles.concat(Array.from(fileInput.files));
    syncInput();
    render();
  });

  function syncInput() {
    const dt = new DataTransfer();
    selectedFiles.forEach(function (f) { dt.items.add(f); });
    fileInput.files = dt.files;
  }

  function render() {
    filesList.innerHTML = "";
    selectedFiles.forEach(function (file, index) {
      const item = document.createElement("div");
      item.className = "inline-flex items-center gap-2 rounded-lg bg-white/10 border border-white/10 text-white px-3 py-2 text-sm";

      const name = document.createElement("span");
      name.className = "break-all";
      name.textContent = file.name;

      const removeBtn = document.createElement("button");
      removeBtn.type = "button";
      removeBtn.className = "text-gray-300 hover:text-red-400 cursor-pointer leading-none text-lg";
      removeBtn.textContent = "×";
      removeBtn.addEventListener("click", function () {
        selectedFiles.splice(index, 1);
        syncInput();
        render();
      });

      item.appendChild(name);
      item.appendChild(removeBtn);
      filesList.appendChild(item);
    });
  }
}
