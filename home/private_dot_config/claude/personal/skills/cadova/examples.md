## Chamfer
<img src="https://github.com/user-attachments/assets/43e27ad2-0d0f-409f-a126-032933f2a6e5" width="40%" align="right">

```swift
await Model("chamfer") {
    Circle(diameter: 12)
        .clonedAt(x: 8)
        .rounded(insideRadius: 2)
        .extruded(height: 7, topEdge: .chamfer(depth: 2))
}
```
<br clear="both"/>

## Colors and materials
<img src="https://github.com/user-attachments/assets/9a2fbfa9-f8da-4fc6-9c76-9df9d39f267a" width="40%" align="right">

```swift
await Model("stack-materials") {
    Stack(.x, spacing: 2, alignment: .center, .bottom) {
        Sphere(diameter: 10)
            .colored(.darkOrange)
        Cylinder(diameter: 8, height: 12)
            .withMaterial(.glossyPlastic(.mediumSeaGreen))
        Box(x: 12, y: 8, z: 15)
            .withMaterial(.steel)
    }
}
```
<br clear="both"/>

## Swept text
<img src="https://github.com/user-attachments/assets/0ecaf146-a025-4829-ac5c-581ff1fbeb59" width="40%" align="right">

```swift
await Model("swept-text") {
    Text("Cadova")
        .withFont("Futura", style: "Condensed Medium", size: 10)
        .wrappedAroundCircle(spanning: 230°..<310°)
        .aligned(at: .centerX, .bottom)
        .swept(along: BezierPath {
            curve(
                controlX: 20, controlY: 10, controlZ: 3,
                endX: 20, endY: 30, endZ: 12
            )
        })
}
```
<br clear="both"/>

## Loft
<img src="https://github.com/user-attachments/assets/7f1900ba-43b5-4444-9765-76bed945977d" width="40%" align="right">

```swift
await Model("loft") {
    Loft(interpolation: .easeInOut) {
        layer(z: 0) {
            Ring(outerDiameter: 20, innerDiameter: 12)
        }
        layer(z: 30) {
            Rectangle(x: 25, y: 6)
                .aligned(at: .center)
                .cloned { $0.rotated(90°) }
                .subtracting {
                    RegularPolygon(sideCount: 8, circumradius: 2)
                }
        }
        layer(z: 35) {
            Ring(outerDiameter: 12, innerDiameter: 10)
        }
    }
}
```
<br clear="both"/>

## Circular overhang
<img src="https://github.com/user-attachments/assets/4b61e227-708b-4746-bcd4-760c2bad5448" width="40%" align="right">

```swift
await Model("circular-overhang") {
    Stack(.x, spacing: 5) {
        Box(20)
            .aligned(at: .centerXY)
            .subtracting {
                Cylinder(diameter: 10, height: 20)
                    .overhangSafe(.teardrop)
            }
            .rotated(x: -90°)

        Circle(diameter: 20)
            .overhangSafe(.bridge)
            .extruded(height: 20)
            .rotated(x: -90°)
    }
    .aligned(at: .minZ)
}
```
Using `overhangSafe(_:)` makes a circle or cylinder extend its shape to work better with FDM 3D printing. The shapes are extended in the right direction automatically, using the geometry's world transform, pointing downward for additive geometry and upward for subtractive geometry (holes).

## Table
<img src="https://github.com/user-attachments/assets/481cd0fa-0f1c-450d-bdaf-e76f7f99ba9e" width="40%" align="right">

```swift
await Model("table") {
    let height = 7.0
    let footDiameter = 2.0
    let footHeight = 2.0
    let legDiameter = 1.0
    let topThickness = 1.0
    let size = Vector2D(5, 7)

    Loft(interpolation: .smootherstep) {
        layer(z: 0) { Circle(diameter: footDiameter) }
        layer(z: footHeight) { Circle(diameter: legDiameter) }
        layer(z: height) { Circle(diameter: legDiameter) }
    }
    .translated(size / 2, z: 0)
    .symmetry(over: .xy)
    .sliced(atZ: height - 1e-6) { base, slice in
        base
        slice.extruded(height: topThickness)
            .convexHull()
            .translated(z: height)
    }
}
```