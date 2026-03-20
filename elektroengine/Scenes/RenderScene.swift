import MetalKit
protocol BaseScene {
    var camera: Camera { get set }
    var usesComputePipeline: Bool { get }
    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options)
    func drawCompute(computeEncoder: MTLComputeCommandEncoder, texture: MTLTexture, options: Options)
    func update(deltaTime: Float)
    func update(size: CGSize)
}
extension BaseScene {
    var usesComputePipeline: Bool { false }
    func drawCompute(computeEncoder: MTLComputeCommandEncoder, texture: MTLTexture, options: Options) {}
}

