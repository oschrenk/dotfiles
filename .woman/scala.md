Access test resource
```scala
import scala.io.Source

// getResource param is path rel to src/main/resource
val source = Source.fromURL(getClass.getResource("/data.xml"))
```
