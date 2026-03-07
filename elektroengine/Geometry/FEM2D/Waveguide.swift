import MetalKit

struct Waveguide: Transformable {
    var pipelineState: MTLRenderPipelineState!
    var transform = Transform()
    var highlighted: Bool = false
    var femObject: FEM_Model = FEM_Model()
    var femValues: [Float] = []

    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let femBuffer: MTLBuffer

    static let wavelength: Float = 10
    static let k_0: Float = 2 * Float.pi / wavelength
    let epsilon_r: Float = 4
    let qLeftBoundary: (real: Float, imag: Float) = (0, -2 * k_0)
    let gammaLeftBoundary: (real: Float, imag: Float) = (0, k_0)
    let qRightBoundary: (real: Float, imag: Float) = (0, 0)
    let gammaRightBoundary: (real: Float, imag: Float) = (0, k_0)

    init(device: MTLDevice) {
        pipelineState = PipelineStates.createFEMPSO()
        let mesh = createWaveguide()

        femObject.beta = -Self.k_0 * Self.k_0

        for val in mesh.allNodeCoords {
            femObject.vertices.append(Vertex(x: Float(val[0]), y: Float(val[1]), z: Float(val[2])))
        }

        for v in mesh.allElementNodes {
            femObject.nodes.append(Int(v-1))
            femObject.f.append(0)
        }
        for v in mesh.allElementTags {
            femObject.allElements.append(Int(v-1))
            femObject.material.append(1)
        }

        for (i, _) in mesh.dielectricElementTags.enumerated() {
            femObject.material[Int(i)] = 1 / epsilon_r
        }

        for v in mesh.leftBoundaryElementTags {
            femObject.robinElements.append(Int(v-1))
            femObject.qComplex.append(qLeftBoundary.real)
            femObject.qComplex.append(qLeftBoundary.imag)
            femObject.gammaComplex.append(gammaLeftBoundary.real)
            femObject.gammaComplex.append(gammaLeftBoundary.imag)
        }
        for node in mesh.leftBoundaryElementNodes {
            femObject.robinNodes.append(Int(node-1))
        }

        for v in mesh.rightBoundaryElementTags {
            femObject.robinElements.append(Int(v-1))
            femObject.qComplex.append(qRightBoundary.real)
            femObject.qComplex.append(qRightBoundary.imag)
            femObject.gammaComplex.append(gammaRightBoundary.real)
            femObject.gammaComplex.append(gammaRightBoundary.imag)
        }

        for node in mesh.rightBoundaryElementNodes {
            femObject.robinNodes.append(Int(node-1))
        }


        guard let vertexBuffer = device.makeBuffer(bytes: femObject.vertices, length: MemoryLayout<Vertex>.stride * femObject.vertices.count, options: []) else {
            fatalError("Could not create vertex buffer")
        }

        let indexData = femObject.nodes.map { UInt16($0) }
        guard let indexBuffer = device.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.stride * indexData.count, options: []) else {
            fatalError("Could not create index buffer")
        }

        let startTime = CFAbsoluteTimeGetCurrent()
        femValues = Solver.solve(model: femObject, complex: true, printDebug: true)
        let endTime = CFAbsoluteTimeGetCurrent()
        print("Total time for the solver: \(String(format: "%.0f", (endTime - startTime)*1000))ms\n")

        guard let femBuffer = device.makeBuffer(bytes: &femValues, length: MemoryLayout<Float>.stride * femValues.count, options: []) else {
            fatalError("Could not create FEM buffer")
        }

        self.vertexBuffer = vertexBuffer
        self.indexBuffer = indexBuffer
        self.femBuffer = femBuffer
    }

    func draw(renderEncoder: MTLRenderCommandEncoder, params fragment: Params, uniforms vertex: Uniforms, options: Options) {
        renderEncoder.setRenderPipelineState(pipelineState)
        var params = fragment
        params.minFem = femValues.min() ?? 0
        params.maxFem = femValues.max() ?? 1
        params.colormapChoice = options.colormap.rawValue
        var uniforms = vertex
        let fillMode: MTLTriangleFillMode = options.drawWireframe ? .lines : .fill
        params.showContours = options.showContours
        renderEncoder.setTriangleFillMode(fillMode)
        uniforms.modelMatrix = transform.modelMatrix

        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: VertexBuffer.index)
        renderEncoder.setVertexBuffer(femBuffer, offset: 0, index: FEMBuffer.index)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: UniformsBuffer.index)
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Params>.stride, index: ParamsBuffer.index)

        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: femObject.nodes.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
    }
}

