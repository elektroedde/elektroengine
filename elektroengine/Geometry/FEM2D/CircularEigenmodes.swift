import MetalKit

struct CircularEigenmodes: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var wireframePipelineState: MTLRenderPipelineState!
    var transform = Transform()
    var highlighted: Bool = false
    var femObject: FEM_Model = FEM_Model()
    var femValues: [Float] = []
    var eigenmodes: [[Float]] = []
    var frequencies: [Float] = [Float](repeating: 0, count: 7)

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let femBuffer: MTLBuffer
    let indexCount: Int

    init(device: MTLDevice) {
        pipelineState = PipelineStates.createFEMPSO()
        wireframePipelineState = PipelineStates.createWireframePSO()
        let mesh = getCircle()

        // Build connectivity (0-based)
        for v in mesh.nodes {
            femObject.nodes.append(Int(v - 1))
        }

        // Build vertex positions
        for i in stride(from: 0, to: mesh.nodeCoords.count, by: 3) {
            femObject.vertices.append(Vertex(x: Float(mesh.nodeCoords[i]),
                                             y: Float(mesh.nodeCoords[i + 1]),
                                             z: Float(mesh.nodeCoords[i + 2])))
        }

        // Create GPU buffers
        guard let vertexBuffer = device.makeBuffer(bytes: femObject.vertices, length: MemoryLayout<Vertex>.stride * femObject.vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }
        let indexData = femObject.nodes.map { UInt16($0) }
        guard let indexBuffer = device.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.stride * indexData.count, options: []) else {
            fatalError("Could not create index buffer")
        }
        indexCount = indexData.count

        // Solve eigenvalue problem
        let startTime = CFAbsoluteTimeGetCurrent()
        guard let result = Solver.solveEigen(model: femObject, numModes: 7, printDebug: true) else {
            fatalError("Eigenvalue solver failed")
        }
        let endTime = CFAbsoluteTimeGetCurrent()
        print("Total time for the solver: \(String(format: "%.0f", (endTime - startTime) * 1000))ms\n")

        // Store all eigenmodes
        eigenmodes = result.eigenvectors
        femValues = eigenmodes[0]

        // Compute cutoff frequencies
        let eps0: Float = 8.854e-12
        let mu0: Float = 1.257e-6
        for i in 0..<result.eigenvalues.count {
            frequencies[i] = sqrt(result.eigenvalues[i] / (eps0 * mu0)) / (2 * .pi * 1e6)
        }

        guard let femBuffer = device.makeBuffer(bytes: &femValues, length: MemoryLayout<Float>.stride * femValues.count, options: []) else {
            fatalError("Could not create FEM buffer")
        }

        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.femBuffer = femBuffer
    }

    mutating func selectMode(_ mode: EigenmodeNumber, options: Options) {
        let i = mode.index
        femValues = eigenmodes[i]
        options.fem2D.displayFrequency = frequencies[i]

        let pointer = femBuffer.contents().bindMemory(to: Float.self, capacity: femValues.count)
        for j in 0..<femValues.count {
            pointer[j] = femValues[j]
        }
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms, options: Options) {
        options.fem2D.quantity = "Electric field - Z component"

        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        var uniforms = vertex
        params.minFem = femValues.min() ?? 0
        params.maxFem = femValues.max() ?? 1
        params.colormapChoice = options.colormap.rawValue
        uniforms.modelMatrix = transform.modelMatrix

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)
        renderEncoder.setVertexBuffer(femBuffer, offset: 0, index: FEMBuffer.index)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        // Draw filled mesh
        renderEncoder.setTriangleFillMode(.fill)
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: indexCount,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)

        // Draw wireframe overlay with depth bias to avoid z-fighting
        if options.drawWireframe {
            renderEncoder.setRenderPipelineState(wireframePipelineState)
            renderEncoder.setTriangleFillMode(.lines)
            renderEncoder.setDepthBias(-1, slopeScale: -1, clamp: 0)
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: indexCount,
                                                indexType: .uint16,
                                                indexBuffer: indexBuffer,
                                                indexBufferOffset: 0)
            renderEncoder.setDepthBias(0, slopeScale: 0, clamp: 0)
        }

        options.displayMinValue = femValues.min() ?? 0
        options.displayMaxValue = femValues.max() ?? 1
    }
}

