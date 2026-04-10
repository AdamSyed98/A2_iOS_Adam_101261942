import UIKit
import CoreData

class ProductDetailViewController: UIViewController {

    private var products: [Product] = []
    private var currentIndex: Int = 0

    private let idLabel = UILabel()
    private let nameLabel = UILabel()
    private let descLabel = UILabel()
    private let priceLabel = UILabel()
    private let providerLabel = UILabel()

    private let searchField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search by name or description"
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Search", for: .normal)
        return btn
    }()

    private let resetButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Reset", for: .normal)
        return btn
    }()

    private let previousButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Previous", for: .normal)
        return btn
    }()

    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        return btn
    }()

    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add Product", for: .normal)
        return btn
    }()

    private let listButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("View All Products", for: .normal)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Details"
        view.backgroundColor = .systemBackground

        setupUI()
        setupActions()
        preloadProductsIfNeeded()
        fetchProducts()
    }

    private func setupUI() {
        [idLabel, nameLabel, descLabel, priceLabel, providerLabel].forEach {
            $0.numberOfLines = 0
            $0.font = UIFont.systemFont(ofSize: 18)
        }

        let searchStack = UIStackView(arrangedSubviews: [searchField, searchButton, resetButton])
        searchStack.axis = .horizontal
        searchStack.spacing = 8

        let navStack = UIStackView(arrangedSubviews: [previousButton, nextButton])
        navStack.axis = .horizontal
        navStack.spacing = 12
        navStack.distribution = .fillEqually

        let actionStack = UIStackView(arrangedSubviews: [addButton, listButton])
        actionStack.axis = .vertical
        actionStack.spacing = 12

        let mainStack = UIStackView(arrangedSubviews: [
            searchStack,
            idLabel,
            nameLabel,
            descLabel,
            priceLabel,
            providerLabel,
            navStack,
            actionStack
        ])

        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        listButton.addTarget(self, action: #selector(listTapped), for: .touchUpInside)
    }

    private func context() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    private func preloadProductsIfNeeded() {
        let context = context()
        let request: NSFetchRequest<Product> = Product.fetchRequest()

        do {
            let count = try context.count(for: request)
            if count == 0 {
                let sampleProducts = [
                    ("P001", "iPhone 15", "Apple smartphone with advanced camera", 1299.99, "Apple"),
                    ("P002", "MacBook Air", "Lightweight laptop for everyday use", 1599.99, "Apple"),
                    ("P003", "AirPods Pro", "Wireless earbuds with noise cancellation", 329.99, "Apple"),
                    ("P004", "Apple Watch", "Smart watch for fitness and notifications", 549.99, "Apple"),
                    ("P005", "iPad Air", "Tablet device for work and entertainment", 899.99, "Apple"),
                    ("P006", "Galaxy S24", "Samsung smartphone with powerful features", 1199.99, "Samsung"),
                    ("P007", "Dell XPS 13", "Premium ultrabook with sleek design", 1499.99, "Dell"),
                    ("P008", "Sony WH-1000XM5", "Noise cancelling over-ear headphones", 499.99, "Sony"),
                    ("P009", "Logitech MX Master 3", "Advanced wireless productivity mouse", 129.99, "Logitech"),
                    ("P010", "HP LaserJet", "Reliable office printer", 299.99, "HP")
                ]

                for item in sampleProducts {
                    let product = Product(context: context)
                    product.productID = item.0
                    product.productName = item.1
                    product.productDesc = item.2
                    product.productPrice = item.3
                    product.productProvider = item.4
                }

                try context.save()
            }
        } catch {
            print("Preload error: \(error)")
        }
    }

    private func fetchProducts() {
        let context = context()
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "productID", ascending: true)]

        do {
            products = try context.fetch(request)
            if !products.isEmpty {
                currentIndex = 0
                displayProduct()
            }
        } catch {
            print("Fetch error: \(error)")
        }
    }

    private func displayProduct() {
        guard !products.isEmpty, currentIndex >= 0, currentIndex < products.count else { return }

        let product = products[currentIndex]
        idLabel.text = "Product ID: \(product.productID ?? "")"
        nameLabel.text = "Product Name: \(product.productName ?? "")"
        descLabel.text = "Description: \(product.productDesc ?? "")"
        priceLabel.text = String(format: "Price: $%.2f", product.productPrice)
        providerLabel.text = "Provider: \(product.productProvider ?? "")"
    }

    @objc private func searchTapped() {
        guard let keyword = searchField.text, !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let context = context()
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        request.predicate = NSPredicate(format: "productName CONTAINS[cd] %@ OR productDesc CONTAINS[cd] %@", keyword, keyword)
        request.sortDescriptors = [NSSortDescriptor(key: "productID", ascending: true)]

        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                products = results
                currentIndex = 0
                displayProduct()
            }
        } catch {
            print("Search error: \(error)")
        }
    }

    @objc private func resetTapped() {
        searchField.text = ""
        fetchProducts()
    }

    @objc private func previousTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            displayProduct()
        }
    }

    @objc private func nextTapped() {
        if currentIndex < products.count - 1 {
            currentIndex += 1
            displayProduct()
        }
    }

    @objc private func addTapped() {
        let vc = AddProductViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func listTapped() {
        let vc = ProductListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
