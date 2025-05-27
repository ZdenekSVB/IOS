//
//  MockDataManager.swift
//  CityGuide
//
//  Created by David Procházka on 19.03.2025.
//
import Foundation
import CoreData
import UIKit

final class MockDataManager: DataManaging {
    var pois: [PointOfInterest] = []
    
    var context: NSManagedObjectContext {
        NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    func savePlace(place: PointOfInterest) {
        pois.append(place)
    }
    
    func removePlace(place: PointOfInterest) {
        pois.removeAll(where: { $0.id == place.id })
    }

    func fetchPlaces() -> [PointOfInterest] {
        return pois
    }
    
    func fetchPlaceWithId(id: UUID) -> PointOfInterest? {
        return pois.first(where: { $0.id == id })
    }
}
