//
//  Setup.swift
//  Weather
//
//  Created by Steven Spencer on 10/2/24.
//

import Foundation
import SwiftUI
import BackgroundTasks
import MapKit

struct SetupView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss

    @State private var widgetLocation: String = UserDefaults.standard.string(forKey: "widgetLocation") ?? ""
    @State private var notificationSetting: Bool = UserDefaults.standard.bool(forKey: "notificationSetting")
    @State private var locationSetting: Bool = UserDefaults.standard.bool(forKey: "locationSetting")
    @State private var navigateToMainView = false // State to control navigation
    @AppStorage("widgetLocation", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var widgetLocation_s: String = "Vinton, IA"
    @State private var isKeyboardVisible = false // State to track keyboard visibility
    @FocusState private var isSearchFieldFocused: Bool // Manage focus state of the search field
    @AppStorage("widgetLocationCurrent", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var widgetLocationCurrent: Bool = false
    @State private var isSearchDisabled = false // Disable search updates when suggestion is tapped
    @State var useCurrent: Bool = UserDefaults.standard.bool(forKey: "useCurrent")
    init() {
        // Customize the appearance of the navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Keep the background as is
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    @ObservedObject var viewModel = AddressSearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Image("night_sky")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Toggle(isOn: $notificationSetting) {
                            Text("Enable Notifications")
                                .foregroundColor(.white)
                                .padding(.vertical)
                        }
                        
                        Toggle(isOn: $locationSetting) {
                            Text("Enable Location")
                                .foregroundColor(.white)
                                .padding(.vertical)
                        }
                        
                        Toggle(isOn: $useCurrent) {
                            Text("Enable Location")
                                .foregroundColor(.white)
                                .padding(.vertical)
                        }

                        if locationSetting {
                            Text("Enter Location to Use for Widget")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 5)

                            // Search Bar and Address Results List
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search for a place or address", text: $viewModel.searchQuery)
                                    .focused($isSearchFieldFocused) // Bind the search field focus to @FocusState
                                    .onChange(of: viewModel.searchQuery) {
                                        // Only update search results if search is not disabled
                                        if !isSearchDisabled {
                                            viewModel.updateSearchResults()
                                        }
                                    }
                                    .foregroundColor(.primary)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)

                            // Show the list only if there are search results
                            if !viewModel.searchResults.isEmpty {
                                List(viewModel.searchResults, id: \.self) { result in
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                            .font(.headline)
                                        Text(result.subtitle)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 5)
                                    .onTapGesture {
                                        // Fill in the text field with the selected address, dismiss the keyboard, and clear the results
                                        viewModel.searchQuery = "\(result.title), \(result.subtitle)"
                                        widgetLocation = viewModel.searchQuery
                                        isSearchFieldFocused = false // Dismiss the keyboard
                                        isSearchDisabled = true // Disable further search updates
                                        viewModel.searchResults = [] // Clear the search results to hide the list
                                    }
                                }
                                .listStyle(PlainListStyle()) // Native style
                                .frame(height: 150) // Limit the height of the list
                            }
                        }



                        // Button with action
                        Button(action: {
                            dismiss() // Dismiss the view
                            UserDefaults.standard.set(true, forKey: "weatherlySettings")
                            navigateToMainView = true
                        }) {
                            Text("Go to Main View")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 200)
                }
            }
            
            .onChange(of: useCurrent) {
                widgetLocationCurrent = useCurrent
                UserDefaults.standard.set(useCurrent, forKey: "useCurrent")
            }
            .onChange(of: notificationSetting) {
                UserDefaults.standard.set(notificationSetting, forKey: "notificationSetting")
                print(showNotificationPrompt())
            }
            .onChange(of: locationSetting) {
                UserDefaults.standard.set(locationSetting, forKey: "locationSetting")
                print(showLocationPrompt())
            }
            .onChange(of: widgetLocation) {
                widgetLocation_s = widgetLocation
                UserDefaults.standard.set(widgetLocation, forKey: "widgetLocation")
            }
            // Conditionally show navigation title based on keyboard visibility
            .navigationTitle(isSearchFieldFocused ? "" : "Weatherly Setup")
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToMainView) {
                MainView()
            }
            .onAppear {
                // Add observers for keyboard notifications
                widgetLocation_s = UserDefaults.standard.string(forKey: "widgetLocation") ?? "Vinton, IA"

            }
        }
    }

    func showLocationPrompt() -> String {
        LocationManager().manager.requestWhenInUseAuthorization()
        return " "
    }

    func showNotificationPrompt() -> String {
        NotificationManager().requestNotificationAuthorization()
        return " "
    }
}

#Preview {
    SetupView()
}

import SwiftUI
import MapKit

class AddressSearchViewModel: NSObject, ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []

    private var completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = .address
        completer.delegate = self
    }

    func updateSearchResults() {
        completer.queryFragment = searchQuery
    }
}

extension AddressSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching search completions: \(error.localizedDescription)")
    }
}
