import GameController
#if os(macOS)
import AppKit
#endif

struct Point {
    var x: Float
    var y: Float
    static let zero = Point(x: 0, y: 0)
}
class InputController {
    static let shared = InputController()
    var canMouseDown = false
    private var mouseLocked = false

    func lockMouse() {
        #if os(macOS)
        guard !mouseLocked else { return }
        mouseLocked = true
        CGAssociateMouseAndMouseCursorPosition(0)
        NSCursor.hide()
        #endif
    }

    func unlockMouse() {
        #if os(macOS)
        guard mouseLocked else { return }
        mouseLocked = false
        CGAssociateMouseAndMouseCursorPosition(1)
        NSCursor.unhide()
        #endif
    }
    var leftMouseDown = false
    var rightClick: CGPoint = .zero
    var mouseDelta = Point.zero
    var mouseScroll = Point.zero
    var touchLocation: CGPoint?
    var touchDelta: CGSize? {
      didSet {
        touchDelta?.height *= -1
        if let delta = touchDelta {
          mouseDelta = Point(x: Float(delta.width), y: Float(delta.height))
        }
        leftMouseDown = touchDelta != nil
      }
    }
    
    
    var keysPressed: Set<GCKeyCode> = []

    

    init() {
        let center = NotificationCenter.default
        center.addObserver(
          forName: .GCKeyboardDidConnect,
          object: nil,
          queue: nil) { notification in
            let keyboard = notification.object as? GCKeyboard
              keyboard?.keyboardInput?.keyChangedHandler
                = { _, _, keyCode, pressed in
              if pressed {
                if keyCode == .escape {
                    if self.mouseLocked {
                        self.unlockMouse()
                    } else {
                        self.lockMouse()
                    }
                }
                self.keysPressed.insert(keyCode)
              } else {
                self.keysPressed.remove(keyCode)
              }
            }
        }
    #if os(macOS)
      NSEvent.addLocalMonitorForEvents(
        matching: [.keyUp, .keyDown]) { event in
          // Only consume key events when the Metal view has focus,
          // so SwiftUI TextFields can still receive input.
          if event.window?.firstResponder is MyMTKView {
              return nil
          }
          return event
      }
    #endif
        
        
        center.addObserver(forName: .GCMouseDidConnect, object: nil, queue: nil) { notification in
            let mouse = notification.object as? GCMouse

            mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                self.leftMouseDown = self.canMouseDown && pressed
            }


            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                self.mouseDelta = Point(x: deltaX, y: deltaY)


            }

            mouse?.mouseInput?.scroll.valueChangedHandler = { _, scrollX, scrollY in
                self.mouseScroll = Point(x: scrollX, y: scrollY)
            }
        }
    }

}
