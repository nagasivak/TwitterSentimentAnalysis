//
//  MainViewController.swift
//  TwitterSenti
//
//  Created by Naga Siva on 12/02/21.
//

import UIKit
import SwifteriOS
import CoreML


class MainViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var sentimentNameLbl: UILabel!
    
    
    let sentimentClassifier: TweetSentimentClassifier = {
        do {
            let config = MLModelConfiguration()
            return try TweetSentimentClassifier(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create Sentiment Classifier")
        }
    }()
    
    let swifter = Swifter(consumerKey: K.consumerAPIKey, consumerSecret: K.consumerAPISecretKey)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        sentimentNameLbl.isHidden = false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        fetchTweets()
        textField.resignFirstResponder()
        return true;
        
    }
    
    @IBAction func predictTapped(_ sender: UIButton) {
        
        fetchTweets()
        
    }
    
    func fetchTweets() {
        
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: K.tweetCount, tweetMode: .extended) { (results, metadata) in
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<K.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        print(">>>>>\(tweet)")
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.predict(with: tweets)
            } failure: { (error) in
                print("There was an error with the Twitter API Request.")
            }
        }
    }
    
    
    
    func predict(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for prediction in predictions {
                let sentiment = prediction.label
                if sentiment == "Positive" {
                    sentimentScore += 1
                } else {
                    sentimentScore -= 1
                }
            }
            updateUI(sentimentScore: sentimentScore)
        } catch {
            print("Error in prediction")
        }
    }
    
    func updateUI(sentimentScore: Int) {
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
            self.sentimentNameLbl.text = "Positive"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😃"
            self.sentimentNameLbl.text = "Positive"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
            self.sentimentNameLbl.text = "Neutral"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
            self.sentimentNameLbl.text = "Neutral"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
            self.sentimentNameLbl.text = "Negative"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
            self.sentimentNameLbl.text = "Negative"
        } else {
            self.sentimentLabel.text = "🤮"
            self.sentimentNameLbl.text = "Negative"
        }
    }
}

