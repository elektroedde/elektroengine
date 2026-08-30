import MetalKit

class FEM2DScene: BaseScene {

    lazy var background: Background = {
        Background(device: Renderer.device)
    }()

    var camera: any Camera

    var timer: Float = 0

    init() {
        camera = GraphCamera()
        background.transform.position.z += 0.001
    }

    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        background.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        // gmsh-based FEM geometries (Rectangle, ChargedCylinder, Waveguide, Eigenmode) were
        // removed along with the gmsh/C++ dependency. Re-wire this once geometries are
        // loaded externally from files/coords instead.
    }
}
