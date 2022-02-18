//
//  ContentView.swift
//  Country Guessr
//
//  Created by Ben Buchanan on 2/16/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var randomCountry: Country
    @State var guess: String = ""
    @State var allSuggestions: [String]
    @State var currentSuggestions: [String] = []
    @State var showSuggestions: Bool = false
    @State var suggestionTapped: Bool = false
    @State var distance: Double = 0.0
    @State var showDistance: Bool = false
    
    init() {
        _randomCountry = State(initialValue: countries[Int.random(in: 0..<countries.count)])
        var sugs: [String] = []
        for country in countries {
            sugs.append(country.country)
        }
        _allSuggestions = State(initialValue: sugs)
    }
        
    var body: some View {
        VStack {
            Image(self.randomCountry.countryCode.lowercased()).resizable().frame(width:300, height: 300)
            Spacer()
            VStack {
                if self.showSuggestions {
                    List(self.currentSuggestions, id: \.self) { sug in
                        Button(action: {
                            self.suggestionTapped = true
                            self.guess = sug
                            self.showSuggestions = false
                        }) {
                            Text(sug)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: 125)
                }
                TextField("Enter your guess", text: $guess)
                    .onChange(of: guess) { _ in
                        if !self.showSuggestions && self.suggestionTapped {
                            self.suggestionTapped.toggle()
                            return
                        }
                        self.showSuggestions = true
                        updateSuggestions()
                    }
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        print(self.guess)
                        self.showSuggestions = false
                        if self.guess.lowercased() == self.randomCountry.country.lowercased() {
                            print("CORRECT")
                            self.showDistance = false
                            self.guess = ""
                            self.showSuggestions = false
                            self.randomCountry = countries[Int.random(in: 0..<countries.count)]
                            print(self.randomCountry.country)
                        } else {
                            print("WRONG")
                            // Get guessed country
                            let guessedCountry = getCountryByName(name: self.guess)
                            if guessedCountry == nil {
                                print("invalid country guessed")
                            } else {
                                self.distance = calculateDistance(country1: self.randomCountry, country2: guessedCountry!)
                                self.showDistance = true
                            }
                            // TODO: calculate direction to correct country
                        }
                    }
                if self.showDistance {
                    Text("Incorrect. \(String(format: "%.0f", round(self.distance)))km away.")
                }
            }
            Spacer()
        }.onAppear() {
            print(self.randomCountry.country.lowercased())
        }
    }
    
    // Update the suggestions list based on the current guess
    func updateSuggestions() {
        var newSugs: [String] = []
        for word in self.allSuggestions {
            if word.lowercased().contains(self.guess.lowercased()) {
                newSugs.append(word)
            }
        }
        self.currentSuggestions = newSugs
    }
    
    // Find the Country struct by its name
    func getCountryByName(name: String) -> Country? {
        for country in countries {
            if country.country.lowercased() == name.lowercased() {
                return country
            }
        }
        return nil
    }
    
    func calculateDistance(country1: Country, country2: Country) -> Double {
        // Get values in radians
        let lat1 = country1.latitude * Double.pi / 180
        let lon1 = country1.longitude * Double.pi / 180
        let lat2 = country2.latitude * Double.pi / 180
        let lon2 = country2.longitude * Double.pi / 180
        
        let distance = earthRadiusInKm * acos((sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(lon2 - lon1))
        
        return distance
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
