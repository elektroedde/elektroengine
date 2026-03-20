import MetalKit

class Graphing2DScene: BaseScene {

    lazy var background: Background = {
        Background(device: Renderer.device)
    }()

    lazy var graph: Graph = {
        Graph(device: Renderer.device)
    }()

    var camera: any Camera

    var timer: Float = 0

    let count: Int = 100
    let offsetX: Float = 3
    let offsetY: Float = 2
    var vectorField: VectorField

    init() {
        camera = GraphCamera()
        vectorField = VectorField(device: Renderer.device, count: count * count)

        background.transform.position.z += 0.01

        for i in 0..<count {
            for j in 0..<count {
                let idx = count * i + j
                let px = Float(i) - Float(count / 2) + offsetX
                let py = Float(j) - Float(count / 2) + offsetY

                let xpos = px - offsetX
                let ypos = py - offsetY

                let angle = atan2(ypos, xpos)

                vectorField.instancePointer[idx] = VectorInstance_Swift(
                    position: SIMD2<Float>(px, py),
                    rotation: angle
                )
            }
        }
    }

    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
        for i in 0..<vectorField.instanceCount {
            vectorField.instancePointer[i].rotation += deltaTime * 0.5
        }
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        background.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        if options.equationChoice == .sin {
            graph.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        } else if options.equationChoice == .vector {
            vectorField.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        }
    }
}
