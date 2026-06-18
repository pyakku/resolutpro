/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        // Brand tokens (see CLAUDE.md)
        brand: {
          dark: "#1d2428", // primary dark (nav, headers)
          DEFAULT: "#5e90c0", // primary light (CTAs, links)
          light: "#D5E8F0", // light blue (accents)
        },
      },
      fontFamily: {
        sans: [
          "Inter",
          "system-ui",
          "-apple-system",
          "Segoe UI",
          "Roboto",
          "Helvetica Neue",
          "Arial",
          "sans-serif",
        ],
      },
    },
  },
  plugins: [],
};
