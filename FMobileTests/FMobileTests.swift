//
//  FMobileTests.swift
//  FMobileTests
//
//  Created by PlugN on 28/01/2019.
//  Copyright © 2019 Groupe MINASTE. All rights reserved.
//

import XCTest

class FMobileTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDataManager() {
        self.measure {
            let data = DataManager()
            let genView = GeneralTableViewController()
            let speedView = SpeedtestViewController()
            let appD = AppDelegate()
            
            XCTAssertNotNil(data.datas, "FATAL ERROR: DataManager unable to read values")
            XCTAssertNoThrow(genView.updateSetup(), "COULD NOT UPDATE SETUP!")
            XCTAssertNoThrow(speedView.start(self), "Speedtest failed!")
            XCTAssertNoThrow(appD.WIFIDIS(), "WIFI detection failed!")
            XCTAssertNotNil(CarrierIdentification.getIsoCountryCode("208", "15"))
            CarrierConfiguration.fetch(forMCC: "208", andMNC: "15") { (configuration) in
                XCTAssertNotNil(configuration?.mcc, "MCC nil will fail!")
                XCTAssertNotNil(configuration?.mnc, "MNC nli will fail!")
            }
            XCTAssertNoThrow(RoamingManager.bgUpdateSetup(), "BACKGROUND UPDATE FAILED")
            XCTAssertNoThrow(RoamingManager.engine(g3engine: true, completionHandler: { (result) in
                XCTAssertNotNil(result, "ENGINE RESULT FAILED!")
            }), "ENGINE FAILED")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
