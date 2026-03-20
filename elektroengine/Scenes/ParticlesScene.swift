import MetalKit

class ParticlesScene: BaseScene {

    let particlePSO: MTLComputePipelineState
    let clearScreenPSO: MTLComputePipelineState
    
    let particleCount = 1
    var camera: any Camera
    var usesComputePipeline: Bool { true }
    

    var timer: Float = 0
    var deltaTime: Float = 0
    
    let particleBuffer: MTLBuffer

    
    // Must match the constants in Compute.metal
    
    let yMin: Float = 0.0
    let yMax: Float = 2.0
    let halfW: Float = 2e-2 * Float(Settings.width / Settings.height) //2 cm
    let halfH: Float = 5e-2
    var pointer: UnsafeMutablePointer<Particle>
    
    init() {
        particlePSO = PipelineStates.createComputePSO(functionName: "magneticfield")
        clearScreenPSO = PipelineStates.createComputePSO(functionName: "clearScreen")
        camera = GraphCamera()
        
        let bufferSize = MemoryLayout<Particle>.stride * particleCount
        particleBuffer = Renderer.device.makeBuffer(length: bufferSize)!
        
        pointer = particleBuffer.contents().bindMemory(to: Particle.self, capacity: particleCount)
        
        for _ in 0..<particleCount {
            //let t = Float(i) / Float(particleCount - 1)  // 0...1
            //let y: Float = 1 //yMin + t * (yMax - yMin)              // -3...3
            //pointer.pointee.position = float2(0, y)
            
            //This corresponds to meters
            
            
            pointer.pointee.position = float2(1e-2, 4e-2)
            pointer.pointee.velocity = float2(3e5, 0) // c/10 in x
            pointer.pointee.acceleration = float2(0,0)
            pointer = pointer.advanced(by: 1)
        }
        pointer = pointer.advanced(by: -particleCount)
    }
    
    func update(size: CGSize) {
        camera.update(size: size)
    }

    // Must match gravityHalfW/H in Compute.metal
    let minRadius: Float = 6378e3
    
    func update(deltaTime: Float) {
        self.deltaTime = deltaTime
        timer += deltaTime
        camera.update(deltaTime: deltaTime)
        
   
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
    }
    
    func drawCompute(computeEncoder: MTLComputeCommandEncoder, texture: MTLTexture, options: Options) {
        computeEncoder.setComputePipelineState(clearScreenPSO)
        computeEncoder.setTexture(texture, index: 0)
        
        var threadsPerGrid = MTLSize(width: texture.width, height: texture.height, depth: 1)
        let w = clearScreenPSO.threadExecutionWidth
        var threadsPerThreadgroup = MTLSize(width: w, height: clearScreenPSO.maxTotalThreadsPerThreadgroup / w, depth: 1)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        
        // Particles
        computeEncoder.setComputePipelineState(particlePSO)
        computeEncoder.setTexture(texture, index: 0)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        computeEncoder.setBytes(&deltaTime, length: MemoryLayout<Float>.size, index: 1)
        
        threadsPerGrid = MTLSize(width: particleCount, height: 1, depth: 1)
        threadsPerThreadgroup = MTLSize(width: 1, height: 1, depth: 1)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}
