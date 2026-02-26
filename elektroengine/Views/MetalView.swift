
import SwiftUI
import MetalKit

struct MetalView: View {
    let options: Options
    #if os(macOS)
    @State private var metalView = MTKView()
    #elseif os(iOS)
    @State private var metalView = MTKView()
    #endif
    @State private var applicationController: ApplicationController?

    @State private var previousTranslation = CGSize.zero
    @State private var previousScroll: CGFloat = 1


    var body: some View {
        MetalViewRepresentable(applicationController: applicationController, metalView: $metalView, options: options)
            .onAppear {
                /// We initialize the renderer only when metalview first appears
                applicationController = ApplicationController(metalView: metalView, options: options)
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    InputController.shared.touchLocation = value.location
                    InputController.shared.touchDelta = CGSize(width: value.translation.width - previousTranslation.width,
                                                               height: value.translation.height - previousTranslation.height)
                    previousTranslation = value.translation
                    // if the user drags, cancel the tap touch
                    if abs(value.translation.width) > 1 ||
                        abs(value.translation.height) > 1 {
                        InputController.shared.touchLocation = nil
                    }
                }
                .onEnded {_ in
                  previousTranslation = .zero
              })
            .gesture(MagnificationGesture()
                .onChanged { value in
                    let scroll = value - previousScroll
                    InputController.shared.mouseScroll.x = Float(scroll)
                    previousScroll = value
                }
                .onEnded {_ in
                    previousScroll = 1
                })
            
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
    let applicationController: ApplicationController?

    #if os(macOS)
    @Binding var metalView: MTKView
    #elseif os(iOS)
    @Binding var metalView: MTKView
    #endif
    let options: Options

#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        let trackingArea = NSTrackingArea(rect: metalView.bounds, options: [.activeWhenFirstResponder, .mouseMoved, .enabledDuringMouseDrag], owner: self, userInfo: nil)
        metalView.addTrackingArea(trackingArea)
        return metalView
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
        updateMetalView()
    }
#elseif os(iOS)
  func makeUIView(context: Context) -> MTKView {
      metalView
    }

  func updateUIView(_ uiView: MTKView, context: Context) {
      updateMetalView()
    }
#endif

  func updateMetalView() {
      applicationController?.options = options
    }
}

#Preview {
    VStack {
        MetalView(options: Options())
    }
}



#if os(macOS)
class MyMTKView: MTKView {
    override func mouseDown(with event: NSEvent) {
        InputController.shared.canMouseDown = true
    }

    override func mouseUp(with event: NSEvent) {
        InputController.shared.canMouseDown = false
    }
}
#endif
