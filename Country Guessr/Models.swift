//
//  Models.swift
//  Country Guessr
//
//  Created by Ben Buchanan on 2/16/22.
//

import Foundation

// CONSTS
let earthRadiusInKm: Double = 6378.8

// Country
struct Country: Identifiable, Decodable {
    var id: String { countryCode }
    var country: String
    var countryCode: String
    var countryCode3: String
    var numericCode: Int
    var latitude: Double
    var longitude: Double
}

var countries: [Country] = load("countrydata.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
