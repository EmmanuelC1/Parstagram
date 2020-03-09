//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Emmanuel Castillo on 2/26/20.
//  Copyright © 2020 Emmanuel Castillo. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //Create instance if MessageInputBar
    let commentBar = MessageInputBar()
    
    //Boolean variable to not have comment bar display by default
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var selectedPost: PFObject!

    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Customize commentBar when adding a new comment to a post
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //Dismiss keyboard with pull down
        tableView.keyboardDismissMode = .interactive
        
        //Call keyboardWillBeHidden when event happens (event: keyboard will hide)
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: keyboardWillBeHidden
    //Function that dismisses the commentBar and clears the text in the inputTextView
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        //Display comment bar if showsCommentBar is true
        return showsCommentBar
    }
    
    //MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Query for Posts
        let query = PFQuery(className:"Posts")
        
        //Fetch actual object for author and comments and the respective author for the comment
        query.includeKeys(["author", "comments", "comments.author"])
        
        //Limit to only 20 posts
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: MessageInputBar
    //Function that handles Post button in commentBar
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error) in
            if(success) {
                print("Comment Saved Successfully")
            }
            else {
                print("Error: Saving Comment >> \(error?.localizedDescription)")
            }
        }
        
        //Reload table View
        tableView.reloadData()
        
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    //MARK: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        //If a post has no comments, then the comments array of PFObjects is nil
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    //MARK: numberOFSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    //MARK: cellForAtRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Set current post at specific table view section to post variable
        let post = posts[indexPath.section]
        
        //Set post comments to comments array of PFObjects
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //MARK: Post Cell
        //Post Cell if indexPath.row = 0
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            //Set Username to usernameLabel
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            //Set Caption to captionLabel
            cell.captionLabel.text = post["caption"] as? String
            
            //Get url for image
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            //Set image to photoView
            cell.photoView.af_setImage(withURL: url)
            
            return cell
        }
        else if(indexPath.row <= comments.count) { //MARK: Comments Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            //Set first comment (-1) to comment
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            //Set Username to nameLabel (Username is the comment author)
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        else { //MARK: Add Comment Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    //MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //Set showsCommentsBar = true if last cell. Also makes keyboard pop up
        if(indexPath.row == comments.count + 1) {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            //Set selectedPost to current post selected (used in MessageInputBar)
            selectedPost = post
        }
    }
    
    //MARK: onLogoutButton
    // Log user out when user clicks on Logout button
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        sceneDelegate.window?.rootViewController = loginViewController
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
