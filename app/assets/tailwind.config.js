export default {
  darkMode: "class",
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
    extend: {},
  },
  plugins: [],
};
