//
//  Usercentrics.swift
//  testApp
//
//  Created by Hugo Silva on 12/01/2022.
//

import Foundation
import Usercentrics
import UsercentricsUI
import UIKit
import WebKit

struct Usercentrics {

    private let sdkDefaults = SDKDefaults()
    
    func appInit(){
        /// Initialize Usercentrics with your configuration
        let options = UsercentricsOptions(settingsId: sdkDefaults.settingsId)
        options.loggerLevel = .debug
        UsercentricsCore.configure(options: options)
        ifNeeded()
        
    }
    
    func showCMP(_ vc: UIViewController, buttonIdentifier: String?) {
        UsercentricsCore.isReady { status in
            // Order as displayed visualy on the Main Interface
            switch buttonIdentifier {
            case "1":
                self.presentBannerV2(navigationController: vc.navigationController, layout: "full")
            case "2":
                self.presentBannerV2(navigationController: vc.navigationController, layout: "bottom")
            case "3":
                self.presentBannerV2(navigationController: vc.navigationController, layout: "center")
            case "4":
                self.presentBannerV2(navigationController: vc.navigationController, layout: "sheet")
            default:
                print("No proper layout selected")
                return
            }
            print("CMP shown")
        } onFailure: { error in
            print("Error on init: \(error.localizedDescription)")
        }
    }
    
    
    func ifNeeded(){
        UsercentricsCore.isReady { status in
            
            if status.shouldCollectConsent {
                let banner = UsercentricsBanner()
                banner.showFirstLayer() { userResponse in
                    // Handle userResponse
                }

            } else {
                // Apply consent with status.consents
            }
        } onFailure: { error in
            // Handle non-localized error
        }
    }
    
    func openWebview(webView: WKWebView, viewController: ViewController){
        
        
    }
    
    func resetCMP(){
        UsercentricsCore.reset()
        self.appInit()
    }
    
    /*
    private func getSettings(customFont: UIFont?, customLogo: UIImage?, showCloseButton: Bool = false) -> UsercentricsUISettings {
        return UsercentricsUISettings(customFont: customFont,
                                      customLogo: customLogo,
                                      showCloseButton: showCloseButton)
    }
    */
    
    private func applyConsent(with consents: [UsercentricsServiceConsent]) {
        self.getCMPData(consents: consents)
    }
    
    private func getCMPData(consents: [UsercentricsServiceConsent]){
        UsercentricsCore.isReady { status in

            // CMP Data
            //let data = UsercentricsCore.shared.getCMPData()
            //let settings = data.settings
            //let tcfSettings = settings.tcf2
            // Non-TCF Data - if you have services not included in IAB
            //let services = data.services
            //let categories = data.categories
            //print("-- CMP DATA --")
            //print("Categories: \(categories)")
            
            print("-- BANNER MESSAGE --")
            print(UsercentricsCore.shared.getCMPData().settings.firstLayerDescription.string)
            
            print("-- GET CONSENTS -- ")
            for consent in consents {
                print("\(String(describing: consent.dataProcessor).padding(toLength: 40, withPad: " ", startingAt: 0)) | TemplateId: \(String(describing: consent.templateId).padding(toLength: 10, withPad: " ", startingAt: 0)) | Consent Status: \(String(describing: consent.status).padding(toLength: 10, withPad: " ", startingAt: 0)) ")
            }
            
            // TCF Data
            UsercentricsCore.shared.getTCFData{ tcfData in
                //let tcfData = UsercentricsCore.shared.getTCFData()
                let purposes = tcfData.purposes
                //let specialPurposes = tcfData.specialPurposes
                //let features = tcfData.features
                //let specialFeatures = tcfData.specialFeatures
                //let stacks = tcfData.stacks
                let vendors = tcfData.vendors

                // TCString
                print("-- TCSTRING --")
                //let tcString = UsercentricsCore.shared.getTCString()
                let tcString = tcfData.tcString
                print("TCString: \(tcString)")

                print("-- PURPOSES --")
                let purposesList = purposes.sorted(by: { tcfVendor1, tcfVendor2 in
                    tcfVendor1.id < tcfVendor2.id })
                
                for purpose in purposesList {
                    print("\(String(describing: purpose.name).padding(toLength: 40, withPad: " ", startingAt: 0)) | Id: \(String(describing: purpose.id).padding(toLength: 10, withPad: " ", startingAt: 0)) | LI Toggle: \(String(describing: purpose.showLegitimateInterestToggle).padding(toLength: 10, withPad: " ", startingAt: 0)) | LI Value: \(String(describing: purpose.legitimateInterestConsent).padding(toLength: 10, withPad: " ", startingAt: 0))")
                }

                print("-- VENDORS WITH CONSENT TRUE--")
                var vendorsList = vendors.filter { tcfVendor in tcfVendor.consent == true }
                vendorsList = vendorsList.sorted(by: { tcfVendor1, tcfVendor2 in
                    tcfVendor1.id < tcfVendor2.id })

                for vendor in vendorsList {
                    print("\(String(describing: vendor.name).padding(toLength: 40, withPad: " ", startingAt: 0)) | Id: \(String(describing: vendor.id).padding(toLength: 7, withPad: " ", startingAt: 0))")
                }
                
                print("-- PURPOSES WITH LI TRUE--")
                var vendorsListLI = vendors.filter { tcfVendor in tcfVendor.legitimateInterestConsent == true }
                vendorsListLI = vendorsList.sorted(by: { tcfVendor1, tcfVendor2 in
                    tcfVendor1.id < tcfVendor2.id })

                for vendor in vendorsListLI {
                    print("\(String(describing: vendor.name).padding(toLength: 40, withPad: " ", startingAt: 0)) | Id: \(String(describing: vendor.id).padding(toLength: 7, withPad: " ", startingAt: 0))")
                    print("--\(vendor.name) LI Purposes --")
                    for vendor in vendor.legitimateInterestPurposes {
                        print("|$| \(String(describing: vendor.name).padding(toLength: 40, withPad: " ", startingAt: 0)) | Id: \(String(describing: vendor.id).padding(toLength: 7, withPad: " ", startingAt: 0)) |$|")
                    }
                }
            }

        } onFailure: { error in
            print("Error on initialization: \(error.localizedDescription)")
        }
    }
    
