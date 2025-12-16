//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Екатерина Барданова on 13. 12. 2025..
//

import Foundation
import UIKit

final class AlertPresenter {
    private weak var screenToShowAlertOn: UIViewController?
    
    init(screen: UIViewController?) {
        self.screenToShowAlertOn = screen
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in model.completion()
        }
        alert.addAction(action)
        screenToShowAlertOn?.present(alert, animated: true, completion: nil)
    }
}

    

