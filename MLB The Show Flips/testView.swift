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
    
    
    var body: some View {
        Text("hello world")
    }
    
    private var excludeSeriesButton: some View {
        Button {
            
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

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
