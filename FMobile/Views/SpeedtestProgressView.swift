/*
Copyright (C) 2020 Groupe MINASTE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
//
//  SpeedtestProgressView.swift
//  FMobile
//
//  Created by Nathan FALLET on 15/05/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import UIKit

class SpeedtestProgressView: UIView {

    var speed = UILabel()
    var unit = UILabel()
    var low = UILabel()
    var high = UILabel()
    var backgroundShape = CAShapeLayer()
    var speedShape = CAShapeLayer()
    var speedtest: Speedtest?
    var max: Double
    
    override init(frame: CGRect) {
        max = 10
        super.init(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: 250)))
    }
    
    func loadViews() {
        // Initialisation des views
        addSubview(speed)
        addSubview(unit)
        addSubview(low)
        addSubview(high)
        
        speed.translatesAutoresizingMaskIntoConstraints = false
        speed.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        speed.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15).isActive = true
        speed.font = UIFont.boldSystemFont(ofSize: 22)
        speed.text = "-"
        
        unit.translatesAutoresizingMaskIntoConstraints = false
        unit.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        unit.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 15).isActive = true
        unit.font = UIFont.systemFont(ofSize: 20)
        unit.text = "Mbps"
        
        low.translatesAutoresizingMaskIntoConstraints = false
        low.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -90).isActive = true
        low.trailingAnchor.constraint(equalTo: centerXAnchor, constant: 35).isActive = true
        low.text = "0"
        
        high.translatesAutoresizingMaskIntoConstraints = false
        high.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -90).isActive = true
        high.leadingAnchor.constraint(equalTo: centerXAnchor, constant: -35).isActive = true
        high.text = "\(Int(max))"
        
        backgroundShape.path = UIBezierPath(arcCenter: center, radius: 100, startAngle: -1 * CGFloat.pi / 3, endAngle: 4 * CGFloat.pi / 3, clockwise: true).cgPath
        backgroundShape.lineWidth = 10
        backgroundShape.lineCap = .round
        backgroundShape.strokeEnd = 1
        backgroundShape.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundShape)
        
        speedShape.path = UIBezierPath(arcCenter: center, radius: 100, startAngle: -1 * CGFloat.pi / 3, endAngle: 4 * CGFloat.pi / 3, clockwise: true).cgPath
        speedShape.lineWidth = 10
        speedShape.lineCap = .round
        speedShape.strokeEnd = 0
        speedShape.fillColor = UIColor.clear.cgColor
        layer.addSublayer(speedShape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func start(_ sender: Any) {
        if speedtest == nil {
            speedtest = Speedtest()
            speedtest?.set(){ (_ megabytesPerSecond) in
                DispatchQueue.main.async {
                    self.adjustMax(for: megabytesPerSecond ?? 0)
                    self.speedShape.strokeEnd = CGFloat((megabytesPerSecond ?? 0) < self.max ? ((megabytesPerSecond ?? 0) / self.max) : 1.0)
                    (self.speed.text, self.unit.text) = (megabytesPerSecond ?? 0).toSpeedtest()
                }
            }
            
            let datas = Foundation.UserDefaults.standard
            
            var urlst = "http://test-debit.free.fr/1048576.rnd"
            if(datas.value(forKey: "URLST") != nil){
                urlst = datas.value(forKey: "URLST") as? String ?? "http://test-debit.free.fr/1048576.rnd"
            }
            
            speedtest?.testDownloadSpeedWithTimout(timeout: 15.0, usingURL: urlst) { (speed, _) in
                DispatchQueue.main.async {
                    self.speedShape.strokeEnd = CGFloat((speed ?? 0) < self.max ? ((speed ?? 0) / self.max) : 1.0)
                    (self.speed.text, self.unit.text) = (speed ?? 0).toSpeedtest()
                    
                    self.speedtest = nil
                }
            }
        } else {
            let alert = UIAlertController(title: "speedtest_in_progress".localized(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func enableDarkMode() {
        backgroundShape.strokeColor = CustomColor.darkShapeBackgroud.cgColor
        speedShape.strokeColor = CustomColor.darkActive.cgColor
        unit.textColor = CustomColor.darkText
        speed.textColor = CustomColor.darkText
        low.textColor = CustomColor.darkText
        high.textColor = CustomColor.darkText
    }
    
    func disableDarkMode() {
        backgroundShape.strokeColor = CustomColor.lightShapeBackgroud.cgColor
        speedShape.strokeColor = CustomColor.lightActive.cgColor
        unit.textColor = CustomColor.lightText
        speed.textColor = CustomColor.lightText
        low.textColor = CustomColor.lightText
        high.textColor = CustomColor.lightText
    }
    
    func adjustMax(for value: Double) {
        if value < 1 {
            self.max = 1
        } else if value < 10 {
            self.max = 10
        } else if value < 50 {
            self.max = 50
        } else if value < 100 {
            self.max = 100
        } else if value < 250 {
            self.max = 250
        } else if value < 500 {
            self.max = 500
        } else {
            self.max = 1000
        }
        high.text = "\(Int(max))"
    }
    
}
