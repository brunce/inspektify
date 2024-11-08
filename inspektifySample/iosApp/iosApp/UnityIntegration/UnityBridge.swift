import Foundation
import UnityFramework

protocol UnityBridgeObserver : AnyObject {
    func mapStarting();
    func mapReady(frameworkVersion: String)
    func mapAssetLoadingStarted()
    func mapAssetLoadingFinished()
    func mapGpsAvailabilityChanged(available: Bool)
    func mapEmptyAreaTapped()
    
    func cameraAnimationStarted()
    func cameraAnimationFinished()
    func cameraPositionChanged(position: Vector3, rotation: Vector3)
    func cameraTiltChanged(tilt3D: Bool)
    func cameraFollowGpsChanged(followingGps: Bool)
    func cameraFollowCompassChanged(followingCompass: Bool)
    
    func poiTapped(key: String)
    func poiPresentationChanged(key: String, title: String, type: String, presented: Bool)
    func interactionItemTapped(key: String)
}

enum UnityBridgeError: Error {
    case argumentFormat
}

final class UnityBridge {
    
    enum PoiGroup: Int {
        case none = 0
        case stores
        case parking
        case restaurants
        case service
        case chargingStation
        case hygiene
        case favorites
        case health
    }
    
    public static let sharedInstance = UnityBridge()
    
    private let nativeBridge = "NativeBridge"
    private let commandSeparator = "\t"
    private let partSeparator = ","

    public var observer: UnityBridgeObserver?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(mapStarting), name:NSNotification.Name("UnityMapStarting"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mapReady(_:)), name:NSNotification.Name("UnityMapReady"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mapAssetLoadingStarted), name:NSNotification.Name("UnityMapAssetLoadingStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mapAssetLoadingFinished), name:NSNotification.Name("UnityMapAssetLoadingFinished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mapGpsAvailabilityChanged(_:)), name:NSNotification.Name("UnityMapGpsAvailabilityChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mapEmptyAreaTapped(_:)), name:NSNotification.Name("UnityMapEmptyAreaTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraAnimationStarted), name:NSNotification.Name("UnityCameraAnimationStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraAnimationFinished), name:NSNotification.Name("UnityCameraAnimationFinished"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraPositionChanged(_:)), name:NSNotification.Name("UnityCameraPositionChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraTiltChanged(_:)), name:NSNotification.Name("UnityCameraTiltChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraFollowGpsChanged(_:)), name:NSNotification.Name("UnityCameraFollowGpsChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameraFollowCompassChanged(_:)), name:NSNotification.Name("UnityCameraFollowCompassChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(poiTapped(_:)), name:NSNotification.Name("UnityPoiTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(poiPresentationChanged(_:)), name:NSNotification.Name("UnityPoiPresentationChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(interactionItemTapped(_:)), name:NSNotification.Name("UnityInteractionItemTapped"), object: nil)
    }
    
    // MARK: Global state
    
    @objc
    func mapAssetImporterVersion() -> Int {
        return Int(1)
    }
    
    func mapBuildDate() -> Date {
        let infoString = String("2024-11-08")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from:infoString) else {
            print("Error: Could not determine build date. Expected a value of format 'yyyy-MM-dd' but found '" + infoString + "'")
            return Date.init()
        }
                
        return date
    }
    
    func mapSetLoggingLevel(level: Int) {
        UnityEmbeddedSwift.sendUnityMessage(nativeBridge, methodName: "MapSetLoggingLevel", message: String(level))
    }
    
    func mapSetFrameRate(min: Int, max: Int, delay: Float) {
        let command = commandFromParts(parts: String(min), String(max), String(delay))
        unityPostMessage(nativeBridge, methodName: "MapSetFrameRate", message: command)
    }
    
    func mapSetAntiAliasing(antialiasing: Int) {
        unityPostMessage(nativeBridge, methodName: "MapSetAntiAliasing", message: String(antialiasing))
    }
    
    func mapSetResolution(width: Int, height: Int) {
        let command = commandFromParts(parts: String(width), String(height))
        unityPostMessage(nativeBridge, methodName: "MapSetResolution", message: command)
    }
    
    func mapSetResolutionScale(scaleFactor: Float) {
        unityPostMessage(nativeBridge, methodName: "MapSetResolutionScale", message: String(scaleFactor))
    }

    func mapEnableDebugUI(enable: Bool) {
        unityPostMessage(nativeBridge, methodName: "MapEnableDebugUI", message: stringFromBool(value: enable))
    }
    
    func mapEnableProfileUI(enable: Bool) {
        unityPostMessage(nativeBridge, methodName: "MapEnableProfileUI", message: stringFromBool(value: enable))
    }
    
