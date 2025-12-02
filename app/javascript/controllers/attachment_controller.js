import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  files = [];

  preview(event) {
    const input = event.target;
    const previewBox = document.getElementById("attachment-preview");
    this.files = Array.from(input.files);
    previewBox.innerHTML = "";

    this.files.forEach((file, index) => {
      const wrapper = document.createElement("div");
      wrapper.className = "relative inline-block";

      if (file.type.startsWith("image/")) {
        const url = URL.createObjectURL(file);
        wrapper.innerHTML = `
          <img src="${url}" class="h-24 rounded border border-gray-700">

          <button data-index="${index}"
                  class="absolute -top-2 -right-2 bg-black/60 text-white rounded-full w-6 h-6 flex items-center justify-center cursor-pointer">
            <i class='bx bx-x text-lg'></i>
          </button>
        `;
      } else {
        wrapper.innerHTML = `
          <div class="bg-gray-800 text-white px-3 py-2 rounded border border-gray-700 max-w-[140px]">
            ${file.name}
          </div>

          <button data-index="${index}"
                  class="absolute -top-2 -right-2 bg-black/60 text-white rounded-full w-6 h-6 flex items-center justify-center cursor-pointer">
            <i class='bx bx-x text-lg'></i>
          </button>
        `;
      }

      previewBox.appendChild(wrapper);
    });

    previewBox.querySelectorAll("button[data-index]").forEach((btn) => {
      btn.addEventListener("click", (e) => this.removeFile(e));
    });
  }

  removeFile(event) {
    const index = parseInt(event.target.closest("button").dataset.index);
    this.files.splice(index, 1);
    const dt = new DataTransfer();
    this.files.forEach((f) => dt.items.add(f));
    const input = document.getElementById("attachment");
    input.files = dt.files;
    this.preview({ target: input });
  }
}
