import MetalKit

class FEM3DScene: SceneX {



    lazy var cube: Cube = {
        return Cube(device: Renderer.device)
    }()

    var camera: any Camera

    var timer: Float = 0





    init() {
        camera = ArcballCamera()
        

    }
    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)

    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {

        cube.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
    }
}
