import MetalKit

class RayMarchingScene: BaseScene {

    var camera: any Camera
    var timer: Float = 0
    var usesComputePipeline: Bool { true }
    
    let computePipelineState: MTLComputePipelineState

    init() {
        camera = GraphCamera()
        computePipelineState = PipelineStates.createComputePSO(functionName: "compute")
    }

    func update(size: CGSize) {
        camera.update(size: size)
    }

    func update(deltaTime: Float) {
        timer += deltaTime
        camera.update(deltaTime: deltaTime)
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options) {
        // Not used — this scene uses the compute pipeline
    }
    
    func drawCompute(computeEncoder: MTLComputeCommandEncoder, texture: MTLTexture, view: MTKView, options: Options) {
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setTexture(texture, index: 0)
        computeEncoder.setBytes(&timer, length: MemoryLayout<Float>.size, index: 0)
        
        let width = computePipelineState.threadExecutionWidth
        let height = computePipelineState.maxTotalThreadsPerThreadgroup / width
        let threadsPerThreadgroup = MTLSize(width: width, height: height, depth: 1)
        let threadGroupCount = MTLSize(
            width: (texture.width + width - 1) / width,
            height: (texture.height + height - 1) / height,
            depth: 1)
        computeEncoder.dispatchThreadgroups(threadGroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}
