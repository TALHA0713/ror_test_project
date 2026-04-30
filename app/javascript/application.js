// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"


document.addEventListener("turbo:load", function () {
    setupFileAttachments("[data-comment-files]", "[data-comment-files-add]", "[data-comment-files-list]");
    setupFileAttachments("[data-ticket-files]", "[data-ticket-files-add]", "[data-ticket-files-list]");

    setupTicketTabs();
});

function setupFileAttachments(inputSelector, buttonSelector, listSelector) {
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
        updateFileInput();
        renderFiles();
    });

    function updateFileInput() {
        const dataTransfer = new DataTransfer();

        selectedFiles.forEach(function (file) {
            dataTransfer.items.add(file);
        });

        fileInput.files = dataTransfer.files;
    }

    function renderFiles() {
        filesList.innerHTML = "";

        selectedFiles.forEach(function (file, index) {
            const item = document.createElement("div");
            item.className =
                "inline-flex items-center gap-2 rounded-lg bg-white/10 border border-white/10 text-white px-3 py-2 text-sm";

            const name = document.createElement("span");
            name.className = "break-all";
            name.textContent = file.name;

            const removeBtn = document.createElement("button");
            removeBtn.type = "button";
            removeBtn.className =
                "text-gray-300 hover:text-red-400 cursor-pointer leading-none text-lg";
            removeBtn.textContent = "×";

            removeBtn.addEventListener("click", function () {
                selectedFiles.splice(index, 1);
                updateFileInput();
                renderFiles();
            });

            item.appendChild(name);
            item.appendChild(removeBtn);
            filesList.appendChild(item);
        });
    }
}

function setupTicketTabs() {
    const tabButtons = document.querySelectorAll("[data-ticket-tab]");
    const tabPanes = document.querySelectorAll("[data-ticket-pane]");
    if (tabButtons.length === 0 || tabPanes.length === 0) return;

    const activeClasses = ["text-white", "border-indigo-400"];
    const inactiveClasses = ["text-gray-300", "hover:text-white", "border-transparent"];

    tabButtons.forEach(function (button) {
        if (button.dataset.initialized === "true") return;
        button.dataset.initialized = "true";

        button.addEventListener("click", function () {
            const target = button.dataset.ticketTab;

            tabButtons.forEach(function (btn) {
                if (btn === button) {
                    btn.classList.add(...activeClasses);
                    btn.classList.remove(...inactiveClasses);
                } else {
                    btn.classList.remove(...activeClasses);
                    btn.classList.add(...inactiveClasses);
                }
            });

            tabPanes.forEach(function (pane) {
                pane.classList.toggle("hidden", pane.dataset.ticketPane !== target);
            });
        });
    });
}