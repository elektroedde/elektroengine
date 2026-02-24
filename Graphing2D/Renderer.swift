import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!

    var vertexBuffer: MTLBuffer!

    var mesh: MTKMesh!

    lazy var background: Background = {
        Background(device: Self.device)
    }()

    lazy var graph: Graph = {
        Graph(device: Self.device)
    }()

    lazy var scene = ApplicationScene()
    var lastTime: Double = CFAbsoluteTimeGetCurrent()

    var params = Params()
    var uniforms = Uniforms()

    var options: Options
    init(metalView: MTKView, options: Options) {

        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }

        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device




        /// This code puts the mesh data in an MTLBuffer


        let library = device.makeDefaultLibrary()
        Self.library = library

        self.options = options
        super.init()

        metalView.clearColor = MTLClearColor(red: 1.0,
                                             green: 1.0,
                                             blue: 0.8,
                                             alpha: 1.0)

        metalView.preferredFramesPerSecond = 75
        metalView.delegate = self
        

        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
    }
}


extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        params.width = UInt32(size.width)
        params.height = UInt32(size.height)

        scene.update(size: size)
        
    }

    func updateUniforms() {

    }

    func draw(in view: MTKView) {

        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }





        /// Draw the background
        ///
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = (currentTime - lastTime)
        lastTime = currentTime
        scene.update(deltaTime: Float(deltaTime))
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix

        scene.background.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)

        if(options.equationChoice == .sin) {
            scene.graph.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
        } else if(options.equationChoice == .cos) {

        } else if(options.equationChoice == .exp) {
            
        } else if(options.equationChoice == .vector) {
            
            for vector in scene.vectors {
                vector.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms)
            }
        }





        renderEncoder.endEncoding()

        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

