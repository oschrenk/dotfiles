---
name: cadova
description: Reference and cheatsheet for Cadova, a Swift DSL for parametric 3D modeling (3MF output, Manifold-backed). Use when reading or writing Swift files that import Cadova, when working in a directory whose Package.swift depends on github.com/tomasf/Cadova, or when the user asks about Cadova primitives, models, edge profiles, materials, or 3MF generation.
user-invocable: true
---

# Cadova

Swift DSL for parametric 3D modeling. Pre-1.0 — the API shifts between minor
versions, so **verify against the bundled source rather than recalling an API
from memory**. This skill bundles a snapshot of upstream docs and source.

Bundled snapshot: **Cadova 0.9.1**, **Helical 1.0.4**. Run `update.sh` to refresh.

## Where to look, in order

1. **`docs/`** — 21 guide articles plus the style guide, plain markdown, grep-friendly.
   This is upstream's own documentation (its DocC catalog), so it is current with
   the pinned version. Read these before searching the web.
2. **`sources/cadova/Sources/Cadova/`** — the source, with DocC comments on every
   public symbol. **The authoritative API reference.** Grep here whenever you are
   unsure of a method name, a parameter label, or a default.
3. **`sources/helical/Sources/Helical/`** — Helical (threads, screws, bolts, nuts,
   washers, holes). No prose docs upstream; source only.

Only reach for the web if all three miss. Upstream publishes the same docs at
<https://cadova.org/docs>.

> Upstream **retired its GitHub wiki** — it is now a single stub page pointing at
> the DocC catalog. Anything referring to `wiki/` or `examples.md` in this skill
> is stale; the content moved to `docs/`.

## The guides in `docs/`

| Looking for | Read |
| --- | --- |
| First model, Package.swift template | `GettingStarted.md`, `WhatIsCadova.md` |
| How geometry composes; booleans | `GeometryConcepts.md` |
| `Vector3D`, `Direction3D`, `Angle`, `°` | `VectorsAndAngles.md` |
| translate / rotate / scale / mirror | `Transformations.md` |
| `.aligned(at:)`, `Stack` | `AlignmentAndStacking.md` |
| Bounding boxes, `measuringBounds` | `MeasuringGeometry.md` |
| `@Environment`, segmentation, tolerances | `EnvironmentConcepts.md` |
| Anchors, tags, attaching parts together | `AnchorsAndTags.md` |
| `Model`, `Project`, output formats | `ModelAndProject.md` |
| `.extruded`, `.revolved`, edge profiles | `ExtrusionAndRevolution.md` |
| `BezierPath`, sweeps, `.swept(along:)` | `CurvesAndPaths.md` |
| Twist, warp, deform, loft | `BendingAndDeforming.md` |
| Arrays, mirrored copies, patterns | `RepetitionAndPatterns.md` |
| Splitting a model for printing | `CuttingAndSplitting.md` |
| Overhangs, tolerances, print orientation | `DesigningFor3DPrinting.md` |
| Multi-part models, materials, colours | `WorkingWithParts.md` |
| Worked examples | `Examples.md` |
| Something crashes or renders wrong | `Troubleshooting.md` |
| Idioms upstream expects you to write | `CadovaStyleGuide.md` |
| Caching, the node graph, evaluation | `Internals.md` |

## Source tree map

`sources/cadova/Sources/Cadova/`

| Directory | Holds |
| --- | --- |
| `Abstract Layer/2D`, `/3D` | Primitives — `Box`, `Sphere`, `Cylinder`, `Circle`, `Rectangle`, `Text`, … |
| `Abstract Layer/Operations/` | Everything you chain: `Boolean/`, `Extrude/`, `Loft/`, `Edge Profiling/`, `Transformations/`, `Duplication/`, `Offsetting/`, `Stack.swift`, `Split3D.swift`, `Twist.swift`, `Warp.swift` |
| `Abstract Layer/Environment/` | `@Environment` values — segmentation, twist rate |
| `Values/` | `Vector3D`, `Angle`, `BoundingBox`, edge profiles, materials, colours |
| `Concrete Layer/` | `Model`, `Project`, and the output writers (3MF, STL, SVG) |
| `Node Layer/` | The evaluation graph. You rarely touch this. |

