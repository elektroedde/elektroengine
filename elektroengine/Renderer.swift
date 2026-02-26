import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    
    weak var metalView: MTKView?
    
    var params = Params()
    var uniforms = Uniforms()
    var options: Options

    let depthStencilState: MTLDepthStencilState?

    init(metalView: MTKView, options: Options) {
        self.metalView = metalView
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }

        /// For now I do this, but want to seperate this into Engine.swift or something
        Self.device = device
        Self.commandQueue = commandQueue
        ShaderLibrary.initialize()
        Self.library = ShaderLibrary.defaultLibrary

        metalView.device = device
        metalView.clearColor = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        metalView.preferredFramesPerSecond = 75
        
        self.options = options

        depthStencilState = Self.buildDepthStencilState()
        super.init()
        
        mtkView(metalView, drawableSizeWillChange: metalView.drawableSize)
        metalView.depthStencilPixelFormat = .depth32Float
    }

    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
}

extension Renderer {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        params.width = UInt32(size.width)
        params.height = UInt32(size.height)
        print("Resizing")
    }
    
    func draw(scene: SceneX, in view: MTKView) {
        guard let commandBuffer = Self.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        renderEncoder.setDepthStencilState(depthStencilState)
        scene.draw(renderEncoder: renderEncoder, params: params, uniforms: uniforms, options: options)
        
        renderEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

