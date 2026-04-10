import UIKit
import CoreData

class AddProductViewController: UIViewController {

    private let idField = UITextField()
    private let nameField = UITextField()
    private let descField = UITextField()
    private let priceField = UITextField()
    private let providerField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Product"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        idField.placeholder = "Product ID"
        nameField.placeholder = "Product Name"
        descField.placeholder = "Product Description"
        priceField.placeholder = "Product Price"
        providerField.placeholder = "Product Provider"

        [idField, nameField, descField, priceField, providerField].forEach {
            $0.borderStyle = .roundedRect
        }

        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Product", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [idField, nameField, descField, priceField, providerField, saveButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func saveTapped() {
        guard
            let productID = idField.text, !productID.isEmpty,
            let productName = nameField.text, !productName.isEmpty,
            let productDesc = descField.text, !productDesc.isEmpty,
            let provider = providerField.text, !provider.isEmpty,
            let priceText = priceField.text, let price = Double(priceText)
        else {
            return
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let product = Product(context: context)
        product.productID = productID
        product.productName = productName
        product.productDesc = productDesc
        product.productPrice = price
        product.productProvider = provider

        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Save error: \(error)")
        }
    }
}
