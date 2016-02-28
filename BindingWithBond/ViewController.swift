/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController {
  
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultsTable: UITableView!

    private let viewModel = PhotoSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.searchString.bidirectionalBindTo(searchTextField.bnd_text)
        
        viewModel.validSearchText
            .map { $0 ? UIColor.blackColor() : UIColor.redColor() }
            .bindTo(searchTextField.bnd_textColor)
        
        viewModel.searchInProgress
            .map { !$0 }
            .bindTo(activityIndicator.bnd_hidden)
        viewModel.searchInProgress
            .map { $0 ? CGFloat(0.5) : CGFloat(1.0) }
            .bindTo(resultsTable.bnd_alpha)
        
        viewModel.searchResults.lift().bindTo(resultsTable) { indexPath, dataSource, tableView in
            let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! PhotoTableViewCell
            let photo = dataSource[indexPath.section][indexPath.row]
            cell.title.text = photo.title
            
            let qos = QOS_CLASS_BACKGROUND
            let queue = dispatch_get_global_queue(qos, 0)
            cell.photo.image = nil
            dispatch_async(queue) {
                if let data = NSData(contentsOfURL: photo.url) {
                    dispatch_async(dispatch_get_main_queue()) { cell.photo.image = UIImage(data: data) }
                }
            }
            return cell
        }
        
        viewModel.errorMessages.observe {[unowned self] (error) -> Void in
            let alertController = UIAlertController(title: "Something went wrong :-(", message: error, preferredStyle: .Alert)
            self.presentViewController(alertController, animated: true, completion: nil)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: {
                _ in alertController.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(ok)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSettings" {
            let navVC = segue.destinationViewController as! UINavigationController
            let settingsVC = navVC.topViewController as! SettingsViewController
            settingsVC.viewModel = viewModel.searchMetadataViewModel
        }
    }
}

