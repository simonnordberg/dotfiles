---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## 1. Understand Before Designing

Before writing any code, build a clear picture of what you're designing for:

- **Purpose**: What problem does this solve? What's the core user action?
- **Audience**: Who uses this? What do they expect? What context are they in?
- **Constraints**: Existing design system, framework, performance budget, accessibility needs.
- **Tone**: What feeling should this evoke? Match the aesthetic to the context — a developer tool feels different from a consumer app, a dashboard feels different from a landing page.

If the project has a design system or component library, use it. Don't reinvent what exists — extend it thoughtfully.

## 2. Explore Multiple Directions

The best design comes from exploring options, not committing to the first idea. Before implementing, briefly describe 2-3 distinct aesthetic directions — not variations on a theme, but genuinely different approaches. For example:

- **Direction A**: Minimal, editorial — generous whitespace, restrained palette, typography-driven hierarchy
- **Direction B**: Dense, data-rich — compact layout, subtle color coding, information-forward
- **Direction C**: Warm, approachable — rounded forms, soft gradients, friendly micro-interactions

State which direction you recommend and why, then implement it. If the user has a clear preference or the project has an established style, skip exploration and match it.

## 3. Design Principles

Every decision should have a reason. Apply these principles:

- **Intentionality over intensity**: A restrained, precise design can be as powerful as a bold one. The key is that every choice — color, spacing, type — serves the design's purpose.
- **Hierarchy is everything**: The user should know exactly where to look first, second, third. Size, weight, color, and space all create hierarchy. If everything is loud, nothing is.
- **Cohesion over novelty**: A design that feels unified and considered beats one with many flashy elements that don't relate. Pick a clear direction and execute it with discipline.
- **Context-appropriate craft**: A SaaS dashboard needs clarity and efficiency. A portfolio needs personality and delight. A landing page needs persuasion and flow. Match the level of expressiveness to what the interface actually needs.

## 4. Visual Craft

### Typography
Choose fonts that have character and suit the context. Avoid defaults (Inter, Roboto, Arial, system-ui) — they signal "no one made a decision here." Pair a distinctive display font with a legible body font. Use scale, weight, and spacing to create clear hierarchy. Type alone can carry an entire design.

### Color & Theme
Commit to a cohesive palette. Use CSS variables for consistency. A dominant color with sharp accents outperforms a timid, evenly-distributed palette. Dark and light themes are both valid — choose based on context, not habit. Avoid the cliché purple-gradient-on-white that marks AI-generated design.

### Layout & Space
Use space with intention. Generous negative space creates calm and focus. Controlled density creates efficiency and power. Asymmetry, overlap, and grid-breaking elements add energy — but only when they serve the design. Don't add visual complexity for its own sake.

### Motion & Interaction
Prioritize high-impact moments over scattered micro-interactions. A well-orchestrated page entrance with staggered reveals creates more delight than random hover effects. Use CSS transitions and animations by default; reach for Motion (Framer Motion) in React when interaction complexity demands it. Every animation should feel purposeful — it either guides attention, provides feedback, or creates continuity.

### Surface & Texture
Go beyond flat solid colors when the design calls for it. Gradient meshes, noise textures, subtle shadows, layered transparencies — these create depth and atmosphere. But restraint matters: a clean, flat design with perfect spacing can feel more crafted than one drowning in effects.

## 5. Anti-Patterns (AI Slop Indicators)

These signal "AI generated this, no human cared":
- Default font stacks with no typographic opinion
- Purple/blue gradients on white as the default "modern" look
- Evenly-spaced, evenly-sized elements with no hierarchy
- Generic placeholder copy ("Welcome to our platform")
- Decorative elements that don't relate to the content
- Same layout and aesthetic regardless of context
- Animations on everything with no purpose
- Converging on the same "safe" choices (Space Grotesk, indigo-500, rounded-2xl cards) across every generation

## 6. Polish Pass

After the main implementation, do a dedicated polish pass:
- Check spacing consistency and alignment
- Verify typographic hierarchy reads correctly
- Test interactive states (hover, focus, active, disabled)
- Ensure color contrast meets accessibility standards
- Review transitions — do they feel smooth and purposeful?
- Look for "uncanny valley" moments where something feels almost right but off

Ship code that feels like a designer was involved, because one was.
