struct FEM_Model {

    var N: Int { vertices.count }
    var M: Int { nodes.count / 3 }

    var nodes: [Int] = []
    var vertices: [Vertex] = []
    
    /// All node coordinates for 3D FEM (includes interior nodes)
    var nodeCoords: [SIMD3<Float>] = []
    var N3D: Int { nodeCoords.count }
    var M3D: Int { nodes.count / 4 }

    var dirichletNodes: [Int] = []
    var dirichletValues: [Int] = []

    var robinElements: [Int] = []
    var robinNodes: [Int] = []

    var f: [Float] = []
    var q: [Float] = []
    var gamma: [Float] = []

    // Complex Robin coefficients: interleaved [real, imag] pairs
    var qComplex: [Float] = []
    var gammaComplex: [Float] = []

    var chargeElements: [Int] = []
    var allElements: [Int] = []

    var material: [Float] = []

    var beta: Float = 0

}

