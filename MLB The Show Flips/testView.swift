//
//  testView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import SwiftUI


//                    VStack (alignment: .center, spacing: 0){
//                        Spacer()
//                        Text("Max listings shown: \(maxSize)")
//                        HStack {
//                            Button(action: {
//                                maxSize = max(maxSize-1, 1)
//                            }, label: {
//                                Image(systemName: "minus")
//                            }).foregroundColor(.black)
//                                .disabled(maxSize <= 1)
//
//                            Slider(value: $maxSize.double, in: 1...30, step: 1)
//                                .accentColor(Colors.darkTeal)
//
//                            Button(action: {
//                                maxSize = min(maxSize+1, 30)
//                            }, label: {
//                                Image(systemName: "plus")
//                            }).foregroundColor(.black)
//                                .disabled(maxSize >= 30)
//                        }.foregroundColor(.black)
//                            .padding()
//                    }



struct testView: View {
    
    
    @State private var color1 = Color.blue
    @State private var color2 = Color.teal
    
    @State private var rotate = false
    
    @State var grad = BackgroundGradientView()
    
    var body: some View {
        
        grad
            .overlay (
                VStack{
                    ColorPicker("First Gradient Color", selection: $color1)
                        .padding(.horizontal, 100)
                        .scaleEffect(1.2)
                    swapButton.onTapGesture {
                        self.rotate.toggle()
                    }
                    ColorPicker("Second Gradient Color", selection: $color2)
                        .padding(.horizontal, 100)
                        .scaleEffect(1.2)
                    
                }
                
            )
    }
    
    private var swapButton: some View {
        
        Button {
            grad.gradientColors[0] = .purple
            let temp = color1
            color1 = color2
            color2 = temp
        } label: {
            SmallSystemImageButton(sysName: "arrow.up.arrow.down")
                
        }
    }
    
    private var excludeSeriesButton: some View {
        Button {
            //action here
        } label: {
            HStack {
                Text("Exclude Card Series")
                Image(systemName: "arrow.right")
            }.foregroundColor(.white)
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .frame(width: 200, height: 40)
                .background(Colors.midGray)
                .cornerRadius(20)
            
            
        }
    }
}

struct SmallSystemImageButton: View {
    var systemName = ""
    init(sysName: String) {
        self.systemName = sysName
    }
    
    var body: some View {
        Image(systemName: self.systemName)
            .frame(width: 40, height: 40, alignment: .center)
            .foregroundColor(.black)
            .background(.red)
            .cornerRadius(8)
            .buttonStyle(.bordered)
    }
    
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
