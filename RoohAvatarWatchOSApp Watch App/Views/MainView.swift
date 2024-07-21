//
//  MainView.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI


struct MainView: View {
    
    @FocusState private var isPickerFocused: Bool
    
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        
        TabView {
            imagesScrollView
            parametersView
                .padding(5)
        }
        .padding(-10)
        .tabViewStyle(.verticalPage)
        
    }
    
    var parametersView: some View {
        VStack {
            HStack {
                agePicker
                heightPicker
                weightPicker
            }
            
            .labelsHidden()
            
            sendButtonView
        }
        
    }
    
    var sendButtonView: some View {
        Button("Send to iPhone") {
            
            isPickerFocused = false
            viewModel.sendAvatarToiPhone()
        }
    }
    
    var agePicker: some View {
        VStack {
            Text("Age")
                .font(.caption2)
                .bold()
            Spacer()
            Picker("Age", selection: $viewModel.age) {
                ForEach(CharacterModel.ageAllowedRange, id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
            .focused($isPickerFocused)
        }
    }
    
    var heightPicker: some View {
        VStack {
            Text("Height")
                .font(.caption2)
                .bold()
            Spacer()
            Picker("Height", selection: $viewModel.height) {
                ForEach(CharacterModel.heightAllowedRange, id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
        }
    }
    
    var weightPicker: some View {
        VStack {
            Text("Weight")
                .font(.caption2)
                .bold()
            Spacer()
            Picker("Weight", selection: $viewModel.weight) {
                ForEach(CharacterModel.weightAllowedRange, id: \.self) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
        }
    }
    
    var imagesScrollView: some View {
        HorizontalPickerView(viewModel: viewModel)
    }
    
}

#Preview {
    MainView()
}