`sources/helical/Sources/Helical/`: `Bolt/`, `Nut/`, `Screw.swift`, `Thread/`,
`Washers/`, `Holes/`, `LeadIn.swift`.

Useful greps:

```sh
grep -rn "func swept" sources/cadova/Sources/Cadova/     # confirm a signature
grep -rE "public (struct|enum|func|protocol)" sources/cadova/Sources/Cadova/
grep -rni "chamfer" docs/                                 # concept first
```

## Hard facts

### Units: millimeters only
- Every `Double` dimension is millimeters. There is no `Length` or
  `Measurement<UnitLength>` type.
- `Measurements2D.area` is mm², `Measurements3D.volume` is mm³.
- Inches → multiply by `25.4` yourself.

### `Geometry2D` / `Geometry3D`, not `Shape2D` / `Shape3D`
`Shape2D` and `Shape3D` are **deprecated** as of 0.9 (`Compatibility.swift`) —
conform to `Geometry2D` / `Geometry3D` directly. Existing code still compiles,
with a warning per conformance.

```swift
struct KickPlate: Geometry3D {          // not Shape3D
    var body: any Geometry3D { Box([w, t, h]) }
}
```

### Entry points are async
- `Model` and `Project` are async — `await` them, including at top level in `main.swift`.
- Closure bodies are result builders. No `return`; stack geometry.
- `Project(root:)` takes a `String?` path (or a `URL?`); `Project(packageRelative:)`
  resolves against the package root. A bare `Model` writes to the working directory.
- Two models may share a name if their output formats differ (`.3mf` and `.stl`).

```swift
await Project(root: "Build/Caddy") {
    await Model("caddy") { Cabinet() }                       // → caddy.3mf
    await Model("caddy", options: .format3D(.stl)) { … }     // → caddy.stl
    await Model("Nesting", options: .format2D(.svg)) { … }   // → Nesting.svg
}
```

### Booleans take closures, not arrays
`.adding { }`, `.subtracting { }`, `.intersecting { }` — or the free builders
`Union { }`, `Difference { }`, `Intersection { }`.

### Package.swift requirements
- `// swift-tools-version: 6.1` minimum, `platforms: [.macOS(.v14)]`
- **Every** target touching Cadova needs
  `swiftSettings: [.interoperabilityMode(.Cxx)]`. Cadova wraps the C++ Manifold
  kernel and the setting does **not** propagate across a module boundary — a
  shared library and each executable that imports it both need it.
- Commit `Package.resolved` for model projects; gitignore it for libraries.

### Toolchain gotcha
manifold-swift **below 1.1.1** segfaults on Swift 6.4 when the 3MF writer reads
`MeshGL.originalIDs` — the runtime cannot resolve a `Sequence` conformance on a
C++ `std::vector`. STL output is unaffected. Do not pin below 1.1.1.

## The woodwork repo

`~/Projects/resources/woodwork` — one Swift package, a shared `Woodwork` library
plus one executable target per furniture project.

- Build with `task build:<project>`; outputs land in `Build/<Project>/`.
- Docs, cutlists, and shopping lists live in `Docs/<Project>/`.
- Open the generated `.3mf` in [CadovaViewer](https://github.com/tomasf/CadovaViewer)
  for live reload.
- Adding a project: see `DEVELOPMENT.md`.

## Refreshing this skill

```sh
bash "$CLAUDE_CONFIG_DIR/skills/cadova/update.sh"
```

Re-clones Cadova and Helical at the versions pinned at the top of `update.sh`,
then copies the DocC articles into `docs/`. Set `CADOVA_VERSION=main` to track
latest. Keep the pins in step with the `Package.swift` of the project you work in.
