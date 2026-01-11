// app/assets/tailwind.config.js
import colors from "tailwindcss/colors";

export default {
  // darkMode: "class",
  content: [
    "./app/views/**/*.{erb,html}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
  ],
  safelist: [
    { pattern: /border-\[#.*?\]/ },
    { pattern: /bg-\[#.*?\]/ },
    { pattern: /from-\[#.*?\]/ },
    { pattern: /to-\[#.*?\]/ },
  ],
  theme: {
    extend: {
      // Do NOT redefine "colors" here → Tailwind keeps ALL defaults
    },
  },
  plugins: [],
};


module.exports = {
  important: true,
  // ...
}
