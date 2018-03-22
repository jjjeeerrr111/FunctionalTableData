import UIKit
import PlaygroundSupport
import FunctionalTableData

class ExampleViewController: UICollectionViewController {
	private let functionalData = FunctionalCollectionData()
	
	private var disableRender: Bool = false
	private var items: [String] = [] {
		didSet {
			guard !disableRender else { return }
			render()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView?.backgroundColor = .white
		functionalData.collectionView = collectionView
		title = "Example"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAdd))
		render()
	}
	
	@objc private func didSelectAdd() {
		items.append("\(Int(arc4random_uniform(1500)+1))")
	}
	
	private var headerEnabled: Bool = true
	
	private func toggleHeader() {
		headerEnabled = !headerEnabled
		render()
	}
	
	private func render() {
		let header = LabelCell(
			key: "head",
			style: CellStyle(backgroundColor: .lightGray),
			state: LabelState(text: headerEnabled ? "1" : "2"),
			cellUpdater: LabelState.updateView
		)
		
		let rows: [CellConfigType] = items.enumerated().map { index, item in
			return LabelCell(
				key: item,
				style: CellStyle(backgroundColor: .lightGray),
				actions: CellActions(canBeMoved: true),
				state: LabelState(text: item),
				cellUpdater: LabelState.updateView)
		}
		
		functionalData.renderAndDiff([
			TableSection(key: "head", rows: [header]),
			TableSection(key: "section", rows: rows, didMoveRow: { [weak self ] (_ from: Int, _ to: Int) in
				guard let strongSelf = self else { return }
				strongSelf.disableRender = true
				let item = strongSelf.items.remove(at: from)
				strongSelf.items.insert(item, at: to)
				strongSelf.disableRender = false
				strongSelf.toggleHeader()
			})])
	}
}

// Create a layout, this is the key part when dealing with UICollectionView.
let layout = UICollectionViewFlowLayout()
layout.itemSize = CGSize(width: 72.0, height: 72.0)

// Present the view controller in the Live View window
let liveController = UINavigationController(rootViewController: ExampleViewController(collectionViewLayout: layout))
liveController.preferredContentSize = CGSize(width: 320, height: 420)
PlaygroundPage.current.liveView = liveController
