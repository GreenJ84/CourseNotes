# **Topic 1: Exports and Imports (ES Modules)**

JavaScript’s module system enables code organization, reusability, encapsulation, and predictable dependency management. In modern React applications, ES Modules serve as the foundation for component organization, code-splitting, tree shaking, and inter-module contracts. Understanding both current and legacy module systems is essential for working in diverse codebases, bundler environments, and interoperating with external libraries.

## **Learning Objectives**

* Master modern ES module syntax (named exports, default exports, namespace imports).
* Understand dynamic imports for code-splitting and optimized React rendering.
* Learn how re-export patterns build scalable component libraries.
* Compare ES Modules with legacy systems like CommonJS (`require`, `module.exports`) and global script patterns.
* Apply module best practices in small components, large React architectures, and multi-package repositories.

---

## **ES Modules — Named, Default, and Namespace Exports**

* **Named exports:** Export multiple bindings from a module. Must be imported using matching names.
* **Default exports:** Export a single “primary” binding; imported with any name.
* **Namespace imports:** Import the entire module as a single object.

### Modern Usage Examples

```js
// ---------- math.js ----------
export const PI = 3.14; // named export
export function square(x) { return x * x; } // named export

// default export
// Only one default allowed per file
export default class Calculator {
  add(a, b) { return a + b; }
}
```

```js
// ---------- index.js ----------
import Calculator from './math.js';          // default import
import { PI, square } from './math.js'; // named import

import * as MathUtils from './math.js';      // namespace import
MathUtils.PI. // namespace usages
```

### React Usage

* Export components with named or default exports:

```js
export default function Button() { ... }
export function Card() { ... }
```

* Named exports help with auto-completion and tooling.
* Default exports simplify importing components with custom names.

### Pros / Cons Summary

| Type              | Pros                                | Cons                                 |
| ----------------- | ----------------------------------- | ------------------------------------ |
| Named exports     | Clear APIs, great tooling, explicit | Must match names                     |
| Default exports   | Simple import syntax, flexible name | Harder refactoring, ambiguous API    |
| Namespace imports | Useful for utility modules          | Less tree-shakeable in some bundlers |

---

## **Module Resolution Rules**

Understanding how modules are resolved is important across bundlers (Webpack, Vite, Node):

* File extensions are optional with some bundlers: `import A from './file'` → `.js`, `.jsx`, `.ts`, `.tsx`
* Directory imports may load `index.js`
* Bare imports (`import React from 'react'`) resolved using `node_modules`

### React Advice

* Prefer **absolute imports** when project structure grows:

```js
// after setting a baseUrl or alias
import Button from 'components/Button';
```

---

## **Re-Exports and Barrel Files**

Re-exports help create clean, consolidated module interfaces.

### Example

* Barrel File (`components.js`)

```js
// button.js exports Button
export { Button } from './button.js';

// card.js exports Card
export { Card } from './card.js';
```

* Application consumption

```js
// Consumers:
import { Button, Card } from './components';
```

### Notes

* Helps structure large apps.
* Simplifies public API surfaces (e.g., shared UI libraries).
* Must ensure circular dependencies are avoided.

---

## **Code splitting**

* Split where it affects perceived load time and interactions — routes, large dashboard panels, editor widgets, or rarely used admin pages. Avoid splitting micro-components that add runtime overhead without UX gain.

### Chunk boundaries

* Route-based splitting yields the biggest wins: lazy-load route bundles and keep initial bundle small.
* Component-level splitting for heavy, non-critical UI (map components, graphing libraries, rich text editors).
* Library splits: isolate large third‑party libs (charting, ace/editor) into their own chunk when only used in some pages.

### Patterns and APIs

* Use dynamic import() for code-splitting; combine with React.lazy + Suspense for simple cases.
* For advanced control, use libraries like @loadable/component or react-loadable to support SSR, chunk naming, and server preloading.
* Example (Webpack chunk named import):

  ```js
  const Editor = React.lazy(() => import(/* webpackChunkName: "editor" */ './Editor'));
  ```

### Chunk naming & cacheability

* Goal: produce content-hashed artifacts so unchanged assets remain cacheable across deploys.
* Avoid unpredictable chunk graphs that change on unrelated edits; prefer stable entry boundaries to reduce cache misses.

