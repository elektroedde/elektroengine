import simd
import CoreGraphics
typealias float2 = SIMD2<Float>
typealias float3 = SIMD3<Float>
typealias float4 = SIMD4<Float>
extension Float {
    var radiansToDegrees: Float {
        (self / Float.pi) * 180
    }

    var degreesToRadians: Float {
        (self / 180) * Float.pi
    }
}

extension float4 {
    var xyz: float3 {
        return float3(x, y, z)
    }
}

extension float4x4 {
    init(translation: float3) {
        let x = translation.x
        let y = translation.y
        let z = translation.z
        self = float4x4([1,0,0,0],
                        [0,1,0,0],
                        [0,0,1,0],
                        [x,y,z,1])
    }

    init(rotationZ: Float) {
        /// Rotates around z-axis
        let c = cos(rotationZ)
        let s = sin(rotationZ)
        self = float4x4([ c, s, 0, 0],
                        [-s, c, 0, 0],
                        [ 0, 0, 1, 0],
                        [ 0, 0, 0, 1])
    }

    init(rotationX angle: Float) {
        /// Rotates around x-axis
        self = float4x4([ 1,  0, 0, 0],
                        [ 0,  cos(angle), sin(angle), 0],
                        [ 0, -sin(angle), cos(angle), 0],
                        [ 0,  0, 0, 1])
    }

    init(rotationY: Float) {
        /// Rotates around y-axis
        let c = cos(rotationY)
        let s = sin(rotationY)
        self = float4x4([ c, 0, -s, 0],
                        [ 0, 1, 0, 0],
                        [ s, 0, c, 0],
                        [ 0, 0, 0, 1])
    }

    init(rotation angle: float3) {
        self = float4x4(rotationX: angle.x) * float4x4(rotationY: angle.y) * float4x4(rotationZ: angle.z)
    }

    init(scaling: float3) {
        self = float4x4([scaling.x, 0, 0, 0],
                        [0, scaling.y, 0, 0],
                        [0, 0, scaling.z, 0],
                        [0, 0, 0, 1])
    }

    init(scaling: Float) {
        self = matrix_identity_float4x4
        columns.3.w = 1 / scaling
    }

    static var identity: float4x4 {
        matrix_identity_float4x4
    }

    init(eye: float3, center: float3, up: float3) {
        let z = normalize(center - eye)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        
        let X = float4(x.x, y.x, z.x, 0)
        let Y = float4(x.y, y.y, z.y, 0)
        let Z = float4(x.z, y.z, z.z, 0)
        let W = float4(-dot(x, eye), -dot(y, eye), -dot(z, eye), 1)

        self.init()
        columns = (X, Y, Z, W)
    }

    init(rotationYXZ angle: float3) {
      let rotationX = float4x4(rotationX: angle.x)
      let rotationY = float4x4(rotationY: angle.y)
      let rotationZ = float4x4(rotationZ: angle.z)
      self = rotationY * rotationX * rotationZ
    }

    init(projectionFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
      let y = 1 / tan(fov * 0.5)
      let x = y / aspect
      let z = lhs ? far / (far - near) : far / (near - far)
      let X = float4( x,  0,  0,  0)
      let Y = float4( 0,  y,  0,  0)
      let Z = lhs ? float4( 0,  0,  z, 1) : float4( 0,  0,  z, -1)
      let W = lhs ? float4( 0,  0,  z * -near,  0) : float4( 0,  0,  z * near,  0)
      self.init()
      columns = (X, Y, Z, W)
    }
}
