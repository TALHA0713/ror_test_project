import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "pills", "inputs"]
  static values = { users: Array, selected: Array }

  connect() {
    this.selectedIds = new Set(
      this.selectedValue.map(Number).filter(Number.isFinite)
    )

    this.dropdown = this.element.querySelector("[data-member-dropdown]")
    if (!this.dropdown) return

    document.body.appendChild(this.dropdown)

    this.onListClick = this.handleListClick.bind(this)
    this.onPillClick = this.handlePillClick.bind(this)
    this.onOutsideClick = this.handleOutsideClick.bind(this)
    this.onResize = this.handleResize.bind(this)
    this.onScroll = this.handleScroll.bind(this)

    this.dropdown.addEventListener("click", this.onListClick)
    this.pillsTarget.addEventListener("click", this.onPillClick)
    document.addEventListener("click", this.onOutsideClick)
    window.addEventListener("resize", this.onResize)
    window.addEventListener("scroll", this.onScroll, true)

    this.renderPills()
    this.renderInputs()
    this.renderList()
  }

  disconnect() {
    if (!this.dropdown) return

    this.dropdown.removeEventListener("click", this.onListClick)
    this.pillsTarget.removeEventListener("click", this.onPillClick)
    document.removeEventListener("click", this.onOutsideClick)
    window.removeEventListener("resize", this.onResize)
    window.removeEventListener("scroll", this.onScroll, true)

    this.dropdown.classList.add("hidden")
    this.dropdown.removeAttribute("style")
    this.element.appendChild(this.dropdown)
  }

  open() {
    if (!this.dropdown) return

    this.positionDropdown()
    this.dropdown.classList.remove("hidden")
  }

  close() {
    if (!this.dropdown) return

    this.dropdown.classList.add("hidden")
    this.searchTarget.value = ""
    this.applyFilter("")
  }

  filter() {
    this.open()
    this.applyFilter(this.searchTarget.value)
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  handleOutsideClick(event) {
    const path = event.composedPath()

    if (!path.includes(this.element) && !path.includes(this.dropdown)) {
      this.close()
    }
  }

  handleResize() {
    if (!this.dropdown.classList.contains("hidden")) {
      this.positionDropdown()
    }
  }

  handleScroll(event) {
    if (this.dropdown.classList.contains("hidden")) return
    if (this.dropdown.contains(event.target)) return

    this.positionDropdown()
  }

  handleListClick(event) {
    const row = event.target.closest("[data-user-id]")
    if (!row) return

    const id = Number(row.dataset.userId)
    if (!Number.isFinite(id)) return

    if (this.selectedIds.has(id)) {
      this.selectedIds.delete(id)
    } else {
      this.selectedIds.add(id)
    }

    this.renderPills()
    this.renderInputs()
    this.updateRow(row, this.selectedIds.has(id))
  }

  handlePillClick(event) {
    const button = event.target.closest("[data-remove-id]")
    if (!button) return

    const id = Number(button.dataset.removeId)
    if (!Number.isFinite(id)) return

    this.selectedIds.delete(id)

    this.renderPills()
    this.renderInputs()

    const row = this.dropdown.querySelector(`[data-user-id="${id}"]`)
    if (row) this.updateRow(row, false)
  }

  renderPills() {
    const selected = this.usersValue.filter((user) =>
      this.selectedIds.has(Number(user.id))
    )

    this.pillsTarget.innerHTML = selected.length === 0
      ? `<span class="text-gray-500 text-sm italic">No members selected yet</span>`
      : selected.map((user) => `
          <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg
                       bg-indigo-500/20 text-indigo-300 border border-indigo-400/20
                       text-sm font-medium">
            ${this.escapeHtml(user.name)}
            <button type="button"
                    data-remove-id="${Number(user.id)}"
                    aria-label="Remove ${this.escapeHtml(user.name)}"
                    class="leading-none text-base hover:text-red-400 transition cursor-pointer">
              ×
            </button>
          </span>
        `).join("")
  }

  renderInputs() {
    this.inputsTarget.innerHTML = [...this.selectedIds].map((id) =>
      `<input type="hidden" name="project_user_ids[]" value="${id}">`
    ).join("")
  }

  renderList() {
    if (this.usersValue.length === 0) {
      this.dropdown.innerHTML = `
        <p class="px-4 py-4 text-gray-300 text-sm text-center">
          No other users in the system.
        </p>
      `
      return
    }

    this.dropdown.innerHTML = this.usersValue.map((user) => {
      const id = Number(user.id)
      const selected = this.selectedIds.has(id)
      const name = String(user.name ?? "")
      const email = String(user.email ?? "")
      const role = this.capitalize(user.role)

      return `
        <div data-user-id="${id}"
             data-user-name="${this.escapeHtml(name.toLowerCase())}"
             class="flex items-center justify-between px-4 py-3 cursor-pointer
                    hover:bg-white/10 transition select-none ${selected ? "bg-indigo-500/10" : ""}">
          <div class="flex items-center gap-3 min-w-0">
            <div class="h-8 w-8 rounded-lg bg-indigo-500/20 text-indigo-300 flex items-center
                        justify-center text-xs font-bold border border-indigo-400/20 flex-shrink-0">
              ${this.escapeHtml(name.charAt(0).toUpperCase() || "?")}
            </div>

            <div class="min-w-0">
              <p class="text-white text-sm font-medium truncate">${this.escapeHtml(name)}</p>
              <p class="text-gray-400 text-xs truncate">${this.escapeHtml(email)}</p>
            </div>
          </div>

          <div class="flex items-center gap-2 ml-3 flex-shrink-0">
            <span class="text-xs px-2 py-0.5 rounded-full bg-white/10 text-gray-300 border border-white/10">
              ${this.escapeHtml(role)}
            </span>

            <div data-checkbox
                 class="h-5 w-5 rounded border flex items-center justify-center flex-shrink-0 transition ${this.checkboxClass(selected)}">
              ${selected ? this.checkIcon() : ""}
            </div>
          </div>
        </div>
      `
    }).join("") + `
      <div data-empty-state class="hidden px-4 py-4 text-gray-400 text-sm text-center">
        No users match your search.
      </div>
    `
  }

  positionDropdown() {
    // it tells where the element in the view port
    const rect = this.searchTarget.getBoundingClientRect()

    Object.assign(this.dropdown.style, {
      position: "fixed",
      top: `${rect.bottom}px`,
      left: `${rect.left}px`,
      width: `${rect.width}px`,
      zIndex: "9999"
    })
  }

  applyFilter(value) {
    const query = String(value ?? "").toLowerCase().trim()
    let visible = 0

    this.dropdown.querySelectorAll("[data-user-id]").forEach((row) => {
      const matches = !query || row.dataset.userName.includes(query)

      row.classList.toggle("hidden", !matches)
      if (matches) visible++
    })

    const emptyState = this.dropdown.querySelector("[data-empty-state]")
    if (emptyState) emptyState.classList.toggle("hidden", visible > 0)
  }

  updateRow(row, selected) {
    row.classList.toggle("bg-indigo-500/10", selected)

    const checkbox = row.querySelector("[data-checkbox]")
    if (!checkbox) return

    checkbox.className = `
      h-5 w-5 rounded border flex items-center justify-center flex-shrink-0 transition
      ${this.checkboxClass(selected)}
    `

    checkbox.innerHTML = selected ? this.checkIcon() : ""
  }

  checkboxClass(selected) {
    return selected
      ? "bg-indigo-500 border-indigo-500"
      : "border-white/20 bg-white/5"
  }

  checkIcon() {
    return `
      <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
      </svg>
    `
  }

  capitalize(value) {
    const text = String(value ?? "")
    return text ? text.charAt(0).toUpperCase() + text.slice(1) : ""
  }

  escapeHtml(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;")
  }
}