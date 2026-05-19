---
name: cadova
description: Reference and cheatsheet for Cadova, a Swift DSL for parametric 3D modeling (3MF output, Manifold-backed). Use when reading or writing Swift files that import Cadova, when working in a directory whose Package.swift depends on github.com/tomasf/Cadova, or when the user asks about Cadova primitives, models, edge profiles, materials, or 3MF generation.
user-invocable: true
---

# Cadova

Swift DSL for parametric 3D modeling. Pre-1.0 — API may shift between minor versions. This skill bundles a snapshot of upstream docs.

## Bundled reference (use these first, before WebFetch)

- `wiki/` — full Cadova wiki, grep-friendly markdown. Key pages:
  - `wiki/Getting-Started.md` — Package.swift template, hello-world
  - `wiki/Core-Concepts:-1.-Geometry.md` through `5.-Model-and-Project.md`
  - `wiki/Working-with-Parts.md` — multi-part models, materials
  - `wiki/Troubleshooting.md`
- `examples.md` — copy of the Examples wiki page (Chamfer, materials, swept text, loft, …) for quick scanning
- `source/Sources/Cadova/` — Cadova source with inline DocC comments. The authoritative API reference. Grep here when uncertain about method names or parameters.

When the user asks about a Cadova type, primitive, or operation: **grep `source/Sources/Cadova/` first**, then fall back to the wiki. Avoid inventing method names — Cadova's pre-1.0 API is too easy to hallucinate.

## Hard facts to remember

### Units: millimeters only
- All `Double` dimensions are millimeters. There is no `Length`/`Measurement<UnitLength>` type.
- `Measurements2D.area` is mm², `Measurements3D.volume` is mm³.
- Inches → multiply by `25.4` yourself.

### Entry point: `await Model(...)`
- `Model` is async. Top-level use requires `await`.
- The closure body is a result-builder DSL — no `return`, just stack shapes.
- Running the executable writes `<name>.3mf` to the working directory.

```swift
import Cadova

await Model("widget") {
    Box([10, 10, 5])
        .subtracting {
            Sphere(diameter: 10).translated(z: 5)
        }
}
```

### Required Package.swift bits
- `// swift-tools-version: 6.1` (minimum)
- `platforms: [.macOS(.v14)]`
- Target needs `swiftSettings: [.interoperabilityMode(.Cxx)]` — Cadova bridges to Manifold (C++)
- Pin with `.upToNextMinor(from: "X.Y.Z")` because Cadova is pre-1.0

### Package.resolved
- Executable (model) project → commit `Package.resolved` for reproducible builds.
- Library → gitignore it.

## API quick-reference (verified against 0.6.1 source)

Always grep `source/` to confirm — this list is a starting point, not exhaustive.

### 2D primitives
- `Circle(diameter:)`, `Circle(radius:)`
- `Rectangle([x, y])`, `Rectangle(x:, y:)`
- `RegularPolygon(sideCount:, widthAcrossFlats:)` (also `circumradius:`, `inradius:`)
- `Text(_:)` with `.withFont(_:, style:, size:)`

### 3D primitives
- `Box([x, y, z])`, `Box(x:, y:, z:)`
- `Sphere(diameter:)`, `Sphere(radius:)`
- `Cylinder(diameter:, height:)`, `Cylinder(bottomDiameter:, topDiameter:, height:)`

### Booleans (closures, not arrays)
- `.subtracting { ... }` / `.intersecting { ... }` / `.adding { ... }`
- Or the free functions `Union { }`, `Difference { }`, `Intersection { }`

### Transforms
- `.translated(x:, y:, z:)`, `.rotated(x:, y:, z:)` (angles in `Angle` type — `90°` literal works)
- `.scaled(_:)`, `.mirrored(in:)`
- `.clonedAt(x:)` — places a copy at offset, keeps original

### 2D → 3D
- `.extruded(height:)` — basic linear extrusion
- `.extruded(height:, topEdge:, bottomEdge:)` — with edge profiles
- `.revolved()` — around Y axis

### Edge profiles (for `topEdge:`/`bottomEdge:` on extrude)
- `.chamfer(depth:)`, `.chamfer(width:, height:)`
- `.fillet(radius:)`
- `.none`

### Rounding (2D)
- `.rounded(insideRadius:)`, `.rounded(outsideRadius:)`, `.rounded(radius:)`

### Layout
- `Stack(.x, spacing:) { ... }` / `Stack(.y, …)` / `Stack(.z, …)`
- Alignment via `.aligned(at: .centerX, .bottom)` etc.

### Materials & color
- `.colored(.darkOrange)` (CSS color names available)
- `.withMaterial(.glossyPlastic(.mediumSeaGreen))`, `.steel`, etc.

## Conventions for caddy / parts work

- The user is building parts in `/Users/oliver/Projects/parts/`. Each part is its own Swift executable package.
- Build via Taskfile.yml — typically `task build` and `task run` (which writes the `.3mf`).
- Run the executable to view results; `chamfer.3mf` and similar are gitignored.
- The user opens 3MF in [CadovaViewer](https://github.com/tomasf/CadovaViewer) on macOS for live reload.

## Refreshing this skill

```sh
bash $CLAUDE_CONFIG_DIR/skills/cadova/update.sh
```

This re-clones the wiki and Cadova source (defaults to latest `main`; set `CADOVA_VERSION=0.6.1` to pin). Re-run after upstream releases a new minor version.

## Useful greps

```sh
# Find all public symbols
grep -rE "public (struct|enum|class|func|extension|protocol)" source/Sources/Cadova/

# Find a specific method
grep -rn "func extruded" source/Sources/Cadova/

# Search wiki for a concept
grep -rni "alignment" wiki/
```
