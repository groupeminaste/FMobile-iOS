//
//  ActivityViewCustomActivity.swift
//  FMobile
//
//  Created by PlugN on 22/10/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class ActivityViewCustomActivity: UIActivity, MFMailComposeViewControllerDelegate {

    // MARK: Properties

    var customActivityType: UIActivity.ActivityType
    var activityName: String
    var activityImageName: String
    var filesToShare: [Any]


    // MARK: Initializer

    init(title: String, imageName: String, filesToShare: [Any], performAction: @escaping () -> Void) {
        self.activityName = title
        self.activityImageName = imageName
        self.customActivityType = UIActivity.ActivityType(rawValue: "Action \(title)")
        print(filesToShare.first as? URL ?? "FILE LOST")
        self.filesToShare = filesToShare
        super.init()
    }



    // MARK: Overrides

    override var activityType: UIActivity.ActivityType? {
        return customActivityType
    }



    override var activityTitle: String? {
        return activityName
    }



    override class var activityCategory: UIActivity.Category {
        return .share
    }



    override var activityImage: UIImage? {
        return UIImage(named: activityImageName)
    }



    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }



    override func prepare(withActivityItems activityItems: [Any]) {
        // Nothing to prepare
    }



    override func perform() {
        shareMailSheet(activity: filesToShare)
    }
    
    func shareMailSheet(activity: [Any]) {
        print("Recieved \(activity.count) items")
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["contact@groupe-minaste.org"])
            let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
            mail.setSubject("diagnostic_email".localized().format([appVersion, appBuild]))
            mail.setMessageBody("email_default_content".localized(), isHTML: true)
            do {
                let url = activity.first as? URL ?? URL(fileURLWithPath: "NONE")
                let attachement = try Data(contentsOf: url)
                mail.addAttachmentData(attachement, mimeType: "text/plain", fileName: "diagnostic.txt")
                
                UIApplication.shared.windows.first?.rootViewController?.present(mail, animated: true)
            
            } catch {
                print("An error occured: \(error)")
            }
        } else {
            // show failure alert
            print("No email available")
            
            let alert = UIAlertController(title: "mail_not_available".localized(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "close".localized(), style: .cancel, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
