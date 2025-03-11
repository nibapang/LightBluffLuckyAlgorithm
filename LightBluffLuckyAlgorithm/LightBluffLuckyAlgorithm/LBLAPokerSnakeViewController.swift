//
//  PokerSnakeViewController.swift
//  LightBluffLuckyAlgorithm
//
//  Created by jin fu on 2025/3/11.
//


import UIKit

class LBLAPokerSnakeViewController: UIViewController {
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var snake: [UIView] = []
    var pokerItems: [UIView: LBLAPokerItem] = [:]
    var obstacles: [UIView] = []
    
    var direction: LBLADirection = .right
    var snakeSize: CGFloat = 30.0
    var gameTimer: Timer?
    var score: Int = 0
    var speed: TimeInterval = 0.3
    
    let maxPokerItems = 8 // Maximum number of poker items on the screen at a time
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeGestures()
        DispatchQueue.main.async {
            self.showHowToPlayAlert()
        }
    }
    
    // MARK: - Game Setup
    
    func setupGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        for subview in gameView.subviews {
            subview.removeFromSuperview()
        }
        
        snake.removeAll()
        pokerItems.removeAll()
        obstacles.removeAll()
        
        direction = .right
        score = 0
        speed = 0.3
        updateScoreLabel()
        
        setupInitialSnake()
        spawnMultiplePokerItems()
        spawnObstacle()
        
        gameTimer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(moveSnake), userInfo: nil, repeats: true)
    }
    
    func showHowToPlayAlert() {
        let alert = UIAlertController(title: "How to Play", message: """
         Swipe in any direction to move the snake.
         Eat black poker items (+10 points).
         Avoid red poker items (-10 points).
         Avoid obstacles and walls.
         The snake grows with positive items and shrinks with negative items.
         Try to score as high as possible!
        """, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Start Game", style: .default, handler: { _ in
            self.setupGame()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func setupInitialSnake() {
        let startX = gameView.bounds.midX
        let startY = gameView.bounds.midY
        
        for i in 0..<2 {
            let segmentFrame = CGRect(x: startX - CGFloat(i) * snakeSize,
                                      y: startY,
                                      width: snakeSize,
                                      height: snakeSize)
            let segment = createSnakeSegment(at: segmentFrame)
            gameView.addSubview(segment)
            snake.append(segment)
        }
    }
    
    // MARK: - Create Snake Segment with Gradient or Texture
    
    func createSnakeSegment(at frame: CGRect) -> UIView {
        let segment = UIView(frame: frame)
        segment.layer.cornerRadius = 5
        segment.layer.masksToBounds = true
        
        // Add a snake skin texture using an image
        let textureImage = UIImage(named: "snake_texture")
        let textureView = UIImageView(frame: segment.bounds)
        textureView.image = textureImage
        textureView.contentMode = .scaleAspectFill
        textureView.layer.cornerRadius = 5
        textureView.clipsToBounds = true
        
        segment.addSubview(textureView)
        
        return segment
    }
    
    func spawnMultiplePokerItems() {
        let numberOfItems = Int.random(in: 3...5)
        
        for _ in 0..<numberOfItems {
            if pokerItems.count >= maxPokerItems { return }
            spawnPokerItem()
        }
    }
    
    func spawnPokerItem() {
        let pokerItem = LBLAPokerItem.random()
        var itemFrame: CGRect
        
        repeat {
            itemFrame = CGRect(x: CGFloat.random(in: 0...(gameView.bounds.width - snakeSize)),
                               y: CGFloat.random(in: 0...(gameView.bounds.height - snakeSize)),
                               width: snakeSize,
                               height: snakeSize)
        } while checkCollisionWithExistingItems(frame: itemFrame)
        
        let itemView = UIImageView(frame: itemFrame)
        itemView.image = pokerItem.image
        itemView.contentMode = .scaleAspectFit
        gameView.addSubview(itemView)
        
        pokerItems[itemView] = pokerItem
    }
    
    func spawnObstacle() {
        var obstacleFrame: CGRect
        
        repeat {
            obstacleFrame = CGRect(x: CGFloat.random(in: 0...(gameView.bounds.width - snakeSize)),
                                   y: CGFloat.random(in: 0...(gameView.bounds.height - snakeSize)),
                                   width: snakeSize,
                                   height: snakeSize)
        } while checkCollisionWithExistingItems(frame: obstacleFrame)
        
        let obstacle = UIImageView(frame: obstacleFrame)
        obstacle.image = UIImage(named: "obstacle")
        obstacle.contentMode = .scaleAspectFit
        gameView.addSubview(obstacle)
        obstacles.append(obstacle)
    }
    
    func checkCollisionWithExistingItems(frame: CGRect) -> Bool {
        return snake.contains(where: { $0.frame.intersects(frame) }) ||
               pokerItems.keys.contains(where: { $0.frame.intersects(frame) }) ||
               obstacles.contains(where: { $0.frame.intersects(frame) })
    }
    
    
    
    // MARK: - Game Logic
    
    @objc func moveSnake() {
        guard let head = snake.first else { return }
        
        var newHeadFrame = head.frame
        
        switch direction {
        case .up:
            newHeadFrame.origin.y -= snakeSize
        case .down:
            newHeadFrame.origin.y += snakeSize
        case .left:
            newHeadFrame.origin.x -= snakeSize
        case .right:
            newHeadFrame.origin.x += snakeSize
        }
        
        if !gameView.bounds.contains(newHeadFrame) ||
            snake.dropFirst().contains(where: { $0.frame == newHeadFrame }) ||
            obstacles.contains(where: { $0.frame.intersects(newHeadFrame) }) {
            gameOver()
            return
        }
        
        let newHead = createSnakeSegment(at: newHeadFrame)
        gameView.addSubview(newHead)
        snake.insert(newHead, at: 0)
        
        for (itemView, pokerItem) in pokerItems {
            if itemView.frame.intersects(newHead.frame) {
                score += pokerItem.isRed ? -10 : 10
                score = max(score, 0) // Prevent negative score
                
                itemView.removeFromSuperview()
                pokerItems.removeValue(forKey: itemView)
                
                if pokerItem.isRed && snake.count > 1 {
                    // Shrink the snake if red item (negative score)
                    snake.last?.removeFromSuperview()
                    snake.removeLast()
                } else if !pokerItem.isRed {
                    // Grow the snake if black item (positive score)
                    let extraSegment = createSnakeSegment(at: snake.last!.frame)
                    gameView.addSubview(extraSegment)
                    snake.append(extraSegment)
                }
                
                spawnMultiplePokerItems()
                spawnObstacle()
                updateScoreLabel()
                
                speed = max(0.1, speed - 0.01)
                gameTimer?.invalidate()
                gameTimer = Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(moveSnake), userInfo: nil, repeats: true)
                
                return
            }
        }
        
        let tail = snake.removeLast()
        tail.removeFromSuperview()
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    func gameOver() {
        gameTimer?.invalidate()
        
        let alert = UIAlertController(title: "Game Over", message: "Your score: \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.setupGame()
        }))
        alert.addAction(UIAlertAction(title: "Main Menu", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Swipe Gestures

    func setupSwipeGestures() {
        let swipeDirections: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]
        
        for direction in swipeDirections {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
        }
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            if direction != .down { direction = .up }
        case .down:
            if direction != .up { direction = .down }
        case .left:
            if direction != .right { direction = .left }
        case .right:
            if direction != .left { direction = .right }
        default:
            break
        }
    }
    
    @IBAction func back(_ sender :UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
}