#### Webpack example

```js
output: {
  filename: '[name].[contenthash].js',
  chunkFilename: '[name].[contenthash].chunk.js',
  publicPath: '/static/',
},
optimization: {
  moduleIds: 'deterministic', // stable ids across builds
  runtimeChunk: { name: 'runtime' },
  splitChunks: { chunks: 'all' },
}
```

#### Best practices

* Use [contenthash] (not [hash]) for long-term caching.
* Keep entry points stable: moving modules between entries causes churn and cache misses.
* Use deterministic or hashed module ids to avoid large-scale renames when unrelated code changes.

#### Gotchas

* Large shared libraries duplicated across chunks increase total bytes — use splitChunks.cacheGroups to avoid duplication.
* If you publish to a CDN, ensure the server and CDNs honor far-future cache headers and that filenames change when content changes.

### Measuring and validating

* Use bundle analyzers (webpack-bundle-analyzer, source-map-explorer) and Lighthouse to verify size and load impact.
* Establish performance budgets and track real-user metrics (CLS, LCP, TTFB) to validate splitting effectiveness.

#### Tools and commands

* webpack-bundle-analyzer
  * **Generate stats**: `webpack --profile --json > stats.json`
  * **Visualize**: `npx webpack-bundle-analyzer stats.json`
* source-map-explorer
  * `npx source-map-explorer dist/*.js`
* Lighthouse (Chrome DevTools or CLI)
  * Metrics to track: LCP (Largest Contentful Paint), CLS (Cumulative Layout Shift), TTFB (Time to First Byte), FCP (First Contentful Paint), JS execution time
  * CLI: `npx lighthouse https://example.com --output html --output-path report.html`

#### Establish performance budgets

> Example: limit initial JS to 150–250 KB gzipped, lazy chunks < 100 KB each.

* Track real-user metrics (RUM) to validate real-world impact.

### Caveats

* Excessive splitting increases request overhead and complexity. Mitigate with HTTP/2/3 multiplexing or combine very small modules.
* Preloading many resources can slow down the critical path — prefer targeted preloads.
* Duplicate large dependencies: configure splitChunks to extract common libraries to a shared vendor chunk.
* Build determinism: enable stable module ids and consistent entry boundaries to reduce cache invalidation.

### Quick tips

* Audit with bundle analyzer regularly after each major dependency bump.
* Use runtimeChunk and a small runtime file to stabilize chunk contents across builds.
* Prefer automated preload/prefetch via your bundler/tooling rather than manually maintaining link tags.

---

## **Prefetching and preloading**

Prefetch and preload are resource hints with different intent:

* rel="preload": for resources you need immediately after navigation (critical chunks, fonts, large scripts that block hydration). The browser downloads them with high priority.
* rel="prefetch": for resources you expect to need in the near future (next-route chunks). The browser downloads them at low priority (usually when idle).

### Examples

* HTML

```html
<link rel="preload" href="/static/js/main.abc123.js" as="script">
<link rel="prefetch" href="/static/js/settings.def456.js" as="script">
```

* Webpack / dynamic import (magic comments)

```js
// ask webpack to emit a separate chunk named "settings" and mark it for low-priority prefetch
const Settings = () => import(
  /* webpackChunkName: "settings" */
  /* webpackPrefetch: true */
  './Settings'
);
```

* Loadable-components (runtime API)

```js
import loadable from '@loadable/component';
const Admin = loadable(() => import('./Admin'));

// trigger an early load (e.g., on hover or after login)
Admin.preload();
```

### Gotchas and tips

