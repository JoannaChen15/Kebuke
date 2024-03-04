//
//  DrinkDetailViewController.swift
//  Demo
//
//  Created by 陳柔夆 on 2024/2/23.
//

import UIKit
import Kingfisher

class DrinkDetailViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let drinkView = UIView()
    let drinkImageView = UIImageView()
    let drinkName = UILabel()
    let drinkDescription = UILabel()
    let backButton = UIButton()
    
    let sizeView = UIView()
    let sizeTitle = UILabel()
    let addOnsView = UIView()
    let addOnsTitle = UILabel()
    let temperatureView = UIView()
    let temperatureTitle = UILabel()
    let sugarView = UIView()
    let sugarTitle = UILabel()
    let optionTitleFontSize: CGFloat = 20
    let viewGap: CGFloat = 8
    
    let bottomCheckoutView = UIView()
    let checkoutStackView = UIStackView()
    let checkoutItem = UIStackView()
    let checkoutPrice = UILabel()
    let checkoutOptions = UILabel()
    let addToCartButton = UIButton()
    
    static let orderUpdateNotification = Notification.Name("orderUpdate")
    
    var priceDifference = 0
    var totalPrice = 0

    // 用於保存當前選中的按鈕
    var selectedSize: RadioButton?
    var selectedTemperature: RadioButton?
    var selectedSugar: RadioButton?
    var selectedAddOns: CheckBox?
    var totalAddOns = [String]()
    var selectedOptions = [String]()
    
    var drink: Record!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        getOriginalPrice()
        calculateLargeCupPriceDifference()
        
        configScrollView()
        configDrinkView()
        configSizeView()
        configTemperatureView()
        configSugarView()
        configAddOnsView()
        configBackButton()
        configBottomCheckoutView()
    }
    
    func getOriginalPrice() {
        totalPrice = drink.fields.medium
    }
    
    func calculateLargeCupPriceDifference() {
        // 計算大杯價差
        let mediumPrice = drink.fields.medium
        let largePrice = drink.fields.large
        priceDifference = largePrice - mediumPrice
    }
    
    func createRadioButton(title: String, checkoutName: String, type: TypeOfOption) -> RadioButton {
        let radioButton = RadioButton()
        radioButton.titleLable.text = "\(title)"
        radioButton.titleLable.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        radioButton.checkoutName = checkoutName
        radioButton.type = type
        radioButton.delegate = self
        return radioButton
    }
    
    func createCheckBox(title: String, checkoutName: String) -> CheckBox {
        let checkBox = CheckBox()
        checkBox.titleLable.text = "\(title)"
        checkBox.titleLable.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        checkBox.checkoutName = checkoutName
        checkBox.delegate = self
        return checkBox
    }
    
    func layoutRadioButton(view: UIView, title: UILabel) {
        var previousButton: RadioButton? // 用於保存前一個按鈕
        for case let radioButton as RadioButton in view.subviews {
            // 設置頂部約束
            if let previousButton = previousButton {
                radioButton.snp.makeConstraints { make in
                    make.top.equalTo(previousButton.snp.bottom).offset(10)
                }
            } else {
                radioButton.snp.makeConstraints { make in
                    make.top.equalTo(title.snp.bottom).offset(10)
                }
            }
            // 設置左右約束
            radioButton.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16)
            }
            // 更新前一個按鈕
            previousButton = radioButton
        }
    }
    
    func layoutCheckBox(view: UIView, title: UILabel) {
        var previousButton: CheckBox?
        for case let checkBox as CheckBox in view.subviews {
            if let previousButton = previousButton {
                checkBox.snp.makeConstraints { make in
                    make.top.equalTo(previousButton.snp.bottom).offset(10)
                }
            } else {
                checkBox.snp.makeConstraints { make in
                    make.top.equalTo(title.snp.bottom).offset(10)
                }
            }
            checkBox.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(16)
            }
            previousButton = checkBox
        }
    }
    
    func configScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    func configDrinkView() {
        scrollView.addSubview(drinkView)
        drinkView.backgroundColor = .white
        drinkView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide)
            make.left.right.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        drinkView.addSubview(drinkImageView)
        drinkImageView.contentMode = .scaleAspectFill
        drinkImageView.clipsToBounds = true
        drinkImageView.layer.shadowOpacity = 0
        drinkImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(view.frame.width * 720 / 960)
        }
        drinkImageView.kf.setImage(with: drink.fields.image.first?.url)
        
        drinkView.addSubview(drinkName)
        drinkName.text = drink.fields.name
        drinkName.font = UIFont.systemFont(ofSize: 24, weight: .black)
        drinkName.textColor = .darkPrimary
        drinkName.snp.makeConstraints { make in
            make.top.equalTo(drinkImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        drinkView.addSubview(drinkDescription)
        drinkDescription.text = drink.fields.description
        drinkDescription.font = UIFont.systemFont(ofSize: 14)
        drinkDescription.textColor = .secondary
        drinkDescription.snp.makeConstraints { make in
            make.top.equalTo(drinkName.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        drinkView.snp.makeConstraints { make in
            make.bottom.equalTo(drinkDescription.snp.bottom).offset(10)
        }
    }
    
    func configSizeView() {
        scrollView.addSubview(sizeView)
        sizeView.backgroundColor = .white
        sizeView.snp.makeConstraints { make in
            make.top.equalTo(drinkView.snp.bottom).offset(viewGap)
            make.left.right.equalToSuperview()
        }
        
        sizeView.addSubview(sizeTitle)
        sizeTitle.text = "尺寸 Size"
        sizeTitle.font = UIFont.systemFont(ofSize: optionTitleFontSize, weight: .bold)
        sizeTitle.textColor = .darkPrimary
        sizeTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(16)
        }
          
        // 創建單選按鈕
        let mediumButton = createRadioButton(title: "中杯 Medium", checkoutName: "中杯", type: .size)
        let largeButton = createRadioButton(title: "大杯 Large  +$\(priceDifference)", checkoutName: "大杯", type: .size)
        sizeView.addSubview(mediumButton)
        sizeView.addSubview(largeButton)
        layoutRadioButton(view: sizeView, title: sizeTitle)
        sizeView.snp.makeConstraints { make in
            if let lastSubview = sizeView.subviews.last {
                make.bottom.equalTo(lastSubview.snp.bottom).offset(10)
            }
        }
    }
    
    func configTemperatureView() {
        scrollView.addSubview(temperatureView)
        temperatureView.backgroundColor = .white
        temperatureView.snp.makeConstraints { make in
            make.top.equalTo(sizeView.snp.bottom).offset(viewGap)
            make.left.right.equalToSuperview()
        }
        
        temperatureView.addSubview(temperatureTitle)
        temperatureTitle.text = "飲品溫度 Beverage Temperature"
        temperatureTitle.font = UIFont.systemFont(ofSize: optionTitleFontSize, weight: .bold)
        temperatureTitle.textColor = .darkPrimary
        temperatureTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(16)
        }
        // 創建單選按鈕
        let regularIce = createRadioButton(title: "正常冰 Regular Ice", checkoutName: "正常冰", type: .temperature)
        let lessIce = createRadioButton(title: "少冰 Less Ice", checkoutName: "少冰", type: .temperature)
        let halfIce = createRadioButton(title: "微冰 Half Ice", checkoutName: "微冰", type: .temperature)
        let iceFree = createRadioButton(title: "去冰 Ice-Free", checkoutName: "去冰", type: .temperature)
        let withoutIce = createRadioButton(title: "完全去冰 Without Ice", checkoutName: "完全去冰", type: .temperature)
        let roomTemperature = createRadioButton(title: "常溫 Room Temperature", checkoutName: "常溫", type: .temperature)
        let warm = createRadioButton(title: "溫 Warm", checkoutName: "溫", type: .temperature)
        let hot = createRadioButton(title: "熱 Hot", checkoutName: "熱", type: .temperature)

        temperatureView.addSubview(regularIce)
        temperatureView.addSubview(lessIce)
        temperatureView.addSubview(halfIce)
        temperatureView.addSubview(iceFree)
        temperatureView.addSubview(withoutIce)
        temperatureView.addSubview(roomTemperature)
        temperatureView.addSubview(warm)
        temperatureView.addSubview(hot)

        layoutRadioButton(view: temperatureView, title: temperatureTitle)
        temperatureView.snp.makeConstraints { make in
            if let lastSubview = temperatureView.subviews.last {
                make.bottom.equalTo(lastSubview.snp.bottom).offset(10)
            }
        }
    }
    
    func configSugarView() {
        scrollView.addSubview(sugarView)
        sugarView.backgroundColor = .white
        sugarView.snp.makeConstraints { make in
            make.top.equalTo(temperatureView.snp.bottom).offset(viewGap)
            make.left.right.equalToSuperview()
        }
        
        sugarView.addSubview(sugarTitle)
        sugarTitle.text = "甜度選擇 Choose Sweetness Level"
        sugarTitle.font = UIFont.systemFont(ofSize: optionTitleFontSize, weight: .bold)
        sugarTitle.textColor = .darkPrimary
        sugarTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(16)
        }
        // 創建單選按鈕
        let regularSugar = createRadioButton(title: "正常糖 100% Sugar", checkoutName: "正常糖", type: .sugar)
        let lowSugar = createRadioButton(title: "少糖 70% Sugar", checkoutName: "少糖", type: .sugar)
        let halfSugar = createRadioButton(title: "半糖 50% Sugar", checkoutName: "半糖", type: .sugar)
        let lightSugar = createRadioButton(title: "微糖 30% Sugar", checkoutName: "微糖", type: .sugar)
        let twoThirdsSugar = createRadioButton(title: "二分糖 20% Sugar", checkoutName: "二分糖", type: .sugar)
        let oneThirdsSugar = createRadioButton(title: "一分糖 10% Sugar", checkoutName: "一分糖", type: .sugar)
        let sugarFree = createRadioButton(title: "無糖 Sugar-Free", checkoutName: "無糖", type: .sugar)

        sugarView.addSubview(regularSugar)
        sugarView.addSubview(lowSugar)
        sugarView.addSubview(halfSugar)
        sugarView.addSubview(lightSugar)
        sugarView.addSubview(twoThirdsSugar)
        sugarView.addSubview(oneThirdsSugar)
        sugarView.addSubview(sugarFree)

        layoutRadioButton(view: sugarView, title: sugarTitle)
        sugarView.snp.makeConstraints { make in
            if let lastSubview = sugarView.subviews.last {
                make.bottom.equalTo(lastSubview.snp.bottom).offset(10)
            }
        }
    }
    
    func configAddOnsView() {
        scrollView.addSubview(addOnsView)
        addOnsView.backgroundColor = .white
        addOnsView.snp.makeConstraints { make in
            make.top.equalTo(sugarView.snp.bottom).offset(viewGap)
            make.left.right.equalToSuperview()
        }
        
        addOnsView.addSubview(addOnsTitle)
        addOnsTitle.text = "加料 Add-Ons"
        addOnsTitle.font = UIFont.systemFont(ofSize: optionTitleFontSize, weight: .bold)
        addOnsTitle.textColor = .darkPrimary
        addOnsTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.left.equalToSuperview().inset(16)
        }
        // 創建多選按鈕
        let whiteTapioca = createCheckBox(title: "白玉 White Tapioca  +$10", checkoutName: "加白玉")
        let agarPearl = createCheckBox(title: "水玉 Agar Pearl  +$10", checkoutName: "加水玉")
        let confectionery = createCheckBox(title: "菓玉 Confectionery  +$10", checkoutName: "加菓玉")
        addOnsView.addSubview(whiteTapioca)
        addOnsView.addSubview(agarPearl)
        addOnsView.addSubview(confectionery)
        layoutCheckBox(view: addOnsView, title: addOnsTitle)
        addOnsView.snp.makeConstraints { make in
            if let lastSubview = addOnsView.subviews.last {
                make.bottom.equalTo(lastSubview.snp.bottom).offset(10)
            }
        }
        addOnsView.snp.makeConstraints { make in
            make.bottom.equalTo(scrollView.contentLayoutGuide).inset(92 - viewGap * 3)
        }
    }
    
    func configBackButton() {
        scrollView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.frameLayoutGuide).inset(10)
            make.left.equalTo(scrollView.frameLayoutGuide).inset(16)
            make.size.equalTo(46)
        }
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 23
        backButton.layer.shadowColor = UIColor.unselected.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2) // 陰影偏移量
        backButton.layer.shadowOpacity = 0.2 // 陰影透明度
        backButton.layer.shadowRadius = 6 // 陰影半徑
        backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        backButton.tintColor = .secondary
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    }
    
    func configBottomCheckoutView() {
        scrollView.addSubview(bottomCheckoutView)
        bottomCheckoutView.backgroundColor = .darkPrimary
        bottomCheckoutView.snp.makeConstraints { make in
            make.bottom.equalTo(scrollView.frameLayoutGuide)
            make.left.right.equalToSuperview()
            make.height.equalTo(92)
        }
        
        bottomCheckoutView.addSubview(checkoutStackView)
        checkoutStackView.axis = .horizontal
        checkoutStackView.spacing = 6
        checkoutStackView.alignment = .fill
        checkoutStackView.distribution = .fillProportionally
        checkoutStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(28)
            make.left.right.equalToSuperview().inset(26)
        }
        
        checkoutStackView.addArrangedSubview(checkoutItem)
        checkoutItem.axis = .vertical
        checkoutItem.spacing = 6
        checkoutItem.alignment = .leading
        checkoutItem.distribution = .equalSpacing
        checkoutItem.addArrangedSubview(checkoutPrice)
        checkoutPrice.text = "$\(totalPrice)"
        checkoutPrice.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        checkoutPrice.textColor = .secondary
        
        checkoutItem.addArrangedSubview(checkoutOptions)
        checkoutOptions.text = "請選擇尺寸、冰塊、甜度"
        checkoutOptions.font = UIFont.systemFont(ofSize: 14)
        checkoutOptions.textColor = .gray
        
        checkoutStackView.addArrangedSubview(addToCartButton)
        addToCartButton.setTitle("加入購物車", for: .normal)
        addToCartButton.setTitleColor(.darkPrimary, for: .normal)
        addToCartButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        addToCartButton.setImage(UIImage(systemName: "cart"), for: .normal)
        addToCartButton.tintColor = .darkPrimary
        addToCartButton.backgroundColor = .secondary
        addToCartButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
