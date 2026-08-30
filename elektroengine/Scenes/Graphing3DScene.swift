import MetalKit

class Graphing3DScene: BaseScene {
    var camera: any Camera

    /*lazy var waveguide: Surface3D = {
        Surface3D(device: Renderer.device)
    }()*/
    
    lazy var gravity: GravitySurface = {
        GravitySurface(device: Renderer.device)
    }()

    var timer: Float = 0
    var pointer: UnsafeMutablePointer<Vertex>!

    init() {
        camera = FPCamera()
        camera.transform.rotation.x = Float(-30).degreesToRadians
        /*pointer = waveguide.vertexBuffer.contents().bindMemory(to: Vertex.self, capacity: waveguide.vertices.count)*/

    }

    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        timer += deltaTime
        camera.update(deltaTime: deltaTime)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        
        if(options.surface == .waveguide) {
            /*waveguide.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options, timer: timer)*/
        } else if(options.surface == .gravity) {
            gravity.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options, timer: timer)
        }
        
    }
}
