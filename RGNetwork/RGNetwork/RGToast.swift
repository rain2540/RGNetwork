//
//  RGToast.swift
//  RGNetwork
//
//  Created by Rain on 2017/4/21.
//  Copyright © 2017年 Smartech. All rights reserved.
//

import UIKit

//  MARK: RGToast
class RGToast: NSObject {
    static public let shared = RGToast()
    
    private var alerts: Array<[CanBeToast]> = []
    private var active = false
    private var alertView: RGToastView?
    private var alertFrame = UIScreen.main.bounds
    
    //  MARK: Lifecycle
     override private init () {
        super.init()
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(RGToast.keyboardWillAppear(notification:)),
                         name: NSNotification.Name.UIKeyboardWillShow,
                         object: nil)
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(RGToast.keyboardWillDisappear(notification:)),
                         name: NSNotification.Name.UIKeyboardDidHide,
                         object: nil)
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(RGToast.orientationWillChange(notification:)),
                         name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation,
                         object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //  MARK: Show Toast Message
    private func showToast() {
        if alerts.count < 1 {
            active = false
            return
        }
        
        active = true
        alertView = RGToastView()
        let ar = alerts[0]
        
        var img: UIImage? = nil
        if ar.count > 1 {
            img = alerts[0][1] as? UIImage
            alertView?.image = img
        }
        
        if ar.count > 0 {
            alertView?.messageText = alerts[0][0] as? String
        }
        alertView?.transform = CGAffineTransform.identity
        alertView?.alpha = 0.0
        UIApplication.shared.keyWindow?.addSubview(alertView!)
        
        alertView?.center = CGPoint(x: alertFrame.midX, y: alertFrame.midY)
        
        var rr = alertView?.frame
        rr?.origin.x = (rr?.origin.x)!
        rr?.origin.y = (rr?.origin.y)!
        alertView?.frame = rr!
        
        let o = UIApplication.shared.statusBarOrientation
        let degress = rotationDegress(orientation: o)
        alertView?.transform = CGAffineTransform(rotationAngle: degress * .pi / 180.0)
        alertView?.transform.scaledBy(x: 2.0, y: 2.0)
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.15)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(RGToast.animationStep2))
        alertView?.transform = CGAffineTransform(rotationAngle: degress * .pi / 180.0)
        alertView?.frame = (alertView?.frame.integral)!
        alertView?.alpha = 1.0
        UIView.commitAnimations()
    }
    
    @objc private func animationStep2() {
        UIView.beginAnimations(nil, context: nil)
        let words = (alerts[0][0] as! String).components(separatedBy: CharacterSet.whitespaces)
        let duration = max(Double(words.count) * 60.0 / 200.0, 1.4)
        
        UIView.setAnimationDelay(duration)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(RGToast.animationStep3))
        
        let o = UIApplication.shared.statusBarOrientation
        let degress = rotationDegress(orientation: o)
        alertView?.transform = CGAffineTransform(rotationAngle: degress * .pi / 180.0)
        alertView?.transform.scaledBy(x: 0.5, y: 0.5)
        alertView?.alpha = 0.0
        UIView.commitAnimations()
    }
    
    @objc private func animationStep3() {
        alertView?.removeFromSuperview()
        alerts.remove(at: 0)
        showToast()
    }
    
    func toast(message: String?, image: UIImage? = nil) {
        if message != nil && image != nil  {
            alerts.append([message!, image!])
        } else if message != nil {
            alerts.append([message!])
        } else if image != nil {
            alerts.append([image!])
        }
        if !active {
            showToast()
        }
    }
    
    //  MARK: System Observation Changes
    private func subtractRect(wf: CGRect, kf: CGRect) -> CGRect {
        var vkf = kf
        if CGPoint.zero != vkf.origin {
            if vkf.origin.x > 0 {
                vkf.size.width = kf.origin.x
            }
            if vkf.origin.y > 0 {
                vkf.size.height = kf.origin.y
            }
            vkf.origin = CGPoint.zero
        } else {
            vkf.origin.x = fabs(kf.size.width - wf.size.width)
            vkf.origin.y = fabs(kf.size.height - wf.size.height)
            
            if vkf.origin.x > 0 {
                let temp = vkf.origin.x
                vkf.origin.x = vkf.size.width
                vkf.size.width = temp
            } else if vkf.origin.y > 0 {
                let temp = vkf.origin.y
                vkf.origin.y = vkf.size.height
                vkf.size.height = temp
            }
        }
        return wf.intersection(vkf)
    }
    
    //  MARK: Target - Action
    @objc private func keyboardWillAppear(notification: Notification) {
        let userInfo = notification.userInfo
        let aValue = userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let kf = aValue.cgRectValue
        let wf = UIScreen.main.bounds
        
        UIView.beginAnimations(nil, context: nil)
        alertFrame = subtractRect(wf: wf, kf: kf)
        alertView?.center = CGPoint(x: alertFrame.midX, y: alertFrame.midY)
        UIView.commitAnimations()
    }
    
    @objc private func keyboardWillDisappear(notification: Notification) {
        alertFrame = UIScreen.main.bounds
    }
    
    @objc private func orientationWillChange(notification: Notification) {
        let userInfo = notification.userInfo
        let v = userInfo?[UIApplicationStatusBarOrientationUserInfoKey] as! NSNumber
        let o = UIInterfaceOrientation(rawValue: v.intValue)
        
        let degress = rotationDegress(orientation: o!)
        
        UIView.beginAnimations(nil, context: nil)
        alertView?.transform = CGAffineTransform(rotationAngle: degress * .pi / 180.0)
        alertView?.frame = CGRect(x: (alertView?.frame.minX)!, y: (alertView?.frame.minY)!, width: (alertView?.frame.width)!, height: (alertView?.frame.height)!)
        UIView.commitAnimations()
    }
    
    //  MARK: Callback
    private func rotationDegress(orientation: UIInterfaceOrientation) -> CGFloat {
        var degress: CGFloat = 0.0
        if orientation == .landscapeLeft {
            degress = -90.0
        } else if orientation == .landscapeRight {
            degress = 90.0
        } else if orientation == .portraitUpsideDown {
            degress = 180.0
        }
        return degress
    }
}

