import Accelerate

class EigenSolver {
    static var printDebug: Bool = false

    static func solve(model: FEM_Model, numModes: Int = 10, printDebug: Bool = false) -> (eigenvalues: [Float], eigenvectors: [[Float]])? {
        self.printDebug = printDebug
        let N = model.N
        let M = model.M

        printDebug ? print("=== Starting Eigenvalue Solver ===") : ()

        var A = [Float](repeating: 0, count: N * N)
        var B = [Float](repeating: 0, count: N * N)

        assemble(model: model, N: N, M: M, A: &A, B: &B)

        // Eliminate Dirichlet DOFs: extract submatrix for free (interior) nodes only
        let boundarySet = Set(model.dirichletNodes)
        let freeDOFs = (0..<N).filter { !boundarySet.contains($0) }
        let nFree = freeDOFs.count

        printDebug ? print("Total DOFs: \(N), Free DOFs: \(nFree), Boundary DOFs: \(boundarySet.count)") : ()

        var Ar = [Float](repeating: 0, count: nFree * nFree)
        var Br = [Float](repeating: 0, count: nFree * nFree)

        for (ri, i) in freeDOFs.enumerated() {
            for (rj, j) in freeDOFs.enumerated() {
                Ar[rj * nFree + ri] = A[j * N + i]
                Br[rj * nFree + ri] = B[j * N + i]
            }
        }

        guard var result = solveLAPACK(&Ar, &Br, n: nFree, numModes: numModes) else {
            return nil
        }

        // Map reduced eigenvectors back to full node space (boundary nodes stay 0)
        for i in 0..<result.eigenvectors.count {
            var fullVec = [Float](repeating: 0, count: N)
            for (ri, globalIdx) in freeDOFs.enumerated() {
                fullVec[globalIdx] = result.eigenvectors[i][ri]
            }
            result.eigenvectors[i] = fullVec
        }

        return result
    }

    // MARK: - Assembly

    /// Assembles A and B matrices for the eigenvalue problem A x = λ B x.
    static func assemble(model: FEM_Model, N: Int, M: Int, A: inout [Float], B: inout [Float]) {
        let t1 = CFAbsoluteTimeGetCurrent()

        for element in 0..<M {
            let n0 = model.nodes[element * 3 + 0]
            let n1 = model.nodes[element * 3 + 1]
            let n2 = model.nodes[element * 3 + 2]
            let nodes = [n0, n1, n2]

            let x = [model.vertices[n0].x, model.vertices[n1].x, model.vertices[n2].x]
            let y = [model.vertices[n0].y, model.vertices[n1].y, model.vertices[n2].y]

            let area = abs(0.5 * (x[0]*(y[1] - y[2]) + x[1]*(y[2] - y[0]) + x[2]*(y[0] - y[1])))

            let b_e  = [y[1] - y[2], y[2] - y[0], y[0] - y[1]]
            let c_e = [x[2] - x[1], x[0] - x[2], x[1] - x[0]]

            let material: Float = model.material.count > 0 ? model.material[element] : 1

            for i in 0..<3 {
                for j in 0..<3 {
                    let dirac: Float = i == j ? 1 : 0
                    A[nodes[j] * N + nodes[i]] += (material * b_e[i] * b_e[j] + material * c_e[i] * c_e[j]) / (4 * area)
                    B[nodes[j] * N + nodes[i]] += area * (1 + dirac) / 12
                }
            }
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ Eigenvalue assembly took: [%.0fms]", (t2 - t1)*1000)) : ()
    }

    // MARK: - LAPACK

    /// Solves the generalized eigenvalue problem A x = λ B x using LAPACK ssygvx_.
    static func solveLAPACK(_ A: inout [Float], _ B: inout [Float], n: Int, numModes: Int) -> (eigenvalues: [Float], eigenvectors: [[Float]])? {
        let t1 = CFAbsoluteTimeGetCurrent()
        let m = min(numModes, n)

        var eigenvalues = [Float](repeating: 0, count: n)
        var lda = __LAPACK_int(n)
        var ldb = __LAPACK_int(n)
        var ldz = __LAPACK_int(n)
        var info: __LAPACK_int = 0
        var numFound: __LAPACK_int = 0

        var Z = [Float](repeating: 0, count: n * m)
        var ifail = [__LAPACK_int](repeating: 0, count: n)

        var vl: Float = 0
        var vu: Float = 0
        var abstol: Float = 0

        var lwork = __LAPACK_int(8 * n)
        var work = [Float](repeating: 0, count: Int(lwork))
        var iwork = [__LAPACK_int](repeating: 0, count: 5 * n)

        withUnsafePointer(to: __LAPACK_int(1)) { itype in
        withUnsafePointer(to: __LAPACK_int(n)) { nPtr in
        withUnsafePointer(to: __LAPACK_int(1)) { il in
        withUnsafePointer(to: __LAPACK_int(m)) { iu in
            ssygvx_(itype, "V", "I", "U", nPtr,
                    &A, &lda,
                    &B, &ldb,
                    &vl, &vu,
                    il, iu,
                    &abstol,
                    &numFound,
                    &eigenvalues,
                    &Z, &ldz,
                    &work, &lwork,
                    &iwork, &ifail,
                    &info)
        }}}}

        if info != 0 {
            print("LAPACK ssygvx_ error \(info)")
            return nil
        }

        var eigenvectors: [[Float]] = []
        for i in 0..<Int(numFound) {
            var vec = [Float](repeating: 0, count: n)
            for j in 0..<n {
                vec[j] = Z[i * n + j]
            }
            eigenvectors.append(vec)
        }

        let t2 = CFAbsoluteTimeGetCurrent()
        printDebug ? print(String(format: "⏰ LAPACK ssygvx_ found %d eigenvalues in: [%.0fms]", numFound, (t2 - t1)*1000)) : ()
        return (Array(eigenvalues.prefix(Int(numFound))), eigenvectors)
    }
}