* Use preload only when the resource is on the critical path; overusing it competes with other critical downloads.
* Prefetch is best triggered from the page that most likely transitions to the next route (or via webpack's magic comments).
* Include as="script" or as="font" to let the browser set the right priority and apply CORs rules when needed.

---

## **SSR, hydration, and critical rendering**

* Problem: hydration fails if the browser doesn't have the JS chunks required to hydrate server-rendered HTML.
* Ensure chunks required for initial render are included server-side (or inlined for critical path) so hydration succeeds.
* When using SSR, prefer loadable-style tools that collect and emit chunk manifests for the server.

### Recommendations

* Server must emit script tags for chunks required for the initial render.
* For critical inline JS/CSS, consider inlining small critical runtime to remove an extra fetch.
* Use tools that collect chunk manifests during render (e.g., @loadable/server, react-loadable's capture) and inject the correct `<script>`/`<link>` tags server-side.

### Example (simplified @loadable/server flow)

```js
// server.js (node)
import { ChunkExtractor } from '@loadable/server';
import stats from './dist/loadable-stats.json';
const extractor = new ChunkExtractor({ stats });

const jsx = extractor.collectChunks(<App url={req.url} />);
const html = renderToString(jsx);

res.send(`
  <html>
    <head>${extractor.getLinkTags() /* preload/prefetch link tags */}</head>
    <body>
      <div id="root">${html}</div>
      ${extractor.getScriptTags() /* script tags for needed chunks */}
    </body>
  </html>
`);
```

### Gotchas

* Forgetting to include vendor/runtime chunks on the server prevents client hydration.
* Ensure correct publicPath so emitted tags point to the right CDN/URL.

---

## **Combine exports for shared libraries**

### Barrel files (index.js or index.ts) create a single public surface

* Example:

```js
// components/index.js
export { default as Button } from './Button';
export { Card } from './Card';
```

* Consumers import from 'components' instead of deep paths.

#### Trade-offs and tree-shaking

* Named re-exports preserve tree-shaking better than aggregating a default export object.
* Avoid creating a single file that imports everything and then exports a default object — that can pull all modules into one bundle.

#### Recommended practices

* Re-export named symbols individually (export { X } from './x') rather than import-and-reexport via a composed object.
* Keep barrels shallow and domain-scoped (e.g., components/, hooks/, utils/) rather than a single monolithic barrel for an entire repo.
* Use path aliases or package entry points to offer stable public APIs (e.g., "@/components" or package.json "exports" field).

### Package and monorepo considerations

* In libraries, define clear package entry points and use the "module" and "exports" fields to support ESM consumers.
* Mark side-effect-free files in package.json ("sideEffects": false) where safe to improve tree-shaking.
* In monorepos, create per-package barrels to keep each package tree-shakable and independently version-able.

### TypeScript and typings

* Export types alongside implementations in barrels to provide a consistent API surface for consumers.
* Keep declaration emit deterministic to avoid confusing consumers and editors.

### Avoiding pitfalls

* Don’t create circular re-exports that introduce import loops; keep barrels purely re-exporting primitives, not executing initialization logic.
* Review bundle analysis after introducing barrels to ensure they don’t inadvertently increase initial bundle size.

### Automation & maintenance

* Consider tooling (eslint rules, index generators) to keep barrels in sync as components change.
* Document public API invariants and semver impact when changing barrels to help downstream consumers.

---

## **Dynamic Imports**

Dynamic imports allow loading modules at runtime and returning a Promise for their exports.

```js
async function loadModule() {
  const mod = await import('./heavyModule.js');
  mod.run();
}
```

### React Use-Case

**Lazy loading with React.lazy + Suspense:**

```js
const HeavyWidget = React.lazy(() => import('./HeavyWidget.js'));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <HeavyWidget />
    </Suspense>
  );
}
```

### Benefits

* Reduces bundle size
* Optimizes performance
* Loads components only when needed (e.g., routes)

---

## **Legacy Systems — CommonJS**

Many older Node.js or older React tooling pipelines use **CommonJS**.

### CommonJS Syntax

```js
// exporting
module.exports = { add, subtract };
exports.multiply = (a,b) => a*b;

// importing
const math = require('./math');
const { add } = require('./math');
```

### Differences vs ES Modules

| ES Modules                         | CommonJS                              |
| ---------------------------------- | ------------------------------------- |
| Static, analyzable at compile-time | Dynamic, evaluated at runtime         |
| Supports tree shaking              | Harder to tree shake                  |
| `import` / `export` keywords   | `require()` / `module.exports`    |
| Native in browsers                 | Node-only (until ESM support emerged) |

### React Context

* Most modern React apps use ES Modules (bundlers support them).
* Node server-side code / older tooling may still use CommonJS.
* Interop: Many bundlers allow using both, but best to stay consistent.

---

## **Legacy Systems — Script Globals & IIFE Modules**

Before modules existed, JavaScript used:

1. **Script files with global variables**

   ```html
   <script src="utils.js"></script>
   <script src="app.js"></script>
   ```

   * Risk of name collisions
   * No encapsulation
2. **IIFE (Immediately Invoked Function Expressions)**
   Used to create private scope:

   ```js
   const App = (function() {
     const hidden = 42;
     function run() { console.log(hidden); }
     return { run };
   })();
   ```

### Why this matters for React developers

* Some legacy libraries still expose globals (`ReactDOM`, `axios`, older utility libs).
* Useful when contributing to old codebases or debugging CDN-delivered scripts.

But modern React development should avoid these patterns in favor of ES modules.

---

## **Module Best Practices for React**

### Component Patterns

* Prefer *named exports* for reusable components and hooks.
* Use *default exports* for single-primary components in a file.
* Create folder-based modules:

```zsh
components/
  Button/
    index.js
    Button.jsx
    styles.css
```

### Avoid circular dependencies

* Happens when two modules import each other.
* Causes undefined bindings during initialization.

#### Example

```js
// moduleA.js
import { valueB } from './moduleB.js';
export const valueA = 'A';
export const combined = valueA + valueB; // valueB may be undefined here
```

```js
// moduleB.js
import { valueA } from './moduleA.js';
export const valueB = valueA + 'B';
```

If you import moduleA, moduleB reads valueA before moduleA finishes initializing, so valueA can be undefined and valueB becomes "undefinedB", producing incorrect results.

##### How to fix

* Delay cross-module access (use functions or getters so values are read at call-time, not module-evaluation time):

```js
// moduleA.js (fixed)
import { getValueB } from './moduleB.js';
export const valueA = 'A';
export function getCombined() { return valueA + getValueB(); }
```

```js
// moduleB.js (fixed)
import { valueA } from './moduleA.js';
export function getValueB() { return valueA + 'B'; }
```

* Or extract shared state into a third module so both import from the same source:

```js
// shared.js - Independent module
export const base = 'A';
```

```js
// moduleA.js - Relies on shared.js and moduleB.js
import { base } from './shared.js';
import { valueB } from './moduleB.js';
export const valueA = base;
export const combined = base + valueB; // valueB may be undefined here
```

```js
// moduleB.js - Relies on shared.js
import { base } from './shared.js';
export const valueB = 'B';
export const valueB = base + 'B';
```

#### General guidance

* Avoid having modules compute derived values from each other at top-level.
* Prefer lazy access (functions/getters) or a single shared module to break the cycle.
* If circular imports are unavoidable, ensure you only access imported bindings at runtime (after initialization) rather than during module evaluation.

---

## **Professional Applications and Implementation**

Modern ES Modules are the backbone of scalable React architectures. They enable clear component boundaries, reusable hook libraries, and predictable state-sharing. Dynamic imports support high-performance apps through lazy loading. Legacy module knowledge allows integrating older third-party tools and working across hybrid codebases. Mastering ES Modules ensures maintainable React systems, clear contracts, and optimized bundling strategies across production environments.

---

## **Key Takeaways**

| Area                     | Summary                                                                                      |
| ------------------------ | -------------------------------------------------------------------------------------------- |
| ES Modules               | Modern module system using `import`/`export`; supports tree-shaking and static analysis. |
| Default vs Named Exports | Named exports improve tooling; defaults simplify consumption.                                |
| Dynamic Imports          | Enable code-splitting and React.lazy-based lazy loading.                                     |
| Re-Exports               | Useful for library-style “barrel files”; simplify APIs.                                    |
| Legacy Systems           | CommonJS (`require/module.exports`) and IIFEs still appear in older environments.          |
| React Integration        | Organize components, hooks, and utils using clear module boundaries.                         |

* ES Modules are the preferred system for React and modern frontend tooling.
* Default exports are flexible but harder to refactor; named exports scale better.
* Dynamic imports support performance-driven architecture via lazy-loading.
* Legacy systems matter when working with older Node or browser environments.
* Module structure directly impacts maintainability and performance in React apps.
