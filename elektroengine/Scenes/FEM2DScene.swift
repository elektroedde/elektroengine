import MetalKit

class FEM2DScene: SceneX {

    lazy var background: Background = {
        Background(device: Renderer.device)
    }()

 

    lazy var gmsh_rectangle: GMSH_Rectangle = {
        GMSH_Rectangle(device: Renderer.device)
    }()

    lazy var charged_cylinder: ChargedCylinder = {
        ChargedCylinder(device: Renderer.device)
    }()

    lazy var waveguide: Waveguide = {
        Waveguide(device: Renderer.device)
    }()
    
    lazy var eigenmode: Eigenmode = {
        Eigenmode(device: Renderer.device)
    }()


    var camera: any Camera

    var timer: Float = 0



    

    init() {
        camera = GraphCamera()
        background.transform.position.z += 0.001

        //charged_cylinder.transform.position.z -= 0.01
        //background.transform.position.z += 0.0001

    }
    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)

    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {

        background.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        if(options.femChoice == .rectangle) {
            gmsh_rectangle.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        } else if(options.femChoice == .chargedCylinder) {
            charged_cylinder.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        } else if(options.femChoice == .waveguide) {
            waveguide.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        } else if(options.femChoice == .eigenmode) {
            eigenmode.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        }

    }
}
