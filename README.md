# Peptide Lab 101

Interactive chalkboard classroom for 49 peptides: which hormones each one raises or blocks, metabolic data, pivotal trial results, half-lives, and a 3D molecule built from the real amino-acid sequence.

Single static `index.html` (Three.js, GSAP, Lenis from CDN). No build step.

Educational only, not medical advice. Data status as of October 2026.

## Interaction layers

- **Scroll engine:** one Lenis instance on the GSAP ticker. Every loop on the page (the 3D viewers, the particle soup, the physics box) rides `gsap.ticker`, and scroll velocity is published once as the `--v` CSS variable.
- **Particle soup:** a seeded Canvas 2D field (5,200 points desktop, 1,800 phone) that scrubs from loose amino acids into a word, repels from the pointer, and reforms after a tap burst.
- **Toy box:** matter-js chips, one per residue, weighted by side-chain size. Drag and throw them.
- **Gestures:** swipe sideways on the lab bench for the next peptide, pull the handle down to close (phone), and drag the capsule to start the quiz. Every gesture has a button or key equivalent.
- **Chalk dust toggle:** turns all motion off (native scroll, settled formations, no inertia).

## Share image (vgpu, headless WebGPU)

`og-hero.png` is a real WGSL shader (`og/chalk.wgsl`) rendered headless through Dawn with vgpu, then titled with ffmpeg:

```
cd og && npm install && npx vgpu check chalk.wgsl && npm run build && bash title.sh
```
