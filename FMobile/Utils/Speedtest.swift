//
//  Speedtest.swift
//  FMobile
//
//  Created by Nathan FALLET on 03/01/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation

class Speedtest: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    typealias speedTestCompletionHandler = (_ megabytesPerSecond: Double? , _ error: Error?) -> Void
    
    var speedTestCompletionBlock: speedTestCompletionHandler?
    var progress: ((_ megabytesPerSecond: Double?) -> Void)?
    
    var startTime: CFAbsoluteTime! = nil
    var stopTime: CFAbsoluteTime! = nil
    var bytesReceived: Int!
    
    let configuration = URLSessionConfiguration.ephemeral
    
    let datas = Foundation.UserDefaults.standard
    
    func testDownloadSpeedWithTimout(timeout: TimeInterval, usingURL: String = "null", withCompletionBlock: @escaping speedTestCompletionHandler) {
        
        // See https://www.thinkbroadband.com/download for file URLs
        // Voir http://test-debit.free.fr pour les autres fichiers
        var fallbackURL = "http://test-debit.free.fr/512.rnd"
        
        if usingURL == "null" {
            
            if(datas.value(forKey: "URL") != nil){
                fallbackURL = datas.value(forKey: "URL") as? String ?? "http://test-debit.free.fr/512.rnd"
            }
            
        } else {
            fallbackURL = usingURL
        }
        
        guard let url = URL(string: fallbackURL) else { return }
        
        if(startTime == nil) {
            startTime = CFAbsoluteTimeGetCurrent()
            stopTime = startTime
        }
        
        bytesReceived = 0
        
        speedTestCompletionBlock = withCompletionBlock
        
        // Initialisation du téléchargement
        print("Initialisation du speedtest avec l'URL : \(url)")
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: url)
        task.resume()
        
    }
    
    func set(progress: @escaping (_ megabytesPerSecond: Double?) -> Void) {
        self.progress = progress
    }
    
    func speed() -> Double {
        let elapsed = stopTime - startTime
        
        let speed = elapsed != 0 ? (Double(bytesReceived) / 125000) / elapsed : -1 // elapsed / 1024.0 / 1024.0  
        
        return speed
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bytesReceived! += data.count
        stopTime = CFAbsoluteTimeGetCurrent()
        print("\(bytesReceived!) bytes received...")
        if progress != nil {
            progress!(speed())
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let elapsed = stopTime - startTime
        print("Fin du téléchargement: \(elapsed)")
        
        if let aTempError = error as NSError?, aTempError.domain != NSURLErrorDomain && aTempError.code != NSURLErrorTimedOut && elapsed == 0  {
            speedTestCompletionBlock?(nil, error)
            return
        }
        
        speedTestCompletionBlock?(speed(), nil)
        
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("Suppression de la task du speedtest")
        session.finishTasksAndInvalidate()
    }
    
}