    private func getLayout(_ layout: String?) -> UsercentricsLayout {
        switch layout {
        case "sheet":
            return UsercentricsLayout.sheet
        case "bottom":
            return UsercentricsLayout.popup(position: PopupPosition.bottom)
        case "center":
            return UsercentricsLayout.popup(position: PopupPosition.center)
        default:
            return UsercentricsLayout.full
        }
        }
    
    /*
    private func presentBannerV1(viewController: UIViewController?) {
        guard let vc = viewController else {
            fatalError("Error! View Controller is nil.")
        }
        
        var usercentricsUI: UIViewController?
        
        let settings = self.getSettings(customFont: nil, customLogo: nil, showCloseButton: true)
        
        usercentricsUI = UsercentricsUserInterface.getPredefinedUI (settings: settings) { userResponse in
            // Apply Consent
            self.applyConsent(with: userResponse.consents)

            self.getTCData()

            // Dismiss CMP
            vc.dismiss(animated: true, completion: nil)
        }
        
        // Present CMP
        guard let ui = usercentricsUI else {
                fatalError("Error! Usercentrics UI is nil.")
        }
        vc.present(ui, animated: true, completion: nil)
    }
     */
    
    private func presentBannerV2(navigationController: UINavigationController?, layout: String?) {
        // Applies to First and Second Layer, and overwrites Admin Interface Styling Settings
        
        // Applies to First Layer, and overwrites General Settings
        let firstLayerSettings = FirstLayerStyleSettings(//logo: <LogoSettings?>,
                                                         //title: <TitleSettings?>,
                                                        //message: <MessageSettings?>,
                                                         //buttons: <[ButtonSettings]?>,
                                                         //backgroundColor: <UIColor?>,
                                                         //cornerRadius: <CGFloat?>,
                                                         //overlayColor: UIColor?
                                                        )
        let secondLayerSettings = SecondLayerStyleSettings(showCloseButton: true
                                                        )
        
        @available(iOS 13.0, *)
        let dynamicBackgroundColor = UIColor(dynamicProvider: { traits in
            switch UIScreen.main.traitCollection.userInterfaceStyle {
                case .dark:
                    return .orange
                default:
                    return UIColor.lightGray
                }
        })

        let dynamicBackgroundSecondaryColor = UIColor(dynamicProvider: { traits in
            switch UIScreen.main.traitCollection.userInterfaceStyle {
                case .dark:
                    return
                          .cyan
                default:
                      return .black
                }
        })


        let dynamicTextColor = UIColor(dynamicProvider: { traits in
            switch UIScreen.main.traitCollection.userInterfaceStyle {
                case .dark:
                      return .green
                default:
                    return .magenta
                }
        })

//
//        let generalStyleSettings = GeneralStyleSettings(font: nil,
//                                                        logo: UIImage(named: "logo"),
//                                                        links: .firstLayerOnly,
//                                                        textColor: dynamicTextColor,
//                                                        layerBackgroundColor: dynamicBackgroundColor,
//                                                        layerBackgroundSecondaryColor: dynamicBackgroundSecondaryColor,
//                                                        linkColor: UIColor.green,
//                                                        tabColor: UIColor.red,
//                                                        bordersColor: UIColor.darkGray,
//                                                        toggleStyleSettings: nil)
        
        let generalStyleSettings = GeneralStyleSettings(
            font: nil,
            logo: nil,
            links: .firstLayerOnly,
            textColor: dynamicTextColor,
            layerBackgroundColor: dynamicBackgroundColor,
            layerBackgroundSecondaryColor: dynamicBackgroundSecondaryColor,
            linkColor: UIColor.white,
            tabColor: UIColor.red,
            bordersColor: UIColor.green,
            toggleStyleSettings: ToggleStyleSettings(
                activeBackgroundColor: UIColor.cyan,
                inactiveBackgroundColor: UIColor.red,
                disabledBackgroundColor: UIColor.darkGray,
                activeThumbColor: UIColor.green,
                inactiveThumbColor: UIColor.magenta,
                disabledThumbColor: UIColor.blue
                )
            )
        
        let bannerSettings = BannerSettings(
            generalStyleSettings: GeneralStyleSettings(), //generalStyleSettings,
            firstLayerStyleSettings: firstLayerSettings,
            secondLayerStyleSettings: secondLayerSettings
        )
        
        
        //let firstLayerSettings = FirstLayerStyleSettings()
        //let bannerSettings = BannerSettings(firstLayerSettings: firstLayerSettings)
        //let banner = UsercentricsBanner(bannerSettings: bannerSettings)
        
        // Create a UsercentricsUserInterface instance
        let ui = UsercentricsBanner(bannerSettings: bannerSettings)

        guard let nav = navigationController else {
            fatalError("Error! Navigation Controller is nil.")
        }
            // Show First Layer and handle result
        ui.showFirstLayer(hostView: nav, layout: self.getLayout(layout)) { userResponse in
                    // Apply Consent
                    self.applyConsent(with: userResponse.consents)
                    // Track User Interaction with userResponse.userInteraction (Only if and until your tracking service has consent)
                    // Save controllerID in your own database with userResponse.controllerId (Needed for Cross-Device Consent Sharing)
            }
    }
}
