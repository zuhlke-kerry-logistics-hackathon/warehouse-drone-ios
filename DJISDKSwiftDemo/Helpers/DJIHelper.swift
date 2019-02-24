//
//  DJIHelper.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 29/1/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import Foundation
import DJISDK

final class DJIHelper {
    
    static func setVirtualStickMode(to:Bool, vc: UIViewController) {
        DJIHelper.fetchFlightController()?.setVirtualStickModeEnabled(to){(error) in
            if let error = error {
                NotiLogger.log(message: error.localizedDescription, event: .error)
            }else {
                NotiLogger.log(message: "virtual stick mode set to \(to)", event: .error)
            }
        }
    }
    
    static func fetchProduct() -> DJIBaseProduct? {
        return DJISDKManager.product()
    }
    
    static func fetchAircraft() -> DJIAircraft? {
        return fetchProduct() as? DJIAircraft
    }
    
    static func fetchFlightController() -> DJIFlightController? {
        if let fc = fetchAircraft()?.flightController {
            return fc
        }else{
            Logger.log(message: "No FC", event: .debug)
            return nil
        }
    }
    
    static func showAlertView(vc: UIViewController, title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
    static func fetchCompass() -> DJICompass? {
        return fetchFlightController()?.compass
    }
    
    static func getHeading() -> Double? {
        return fetchFlightController()?.compass?.heading
    }
    
}

