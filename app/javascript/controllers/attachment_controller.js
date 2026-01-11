import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static values = { maxFiles: { type: Number, default: 20 } };
  files = [];
  connect() {
    this.previewBox = document.getElementById("attachment-preview");
    this.input = document.getElementById("attachment");

    // Event delegation (bind once)
    if (this.previewBox) {
      this.previewBox.addEventListener("click", (e) => {
        const btn = e.target.closest("button[data-remove]");
        if (!btn) return;
        this.removeFileByButton(btn);
      });
    }
  }

  preview(event) {
    const input = event.target;
    const previewBox = this.previewBox || document.getElementById("attachment-preview");
    const max = this.maxFilesValue;

    if (!previewBox) return;
    const newlySelected = Array.from(input.files);
    // Merge old + new
    let merged = [...this.files, ...newlySelected];
    // Limit to max
    if (merged.length > max) {
      merged = merged.slice(0, max);
      this.showLimitMessage(max);
    }

    this.files = merged;
    // Update input.files with the limited list
    this.syncInputFiles(input);
    // Render preview (only on selection)
    previewBox.innerHTML = "";

    this.files.forEach((file, index) => {
      const wrapper = document.createElement("div");
      wrapper.className = "relative flex-shrink-0";
      wrapper.dataset.attachmentItem = "true";
      wrapper.dataset.index = index;

      if (file.type.startsWith("image/")) {
        const url = URL.createObjectURL(file);
        wrapper.innerHTML = `
          <img src="${url}" class="h-20 w-20 object-cover rounded border border-gray-700">
          <button type="button" data-remove="true" data-index="${index}" class="absolute -top-2 -right-2 bg-black/60 text-white rounded-full w-6 h-6 flex items-center justify-center cursor-pointer">
            <i class='bx bx-x text-lg'></i>
          </button>
        `;
      } else {
        wrapper.innerHTML = `
          <div class="bg-gray-800 text-white px-3 py-2 rounded border border-gray-700 max-w-[140px] truncate">
            ${file.name}
          </div>
          <button type="button" data-remove="true" data-index="${index}" class="absolute -top-2 -right-2 bg-black/60 text-white rounded-full w-6 h-6 flex items-center justify-center cursor-pointer">
            <i class='bx bx-x text-lg'></i>
          </button>
        `;
      }

      previewBox.appendChild(wrapper);
    });

    // End spacer so last item scrolls fully
    const spacer = document.createElement("div");
    spacer.className = "w-10 flex-shrink-0";
    previewBox.appendChild(spacer);
  }

  removeFileByButton(btn) {
    const index = parseInt(btn.dataset.index, 10);
    if (Number.isNaN(index)) return;
    // 1) Remove file from array
    this.files.splice(index, 1);
    // 2) Update input.files
    const input = this.input || document.getElementById("attachment");
    if (input) this.syncInputFiles(input);
    // 3) Remove correct wrapper (NOT the button)
    const wrapper = btn.closest('[data-attachment-item="true"]');
    if (wrapper) wrapper.remove();
    // 4) Reindex DOM + buttons to keep delete working
    this.reindexPreviewItems();
  }

  reindexPreviewItems() {
    const previewBox = this.previewBox || document.getElementById("attachment-preview");
    if (!previewBox) return;
    const items = previewBox.querySelectorAll('[data-attachment-item="true"]');

    items.forEach((item, newIndex) => {
      item.dataset.index = newIndex;
      const btn = item.querySelector("button[data-remove]");
      if (btn) btn.dataset.index = newIndex;
    });
  }

  syncInputFiles(input) {
    const dt = new DataTransfer();
    this.files.forEach((f) => dt.items.add(f));
    input.files = dt.files;
  }

  showLimitMessage(max) {
    const box = document.getElementById("attachment-limit-msg");
    if (!box) return;

    box.textContent = `You can select maximum ${max} files. Extra files were removed.`;
    box.classList.remove("hidden");

    clearTimeout(this._msgTimer);
    this._msgTimer = setTimeout(() => box.classList.add("hidden"), 5000);
  }
}
