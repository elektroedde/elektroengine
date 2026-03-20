import CoreGraphics
import GameController

protocol Camera: Transformable {
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    mutating func update(size: CGSize)
    mutating func update(deltaTime: Float)
}


struct FPCamera: Camera {
  var transform = Transform()
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }

  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  var viewMatrix: float4x4 {
    (float4x4(translation: position) *
    float4x4(rotationYXZ: rotation)).inverse
  }

  mutating func update(deltaTime: Float) {
    let transform = updateInput(deltaTime: deltaTime)
    rotation += transform.rotation
    rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
    position += transform.position
  }
}

extension FPCamera: Movement { }

struct GraphCamera: Camera {
    var transform = Transform()
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100

    var projectionMatrix: float4x4 {
        float4x4(projectionFov: fov, near: near, far: far, aspect: aspect)
    }

    var viewMatrix: float4x4 {
        (float4x4(rotation: rotation) * float4x4(translation: position)).inverse
    }

    let minDistance: Float = 0.1
    let maxDistance: Float = 30
    var target: SIMD3<Float> = [0, 0, 0]
    var distance: Float = 10


    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }



    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        var scrollSensitivity = Settings.touchZoomSensitivity * 5 * distance / maxDistance
        var panSensitivity = Settings.touchPanSensitivity * distance / maxDistance
        #if os(macOS)
        scrollSensitivity = Settings.mouseScrollSensitivity
        panSensitivity = Settings.mousePanSensitivity
        #endif


        distance -= (input.mouseScroll.x + input.mouseScroll.y) * scrollSensitivity
        distance = min(maxDistance, distance)
        distance = max(minDistance, distance)
        input.mouseScroll = .zero
        if input.leftMouseDown {

            position.x -= input.mouseDelta.x * panSensitivity
            position.y -= input.mouseDelta.y * panSensitivity
            input.mouseDelta = .zero
        }

        position = float3(position.x, position.y, -distance)
    }
}
struct ArcballCamera: Camera {
  var transform = Transform()
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }
  let minDistance: Float = 0.0
  let maxDistance: Float = 40
  var target: float3 = [0, 0, 0]
  var distance: Float = 4

  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  var viewMatrix: float4x4 {
    let matrix: float4x4
    if target == position {
      matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
    } else {
      matrix = float4x4(eye: position, center: target, up: [0, 1, 0])
    }
    return matrix
  }

  mutating func update(deltaTime: Float) {
    let input = InputController.shared
    let scrollSensitivity = Settings.mouseScrollSensitivity
    distance -= (input.mouseScroll.x + input.mouseScroll.y)
      * scrollSensitivity
    distance = min(maxDistance, distance)
    distance = max(minDistance, distance)
    input.mouseScroll = .zero
    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
      input.mouseDelta = .zero
    }
    let rotateMatrix = float4x4(
      rotationYXZ: [-rotation.x, rotation.y, 0])
    let distanceVector = float4(0, 0, -distance, 0)
    let rotatedVector = rotateMatrix * distanceVector
    position = target + rotatedVector.xyz
  }
}






protocol Movement where Self: Transformable {
}

extension Movement {
    var forwardVector: float3 {
        normalize([sin(rotation.y), 0, cos(rotation.y)])
    }

    var rightVector: float3 {
        [forwardVector.z, forwardVector.y, -forwardVector.x]
    }

    func updateInput(deltaTime: Float) -> Transform {
        var transform = Transform()
        let input = InputController.shared

        // Mouse look (Minecraft-style)
        let sensitivity = Settings.mouseLookSensitivity
        transform.rotation.y += input.mouseDelta.x * sensitivity
        transform.rotation.x -= input.mouseDelta.y * sensitivity
        input.mouseDelta = .zero

        var direction: float3 = .zero
        if input.keysPressed.contains(.keyW) {direction.z += 1}
        if input.keysPressed.contains(.keyS) {direction.z -= 1}
        if input.keysPressed.contains(.keyA) {direction.x -= 1}
        if input.keysPressed.contains(.keyD) {direction.x += 1}
        if input.keysPressed.contains(.spacebar) {direction.y += 1}
        if input.keysPressed.contains(.leftShift) {direction.y -= 1}
        
        let translationAmount = deltaTime * Settings.movementSpeed
        if direction != .zero {
            direction = normalize(direction)
            transform.position += (direction.z * forwardVector + direction.x * rightVector + direction.y * float3(0, 1, 0)) * translationAmount
        }
        return transform
    }
}
