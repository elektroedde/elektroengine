import MetalKit

class FEM3DScene: BaseScene {



    lazy var cube: Cube = {
        return Cube(device: Renderer.device)
    }()
    
    lazy var colorbar: Colorbar = {
        Colorbar(device: Renderer.device)
    }()
    

    var camera: any Camera

    var timer: Float = 0





    init() {
        camera = ArcballCamera()
        colorbar.transform.position.z -= 0.001
        

    }
    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)

    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        colorbar.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        cube.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        

    }
}
