import MetalKit

class FEM2DScene: BaseScene {

    lazy var background: Background = {
        Background(device: Renderer.device)
    }()

    lazy var colorbar: Colorbar = {
        Colorbar(device: Renderer.device)
    }()

    lazy var square: Square = {
        Square(device: Renderer.device)
    }()

    lazy var charged_cylinder: ChargedCylinder = {
        ChargedCylinder(device: Renderer.device)
    }()

    lazy var waveguide: Waveguide = {
        Waveguide(device: Renderer.device)
    }()

    lazy var rectangularEigenmodes: RectangularEigenmodes = {
        RectangularEigenmodes(device: Renderer.device)
    }()

    lazy var circularEigenmodes: CircularEigenmodes = {
        CircularEigenmodes(device: Renderer.device)
    }()

    var camera: any Camera

    init() {
        camera = GraphCamera()
        background.transform.position.z += 0.001
        colorbar.transform.position.z -= 0.001
    }

    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        if options.fem2D.solveFunction {
            square.solve()
            options.fem2D.solveFunction = false
        }

        background.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        colorbar.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)

        switch options.fem2D.femChoice {
        case .square:
            square.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        case .chargedCylinder:
            charged_cylinder.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        case .waveguide:
            waveguide.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        case .rectangularEigenmodes:
            rectangularEigenmodes.selectMode(options.fem2D.eigenmodeNumber, options: options)
            rectangularEigenmodes.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        case .circularEigenmodes:
            circularEigenmodes.selectMode(options.fem2D.eigenmodeNumber, options: options)
            circularEigenmodes.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        }
    }
}
