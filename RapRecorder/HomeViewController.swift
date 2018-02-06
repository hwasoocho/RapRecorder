import UIKit

class HomeViewController: UITableViewController {

    var rapFiles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Directory Files
        reloadRapFiles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadRapFiles()
    }
    
    // MARK: Private Methods.
    
    // Reload rapFiles and reload table data.
    func reloadRapFiles() {
        rapFiles = []
        let rapsDirectory = Util.initRapsDirectory()
        for file in try! FileManager.default.contentsOfDirectory(atPath: rapsDirectory.path) {
            let fileURL = URL(fileURLWithPath: file)
            if fileURL.pathExtension == "m4a" {
                rapFiles.append(fileURL.deletingPathExtension().lastPathComponent)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rapFiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RapCellIdentifier", for: indexPath) as! RapTableViewCell

        cell.rapTitle.text = rapFiles[indexPath.row]
        cell.rapPath = Util.initRapsDirectory().appendingPathComponent(rapFiles[indexPath.row]+".m4a")
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete actual file from raps directory.
            let rapsDirectory = Util.initRapsDirectory()
            try? FileManager.default.removeItem(at: rapsDirectory.appendingPathComponent(rapFiles[indexPath.row]+".m4a"))
            // Delete the row from the data source
            rapFiles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Present Activity View Controller on select row.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rapPath = Util.initRapsDirectory().appendingPathComponent(rapFiles[indexPath.row]+".m4a")
        let activityViewController = UIActivityViewController.init(activityItems: [rapPath], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
