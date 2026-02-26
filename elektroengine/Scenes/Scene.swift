import MetalKit
protocol SceneX {
    var camera: Camera { get set }
    func draw(renderEncoder: MTLRenderCommandEncoder, params: Params, uniforms: Uniforms, options: Options)
    func update(deltaTime: Float)
    func update(size: CGSize)
}
