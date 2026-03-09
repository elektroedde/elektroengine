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

    var pointer: UnsafeMutablePointer<Float>!


    

    init() {
        camera = GraphCamera()
        background.transform.position.z += 0.001
        
        pointer = eigenmode.femBuffer.contents().bindMemory(to: Float.self, capacity: eigenmode.femValues.count)
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
            
            if(options.eigenmodeNumber == .one) {
                for i in 0..<eigenmode.femValues.count {
                    pointer[i] = eigenmode.eigenmode1[i]
                }
                eigenmode.femValues = eigenmode.eigenmode1
                
            } else if(options.eigenmodeNumber == .two) {
                for i in 0..<eigenmode.femValues.count {
                    pointer[i] = eigenmode.eigenmode2[i]
                }
                eigenmode.femValues = eigenmode.eigenmode2
            } else if(options.eigenmodeNumber == .three) {
                for i in 0..<eigenmode.femValues.count {
                    pointer[i] = eigenmode.eigenmode3[i]
                }
                eigenmode.femValues = eigenmode.eigenmode3
            } else if(options.eigenmodeNumber == .four) {
                for i in 0..<eigenmode.femValues.count {
                    pointer[i] = eigenmode.eigenmode4[i]
                }
                eigenmode.femValues = eigenmode.eigenmode4
            } else if(options.eigenmodeNumber == .five) {
                for i in 0..<eigenmode.femValues.count {
                    pointer[i] = eigenmode.eigenmode5[i]
                }
                eigenmode.femValues = eigenmode.eigenmode5
            } else if(options.eigenmodeNumber == .six) {
                for i in 0..<eigenmode.femValues.count {
                    pointer[i] = eigenmode.eigenmode6[i]
                }
                eigenmode.femValues = eigenmode.eigenmode6
            } else if(options.eigenmodeNumber == .seven) {
                for i in 0..<eigenmode.femValues.count {
                    pointer[i] = eigenmode.eigenmode7[i]
                }
                eigenmode.femValues = eigenmode.eigenmode7
            }
            
            
            eigenmode.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        }

    }
}
