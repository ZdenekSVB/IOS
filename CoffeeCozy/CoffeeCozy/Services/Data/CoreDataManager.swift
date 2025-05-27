//
//  CoreDataManager.swift
//  CityGuide
//
//  Created by David Procházka on 09.04.2025.
//
import CoreData

final class CoreDataManager: DataManaging {
    private let container = NSPersistentContainer(name: "CityGuide")
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Cannot create persistent store: \(error.localizedDescription)")
            }
        }
    }
    
    func savePlace(place: PointOfInterest) {
        save()
    }
    
    func removePlace(place: PointOfInterest) {
        context.delete(place)
        save()
    }
    
    func fetchPlaces() -> [PointOfInterest] {
        let request = NSFetchRequest<PointOfInterest>(entityName: "PointOfInterest")
        var pois: [PointOfInterest] = []
        
        do {
            pois = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        return pois
    }
    
    func fetchPlaceWithId(id: UUID) -> PointOfInterest? {
        let request = NSFetchRequest<PointOfInterest>(entityName: "PointOfInterest")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        var pois: [PointOfInterest] = []
        
        do {
            pois = try context.fetch(request)
        } catch {
            print("Cannot fetch data: \(error.localizedDescription)")
        }
        
        return pois.first
    }
}

private extension CoreDataManager {
    private func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Cannot save MOC: \(error.localizedDescription)")
            }
        }
    }
}
