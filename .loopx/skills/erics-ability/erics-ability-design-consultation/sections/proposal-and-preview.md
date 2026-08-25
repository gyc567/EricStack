# Design Proposal and Preview

Run after product context and optional research are complete. The output must serve the memorable thing identified in Phase 1 and remain implementable in the target product stack.

## Phase 3: Direction and System

Propose one primary direction and, only when a real trade-off remains, one alternative. For each direction define:

- positioning and the intended user feeling;
- typography roles and available font fallbacks;
- color tokens with accessible foreground/background pairs;
- spacing, radius, border, elevation, and motion principles;
- information density and responsive layout behavior;
- imagery, iconography, data-visualization, and empty-state style;
- the deliberate risk and the table-stakes patterns retained.

Explain how every major choice supports the memorable thing. Avoid invented brand assets and unavailable fonts.

## Phase 4: Components and States

Map the direction to reusable components in the product's actual stack:

- page shell, navigation, and responsive regions;
- headings, body text, links, and content hierarchy;
- buttons, inputs, selection controls, and validation;
- cards, tables, lists, dialogs, notifications, and loading states;
- focus, hover, active, disabled, error, empty, and success states;
- keyboard behavior, contrast, reduced motion, and screen-reader labels.

For each component, identify existing implementation to reuse and the smallest required extension. Do not create a parallel design system when the repository already owns one.

## Phase 5: Drill-Downs

Apply the system to the highest-value user workflows. Each drill-down includes:

1. user goal and entry point;
2. content hierarchy and primary action;
3. desktop and narrow-screen layout;
4. loading, empty, error, permission, and completion states;
5. accessibility behavior;
6. reusable components and tokens;
7. observable acceptance criteria.

Prioritize workflows that prove the system rather than producing many decorative screens.

## Phase 6: Preview and DESIGN.md

When browser or rendering tools are available, create a preview from real components or a clearly isolated prototype. Capture the exact viewport and note any synthetic data. When tools are unavailable, provide a structured textual preview and mark visual validation pending.

Write `DESIGN.md` with:

```markdown
# Product Design System

## Memorable Thing
## Product and User Context
## Direction and Rationale
## Foundations
### Typography
### Color
### Spacing and Layout
### Shape, Elevation, and Motion
## Components and States
## Workflow Drill-Downs
## Accessibility
## Responsive Behavior
## Implementation Map
## Acceptance Criteria
## Open Questions and Deferred Validation
```

The implementation map names owning files, existing components, new tokens, and migration order. Acceptance criteria must be observable in the real product workflow. Do not call the proposal complete when required assets, product decisions, or preview tooling are unavailable; report `BLOCKED` or `DESIGN READY, VISUAL VALIDATION PENDING` as appropriate.
