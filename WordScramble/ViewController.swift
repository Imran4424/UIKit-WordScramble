//
//  ViewController.swift
//  WordScramble
//
//  Created by Shah Md Imran Hossain on 28/8/22.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "repeat"), style: .plain, target: self, action: #selector(restartGame))
        
        // barButtonSystemItem - defines the type of bar button
        // target - where the action method is
        // action - action method
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        loadFromFile()
        startGame()
    }
    
    func loadFromFile() {
        // incase guard fails
        allWords = ["silkworm"]
        
        // finding the path url where start.txt is located
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            print("path url not found")
            return
        }
        
        // path url found
        // with that path url loading the contents of the txt file
        guard let startWords = try? String(contentsOf: startWordsURL) else {
            print("unable to load words from the txt file")
            return
        }
        
        // contents of txt file loaded
        // now seperating words by new line(\n) with the help of
        // higher order function
        allWords = startWords.components(separatedBy: "\n")
    }

    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func restartGame() {
        startGame()
    }
    
    // @objc indicates it a button action method
    @objc func promptForAnswer() {
        // creating a alert controller
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        // adding text field to the aleart controller
        ac.addTextField()
        
        // creating alert controller submit button
        // this alert has a trialing closure
        // capturing references weakly
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {
                print("answer not found from submit alert action")
                return
            }
            
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        // look this is constant
        // but it still working, not giving error
        // in swift, we can delare a constant
        // initialize it later
        // but once it initialized, it can't be changed
        let errorTitle: String
        let errorMessage: String
        
        // we can also use && operator instead of using nested if
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    // row and section of indexPath
                    let indexPath = IndexPath(row: 0, section: 0)
                    
                    // indexPath
                    // with animation
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    // here, we are not calling reloadData method of table view
                    // we are inserting table view data
                    // we are doing this because of animation
                    // also
                    // tableView.reloadData() will be expensive for this small change
                    
                    // it works so return
                    return
                } else {
                    errorTitle = "word not recognized"
                    errorMessage = "You can't just make them up, you know!"
                }
            } else {
                errorTitle = "Word Already used"
                errorMessage = "Be more original!"
            }
        } else {
            guard let title = title else {
                print("title is nil")
                return
            }
            
            errorTitle = "word not possible"
            errorMessage = "You can't spell that word from \(title.lowercased())."
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        // lower casing the title word
        guard var titleWord = title?.lowercased() else {
            print("lowercasing failed")
            return false
        }
        
        // validating the anagram
        for letter in word {
            if let position = titleWord.firstIndex(of: letter) {
                titleWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        // cheking if the word is a english word or not
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
}

// MARK: - Table View datasource
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}