//        var configuration = UIButton.Configuration.filled()
//        var title = AttributedString("加入購物車")
//        title.font = UIFont.systemFont(ofSize: 16)
//        configuration.attributedTitle = title
//        configuration.baseBackgroundColor = .secondary
//        configuration.baseForegroundColor = .darkPrimary
//        configuration.image = UIImage(systemName: "cart")
//        configuration.imagePadding = 2 // 設置圖像的內邊距
//        addToCartButton.configuration = configuration
        addToCartButton.layer.cornerRadius = 8
        addToCartButton.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
    }
    
    @objc func backButtonPressed(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func addToCart() {
        // 設置訂單內容
        let createOrderFields = CreateOrderFields(
            drinkName: drink.fields.name,
            size: selectedSize?.checkoutName ?? "",
            ice: selectedIce?.checkoutName ?? "",
            sugar: selectedSugar?.checkoutName ?? "",
            addOns: totalAddOns, price: totalPrice,
            orderName: "Joanna", numberOfCups: 1,
            imageUrl: (drink.fields.image.first?.url)!)
        
        let createOrderRecord = CreateOrderRecord(fields: createOrderFields)
        let createOrderDrink = CreateOrderDrink(records: [createOrderRecord])
        // POST
        MenuViewController.shared.postOrder(orderData: createOrderDrink) { result in
            switch result {
            case .success(let createOrderResponse):
                print(createOrderResponse)
                NotificationCenter.default.post(name: .orderUpdateNotification, object: nil)
            case .failure(let error):
                print(error)
            }
        }
        // 關閉當前視圖
        self.dismiss(animated: true)
    }
    
    func updateCheckoutOptions() {
        selectedOptions = []
        if selectedSize != nil {
            selectedOptions.append(selectedSize?.checkoutName ?? "")
        }
        if selectedIce != nil {
            selectedOptions.append(selectedIce?.checkoutName ?? "")
        }
        if selectedSugar != nil {
            selectedOptions.append(selectedSugar?.checkoutName ?? "")
        }
        if totalAddOns != [] {
            selectedOptions.append(contentsOf: totalAddOns)
        }
        checkoutOptions.text = selectedOptions.joined(separator: "•")
    }
    
    func removeCheckoutTitle() {
        if selectedSize == nil && selectedTemperature == nil && selectedSugar == nil && selectedAddOns == nil {
            checkoutOptions.text? = ""
        }
    }

}

