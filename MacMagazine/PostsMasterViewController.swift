//
//  PostsMasterViewController.swift
//  MacMagazine
//
//  Created by Cassio Rossi on 18/08/17.
//  Copyright © 2017 MacMagazine. All rights reserved.
//

import UIKit

class PostsMasterViewController: UITableViewController {

	var detailViewController: PostsDetailViewController? = nil
	var posts = Posts()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
		
		let query = "\(Site.perPage.withParameter(10))&\(Site.page.withParameter(1))"
		Network.getPosts(host: Site.posts.withParameter(nil), query: query) {
			(result: Posts?) in
			
			if result != nil {
				self.posts = result!
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = tableView.indexPathForSelectedRow {
		        let object = self.posts.getPostAtIndex(index: indexPath.row)
		        let controller = (segue.destination as! UINavigationController).topViewController as! PostsDetailViewController
		        controller.detailItem = object
		        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.posts.getNumberOfPosts()
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell", for: indexPath) as? postCell else {
            fatalError("Unexpected Index Path")
        }

		let object = self.posts.getPostAtIndex(index: indexPath.row)
		cell.headlineLabel!.text = object?.title
        cell.subheadlineLabel!.text = object?.excerpt
		
		if let url = object?.artworkURL {
			LazyImage.show(imageView: cell.thumbnailImageView, url: url, defaultImage:"logo") {
				() in
				//Image loaded. Do something..
				//            cell.spin.stopAnimating()
			}
		} else {
			Network.getImageURL(host: Site.artworkURL.withParameter(nil), query: "\((object?.artwork)!)") {
				(result: String?) in
				
				if result != nil {
					object?.artworkURL = result!
					DispatchQueue.main.async {
						LazyImage.show(imageView: cell.thumbnailImageView, url: object?.artworkURL, defaultImage:"logo") {
							() in
							//Image loaded. Do something..
							//            cell.spin.stopAnimating()
						}
					}
				}
			}
		}

        return cell
	}

}
