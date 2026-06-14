import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class"],
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        navy: {
          50:  "#e8ecf0",
          100: "#c5cdd6",
          200: "#9eadb9",
          300: "#778d9c",
          400: "#5a7488",
          500: "#3d5a70",
          600: "#2d4a5e",
          700: "#1c3347",
          800: "#0f2133",
          900: "#0B1F3A"
        },
        gold: {
          50:  "#fdf9ee",
          100: "#faf0ce",
          200: "#f5e099",
          300: "#eecf61",
          400: "#e6bc36",
          500: "#D4AF37",
          600: "#b8922a",
          700: "#96711f",
          800: "#74521a",
          900: "#523917"
        },
        rice: {
          green: "#2E8B57",
          "green-light": "#3da86a",
          cream: "#F5F0E8",
          "cream-dark": "#EDE7D9"
        }
      },
      fontFamily: {
        garamond: ["EB Garamond", "Georgia", "serif"],
        inter:    ["Inter", "system-ui", "sans-serif"],
        mono:     ["JetBrains Mono", "Fira Code", "monospace"]
      },
      animation: {
        "ticker-scroll": "ticker-scroll 30s linear infinite",
        "pulse-ring":    "pulse-ring 2s ease-in-out infinite",
        "fade-up":       "fade-up 0.6s ease-out forwards"
      },
      keyframes: {
        "ticker-scroll": {
          "0%":   { transform: "translateX(0)" },
          "100%": { transform: "translateX(-50%)" }
        },
        "pulse-ring": {
          "0%, 100%": { opacity: "0.4", transform: "scale(1)" },
          "50%":      { opacity: "0.8", transform: "scale(1.05)" }
        },
        "fade-up": {
          "0%":   { opacity: "0", transform: "translateY(20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" }
        }
      }
    }
  },
  plugins: [require("tailwindcss-animate")]
};

export default config;
