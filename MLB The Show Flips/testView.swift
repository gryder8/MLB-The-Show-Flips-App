//
//  testView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import SwiftUI

struct testView: View {
    
    @State var showText: Bool = false
    @State var hasOffset: Bool = true
    
    var body: some View {
        HStack {
            
            //VStack {
            //                Button("Animate") {
            //                    withAnimation(.interpolatingSpring(stiffness: 80, damping: 4))
            //                }
            
            VStack (spacing: 20){
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            showText.toggle()
                        }
                    }
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 110, height: 35, alignment: .center)
                        Text("Toggle Field")
                            .foregroundColor(.black)
                        
                    }
                })
                if (showText) {
                    withAnimation (.interpolatingSpring(mass: 5, stiffness: 80, damping: 1, initialVelocity: 0)) {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(.orange)
                                .frame(width: 110, height: 35, alignment: .center)
                            Text("Dynamic")
                                .foregroundColor(.black)
                                .animation(.easeInOut(duration: 2), value: showText)
                        }
                    }
                }
            }
        }
        
    }
}


struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
