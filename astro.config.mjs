// @ts-check
import starlight from "@astrojs/starlight";
import { defineConfig } from "astro/config";

// GitHub Pages serves the site under /<repository>/: the deploy workflow sets these.
const site = process.env.SITE_URL ?? "http://localhost:4321";
const base = process.env.BASE_PATH ?? "/";
const repoUrl = process.env.BULL_REPO_URL;

export default defineConfig({
  site,
  base,
  // Pages are fetched on hover, so the client router swaps them in without waiting.
  prefetch: { prefetchAll: true, defaultStrategy: "hover" },
  integrations: [
    starlight({
      title: "Bull",
      description: "The opinionated React framework that refuses to build unless you respect MVVM.",
      logo: { src: "./src/assets/bull-logo.svg", alt: "Bull logo" },
      favicon: "/favicon.svg",
      social: repoUrl ? [{ icon: "github", label: "GitHub", href: repoUrl }] : [],
      components: {
        Head: "./src/overrides/Head.astro",
        Header: "./src/overrides/Header.astro",
        ThemeProvider: "./src/overrides/ThemeProvider.astro",
        ThemeSelect: "./src/overrides/ThemeSelect.astro",
      },
      // Long lines wrap instead of scrolling sideways.
      expressiveCode: { defaultProps: { wrap: true }, themes: ["github-dark-dimmed"] },
      customCss: [
        "@fontsource/big-shoulders-display/800",
        "@fontsource-variable/hanken-grotesk",
        "@fontsource-variable/jetbrains-mono",
        "./src/styles/starlight.css",
      ],
      sidebar: [
        {
          label: "Start here",
          items: [
            { label: "Introduction", slug: "docs/introduction" },
            { label: "Getting started", slug: "docs/getting-started" },
            { label: "Run Bull locally", slug: "docs/run-locally" },
          ],
        },
        { label: "Concepts", items: [{ autogenerate: { directory: "docs/concepts" } }] },
        { label: "Runtime API", items: [{ autogenerate: { directory: "docs/runtime" } }] },
        { label: "CLI reference", items: [{ autogenerate: { directory: "docs/cli" } }] },
        {
          label: "Configure",
          items: [
            { label: "bull.config.ts", slug: "docs/configuration" },
            { label: "ESLint plugin", slug: "docs/eslint" },
          ],
        },
        { label: "Contributing", slug: "docs/contributing" },
        { label: "Rules", collapsed: true, items: [{ autogenerate: { directory: "docs/rules" } }] },
      ],
    }),
  ],
});
