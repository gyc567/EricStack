import { defineConfig } from "oxlint";

export default defineConfig({
  // Agent asset directories — these generate code outside the type system
  // and should not be linted by anti-slop rules.
  ignorePatterns: [
    ".agent/**",
    ".agents/**",
    ".claude/**",
    ".codex/**",
    ".continue/**",
    ".cursor/**",
    ".gemini/**",
    ".opencode/**",
    ".pi/**",
    ".roo/**",
    ".windsurf/**",
    // Vendored upstream source (protected from sync overwrite — skip during lint)
    "tools/oxlint/anti-slop/src/**",
    "node_modules/**",
  ],

  jsPlugins: [
    {
      name: "anti-slop",
      specifier: "./tools/oxlint/anti-slop/src/index.ts",
    },
    {
      name: "anti-slop-effect",
      specifier: "./tools/oxlint/anti-slop/src/effect/index.ts",
    },
  ],

  rules: {
    // Effect (opt-in — only in Effect-using repos)
    "anti-slop-effect/no-service-constructor-imports": "error",

    // Type Safety
    "anti-slop/no-chained-type-assertions": "error",
    "anti-slop/no-widen-then-assert": "error",
    "anti-slop/require-safety-comment-for-type-assertion": "error",
    "anti-slop/no-known-value-widening": "error",

    // Reflection
    "anti-slop/no-reflect-apply": "error",
    "anti-slop/no-reflect-get": "error",
    "anti-slop/no-runtime-typeof": ["error", { allowInTypeGuards: true }],

    // Generic Safety
    "anti-slop/no-object-parameters": "error",
    "anti-slop/no-unknown-parameters": "error",
    "anti-slop/no-unknown-returns": "error",
    "anti-slop/no-unknown-type-aliases": "error",
    "anti-slop/no-unsafe-dictionary-type": "error",

    // Code Structure
    "anti-slop/no-conditional-empty-object-spread": "error",
    "anti-slop/no-shape-in-symbol-names": "error",

    // Testing
    "anti-slop/no-module-mocking": "error",
  },
});
