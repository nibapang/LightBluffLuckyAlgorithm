//
//  GameViewController.swift
//  LightBluffLuckyAlgorithm
//
//  Created by jin fu on 2025/3/11.
//


import UIKit

class LBLAGameViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var revealButton: UIButton!
    @IBOutlet weak var doubleButton: UIButton!    // Predict double
    @IBOutlet weak var notDoubleButton: UIButton! // Predict not double
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    @IBOutlet weak var player1CardImageView: UIImageView!
    @IBOutlet weak var player2CardImageView: UIImageView!
    
    // MARK: - Game Variables
    private var deck: [Int] = []
    private var currentDeclaration: String = "Double"
    private var player1Score = 0
    private var player2Score = 0
    private var isPlayer1Turn = true
    private var streakCount = 0 // For bonus points
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()
        showHowToPlayAlert()
    }
    
    // MARK: - Actions
    @IBAction func selectDouble(_ sender: UIButton) {
        currentDeclaration = "Double"
        updateTurnStatus()
        revealButton.isEnabled = true
    }
    
    @IBAction func selectNotDouble(_ sender: UIButton) {
        currentDeclaration = "Not Double"
        updateTurnStatus()
        revealButton.isEnabled = true
    }
    
    @IBAction func revealCards(_ sender: UIButton) {
        guard deck.count >= 2 else {
            showEndGameAlert()
            return
        }
        
        let card1 = deck.removeFirst()
        let card2 = deck.removeFirst()
        
        // Check if second card is double the first
        let isDouble = (card2 == card1 * 2)
        let predictedDouble = (currentDeclaration == "Double")
        
        flipCardImage(player1CardImageView, toImageNamed: "\(card1).png")
        flipCardImage(player2CardImageView, toImageNamed: "\(card2).png")
        
        // Calculate points with streak bonus
        let basePoints = 2
        let streakBonus = min(streakCount, 3) // Max 3 point bonus
        let totalPoints = basePoints + streakBonus
        
        // Score the round
        if (isDouble && predictedDouble) || (!isDouble && !predictedDouble) {
            // Correct prediction
            streakCount += 1
            if isPlayer1Turn {
                player1Score += totalPoints
                statusLabel.text = "Player 1: Correct! +\(totalPoints))"
            } else {
                player2Score += totalPoints
                statusLabel.text = "Player 2: Correct! +\(totalPoints))"
            }
        } else {
            // Wrong prediction
            streakCount = 0
            if isPlayer1Turn {
                player2Score += 1
                statusLabel.text = "Wrong! Player 2 gets 1 point"
            } else {
                player1Score += 1
                statusLabel.text = "Wrong! Player 1 gets 1 point"
            }
        }
        
        // Show card values
        let resultText = "\(card1) → \(card2): " + (isDouble ? "Double!" : "Not Double")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.statusLabel.text = self.statusLabel.text! + "\n" + resultText
        }
        
        updateScores()
        isPlayer1Turn.toggle()
        revealButton.isEnabled = false
        
        if deck.count < 2 {
            showEndGameAlert()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.resetCardsToBack()
                self.updateTurnStatus()
            }
        }
    }
    
    // MARK: - Game Setup
    private func startNewGame() {
        // Initialize deck (1-10, Jack=11, Queen=12, King=13)
        deck = []
        for _ in 1...4 { // 4 suits
            for value in 1...13 {
                deck.append(value)
            }
        }
        deck.shuffle()
        
        player1Score = 0
        player2Score = 0
        isPlayer1Turn = true
        streakCount = 0
        
        statusLabel.text = "Player 1: Make Your Prediction"
        updateScores()
        resetCardsToBack()
        revealButton.isEnabled = false
    }
    
    private func updateScores() {
        player1ScoreLabel.text = " \(player1Score)"
        player2ScoreLabel.text = " \(player2Score)"
    }
    
    private func updateTurnStatus() {
        let currentPlayer = isPlayer1Turn ? "Player 1" : "Player 2"
        statusLabel.text = "\(currentPlayer)'s Turn \(streakCount)"
    }
    
    // MARK: - Show Alert at Game End
    private func showEndGameAlert() {
        let winner: String
        if player1Score > player2Score {
            winner = "Player 1 Wins with \(player1Score) Points!"
        } else if player2Score > player1Score {
            winner = "Player 2 Wins with \(player2Score) Points!"
        } else {
            winner = "It's a Draw! Both players have \(player1Score) points."
        }
        
        let alert = UIAlertController(title: "Game Over", message: winner, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
            self.startNewGame()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Card Flip Animation
    private func flipCardImage(_ imageView: UIImageView, toImageNamed imageName: String) {
        UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromRight, animations: {
            imageView.image = UIImage(named: imageName)
        }, completion: nil)
    }
    
    // MARK: - Reset Cards to Back
    private func resetCardsToBack() {
        let cardBackImage = "card_back.png"
        UIView.transition(with: player1CardImageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.player1CardImageView.image = UIImage(named: cardBackImage)
        }, completion: nil)
        
        UIView.transition(with: player2CardImageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            self.player2CardImageView.image = UIImage(named: cardBackImage)
        }, completion: nil)
    }
    
    private func showHowToPlayAlert() {
        let alert = UIAlertController(
            title: "How to Play",
            message: """
            Predict if the second card will be DOUBLE the value of the first!
            
            Scoring:
            • Correct prediction: 2 points + streak bonus
            • Streak bonus: +1 point per correct prediction (max +3)
            • Wrong prediction: Opponent gets 1 point
            • Streak resets on wrong prediction
            
            Card Values:
            • Number cards: Face value (1-10)
            • Jack = 11, Queen = 12, King = 13
            
            Example:
            • If first card is 3, second card must be 6 for "Double"
            • If first card is 6, second card must be 12 (Queen) for "Double"
            
            Strategy:
            • Keep track of remaining cards
            • Build streaks for bonus points
            • Consider probability before predicting
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Start Game", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender :UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
}
