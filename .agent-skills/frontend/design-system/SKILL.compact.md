# frontend-design-system

> Produce production-grade UI designs using design tokens, layout rules, motion guidance, and accessibility checks.

## When to use this skill
- Production-quality UI from prompt
- Consistent design language
- Typography, layout, motion guidance

## Instructions
**S1: Define Design Tokens**
- Colors (primary, secondary, semantic)
- Typography (font, scale, weights)
- Spacing (8px base unit)
- Border radius, shadows

**S2: Define Layout + UX Goals**
- Page type (landing, dashboard, form)
- Key actions and hierarchy
- Responsive constraints

**S3: Generate UI Output**
- Section list + visual direction
- Layout with components
- Motion/interaction notes

**S4: Validate Accessibility**
- Contrast checks (4.5:1 text, 3:1 UI)
- Keyboard focus order
- Semantic HTML

**S5: Handoff**
- Component breakdown
- CSS/token summary
- Files delivered

## Design Tokens Example
```typescript
colors: { primary: '#2563EB', ... }
typography: { fontSize: { base: '1rem', ... } }
spacing: { 4: '1rem', 8: '2rem', ... }
```

## Best practices
1. Content hierarchy first
2. Consistent spacing scale (8px)
3. Motion with intent
4. Mobile-first testing

## Validation (Multi-Agent)
- R1 (Orchestrator): Visual direction
- R2 (Analyst): Accessibility review
- R3 (Executor): Handoff checklist
