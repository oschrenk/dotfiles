## Access test resource
```scala
import scala.io.Source

// getResource param is path rel to src/main/resource
val source = Source.fromURL(getClass.getResource("/data.xml"))
```

## Self referencing trait

```
trait Point[T <: Point[T]] { self: T =>
  def isNeighborOf(p: T): Boolean
}
case class Manhattan(x: Int, y: Int) extends Point[Manhattan] {
  override def isNeighborOf(that: Manhattan): Boolean = {
    Math.abs(x - that.x) == 1 && Math.abs(y - that.y) == 1
  }
}
```

## Extension method

```
  implicit def t2mapper[A, B](t: (A, B)) = new {
    def map[R](f: A => R, g: B => R) = (f(t._1), g(t._2))
  }

```
