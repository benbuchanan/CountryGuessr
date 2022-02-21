//
//  ContentView.swift
//  Country Guessr
//
//  Created by Ben Buchanan on 2/16/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var randomCountry: Country
    @State var guess: String = ""
    @State var allSuggestions: [String]
    @State var currentSuggestions: [String] = []
    @State var showSuggestions: Bool = false
    @State var suggestionTapped: Bool = false
    @State var distance: Double = 0.0
    @State var bearing: Double = 0.0
    @State var directionToGo: String = ""
    @State var showDistance: Bool = false
    @State var roundOver: Bool = false
    
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
            HStack {
                Text("Country Guessr")
                    .font(.title)
                    .padding()
                Spacer()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemCyan))
                Image(self.randomCountry.countryCode.lowercased()).resizable().frame(width: self.showSuggestions ? 150 : 225, height: self.showSuggestions ? 150 : 225)
            }
            .frame(width: self.showSuggestions ? 200 : 250, height: self.showSuggestions ? 200 : 250)
            if !self.showSuggestions {
                Spacer()
            }
            VStack {
                if self.showSuggestions {
                    List(self.currentSuggestions, id: \.self) { sug in
                        Button(action: {
                            self.suggestionTapped = true
                            self.guess = sug
                            withAnimation(.default) {
                                self.showSuggestions = false
                            }
                        }) {
                            Text(sug)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: 120)
                }
                TextField("Enter your guess", text: $guess)
                    .onChange(of: guess) { _ in
                        if self.roundOver {
                            self.roundOver.toggle()
                            return
                        }
                        if !self.showSuggestions && self.suggestionTapped {
                            self.suggestionTapped.toggle()
                            return
                        }
                        withAnimation(.default) {
                            self.showSuggestions = true
                        }
                        updateSuggestions()
                    }
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        print(self.guess)
                        withAnimation(.default) {
                            self.showSuggestions = false
                        }
                        if self.guess.lowercased() == self.randomCountry.country.lowercased() {
                            print("CORRECT")
                            self.roundOver = true
                            self.showDistance = false
                            self.guess = ""
                            self.randomCountry = countries[Int.random(in: 0..<countries.count)]
                            print(self.randomCountry.country)
                        } else {
                            print("WRONG")
                            // Get guessed country
                            let guessedCountry = getCountryByName(name: self.guess)
                            if guessedCountry == nil {
                                print("invalid country guessed")
                            } else {
                                self.distance = calculateDistance(country1: guessedCountry!, country2: self.randomCountry)
                                self.bearing = calculateBearing(country1: guessedCountry!, country2: self.randomCountry)
                                if self.bearing < 0 && self.bearing > -180 {
                                    print("go left")
                                } else {
                                    print("go right")
                                }
                                self.showDistance = true
                            }
                            // TODO: calculate direction to correct country
                        }
                    }
                if self.showDistance {
                    Text("Incorrect. \(String(format: "%.0f", round(self.distance)))km away.")
                    Text("Bearing \(String(format: "%.2f", self.bearing))º")
                    Text(self.directionToGo)
                    Image(colorScheme == .dark ? "arrow-white" : "arrow-dark")
                        .rotationEffect(.degrees(self.bearing))
                        .frame(width: 25, height: 25)
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
    
    // Calculate the distance between country1 and country2
    func calculateDistance(country1: Country, country2: Country) -> Double {
        // Get values in radians
        let lat1 = country1.latitude * Double.pi / 180
        let lon1 = country1.longitude * Double.pi / 180
        let lat2 = country2.latitude * Double.pi / 180
        let lon2 = country2.longitude * Double.pi / 180
        
        let distance = earthRadiusInKm * acos((sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(lon2 - lon1))
        
        return distance
    }
    
    // Calculate the bearing from country1 to country2
    func calculateBearing(country1: Country, country2: Country) -> Double {
        let lat1 = degreesToRadians(degrees: country1.latitude)
        let lon1 = degreesToRadians(degrees: country1.longitude)
        let lat2 = degreesToRadians(degrees: country2.latitude)
        let lon2 = degreesToRadians(degrees: country2.longitude)
        
        let deltaLon = lon2 - lon1
        
        let bearingRadians = atan2((sin(deltaLon) * cos(lat2)), (cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)))
                
        let bearingDegrees = bearingRadians * 180 / Double.pi
        if bearingDegrees < 0 {
            return bearingDegrees + 360
        }
        
        return bearingDegrees
    }
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * Double.pi / 180
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
