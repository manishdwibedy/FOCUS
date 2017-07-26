//
//  LoginTests.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 6/22/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import XCTest

class LoginTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        sleep(1)
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJunkDate() {
        // Use recording to get started writing UI tests.
        
        
        let app = XCUIApplication()
        app.buttons["New? Map Your World"].tap()
        app.buttons["Email"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("abc@gmail.com")
        app.buttons["Next"].tap()
        
        let fullNameTextField = app.textFields["Full Name"]
        fullNameTextField.tap()
        fullNameTextField.typeText("Qwee")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("qee")
        
        let chooseUsernameSecureTextField = app.secureTextFields["Choose Username"]
        chooseUsernameSecureTextField.tap()
        chooseUsernameSecureTextField.typeText("qwe")
        app.buttons["Finish"].tap()

        app.buttons["Finish"].tap()
        print("registering...")
        
        sleep(10)
        XCTAssert(!app.buttons["Finish"].exists)
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLogout(){
        
        
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 0).tap()
        app.scrollViews.otherElements.buttons["Gear"].tap()
        app.tables.staticTexts["Logout"].tap()
        app.sheets["Logout?"].buttons["Logout"].tap()
        
        sleep(1000000)
    }
    
    func testLogin(){
        
        let app = XCUIApplication()
        
        if !app.textFields["Username, Email or Phone Number"].exists{
            app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element(boundBy: 0).tap()
            app.scrollViews.otherElements.buttons["Gear"].tap()
            app.tables.staticTexts["Logout"].tap()
            app.sheets["Logout?"].buttons["Logout"].tap()
            
        }
        //XCTAssert(app.textFields["Username, Email or Phone Number"].exists)
        
        let usernameEmailOrPhoneNumberTextField = app.textFields["Username, Email or Phone Number"]
        usernameEmailOrPhoneNumberTextField.tap()
        usernameEmailOrPhoneNumberTextField.typeText("abcdefgh@gmail.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("qwerty1234")
        
        app.otherElements.containing(.image, identifier:"Transparent_Logo_225x150.png").element.tap()
        app.buttons["Sign In"].tap()
        
        sleep(1000000)
        
        XCTAssert(!app.alerts["Login error"].exists)
        print()
    }
    
    
    func testProperRegistration(){
        let app = XCUIApplication()
        
        XCTAssert(app.buttons["New? Map Your World"].exists)
        
        app.buttons["New? Map Your World"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("abcdefgh@gmail.com")
        app.buttons["Next"].tap()
        
        let fullNameTextField = app.textFields["Full Name"]
        fullNameTextField.tap()
        fullNameTextField.typeText("testing")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("qwerty1234")
        
        let chooseUsernameSecureTextField = app.textFields["Choose Username"]
        chooseUsernameSecureTextField.tap()
        chooseUsernameSecureTextField.typeText("abcdefgh")
        app.buttons["Finish"].tap()
        
        app.buttons["Finish"].tap()
        print("registering...")
        
        sleep(10)
        XCTAssert(!app.buttons["Finish"].exists)
    }
    
    func testDuplicateUsername(){
        
        let app = XCUIApplication()
        app.buttons["New? Map Your World"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("abcdefg@gmail.com")
        app.buttons["Next"].tap()
        
        let fullNameTextField = app.textFields["Full Name"]
        fullNameTextField.tap()
        fullNameTextField.typeText("testing")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("qwerty1234")
        
        let chooseUsernameSecureTextField = app.textFields["Choose Username"]
        chooseUsernameSecureTextField.tap()
        chooseUsernameSecureTextField.typeText("abc")
        app.buttons["Finish"].tap()
        
        app.buttons["Finish"].tap()
        print("registering...")
        
        sleep(5)
        XCTAssert(app.buttons["Done"].exists)
        
        app.buttons["Done"].tap()
        
        
        let chooseUsernameTextField = app.textFields["Choose Username"]
        chooseUsernameTextField.tap()
        chooseUsernameTextField.typeText("d")
        app.buttons["Finish"].tap()
        
        sleep(1000000)
        
    }
    
    func testEmaiAlreadyUsed(){
        let app = XCUIApplication()
        app.buttons["New? Map Your World"].tap()
        app.buttons["Email"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("manish.dwibedy@gmail.com")
        app.buttons["Next"].tap()
        
        let fullNameTextField = app.textFields["Full Name"]
        fullNameTextField.tap()
        fullNameTextField.typeText("testing")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("tasdasdasdasdasd")
        
        let chooseUsernameSecureTextField = app.secureTextFields["Choose Username"]
        chooseUsernameSecureTextField.tap()
        chooseUsernameSecureTextField.typeText("test")
        app.buttons["Finish"].tap()
        
        app.buttons["Finish"].tap()
        print("registering...")
        
        sleep(10)
        XCTAssert(app.buttons["Finish"].exists)
    }
    
    func testWeakPassword(){
        let app = XCUIApplication()
        app.buttons["New? Map Your World"].tap()
        app.buttons["Email"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("manish.dwibedy@gmail.com")
        app.buttons["Next"].tap()
        
        let fullNameTextField = app.textFields["Full Name"]
        fullNameTextField.tap()
        fullNameTextField.typeText("testing")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("abcd")
        
        let chooseUsernameSecureTextField = app.secureTextFields["Choose Username"]
        chooseUsernameSecureTextField.tap()
        chooseUsernameSecureTextField.typeText("test")
        app.buttons["Finish"].tap()
        
        app.buttons["Finish"].tap()
        print("registering...")
        
        sleep(5)
        XCTAssert(app.buttons["Finish"].exists)
    }
}