extension DrinkDetailViewController: RadioButtonDelegate {
    
    func optionButtonTapped(_ sender: RadioButton) {
        // 移除"請選擇..."
        removeCheckoutTitle()
        // 根據按鈕的 type 設置選中的選項
        switch sender.type {
        case .size:
            addSizeDifference(selectedButton: sender)
            didSelected(type: &selectedSize)
        case .temperature:
            didSelected(type: &selectedTemperature)
        case .sugar:
            didSelected(type: &selectedSugar)
        default:
            break
        }
        updateCheckoutOptions()
        
        func didSelected(type selectedButton: inout RadioButton?) {
            // 取消先前選中的按鈕
            selectedButton?.status = .unchecked
            // 選中當前按鈕
            sender.status = .checked
            selectedButton = sender
        }
        
    }
    
    func addSizeDifference(selectedButton: RadioButton?) {
        if selectedButton?.checkoutName == "大杯" {
            if selectedSize?.checkoutName == "大杯" {
                return
            } else {
                totalPrice += priceDifference
            }
            
        } else {
            if selectedSize?.checkoutName == "大杯" {
                totalPrice -= priceDifference
            } else {
                return
            }
        }
        checkoutPrice.text? = "$\(totalPrice)"
    }
    
}

extension DrinkDetailViewController: CheckBoxDelegate {
    
    func checkBoxTapped(_ sender: CheckBox) {
        removeCheckoutTitle()
        selectedAddOns = sender
        
        switch sender.status {
        case .checked:
            totalPrice += 10
            totalAddOns.append(sender.checkoutName)
        case .unchecked:
            totalPrice -= 10
            let objectToRemove = sender.checkoutName
            if let index = totalAddOns.firstIndex(of: objectToRemove) {
                totalAddOns.remove(at: index)
            }
        }
        checkoutPrice.text = "$\(totalPrice)"
        updateCheckoutOptions()
    }

}

extension Notification.Name {
    static let orderUpdateNotification = Notification.Name("OrderUpdateNotification")
}
