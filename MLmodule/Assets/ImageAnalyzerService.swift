//
//  ImageAnalyzerService.swift
//  MLmodule
//
//  Created by Lucas Abdel Leitao on 14/01/21.
//


import UIKit
import CoreML
import Vision

protocol ImageAnalyzerService {
    func analyzeImage(image: UIImage, navigationController: UINavigationController, failure: @escaping (_ error: String) -> Void)
}

class ImageAnalyzer: ImageAnalyzerService {
    
    func analyzeImage(image: UIImage, navigationController: UINavigationController, failure: @escaping (_ error: String) -> Void) {
        
        guard let ciImage = CIImage(image: image) else {
            failure("couldn't convert UIImage to CIImage")
            return
        }
        
        if #available(iOS 11.0, *) {
            if #available(iOS 12.0, *) {
                guard let model = try? VNCoreMLModel(for: SqueezeNet(configuration: MLModelConfiguration()).model) else {
                    failure("can't load CNNEmotions ML model")
                    return
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
        }
        
        // Create a Vision request with completion handler
        if #available(iOS 11.0, *) {
            let request = VNCoreMLRequest(model: model) { request, error in
                if let _error = error {
                    failure(_error.localizedDescription)
                } else if let results = request.results as? [VNClassificationObservation] {
                    DispatchQueue.main.async {
                        let vc = AnalysisResultViewController(image: image, results: results)
                        //let analysisDetailViewController = AnalysisDetailViewController(image: image, results: results)
                        navigationController.pushViewController(vc, animated: true)
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }

        // Run the Core ML CNNEmotions classifier on global dispatch queue
        if #available(iOS 11.0, *) {
            let handler = VNImageRequestHandler(ciImage: ciImage)
        } else {
            // Fallback on earlier versions
        }
        DispatchQueue.global(qos: .userInteractive).async {
          do {
            try handler.perform([request])
          } catch {
            failure(error.localizedDescription)
          }
        }
    }
}

