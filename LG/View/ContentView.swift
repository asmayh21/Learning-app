//
//  ContentView.swift
//  LG
//
//  Created by asma  on 04/05/1447 AH.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 32) {

                    ZStack {
                        Circle()
                            .fill(Color("back"))
                            .frame(width: 96, height: 96)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.9), radius: 10, x: 0, y: 8)

                        Image(systemName: "flame.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                            .foregroundStyle(.orange)
                    }
                    .padding(.top, 60)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hello Learner")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("This app will help you learn everyday!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 20) {
                        Text("I want to learn")
                            .font(.headline)
                            .foregroundColor(.white)

                        TextField("Swift", text: $viewModel.topic)
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                            .foregroundColor(.white.opacity(0.9))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)

                        Divider()
                            .background(Color.white.opacity(0.2))

                        Text("I want to learn it in a")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            ForEach(LearningPeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    viewModel.selectedPeriod = period
                                }) {
                                    Text(period.rawValue)
                                        .frame(width: 97, height: 48)
                                        .glassEffect(viewModel.selectedPeriod == period ? .clear : .clear)
                                        .background(viewModel.selectedPeriod == period ? Color("Color").opacity(0.5) : Color.clear)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .font(.subheadline.bold())
                                        .foregroundColor(viewModel.selectedPeriod == period ? .white : .white.opacity(0.8))
                                }
                                .animation(.easeInOut(duration: 0.15), value: viewModel.selectedPeriod)
                            }
                        }
                    }

                    Spacer()

                    NavigationLink {
                        ActivityView(topic: viewModel.topic, period: viewModel.selectedPeriod)
                    } label: {
                        Text("Start learning")
                            .frame(width: 200, height: 50)
                            .glassEffect(.clear.tint(Color("Color")))
                            .background(Color("Color"))
                            .font(.headline.bold())
                            .cornerRadius(28)
                            .foregroundColor(.white)
                    }
                    .onTapGesture {
                        viewModel.startLearning()
                    }
                    .padding(.bottom, 50)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.dark)
    }
}


#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
