//
//  ContentView.swift
//  Graphing2D
//
//  Created by Edvin Berling on 2026-02-24.
//

import SwiftUI

let interfaceHeight: CGFloat = 50
let width: CGFloat = 2420/2
let height: CGFloat = 1668/2 - interfaceHeight

struct ContentView: View {
    @State var options = Options()
    var body: some View {
        VStack {
            MetalView(options: options).border(Color.black, width: 2)
                .frame(width: width, height: height)

            Picker(
                selection: $options.equationChoice,
                label: Text("Render Options")) {
                    Text("sin").tag(EquationChoice.sin)
                    Text("cos").tag(EquationChoice.cos)
                    Text("exp").tag(EquationChoice.exp)
                    Text("vector").tag(EquationChoice.vector)
                }

                .pickerStyle(SegmentedPickerStyle())
                //.containerRelativeFrame(.horizontal) { width, _ in
                //    return width * 0.6
                //}
                .frame(width: width, height: interfaceHeight)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
