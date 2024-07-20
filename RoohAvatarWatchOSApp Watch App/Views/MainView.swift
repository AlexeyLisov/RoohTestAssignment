//
//  MainView.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI


struct MainView: View {
    
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        
        TabView {
            imagesScrollView
            agePicker
            heightPicker
            weightPicker
            sendButtonView
        }
        .tabViewStyle(.verticalPage)
        
    }
    
    var parametersView: some View {
        VStack {
            agePicker
            heightPicker
            weightPicker
        }
        .labelsHidden()
    }
    
    var sendButtonView: some View {
        Button("Send to iPhone") {
            viewModel.sendAvatarToiPhone()
        }
    }
    
    var agePicker: some View {
        VStack {
            Text("Age")
                .bold()
            Picker("Age", selection: $viewModel.age) {
                ForEach(0..<125) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
        }
    }
    
    var heightPicker: some View {
        VStack {
            Text("Height")
                .bold()
            Picker("Height", selection: $viewModel.height) {
                ForEach(50..<250) {
                    Text("\($0) cm")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
        }
    }
    
    var weightPicker: some View {
        VStack {
            Text("Weight")
                .bold()
            
            Picker("Weight", selection: $viewModel.weight) {
                ForEach(50..<300) {
                    Text("\($0) kg")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
        }
    }
    
    var imagesScrollView: some View {
        HorizontalPickerView(viewModel: viewModel)
    }
    
}
