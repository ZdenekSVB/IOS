//
//  DataManaging.swift
//  CityGuide
//
//  Created by David Procházka on 19.03.2025.
//
import CoreData
import UIKit

protocol DataManaging {
    var context: NSManagedObjectContext { get }
    
    func savePlace(place: PointOfInterest)
    func removePlace(place: PointOfInterest)
    func fetchPlaces() -> [PointOfInterest]
    func fetchPlaceWithId(id: UUID) -> PointOfInterest?
    
    func addSampleData()
}

extension DataManaging {
    func addSampleData() {
        let sample1 = PointOfInterest(context: context)
        sample1.name = "Mendel University in Brno"
        sample1.latitude = 49.21044343932761
        sample1.longitude = 16.61573011990775
        sample1.image = UIImage(named: "MENDELU")?.jpegData(compressionQuality: 90)
        sample1.style = ArchitecturalStyle.Baroque.rawValue
        sample1.type = LocationType.Historical.rawValue
        
        savePlace(place: sample1)
    }
}