    func mapSetAssetPath(path: String) {
        unityPostMessage(nativeBridge, methodName: "MapSetAssetPath", message: path)
    }
        
    func mapLoadAssets() {
        unityPostMessage(nativeBridge, methodName: "MapLoadAssets", message: "")
    }
    
    func mapSetGpsPosition(latitude: Double, longitude: Double) {
        let command = partFromElements(elements: String(latitude), String(longitude))
        unityPostMessage(nativeBridge, methodName: "MapSetGpsPosition", message: command)
    }
    
    func mapSetCompassFilter(q: Float, r: Float) {
        let command = partFromElements(elements: String(q), String(r))
        unityPostMessage(nativeBridge, methodName: "MapSetCompassFilter", message: command)
    }
    
    @objc func mapStarting() {
        observer?.mapStarting()
    }
    
    @objc func mapReady(_ n: NSNotification) {
        let frameworkVersion = n.userInfo?["frameworkVersion"] as! String
        observer?.mapReady(frameworkVersion: frameworkVersion)
    }
    
    @objc func mapAssetLoadingStarted() {
        observer?.mapAssetLoadingStarted()
    }
    
    @objc func mapAssetLoadingFinished() {
        observer?.mapAssetLoadingFinished()
    }
    
    @objc func mapGpsAvailabilityChanged(_ n: NSNotification) {
        let available = n.userInfo?["available"] as! Bool
        observer?.mapGpsAvailabilityChanged(available: available)
    }
    
    @objc func mapEmptyAreaTapped(_ n: NSNotification) {
        observer?.mapEmptyAreaTapped()
    }
    
    // MARK: Camera
    
    func cameraSetFollowFactor(followFactor: Int) {
        unityPostMessage(nativeBridge, methodName: "CameraSetFollowFactor", message: String(followFactor))
    }
    
    func cameraSetScrollDamp(damp: Int) {
        unityPostMessage(nativeBridge, methodName: "CameraSetScrollDamp", message: String(damp))
    }
    
    func cameraShowPosition(show: Bool) {
        unityPostMessage(nativeBridge, methodName: "CameraShowPosition", message: stringFromBool(value: show))
    }
    
    func cameraSetPosition(position: Vector3, rotation: Vector3, animated: Bool) {
        let command = commandFromParts(parts: partFromElements(elements: position), partFromElements(elements: rotation), stringFromBool(value: animated))
        unityPostMessage(nativeBridge, methodName: "CameraSetPosition", message: command)
    }
    
    func cameraResetPosition(animated: Bool) {
        unityPostMessage(nativeBridge, methodName: "CameraResetPosition", message: stringFromBool(value: animated))
    }
    
    func cameraOffsetVertical(offset: Int) {
        let command = commandFromParts(parts: String(offset))
        unityPostMessage(nativeBridge, methodName: "CameraOffsetVertical", message: command)
    }
    
    func cameraLookAt(keys: [String], zoomIn: Bool, animated: Bool) {
        let command = commandFromParts(parts: partFromElements(elements: keys), stringFromBool(value: zoomIn), stringFromBool(value: animated))
        unityPostMessage(nativeBridge, methodName: "CameraLookAt", message: command)
    }
    
    func cameraLookAtGroup(group: PoiGroup, zoomIn: Bool, animated: Bool) {
        let command = commandFromParts(parts: String(describing: group.rawValue), stringFromBool(value: zoomIn), stringFromBool(value: animated))
        unityPostMessage(nativeBridge, methodName: "CameraLookAtGroup", message: command)
    }
    
    func cameraFocusAt(key: String, animated: Bool) {
        let command = commandFromParts(parts: key, stringFromBool(value: animated))
        unityPostMessage(nativeBridge, methodName: "CameraFocusAt", message: command)
    }
    
    func cameraSetHeading(heading: Float, animated: Bool) {
        let command = commandFromParts(parts: String(heading), stringFromBool(value: animated))
        unityPostMessage(nativeBridge, methodName: "CameraSetHeading", message: command)
    }
    
    func cameraTilt(tilt3D: Bool, animated: Bool) {
        let command = commandFromParts(parts: stringFromBool(value: tilt3D), stringFromBool(value: animated))
        unityPostMessage(nativeBridge, methodName: "CameraTilt", message: command)
    }
    
    func cameraFollowGps(followGps: Bool) {
        unityPostMessage(nativeBridge, methodName: "CameraFollowGps", message: stringFromBool(value: followGps))
    }
    
    func cameraFollowCompass(followCompass: Bool) {
        unityPostMessage(nativeBridge, methodName: "CameraFollowCompass", message: stringFromBool(value: followCompass))
    }
    
    @objc func cameraAnimationStarted() {
        observer?.cameraAnimationStarted()
    }
    
