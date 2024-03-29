//
//  OrderViewController.swift
//  Demo
//
//  Created by 陳柔夆 on 2024/2/22.
//

import UIKit
import SnapKit
import Kingfisher

class OrderViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let orderTableView = UITableView()
        
    let bottomCheckoutView = UIView()
    let checkoutStackView = UIStackView()
    let checkoutPrice = UILabel()
    let checkoutTitle = UILabel()
    let checkoutNumberOfCups = UILabel()
    
    let imageView = UIImageView(image: UIImage(named: "logo-m"))
    var separatorView = UIView()
    
    var numberOfCups = 0
    var totalPrice = 0
    
    var orders = [CreateOrderDrinkResponseRecord]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Order", image: UIImage(systemName: "cart"), selectedImage: UIImage(systemName: "cart"))
        tabBarItem.badgeColor = .secondary
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrder), name: .orderUpdateNotification, object: nil)
        MenuViewController.shared.fetchOrderList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orderListResponse):
                self.orders = orderListResponse.records
                DispatchQueue.main.async {
                    self.updateUI()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設置 navigationItem 圖像
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        // 設置標題顏色為白色
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
         
        configUI()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        separatorView = UIView(frame: CGRect(x: 0, y: navigationController?.navigationBar.frame.maxY ?? 0, width: view.bounds.width, height: 0.5))
        separatorView.backgroundColor = UIColor.unselected // 設置分隔線顏色
        // 添加分隔線視圖到導航欄
        navigationController?.view.addSubview(separatorView)
        separatorView.isHidden = true
    }
    
    func updateUI() {
        orderTableView.reloadData()
        calculateQuantityAndPrice()
        checkoutNumberOfCups.text = "共計 \(numberOfCups)杯"
        checkoutPrice.text = "$\(totalPrice)"
        if orders.count > 0 {
            tabBarItem.badgeValue = "\(numberOfCups)"
        } else {
            tabBarItem.badgeValue = nil
        }
    }
    
    func calculateQuantityAndPrice() {
        totalPrice = 0
        numberOfCups = 0
        for order in orders {
            totalPrice += order.fields.price
            numberOfCups += order.fields.numberOfCups
        }
    }
    
    @objc func updateOrder() {
        MenuViewController.shared.fetchOrderList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let orderListResponse):
                self.orders = orderListResponse.records
                DispatchQueue.main.async {
                    self.updateUI()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
        
    func configUI() {
        view.backgroundColor = .primary

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        scrollView.delegate = self
        
        scrollView.addSubview(orderTableView)
        orderTableView.snp.makeConstraints { make in
            make.top.left.right.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(scrollView.frameLayoutGuide).inset(60)
        }
        orderTableView.backgroundColor = .primary
        orderTableView.separatorColor = .unselected
        orderTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        orderTableView.delegate = self
        orderTableView.dataSource = self
        orderTableView.register(OrderCell.self, forCellReuseIdentifier: "orderCell")
        
        configBottomCheckoutView()
    }
    
    func configBottomCheckoutView() {
        scrollView.addSubview(bottomCheckoutView)
        bottomCheckoutView.backgroundColor = .darkPrimary
        bottomCheckoutView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(60)
        }

        bottomCheckoutView.addSubview(checkoutStackView)
        checkoutStackView.axis = .horizontal
        checkoutStackView.spacing = 20
        checkoutStackView.alignment = .center
        checkoutStackView.distribution = .fill
        checkoutStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        checkoutStackView.addArrangedSubview(checkoutTitle)
        checkoutTitle.text = "總金額"
        checkoutTitle.textColor = .secondary
        checkoutTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        checkoutStackView.addArrangedSubview(checkoutNumberOfCups)
        checkoutNumberOfCups.text = "共計 \(orders.count)杯"
        checkoutNumberOfCups.textColor = .gray
        checkoutNumberOfCups.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        checkoutStackView.addArrangedSubview(checkoutPrice)
        checkoutPrice.text = "$\(totalPrice)"
        checkoutPrice.textColor = .secondary
        checkoutPrice.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        bottomCheckoutView.layer.shadowColor = UIColor.black.cgColor
        bottomCheckoutView.layer.shadowOffset = CGSize(width: 0, height: -1) // 陰影偏移量
        bottomCheckoutView.layer.shadowOpacity = 0.2 // 陰影透明度
        bottomCheckoutView.layer.shadowRadius = 4 // 陰影半徑
    }
    
    deinit {
        // 在視圖控制器被銷毀時移除通知觀察者
        NotificationCenter.default.removeObserver(self, name: .orderUpdateNotification, object: nil)
    }
    
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = orderTableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderCell
        cell.selectionStyle = .none
        // 傳order的資料給cell
        cell.set(order: orders[indexPath.row])
        // cell找delegate幫忙
        cell.delegate = self
        // 設置按鈕的 tag 為 indexPath.row
        cell.minusButton.tag = indexPath.row
        cell.plusButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    // delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let order = self.orders[indexPath.row]
            
            MenuViewController.shared.deleteOrder(orderID: order.id) { result in
                switch result {
                case .success(let message):
                    print(message)
                    DispatchQueue.main.async {
                        self.orders.remove(at: indexPath.row)
                        self.orderTableView.deleteRows(at: [indexPath], with: .left)
                        self.updateUI()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let order = orders[indexPath.row]
        let drinkDetailViewController = DrinkDetailViewController()
        drinkDetailViewController.accessOrderData(data: order.fields, id: order.id)
        present(drinkDetailViewController, animated: true)
    }
    
}

extension OrderViewController: UIScrollViewDelegate {
    // 滾動時調整標題
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY > 10 { // 根據需要調整值
            navigationItem.title = "訂購清單"
            separatorView.isHidden = false
            navigationItem.titleView = nil
        } else {
            navigationItem.title = ""
            separatorView.isHidden = true
            navigationItem.titleView = imageView
        }
    }
}

extension OrderViewController: OrderCellDelegate {
    // 變更飲料杯數時，資料同步至Airtable再載回來
    func updateQuantityAndPrice(sender: UIButton, numberOfCups: Int, orderPrice: Int) {
        // 獲取按鈕的 tag 屬性，即對應的 indexPath.row
        let rowIndex = sender.tag
        // 設置訂單更新內容
        let updateOrderFields = UpdateOrderFields(
            size: orders[rowIndex].fields.size,
            ice: orders[rowIndex].fields.ice,
            sugar: orders[rowIndex].fields.sugar,
            addOns: orders[rowIndex].fields.addOns ?? [], price: orderPrice,
            numberOfCups: numberOfCups)
        
        let updateOrderRecord = UpdateOrderRecord(id: orders[rowIndex].id, fields: updateOrderFields)
        let updateOrderDrink = UpdateOrderDrink(records: [updateOrderRecord])
        // PATCH
        MenuViewController.shared.updateOrder(orderData: updateOrderDrink) { result in
            switch result {
            case .success(let updateOrderResponse):
                print(updateOrderResponse)
                NotificationCenter.default.post(name: .orderUpdateNotification, object: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
