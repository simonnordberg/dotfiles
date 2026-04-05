---
name: frontend-design
description: Design and build production-grade frontend interfaces with strong UX and visual craft. Use this skill when the user asks to build UI, asks UX questions (interaction patterns, flows, empty states, error handling), or needs help with design decisions. Avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
---

This skill guides both UX reasoning and visual implementation for frontend interfaces. It covers interaction design (how it works), visual design (how it looks), and production code (how it's built). Use it for building UI, answering UX questions, or making design decisions.

The user may provide: a component to build, a UX question to answer, a flow to design, or an interface to implement. They may include context about the purpose, audience, or technical constraints.

## 1. Understand Before Designing

Before writing any code, build a clear picture of what you're designing for:

- **Purpose**: What problem does this solve? What's the core user action?
- **Audience**: Who uses this? What do they expect? What context are they in?
- **Constraints**: Existing design system, framework, performance budget, accessibility needs.
- **Tone**: What feeling should this evoke? Match the aesthetic to the context — a developer tool feels different from a consumer app, a dashboard feels different from a landing page.

If the project has a design system or component library, use it. Don't reinvent what exists — extend it thoughtfully.

## 2. Interaction Design (How It Works)

Before thinking about visuals, get the UX right. Think through:

### Information Architecture
- What's the primary action on this screen? Make it obvious.
- What information does the user need, and in what order? Cut everything else.
- Group related actions and content. If things are near each other, users assume they're related.

### Interaction Patterns
Choose patterns based on context, not habit:
- **Modal vs inline**: Modals focus attention but break context. Inline editing keeps flow but adds complexity. Use modals for confirmations and focused creation; inline for quick edits.
- **Progressive disclosure**: Don't show everything at once. Reveal complexity as the user needs it. Defaults should cover 80% of use cases.
- **Direct manipulation vs forms**: Let users drag, click, and interact with the thing itself when possible. Forms are for data entry, not for every interaction.

### States & Edge Cases
Every screen has more than its happy path. Design for:
- **Empty states**: First-time experience. Not a blank page — guide the user toward their first action.
- **Loading states**: Skeleton screens over spinners. Show structure, not a void.
- **Error states**: Be specific about what went wrong and what to do. "Something went wrong" is never acceptable.
- **Partial states**: One item vs many. Truncated content. Missing optional fields.
- **Destructive actions**: Require confirmation proportional to the damage. Delete a draft? Quiet undo. Delete an account? Explicit confirmation.

### Navigation & Flow
- Breadcrumbs, back buttons, and clear wayfinding. The user should always know where they are and how to get back.
- Preserve user context across transitions. Don't reset scroll position, don't lose form state, don't force re-navigation.
- Keyboard navigation and shortcuts for power users. Not optional — it's table stakes.

When the user asks a pure UX question (not "build me X"), reason through the interaction design and present your recommendation with trade-offs. You don't need to write code for every question.

## 3. Explore Multiple Directions

The best design comes from exploring options, not committing to the first idea. Before implementing, briefly describe 2-3 distinct aesthetic directions — not variations on a theme, but genuinely different approaches. For example:

- **Direction A**: Minimal, editorial — generous whitespace, restrained palette, typography-driven hierarchy
- **Direction B**: Dense, data-rich — compact layout, subtle color coding, information-forward
- **Direction C**: Warm, approachable — rounded forms, soft gradients, friendly micro-interactions

State which direction you recommend and why, then implement it. If the user has a clear preference or the project has an established style, skip exploration and match it.

## 4. Design Principles

Every decision should have a reason. Apply these principles:

- **Intentionality over intensity**: A restrained, precise design can be as powerful as a bold one. The key is that every choice — color, spacing, type — serves the design's purpose.
- **Hierarchy is everything**: The user should know exactly where to look first, second, third. Size, weight, color, and space all create hierarchy. If everything is loud, nothing is.
- **Cohesion over novelty**: A design that feels unified and considered beats one with many flashy elements that don't relate. Pick a clear direction and execute it with discipline.
- **Context-appropriate craft**: A SaaS dashboard needs clarity and efficiency. A portfolio needs personality and delight. A landing page needs persuasion and flow. Match the level of expressiveness to what the interface actually needs.

## 5. Visual Craft

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

## 6. Anti-Patterns (AI Slop Indicators)

These signal "AI generated this, no human cared":
- Default font stacks with no typographic opinion
- Purple/blue gradients on white as the default "modern" look
- Evenly-spaced, evenly-sized elements with no hierarchy
- Generic placeholder copy ("Welcome to our platform")
- Decorative elements that don't relate to the content
- Same layout and aesthetic regardless of context
- Animations on everything with no purpose
- Converging on the same "safe" choices (Space Grotesk, indigo-500, rounded-2xl cards) across every generation

## 7. Polish Pass

After the main implementation, do a dedicated polish pass:
- Check spacing consistency and alignment
- Verify typographic hierarchy reads correctly
- Test interactive states (hover, focus, active, disabled)
- Ensure color contrast meets accessibility standards
- Review transitions — do they feel smooth and purposeful?
- Look for "uncanny valley" moments where something feels almost right but off

Ship code that feels like a designer was involved, because one was.
