//
//  SpeedtestViewController.swift
//  FMobile
//
//  Created by Nathan FALLET on 03/01/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import UIKit

class SpeedtestViewController: UIViewController {

    @IBOutlet weak var progress: UIProgressView?
    @IBOutlet weak var speed: UILabel?
    var speedtest: Speedtest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func start(_ sender: Any) {
        if speedtest == nil {
            speedtest = Speedtest()
            speedtest?.set(){ (_ megabytesPerSecond) in
                DispatchQueue.main.async {
                    self.progress?.setProgress(megabytesPerSecond ?? 0 < 10.0 ? Float((megabytesPerSecond ?? 0)/10) : Float((10.0)/10), animated: true)
                    self.speed?.text = megabytesPerSecond ?? 0 > 1 ? "Vitesse : \(megabytesPerSecond?.rounded(toPlaces: 3) ?? 0) Mbps" : "Vitesse : \(Int(((megabytesPerSecond ?? 0) * 1000).rounded())) Kbps"
                }
            }
            
            let datas = Foundation.UserDefaults.standard
            
            var urlst = "http://test-debit.free.fr/1048576.rnd"
            if(datas.value(forKey: "URLST") != nil){
                urlst = datas.value(forKey: "URLST") as? String ?? "http://test-debit.free.fr/1048576.rnd"
            }
            
            speedtest?.testDownloadSpeedWithTimout(timeout: 15.0, usingURL: urlst) { (speed, error) in
                DispatchQueue.main.async {
                    let text = speed ?? 0 > 1 ? "Vitesse : \(speed?.rounded(toPlaces: 3) ?? 0) Mbps" : "Vitesse : \(Int(((speed ?? 0) * 1000).rounded())) Kbps"

                    let alert = UIAlertController(title: "Résulat", message: text, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    self.speedtest = nil
                }
            }
        }else{
            let alert = UIAlertController(title: "Test déjà en cours !", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
