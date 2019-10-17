//
//  ElementModel.swift
//  SwiftyProteins
//
//  Created by Viktoriia LIKHOTKINA on 10/10/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import Foundation

struct ElementModel: Decodable {
    
    var elements: [Element]
    
    struct Element: Decodable {
        var name: String?
        var appearance: String?
        var atomicMass: Double?
        var boil: Double?
        var category: String?
        var density: Double?
        var discoveredBy: String?
        var melt: Double?
        var molarHeat: Double?
        var phase: String?
        var summary: String?
        var symbol: String?
        
        enum CodingKeys: String, CodingKey {
            case name = "name"
            case appearance = "appearance"
            case atomicMass = "atomic_mass"
            case boil = "boil"
            case category = "category"
            case density = "density"
            case discoveredBy = "discovered_by"
            case melt = "melt"
            case molarHeat = "molar_heat"
            case phase = "phase"
            case summary = "summary"
            case symbol = "symbol"
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case elements = "elements"
    }
    
}
