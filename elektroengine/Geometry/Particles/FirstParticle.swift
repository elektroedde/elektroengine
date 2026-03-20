
import MetalKit

struct FirstParticle: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var transform = Transform()
 

    

    let particleBuffer: MTLBuffer
    

    init(device: MTLDevice, particleCount: Int) {
        pipelineState = PipelineStates.createBackgroundPSO()
        
        
        let bufferSize = MemoryLayout<Particle>.stride * particleCount
        particleBuffer = Renderer.device.makeBuffer(length: bufferSize)!
        
        
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms) {

        
    }
}
