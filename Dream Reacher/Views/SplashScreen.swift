//
//  SplashScreen.swift
//  Natumedi
//
//  Created by Julia Kansbod on 2022-12-08.
//

import SwiftUI

struct SplashScreen: View {
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        
        if isActive {
            ContentView()
        } else {
            
            VStack{
                ZStack {
                    Image("splashscreen")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
            
        }
        
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
