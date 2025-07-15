import SwiftUI
import RevenueCat
import RevenueCatUI

struct PaywallView: UIViewControllerRepresentable {
    let onPurchaseCompleted: ((CustomerInfo) -> Void)?
    let onRestoreCompleted: ((CustomerInfo) -> Void)?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let paywallViewController = PaywallViewController()
        paywallViewController.delegate = context.coordinator
        return paywallViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onPurchaseCompleted: onPurchaseCompleted,
            onRestoreCompleted: onRestoreCompleted
        )
    }
    
    class Coordinator: NSObject, PaywallViewControllerDelegate {
        let onPurchaseCompleted: ((CustomerInfo) -> Void)?
        let onRestoreCompleted: ((CustomerInfo) -> Void)?
        
        init(onPurchaseCompleted: ((CustomerInfo) -> Void)?, onRestoreCompleted: ((CustomerInfo) -> Void)?) {
            self.onPurchaseCompleted = onPurchaseCompleted
            self.onRestoreCompleted = onRestoreCompleted
        }
        
        func paywallViewController(_ controller: PaywallViewController, didFinishPurchasingWith customerInfo: CustomerInfo) {
            onPurchaseCompleted?(customerInfo)
        }
        
        func paywallViewController(_ controller: PaywallViewController, didFinishRestoringWith customerInfo: CustomerInfo) {
            onRestoreCompleted?(customerInfo)
        }
    }
}

extension PaywallView {
    func onPurchaseCompleted(_ completion: @escaping (CustomerInfo) -> Void) -> PaywallView {
        PaywallView(
            onPurchaseCompleted: completion,
            onRestoreCompleted: onRestoreCompleted
        )
    }
    
    func onRestoreCompleted(_ completion: @escaping (CustomerInfo) -> Void) -> PaywallView {
        PaywallView(
            onPurchaseCompleted: onPurchaseCompleted,
            onRestoreCompleted: completion
        )
    }
}