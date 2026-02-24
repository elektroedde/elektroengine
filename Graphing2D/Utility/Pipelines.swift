import MetalKit

enum PipelineStates {
    static var scene = ApplicationScene()

    static func createPSO(descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState {
        let pipelineState: MTLRenderPipelineState

        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)

        } catch {
            fatalError(error.localizedDescription)
        }

        return pipelineState
    }

    static func createBackgroundPSO() -> MTLRenderPipelineState {
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_background")
        let fragmentFunction = Renderer.library?.makeFunction(name: "fragment_background")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout

        return createPSO(descriptor: pipelineDescriptor)
    }

    static func createGraphPSO() -> MTLRenderPipelineState {
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_graph")
        let fragmentFunction = Renderer.library?.makeFunction(name: "fragment_graph")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout

        return createPSO(descriptor: pipelineDescriptor)
    }

    static func createVectorPSO() -> MTLRenderPipelineState {
        let vertexFunction = Renderer.library?.makeFunction(name: "vertex_vector")
        let fragmentFunction = Renderer.library?.makeFunction(name: "fragment_vector")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout

        return createPSO(descriptor: pipelineDescriptor)
    }
}
