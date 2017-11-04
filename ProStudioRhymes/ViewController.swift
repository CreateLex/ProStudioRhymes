//
//  ViewController.swift
//  ProStudioRhymes
//
//  Created by Taylor Simpson on 11/1/17.
//  Copyright © 2017 Createlex. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UISearchBarDelegate {
   
    //MARK: - Outlet SetUp
    @IBOutlet weak var fetchingWordsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var proStudioApp2Button: UIButton!
    
    @IBAction func proStudioApp2Action(_ sender: Any) {
        
        UIApplication.shared.open(URL(string:"https://itunes.apple.com/us/app/prostudioapp-2/id1077857613?mt=8")!, options: [:], completionHandler: nil)
    }
    
    
    @IBOutlet weak var proRecorderButton: UIButton!
    
    @IBAction func proRecorderAction(_ sender: Any) {
    }
    
    @IBOutlet weak var beatPack1Button: UIButton!
    
    @IBAction func beatPack1Action(_ sender: Any) {
       
        
         UIApplication.shared.open(URL(string:"https://itunes.apple.com/us/album/prostudio-beat-library-1/id438207346")!, options: [:], completionHandler: nil)
        
    }
    
    @IBOutlet weak var rhymSearchBar: UISearchBar!
    
    @IBOutlet weak var beatPack2Button: UIButton!
    @IBAction func beatpack2Action(_ sender: Any) {
         UIApplication.shared.open(URL(string:"https://itunes.apple.com/us/album/prostudio-beat-library-2/id507205210")!, options: [:], completionHandler: nil)
    }
    
    
    @IBOutlet weak var beatPack3Button: UIButton!
    @IBAction func beatPack3Action(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://itunes.apple.com/us/album/prostudio-beat-pack-3/id672852266")!, options: [:], completionHandler: nil)
        
        
    }
    
    @IBOutlet weak var proStudioFXButton: UIButton!
///////////////////////////////
    
    
    //tool for the searchBar
    var searchActive : Bool = false
    //Array of words that rhyme with the inputted String to be sent to the next View and populate the table.
    var wordArray = [String]()
    
    
    override func viewWillAppear(_ animated: Bool) {
       //This Bit of code calls a function which applies a graident over the button image so that text is easier to read
        let beatPackOneImage = imageWithGradient(img: UIImage(named: "beatsPackOne.jpg"))
        let beatPackTwoImage = imageWithGradient(img: UIImage(named: "beatLibraryTwoImage.jpg"))
        let beatPackThreeImage = imageWithGradient(img: UIImage(named: "beatPack3.jpg"))
                
        beatPack1Button.setBackgroundImage(beatPackOneImage, for: .normal)
        beatPack2Button.setBackgroundImage(beatPackTwoImage, for: .normal)
        beatPack3Button.setBackgroundImage(beatPackThreeImage, for: .normal)
        proStudioApp2Button.setBackgroundImage(UIImage(named:"ProStudioApp2.jpg"), for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchingWordsIndicator.isHidden = true
        rhymSearchBar.delegate = self
        
        //Useful for dismissing Keyboard.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Search Bar Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        
        //To dismisskey board
        self.rhymSearchBar.endEditing(true)
        
        //depopulates array for every search so old data does not appear in the table.
        self.wordArray.removeAll()
       
        //Checks to make sure the searchbar contains text and that it can be unwrapped safely
        guard let wordToRhyme = rhymSearchBar.text else{
            return
        }
       
        print(wordToRhyme)
        //url for obtaining the words that rhyme with inputted word
        let rhymingURL = "http://rhymebrain.com/talk?function=getRhymes&word=\(wordToRhyme)"
        //makes sure the url is not nil
        guard let url = URL(string: rhymingURL) else {return}
        
        //Start of URL GET request to obtain rhyming words
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                return
            }
            //Note all UI changes must be updated on the main thread.
            DispatchQueue.main.async {
                self.fetchingWordsIndicator.isHidden = false
                self.fetchingWordsIndicator.startAnimating()
            }
            /////
            //Checks server responce if 200 then all good else no go.
            let status = (response as! HTTPURLResponse).statusCode
            
            if status == 200 {
                
                guard let data = data else {return}
                do{
                    
                    let rhymingWord = try JSONDecoder().decode([RhymingWords].self, from: data)
                    
                    for words in 0...rhymingWord.count-1{
                        self.wordArray.append(rhymingWord[words].word)
                    }
                    
                    print(self.wordArray)
                    DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "displayRhymesSegue", sender: ViewController())
                    }
                    
                    
                }catch let jsonError {
                    print("No Go \(jsonError)")
                }
                
            }else{print("There was a problem")}
            
        }.resume()
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //some code
    }
    
    ///////////
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        //Taking care of some UI in the next view
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
       
        //passes data to the next view so that the table can be populated.
        if let nextViewController = segue.destination as? RhymingTableTableViewController {
            nextViewController.wordList = wordArray
        }
        
        fetchingWordsIndicator.stopAnimating()
        fetchingWordsIndicator.isHidden = true
        
    }
    //This function takes an image and applies a gradient to it so that text is more readable.
    func imageWithGradient(img:UIImage!) -> UIImage {
        
        UIGraphicsBeginImageContext(img.size)
        let context = UIGraphicsGetCurrentContext()
        
        img.draw(at: CGPoint(x: 0, y: 0))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations:[CGFloat] = [0.0, 1.0]
        
        let bottom = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        let top = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        
        let colors = [top, bottom] as CFArray
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations)
        
        let startPoint = CGPoint(x: img.size.width/2, y: 0)
        let endPoint = CGPoint(x: img.size.width/2, y: img.size.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }


}