    @objc func cameraAnimationFinished() {
        observer?.cameraAnimationFinished()
    }
    
    @objc func cameraPositionChanged(_ n: NSNotification) {
        let command = n.userInfo?["cameraPosition"] as! String
        
        do {
            let parts = try self.partsFromCommand(command: command, expectedLength: 2)
            
            let positionParts = try self.elementsFromPart(part: parts[0], expectedLength: 3).map { (Float($0.trimmingCharacters(in: .whitespaces))! ) }
            let position = Vector3(x: positionParts[0], y: positionParts[1], z: positionParts[2])
            
            let rotationParts = try self.elementsFromPart(part: parts[1], expectedLength: 3).map { (Float($0.trimmingCharacters(in: .whitespaces))! ) }
            let rotation = Vector3(x: rotationParts[0], y: rotationParts[1], z: rotationParts[2])
            
            observer?.cameraPositionChanged(position: position, rotation: rotation)
        } catch  {
            print("Invalid format.")
        }
    }
    
    @objc func cameraTiltChanged(_ n: NSNotification) {
        let tilt3D = n.userInfo?["tilt3D"] as! Bool
        observer?.cameraTiltChanged(tilt3D: tilt3D)
    }
    
    @objc func cameraFollowGpsChanged(_ n: NSNotification) {
        let followGps = n.userInfo?["followingGps"] as! Bool
        observer?.cameraFollowGpsChanged(followingGps: followGps)
    }
    
    @objc func cameraFollowCompassChanged(_ n: NSNotification) {
        let followCompass = n.userInfo?["followingCompass"] as! Bool
        observer?.cameraFollowCompassChanged(followingCompass: followCompass)
    }
    
    // MARK: Poi
    
    func poiSetData(json: String) {
        unityPostMessage(nativeBridge, methodName: "PoiSetData", message: json)
    }
    
    func poiClearData() {
        unityPostMessage(nativeBridge, methodName: "PoiClearData", message: "")
    }
    
    func poiSetActive(keys: [String]) {
        let command = partFromElements(elements: keys)
        unityPostMessage(nativeBridge, methodName: "PoiSetActive", message: command)
    }
    
    func poiSetHighlight(keys: [String]) {
        let command = partFromElements(elements: keys)
        unityPostMessage(nativeBridge, methodName: "PoiSetHighlight", message: command)
    }
    
    @objc func poiTapped(_ n: NSNotification) {
        let key = n.userInfo?["key"] as! String
        observer?.poiTapped(key: key)
    }
    
    @objc func poiPresentationChanged(_ n: NSNotification) {
        let key = n.userInfo?["key"] as! String
        let title = n.userInfo?["title"] as! String
        let type = n.userInfo?["type"] as! String
        let presented = n.userInfo?["presented"] as! Bool
        observer?.poiPresentationChanged(key: key, title: title, type: type, presented: presented)
    }
    
    // MARK: Dynamic events
        
    @objc func interactionItemTapped(_ n: NSNotification) {
        let key = n.userInfo?["key"] as! String
        observer?.interactionItemTapped(key: key)
    }
    
    // MARK: Helper
    
    private func unityPostMessage(_ gameObject: String, methodName: String, message: String) {
        UnityEmbeddedSwift.sendUnityMessage(gameObject, methodName: methodName, message: message)
    }
    
    private func stringFromBool(value: Bool) -> String {
        return value ? "true" : "false";
    }
    
    private func commandFromParts(parts: String...) -> String {
        return parts.joined(separator: commandSeparator)
    }
    
    private func partsFromCommand(command: String, expectedLength: Int) throws -> [String] {
        let parts = command.components(separatedBy: commandSeparator)
    
        guard parts.count == expectedLength else {
            throw UnityBridgeError.argumentFormat
        }
        
        return parts;
    }
    
    private func partFromElements(elements: [Int]) -> String {
        let stringArray: [String] = elements.map { String($0) }
        return partFromElements(elements: stringArray);
    }
    
    private func partFromElements(elements: Int...) -> String {
        return partFromElements(elements: elements);
    }
    
    private func partFromElements(elements: String...) -> String {
        return partFromElements(elements: elements)
    }
    
    private func partFromElements(elements: Vector3) -> String {
        let stringArray: [String] = [String(Float(elements.x)), String(Float(elements.y)), String(Float(elements.z))]
        return partFromElements(elements: stringArray)
    }
    
    private func partFromElements(elements: [String]) -> String {
        return elements.joined(separator: partSeparator)
    }
    
    private func elementsFromPart(part: String, expectedLength: Int) throws -> [String]
    {
        let elements = part.components(separatedBy: partSeparator)
    
        guard elements.count == expectedLength else {
            throw UnityBridgeError.argumentFormat
        }
    
        return elements;
    }
}
