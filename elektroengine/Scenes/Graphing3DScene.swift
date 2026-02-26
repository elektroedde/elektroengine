import MetalKit

class Graphing3DScene: SceneX {
    var camera: any Camera

    lazy var surface: Surface3D = {
        Surface3D(device: Renderer.device)
    }()

    var timer: Float = 0
    var pointer: UnsafeMutablePointer<Vertex>!

    init() {
        camera = ArcballCamera()

        pointer = surface.vertexBuffer.contents().bindMemory(to: Vertex.self, capacity: surface.vertices.count)

    }

    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        timer += deltaTime
        camera.update(deltaTime: deltaTime)
        
        // Frequency increases over time - starts at 0.5 (half period), increases slowly
        let frequency: Float = 0.5 + timer * 0.4  // Starts at 0.5, increases by 0.5 per second

        let nodes = Int(surface.nodes)
        for i in 0..<nodes {
            for j in 0..<nodes {
                let index = i * nodes + j
                
                // Calculate x position in [0, 1] range
                let x: Float = Float(j) / Float(nodes - 1)
                
                // Sine wave formula: y = amplitude * sin(frequency * π * x)
                let amplitude: Float = exp(-Float(i) / Float(nodes))
                let yy = 0.5 + amplitude * sin(frequency * Float.pi * x) / 2

                // Update the vertex
                pointer[index].y = yy
            }
        }
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        surface.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
    }
}