//  MARK: RGToastView
fileprivate class RGToastView: UIView {
    private var messageRect: CGRect?
    private var _image: UIImage?
    private var _messageText: String?
    fileprivate var image: UIImage? {
        get {
            return _image
        }
        set {
            _image = newValue
            adjust()
        }
    }
    fileprivate var messageText: String? {
        get {
            return _messageText
        }
        set {
            _messageText = newValue
            adjust()
        }
    }

    fileprivate init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        self.messageRect = bounds.insetBy(dx: 10.0, dy: 10.0)
        self.backgroundColor = UIColor.clear
        self.messageText = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func drawRoundRectangle(in rect: CGRect, radius: CGFloat) {
        let context = UIGraphicsGetCurrentContext()
        let rRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
        let minX = rRect.minX, midX = rRect.midX, maxX = rRect.maxX
        let minY = rRect.minY, midY = rRect.midY, maxY = rRect.maxY
        context?.move(to: CGPoint(x: minX, y: midY))
        context?.addArc(tangent1End: CGPoint(x: minX, y: minY),
                        tangent2End: CGPoint(x: midX, y: minY),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint(x: maxX, y: minY),
                        tangent2End: CGPoint(x: maxX, y: midY),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint(x: maxX, y: maxY),
                        tangent2End: CGPoint(x: midX, y: maxY),
                        radius: radius)
        context?.addArc(tangent1End: CGPoint(x: minX, y: maxY),
                        tangent2End: CGPoint(x: minX, y: midY),
                        radius: radius)
        context?.closePath()
        context?.drawPath(using: .fill)
    }

    override func draw(_ rect: CGRect) {
        UIColor(white: 0.0, alpha: 0.8).set()
        drawRoundRectangle(in: rect, radius: 10.0)
        UIColor.white.set()

        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy()
        (paragraphStyle as! NSMutableParagraphStyle).lineBreakMode = .byWordWrapping
        (paragraphStyle as! NSMutableParagraphStyle).alignment = .center
        let dict = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0),
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSForegroundColorAttributeName: UIColor.white]
        (messageText! as NSString).draw(in: messageRect!, withAttributes: dict)

        if let image = image {
            var r = CGRect.zero
            r.origin.y = 15.0
            r.origin.x = (rect.width - image.size.width) / 2.0
            r.size = image.size
            image.draw(in: r)
        }
    }

    //  MARK: Setter Methods
    private func adjust() {
        let s = messageText?.boundingRect(with: CGSize(width: 160.0, height: 200.0),
                                          options: [.usesLineFragmentOrigin],
                                          attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0)],
                                          context: nil).size
        messageText?.size(attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0)])
        var imageAdjustment: CGFloat = 0.0
        if image != nil {
            imageAdjustment = 7.0 + (image?.size.height)!
        }
        bounds = CGRect(x: 0.0, y: 0.0, width: (s?.width)! + 40.0, height: (s?.height)! + 15.0 + 15.0 + imageAdjustment)
        messageRect?.size = s!
        messageRect?.size.height += 5
        messageRect?.origin.x = 20.0
        messageRect?.origin.y = 15.0 + imageAdjustment

        setNeedsLayout()
        setNeedsDisplay()
    }
}

protocol CanBeToast { }
extension UIImage: CanBeToast { }
extension String: CanBeToast { }
