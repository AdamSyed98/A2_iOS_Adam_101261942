import Foundation
import CoreData

extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var productID: String?
    @NSManaged public var productName: String?
    @NSManaged public var productDesc: String?
    @NSManaged public var productPrice: Double
    @NSManaged public var productProvider: String?
}

extension Product: Identifiable {

}
