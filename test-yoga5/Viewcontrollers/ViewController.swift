//
//  RoutineScreenViewController.swift
//  test-yoga5
//
//  Created by user@22 on 04/11/24.
//

import UIKit

import UIKit

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var progressPlaceholderView: UIView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var inProgressLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var lifeExpectancyLabel: UILabel!
    
    @IBOutlet weak var extendedLifeLabel: UILabel!
    
    @IBOutlet weak var recentPosesCollectionView: UICollectionView!
    
  
  
    
    
    
   
   /* override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSizeZero
        }
        collectionView.dataSource = self
        collectionView.delegate = self
    }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: 75)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wordCell", for: indexPath)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 10
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 1, height: 2.0)
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowRadius = 2.0
        cell.layer.masksToBounds = false
        if let wordCell = cell as? WordCollectionViewCell {
            wordCell.wordLabel.text = String(words[indexPath.row])
        }
        
        return cell
    }
    
    var progressData = ProgressDataModel(completed: 6, inProgress: 2, remaining: 1, totalTime: 22, completedTime: 18)
    
    var poses: [Pose] = [
            Pose(name: "Downward Dog", imageName: "downward_dog"),
            Pose(name: "Warrior II", imageName: "warrior_ii"),
            Pose(name: "Tree Pose", imageName: "tree_pose"),
            Pose(name: "Bridge Pose", imageName: "bridge_pose"),
            // Add more poses as needed
        ]
        

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display the data in the UI
        updateUI(with: progressData)
        
        // Creating circular progress indicators based on completion percentages
        createCircularProgress(view: progressPlaceholderView, radius: 67, lineWidth: 12, progress: progressData.completionPercentage, duration: 1.5, color: .systemPink, backgroundColor: UIColor.systemPink.withAlphaComponent(0.2)) // Task completion progress
        createCircularProgress(view: progressPlaceholderView, radius: 52, lineWidth: 12, progress: progressData.completionPercentage, duration: 1.5, color: .systemTeal, backgroundColor: UIColor.systemTeal.withAlphaComponent(0.2))
        
        createCircularProgress(view: progressPlaceholderView, radius: 37, lineWidth: 12, progress: progressData.timeCompletionPercentage, duration: 1.5, color: .systemYellow, backgroundColor: UIColor.systemYellow.withAlphaComponent(0.2)) // Time completion progress
        
        /*createCircularProgress(view: progressPlaceholderView, radius: 22, lineWidth: 12, progress: progressData.timeCompletionPercentage, duration: 1.5, color: .systemGreen, backgroundColor: UIColor.systemGreen.withAlphaComponent(0.2))*/
        
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSizeZero
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        
    }

    func updateUI(with data: ProgressDataModel) {
        // Set each label's text with bold styling for dynamic parts
        completedLabel.attributedText = createBoldAttributedText(labelText: "Completed: ", valueText: "\(data.completed)")
        inProgressLabel.attributedText = createBoldAttributedText(labelText: "In Progress: ", valueText: "\(data.inProgress)")
        remainingLabel.attributedText = createBoldAttributedText(labelText: "Remaining: ", valueText: "\(data.remaining)")
        timeLabel.attributedText = createBoldAttributedText(labelText: "Time: ", valueText: "\(data.completedTime)/\(data.totalTime) min")
        // Update life expectancy messages
            lifeExpectancyLabel.text = data.lifeExpectancy.lifeExpectancyMessage
            extendedLifeLabel.text = data.lifeExpectancy.extendedLifeMessage
    }

    func createBoldAttributedText(labelText: String, valueText: String) -> NSAttributedString {
        // Define the regular and bold fonts
        let regularFont = UIFont.systemFont(ofSize: 16)
        let boldFont = UIFont.boldSystemFont(ofSize: 16)
        
        // Regular part of the label
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: regularFont,
            .foregroundColor: UIColor.label // System default text color
        ]
        let regularAttributedString = NSMutableAttributedString(string: labelText, attributes: regularAttributes)
        
        // Bold part of the label
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.label
        ]
        let boldAttributedString = NSAttributedString(string: valueText, attributes: boldAttributes)
        
        // Combine the regular and bold parts
        regularAttributedString.append(boldAttributedString)
        return regularAttributedString
    }

    
    func createCircularProgress(view: UIView, radius: CGFloat, lineWidth: CGFloat, progress: CGFloat, duration: CFTimeInterval, color: UIColor, backgroundColor: UIColor) {
        // Define the circle path based on the center and radius
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: view.bounds.midX, y: view.bounds.midY),
            radius: radius,
            startAngle: -CGFloat.pi / 2,    // Start at the top center
            endAngle: (2 * CGFloat.pi) - (CGFloat.pi / 2), // Complete circle
            clockwise: true
        )
        
        // Create a background layer for the full circle (uncompleted portion)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.strokeColor = backgroundColor.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.strokeEnd = 1.0  // Full circle for the background
        backgroundLayer.lineCap = .round  // Rounded corners for background layer
        
        // Add the background layer behind the progress layer
        view.layer.addSublayer(backgroundLayer)

        // Create the progress layer for the actual progress indicator
        let progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = color.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0  // Start with no progress
        progressLayer.lineCap = .round  // Rounded corners for progress layer
        
        // Add the progress layer to the provided view's layer
        view.layer.addSublayer(progressLayer)
        
        // Set up the animation for the progress
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = progress
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
    }


}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


