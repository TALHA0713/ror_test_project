import "@hotwired/turbo-rails"
import "controllers"

import { initSidebarProjects, toggleSidebarProjects } from "sidebar"
import { setupKanban } from "kanban"
import { setupFileAttachments } from "file_attachments"
import { setupTicketAssigneeSelect } from "ticket_assignee"

window.toggleSidebarProjects = toggleSidebarProjects;

document.addEventListener("turbo:load", function () {
  initSidebarProjects();
  setupKanban();
  setupFileAttachments("[data-comment-files]", "[data-comment-files-add]", "[data-comment-files-list]");
  setupFileAttachments("[data-ticket-files]", "[data-ticket-files-add]", "[data-ticket-files-list]");
  setupTicketAssigneeSelect();
});
document.addEventListener("turbo:render", setupTicketAssigneeSelect);
