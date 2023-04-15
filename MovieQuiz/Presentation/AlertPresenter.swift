//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dolnik Nikolay on 07.04.2023.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
   
    weak var delegate: AlertPresenterDelegate?
        init(delegate: AlertPresenterDelegate?) {
            self.delegate = delegate
        }
    
    
    func showAlert(alertModel: AlertModel) {
    
        let alert = UIAlertController(title: alertModel.title, message: alertModel.massage, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
         alert.addAction(action)
        delegate?.present(alert: alert)
    }
}
