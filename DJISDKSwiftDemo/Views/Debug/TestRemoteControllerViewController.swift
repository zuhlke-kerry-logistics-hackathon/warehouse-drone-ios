//
//  TestRemoteControllerViewController.swift
//  DJI-Warehouse
//
//  Created by Pak Wai Lau on 18/2/2019.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJIWidget
import DJISDK


extension DJIFlightControllerDelegate{
    static func getIsReadyForPhoto(_ state: DJIFlightControllerState) ->Bool{
        let isReadyForPhoto = (abs(state.velocityX) < 0.1) && (abs(state.velocityY) < 0.1)  && (abs(state.velocityZ) < 0.1)
        return isReadyForPhoto
    }
}



class TestRemoteControllerViewController: IndoorFlyingViewController,DJIFlightControllerDelegate {
    override class func storyboardIdentifier() -> String {
        return "TestRemoteControllerViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let rc = DJIHelper.fetchAircraft()?.remoteController{
            rc.delegate = self
        }
        if let fc = DJIHelper.fetchFlightController(){
            fc.delegate = self
        }
        NotiLogger.log(message: "TestRemoteControllerViewController viewDidLoad", event: .info)
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var obstacleDistanceLabel: UILabel!
    
    @IBOutlet weak var velocityXLabel: UILabel!
    @IBOutlet weak var velocityYLabel: UILabel!
    @IBOutlet weak var velocityZLabel: UILabel!
    
    @IBOutlet weak var okLabel: UILabel!
    
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        self.velocityXLabel.text = "\(state.velocityX)"
        self.velocityYLabel.text = "\(state.velocityY)"
        self.velocityZLabel.text = "\(state.velocityZ)"
        
        let isOk = (abs(state.velocityX) < 0.1) && (abs(state.velocityY) < 0.1)  && (abs(state.velocityZ) < 0.1)
        self.okLabel.text = "\(isOk)"
    }
    
    
    func flightAssistant(_ assistant: DJIFlightAssistant, didUpdate state: DJIVisionDetectionState) {
        self.obstacleDistanceLabel.text = "\(state.obstacleDistanceInMeters)"
        NotiLogger.log(message: "state.isSensorBeingUsed: \(state.isSensorBeingUsed)", event: .info)
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

//extension TestRemoteControllerViewController: DJIRemoteControllerDelegate{
//    func remoteController(_ rc: DJIRemoteController, didUpdate state: DJIRCHardwareState) {
//        Logger.log(message: "DJIRCHardwareState didUpdate", event: .info)
//        if (state.shutterButton.isClicked.boolValue){
//            Logger.log(message: "Record button clicked", event: .info)
////            takeSnapshot()
//        }
//    }
//    func remoteController(_ rc: DJIRemoteController, didUpdate action: DJIRCButtonAction) {
//        Logger.log(message: "DJIRCButtonAction didUpdate", event: .info)
//    }
//}
