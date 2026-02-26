import MetalKit

class Graphing2DScene: SceneX {

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

    var camera: any Camera

    var timer: Float = 0

    var width: Float = 0
    var height: Float = 0
    var vectors: [Vector] = []
    let count: Int = 20
    let offsetX: Float = 3
    let offsetY: Float = 2
    init() {
        camera = GraphCamera()
        background.transform.position.z += 0.01
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
    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)


        for i in 0..<vectors.count {
            let x = Float.random(in: 0..<1)
            vectors[i].transform.rotation.z += deltaTime*x*x
        }




    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        background.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        if(options.equationChoice == .sin) {
            graph.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        } else if(options.equationChoice == .cos) {
        } else if(options.equationChoice == .exp) {
        } else if(options.equationChoice == .vector) {
            for vector in vectors {
                vector.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
            }
        }
    }
}
