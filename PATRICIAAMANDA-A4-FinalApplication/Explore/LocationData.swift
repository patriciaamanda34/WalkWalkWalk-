//
//  LocationData.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/23/21.
//

import Foundation

class LocationData: NSObject, Decodable {
    
    //MARK: - Variables
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var categories: String
    var image: String?
    
    
    //MARK: - Methods
    private enum RootKeys: String, CodingKey {
        case name
        case point
        case kinds
    }
    
    
    private enum PointKeys: String, CodingKey {
        case long = "lon"
        case lat
    }
    
    
    required init(from decoder: Decoder) throws {
        // Get the root container first
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        let pointContainer = try rootContainer.nestedContainer(keyedBy: PointKeys.self, forKey: .point)
        
        name =  try rootContainer.decode(String.self, forKey: .name)
        
        latitude =  try pointContainer.decode(Double.self, forKey: .lat)
        longitude =  try pointContainer.decode(Double.self, forKey: .long)
        
        categories =  try rootContainer.decode(String.self, forKey: .kinds)
    }
}
