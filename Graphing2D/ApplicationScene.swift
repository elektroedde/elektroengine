import MetalKit

struct ApplicationScene {

    lazy var background: Background = {
        Background(device: Renderer.device)
    }()

    lazy var graph: Graph = {
        Graph(device: Renderer.device)
    }()

    lazy var vector: Vector = {
        Vector(device: Renderer.device)
    }()

    lazy var vector2: Vector = {
        Vector(device: Renderer.device)
    }()

    /// Change this to [Model] and make all my objects into : Model

    var camera = GraphCamera()

    var timer: Float = 0

    var width: Float = 0
    var height: Float = 0
    var vectors: [Vector] = []
    let count: Int = 20
    let offsetX: Float = 3
    let offsetY: Float = 2
    init() {
        for i in 0..<count {
            for j in 0..<count {
                vectors.append(Vector(device: Renderer.device))
                vectors[count*i + j].transform.position.x = Float(i)-Float(count/2) + offsetX
                vectors[count*i + j].transform.position.y = Float(j)-Float(count/2) + offsetY

                let xpos = vectors[count*i + j].transform.position.x - offsetX
                let ypos = vectors[count*i + j].transform.position.y - offsetY

                

               if(xpos > 0 && ypos > 0) {
                   vectors[count*i + j].transform.rotation.z = atan(abs(ypos/xpos))
               } else if(xpos < 0 && ypos > 0) {
                   ///Quadrant 2
                   vectors[count*i + j].transform.rotation.z = Float.pi - atan(abs(ypos/xpos))
               } else if(xpos < 0 && ypos < 0) {
                   vectors[count*i + j].transform.rotation.z = Float.pi + atan(abs(ypos/xpos))
               } else if(xpos > 0 && ypos < 0) {
                   vectors[count*i + j].transform.rotation.z = 2*Float.pi - atan(abs(ypos)/abs(xpos))
               } else if(xpos == 0 && ypos > 0) {
                   vectors[count*i + j].transform.rotation.z = Float.pi/2
               } else if (xpos == 0 && ypos < 0) {
                   vectors[count*i + j].transform.rotation.z = 3*Float.pi/2
               } else if(xpos > 0 && ypos == 0) {
                   vectors[count*i + j].transform.rotation.z = 0
               } else if(xpos < 0 && ypos == 0) {
                   vectors[count*i + j].transform.rotation.z = Float.pi
               }
            }
        }
    }
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }

    mutating func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)

        let startTime = CFAbsoluteTimeGetCurrent()
        for i in 0..<vectors.count {
            var x = Float.random(in: 0..<1)
            vectors[i].transform.rotation.z += deltaTime*x*x
        }
        let endTime = CFAbsoluteTimeGetCurrent()

        print("Time: \((endTime - startTime)*1000)")

    }
}
