//
//  ViewController.swift
//  pomodoro
//
//  Created by Олег Стригунов on 08.01.2023.
//

import UIKit

class ViewController: UIViewController {
    
    enum timeZone: String {
        case work, rest
    }
    
    // Time
    let workingTime = 25.0
    let restTime = 10
    var timeProgress = 0.0
    var circularStages = 0.0
    
    // Timer
    var timer = Timer()
    var count = 25 // ?
    var isWorkTime = true
    var isStarted = true
    var nextTimeZone: timeZone = .rest
    var statusColor: UIColor = UIColor.red
    
    
    //MARK: - Outlets
    
    let dotLayer = CAShapeLayer()
    let dotLayerWhite = CAShapeLayer()
    
    private lazy var labelTime: UILabel = {
        let label = UILabel()
        label.text = "00 : 00"
        label.font = UIFont.systemFont(ofSize: 64, weight: .regular)
        label.textColor = UIColor.red
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonTimer: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(press), for: .touchUpInside)
        button.setTitle(" ", for: .normal)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = UIColor.red
        button.imageView?.layer.transform = CATransform3DMakeScale(2, 2, 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var mainLayer: UIView = {
        let mainView = UIView(frame: CGRect(x: (view.frame.width / 2) - 150, y: (view.frame.height / 2) - 150, width: 300, height: 300))
        mainView.transform = CGAffineTransform(rotationAngle:  -.pi / 2)
        return mainView
    }()
    
    private lazy var circleLayer: CAShapeLayer = {
        let circleFrame = mainLayer.frame.width
        let radius = circleFrame / 2
        let center = CGPoint(x: radius, y: radius)
        let startAngle = -CGFloat.pi
        let endAngle = CGFloat.pi
        
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: startAngle,
                                      endAngle: endAngle,
                                      clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        
        circleLayer.lineWidth = 4
        circleLayer.strokeEnd = 1 // здесь можно настроить заполняемость линии в круге 0.1 - 1.0
        circleLayer.fillColor = UIColor.clear.cgColor
        return circleLayer
    }()
    
    private lazy var stackInCircle: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.backgroundColor = .clear
        stack.spacing = 0
        stack.addArrangedSubview(labelTime)
        stack.addArrangedSubview(buttonTimer)
        stack.transform = CGAffineTransform(rotationAngle:  .pi / 2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        
        circularStages = 360 / workingTime
        drawProgress(progress: 0.0)
        
        if (isWorkTime) {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            
            print("Start")
        } else {
            print("Stop")
            
        }
    }
    
    
    //MARK: - Setup
    
    private func setupHierarchy() {
        view.backgroundColor = .white
        view.addSubview(mainLayer)
        mainLayer.layer.addSublayer(circleLayer)
        mainLayer.addSubview(stackInCircle)
    }
    
    private func setupLayout() {
        labelTime.widthAnchor.constraint(equalToConstant: 200).isActive = true
        labelTime.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
        buttonTimer.topAnchor.constraint(equalTo: labelTime.bottomAnchor, constant: 40).isActive = true
        buttonTimer.widthAnchor.constraint(equalToConstant: 40).isActive = true
        buttonTimer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        stackInCircle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        stackInCircle.heightAnchor.constraint(equalToConstant: 160).isActive = true
        stackInCircle.centerXAnchor.constraint(equalTo: mainLayer.centerXAnchor).isActive = true
        stackInCircle.centerYAnchor.constraint(equalTo: mainLayer.centerYAnchor).isActive = true
    }
    
    
    //MARK: - Actions
    
    private func drawProgress(progress: Double) {
        circleLayer.strokeColor = statusColor.cgColor
        
        let radius = mainLayer.frame.width / 2
        let center = CGPoint(x: radius, y: radius)
        let dotAngle = -(CGFloat.pi / 180) * progress
        let dotPoint = CGPoint(x: cos(dotAngle) * radius + center.x,
                               y: sin(-dotAngle) * radius + center.y)
        let dotPath = UIBezierPath()
        dotPath.move(to: dotPoint)
        dotPath.addLine(to: dotPoint)
        
        dotLayer.path = dotPath.cgPath
        dotLayer.strokeColor = statusColor.cgColor
        dotLayer.lineCap = .round
        dotLayer.lineWidth = 20
        
        dotLayerWhite.path = dotPath.cgPath
        dotLayerWhite.strokeColor = UIColor.white.cgColor
        dotLayerWhite.lineCap = .round
        dotLayerWhite.lineWidth = 15
        
        mainLayer.layer.addSublayer(dotLayer)
        dotLayer.addSublayer(dotLayerWhite)
    }
    
    @objc func runTimer() {
        if (isStarted) {
            if timeProgress > 360 - circularStages {
                dotLayer.removeFromSuperlayer()
                dotLayerWhite.removeFromSuperlayer()
                timeProgress = 0.0
                
                switch (nextTimeZone) {
                    case .work:
                        circularStages = Double(360 / workingTime)
                        count = Int(workingTime)
                        statusColor = UIColor.red
                        buttonTimer.tintColor = UIColor.red
                        labelTime.textColor = UIColor.red
                        nextTimeZone = .rest
                        
                    case .rest:
                        circularStages = Double(360 / restTime)
                        count = Int(restTime)
                        statusColor = UIColor.green
                        buttonTimer.tintColor = UIColor.green
                        labelTime.textColor = UIColor.green
                        nextTimeZone = .work
                }
            } else {
                count -= 1
            }
            
            let time = secondsToHoursMinuteSecond(seconds: count)
            makeTimeToString(minites: time.0, seconds: time.1)
            dotLayer.removeFromSuperlayer()
            dotLayerWhite.removeFromSuperlayer()
            timeProgress += circularStages
            drawProgress(progress: timeProgress)
        }
    }
    
    func secondsToHoursMinuteSecond(seconds: Int) -> (Int, Int) { // !
        return ((seconds % 3600)/60, seconds % 60 )
    }
    
    func makeTimeToString(minites: Int, seconds: Int) {
        var timeString = ""
        timeString += String(format: "%02d", minites)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        labelTime.text = timeString
    }
    
    @objc func press() {
        isStarted = !isStarted
        if (isStarted) {
            buttonTimer.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            buttonTimer.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
}
