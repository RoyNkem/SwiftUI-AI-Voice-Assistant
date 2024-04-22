//
//  SwiftUI_AI_Voice_AssistantUITestsLaunchTests.swift
//  SwiftUI AI Voice AssistantUITests
//
//  Created by Roy's MacBook M1 on 22/04/2024.
//

import XCTest

final class SwiftUI_AI_Voice_AssistantUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
