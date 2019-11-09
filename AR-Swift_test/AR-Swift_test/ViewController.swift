
import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController {
    @IBOutlet weak var sceneV: ARSCNView!
    @IBOutlet weak var InfoL: UILabel!
    @IBOutlet weak var targetIM: UIImageView!
    var session = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    var isMeasuring = false//默认状态为非测量状态
    
    var canMeasure = true//是否允许测量
    
    
    var vectorZero = SCNVector3() // 0,0,0
    var vectorStart = SCNVector3()
    var vectorEnd = SCNVector3()
    var lines = [Line]()
    var currentLine: Line?
    var unit = LengthUnit.cenitMeter // 默认单位 cm
    
    var lengData = Double()
    
    //必备
    //    let arSCNView = ARSCNView()
    let arSession = ARSession()
    let arConfiguration = ARWorldTrackingConfiguration()
    
    var arIndex = 0
    //图
    let ArtPicNode = SCNNode()
    
    let ArtPicHaloNode = SCNNode()//光晕
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.run(configuration, options:[.resetTracking,.removeExistingAnchors])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        arSession.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setUp()
        
        alertShowBegin()
    }
    func setUp()  {
        sceneV.delegate = self
        sceneV.session = session
        InfoL.text = "Initializing Environment"
        targetIM.image = UIImage(named: "GreenTarget")
        
        
    }
    
    
    @IBOutlet weak var restB: UIButton!
    
    @IBAction func ResetClick(_ sender: UIButton) {
        
        for line in lines {
            line.remove()
        }
        lines.removeAll()
        
    }
    func reset(){
        for line in lines {
            line.remove()
        }
        lines.removeAll()
        currentLine?.remove()
        
        isMeasuring = true
        vectorStart = SCNVector3()
        vectorEnd = SCNVector3()
        
        //scanWorld()
    }
    func scanWorld(){
        //相机位置
        guard let worldPosition = sceneV.worldVector(for: view.center) else {
            return
        }
        if  lines.isEmpty {
            InfoL.text = "Start Measuring"
            restB.titleLabel?.text = ""
        }
        if isMeasuring {
            //            开始点
            if  vectorStart == vectorZero {
                vectorStart = worldPosition //  把现在的位置何止为开始
                currentLine = Line(sceneView: sceneV, startVector: vectorStart, unit: unit)
            }
            //            设置结束
            vectorEnd = worldPosition
            currentLine?.update(to: vectorEnd)
            InfoL.text = currentLine?.distance(to: vectorEnd) ?? "..."
            
            print("Moving..")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //点击屏幕开始测试
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !isMeasuring && canMeasure {
            isMeasuring = true
            reset()
            scanWorld()
            targetIM.image = UIImage(named: "GreenTarget")
            restB.titleLabel?.text = "Finished"
        }else{
            
            if canMeasure {
                canMeasure = false
                //结束
                lengData = (InfoL.text! as NSString).doubleValue
                print(lengData)
                
                alertShowEnd(leng: InfoL.text ?? "1")
                //clickInputBtn()
                
            }
            
        }
    }
    
    
    
    func showPic() {
        //设置arSCNView属性
        //arSCNView.frame = self.view.frame
        
        sceneV.session = arSession
        sceneV.automaticallyUpdatesLighting = true//自动调节亮度
        
        //self.view.addSubview(arSCNView)
        //arSCNView.delegate = self
        
        self.initNode()
        self.addLight()
//        for i in 0..<6{
//            self.addBtns(index: i)
//        }
        
        addGestureRec()
    }
    //MARK:初始化节点信息
    func initNode()  {
        //1.设置几何
        //ArtPicNode.geometry = SCNSphere(radius: 3) //球形
        //图片 45 60 | 60 50 | 80 55
        var boxW: CGFloat = 0.5
        var boxH: CGFloat = 0.5
        let boxL: CGFloat = 0.01
        if self.arIndex == 0 {
            boxW = 0.45
            boxH = 0.6
        } else if self.arIndex == 1 {
            boxW = 0.6
            boxH = 0.5
        } else if self.arIndex == 2 {
            boxW = 0.8
            boxH = 0.55
        }
        
        //创建一个长方体,用来展示图片
        ArtPicNode.geometry = SCNBox.init(width: boxW, height: boxH, length: boxL, chamferRadius: 0.1) //方形
        
        let imageA =  ["timgKuang.jpg","timg2kuang.jpg","timg3Kuang.jpg"];
        
        ArtPicNode.geometry?.firstMaterial?.diffuse.contents = imageA[self.arIndex]
        ArtPicNode.geometry?.firstMaterial?.multiply.intensity = 0.5 //強度
        ArtPicNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        
        //3.设置位置
        ArtPicNode.position = SCNVector3(0, 0.5, lengData * -0.01)
        //添加长方体到界面上
        self.sceneV.scene.rootNode.addChildNode(ArtPicNode)
        
    }
    
    func addGestureRec() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeRight.direction = .right
        self.sceneV.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeLeft.direction = .left
        self.sceneV.addGestureRecognizer(swipeLeft)
        let swipeForward = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeForward.direction = .up
        self.sceneV.addGestureRecognizer(swipeForward)
        let swipeBackward = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.handleGesture(_:)))
        swipeBackward.direction = .down
        self.sceneV.addGestureRecognizer(swipeBackward)
    }
    
    // 1
    @objc func handleGesture(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            moveUpTo(state: "left")
        case UISwipeGestureRecognizerDirection.up:
            moveUpTo(state: "up")
            
        case UISwipeGestureRecognizerDirection.down:
            moveUpTo(state: "down")
            
        case UISwipeGestureRecognizerDirection.right:
            moveUpTo(state: "right")
        
        default:
            break
        }
    }
    
    @objc func moveUpTo(state : String){
        
        var vector = SCNVector3.init()
        vector = ArtPicNode.position
        
        let dat: Float = 0.1
        //["左","上","下","右","前","后","添加"]
        if (state == "left") {
            vector.x = vector.x - dat
        } else if (state == "up") {
            vector.y += dat
        } else if (state == "down") {
            vector.y -= dat
        } else if (state == "right") {
            vector.x+=dat
        }
        ArtPicNode.position = vector;
        
    }
    
    func addLight() {
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.color = UIColor.red //被光找到的地方颜色
        
        ArtPicNode.addChildNode(lightNode)
        lightNode.light?.attenuationEndDistance = 20.0 //光照的亮度随着距离改变
        lightNode.light?.attenuationStartDistance = 1.0
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        lightNode.light?.color =  UIColor.white
        lightNode.opacity = 0.5 // make the halo stronger
        
        SCNTransaction.commit()
        ArtPicHaloNode.geometry = SCNPlane.init(width: 25, height: 25)
        
        ArtPicHaloNode.rotation = SCNVector4Make(1, 0, 0, Float(0 * Double.pi / 180.0))
        ArtPicHaloNode.geometry?.firstMaterial?.diffuse.contents = "sun-halo.png"
        ArtPicHaloNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant // no lighting
        ArtPicHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false // 不要有厚度，看起来薄薄的一层
        ArtPicHaloNode.opacity = 5
        ArtPicHaloNode.addChildNode(ArtPicHaloNode)
    }
    
    
    func addBtns(index: NSInteger) {
        
        let colorA = [UIColor.red,UIColor.green,UIColor.blue,UIColor.orange,UIColor.purple,UIColor.red,UIColor.purple];
        let titleA = ["left","up","down","right","front","back","add"];
        
        let btnW = self.view.frame.size.width/6.0;
        let btnH = 50.0;
        var org_x = 0.0;
        var org_y = self.view.frame.size.height - 50.0;
        if (index == 0) {//左
            org_x = Double(btnW * 1.5);
            org_y = self.view.frame.size.height - 100;
        } else if (index == 1) {//上
            org_x = Double(btnW * 2.5);
            org_y = self.view.frame.size.height - 150;
        } else if (index == 2) {//下
            org_x = Double(btnW * 2.5);
            org_y = self.view.frame.size.height - 50;
        } else if (index == 3) {//右
            org_x = Double(btnW * 3.5);
            org_y = self.view.frame.size.height - 100;
        } else if (index == 4) {//前
            org_x = 15;
            org_y = self.view.frame.size.height - 100;
        } else if (index == 5) {//后
            org_x = Double(self.view.frame.size.width - btnW - 15.0);
            org_y = self.view.frame.size.height - 100;
        } else if (index == 6) {//add
            org_x = Double(btnW * 2.5);
            org_y = self.view.frame.size.height - 100;
        }
        
        //创建一个ContactAdd类型的按钮
        let button:UIButton = UIButton(type:.contactAdd)
        //设置按钮位置和大小
        button.frame = CGRect(x: CGFloat(org_x), y: CGFloat(org_y), width: CGFloat(btnW), height: CGFloat(btnH))
        //设置按钮文字
        button.setTitle(titleA[index], for:.normal)
        button.setTitleColor(UIColor.white, for: .normal) //普通状态下文字的颜色
        //传递触摸对象（即点击的按钮），需要在定义action参数时，方法名称后面带上冒号
        button.addTarget(self, action:#selector(tapped(_:)), for:.touchUpInside)
        button.tag = index
        button.backgroundColor = colorA[index]
        self.view.addSubview(button)
        
    }
    
    @objc func tapped(_ button:UIButton){
        
        var vector = SCNVector3.init()
        vector = ArtPicNode.position
        
        let dat: Float = 0.1
        
        if (button.tag == 0) {
            vector.x = vector.x - dat
        } else if (button.tag == 1) {
            vector.y += dat
        } else if (button.tag == 2) {
            vector.y -= dat
        } else if (button.tag == 3) {
            vector.x+=dat
        } else if (button.tag == 4) {
            vector.z-=dat
        } else if (button.tag == 5) {
            vector.z+=dat
        }
        ArtPicNode.position = vector;
        
    }
    
    
    
    func distance(form vector:SCNVector3) -> Float {
        let distanceX = ArtPicNode.position.x - vector.x
        let distanceY = ArtPicNode.position.y - vector.y
        let distanceZ = ArtPicNode.position.z - vector.z
        
        return sqrt((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }
    
    
    //弹出带有输入框的提示框
    func alertShowBegin() {
        let view = UserView(alertViewStyle: .Default, title: "Start Measuring...", message: "Touch screen to start. Touch again to finish")
        view.messageHeight = 90
        view.titleFont = UIFont.systemFont(ofSize: 20)
        view.titleColor = UIColor.darkText
        
        view.messageFont = UIFont.systemFont(ofSize: 18)
        view.messageColor = UIColor.orange
        
        view.titleTopMargin = 6
        view.messageWithButtonMargin = 6
        
        view.cancelButtonColor = UIColor.blue
        view.cancelButtonTitleColor = UIColor.white
        view.buttonColor = UIColor.orange
        view.buttonTitleColor = UIColor.white
        //view.buttonLayerBorderColor = UIColor.blue
        
        let cancel = AEAlertAction(title: "Input", style: .Cancel) { (action) in
            view.close()
            
            self.clickInputBtn()
            print("Cancel")
        }
        view.addAction(action: cancel)
        
        let confirm = AEAlertAction(title: "Start Measuring", style: .Default) { (action) in
            view.close()
            self.canMeasure = true
            print("Confirm")
        }
        view.addAction(action: confirm)
        
        view.show()
    }
    
    //弹出带有输入框的提示框
    func alertShowEnd(leng: String) {
        let lengStr = "Please face the wall! The distance between you and wall:" + leng + "cm"
        
        let view = UserView(alertViewStyle: .Default, title: "Measurement Result", message: lengStr)
        view.messageHeight = 50
        let cancel = AEAlertAction(title: "confirm", style: .Cancel) { (action) in
            view.close()
            self.reset()
            self.isMeasuring = false
            self.canMeasure = false
            self.showPicBegin()
            print("Cancel")
        }
        view.addAction(action: cancel)
        
        let confirm = AEAlertAction(title: "Re-measure", style: .Default) { (action) in
            view.close()
//            self.reset()
            self.isMeasuring = false
            self.canMeasure = true
            print("Confirm")
        }
        view.addAction(action: confirm)
        
        let other = AEAlertAction(title: "Input", style: .Default) { (action) in
            view.close()
            print("Other")
            self.clickInputBtn()
        }
        view.addAction(action: other)
        
        view.show()
    }
    
    //弹出带有输入框的提示框
    func clickInputBtn() {
        
        //初始化UITextField
        var inputText:UITextField = UITextField();
        inputText.keyboardType = UIKeyboardType.numberPad
        
        let msgAlertCtr = UIAlertController.init(title:"Input:",message:"Please enter the distance between you and wall",preferredStyle:.alert)
        
        let ok = UIAlertAction.init(title:"Confirm",style:.default){(action:UIAlertAction)->()in
            
            if((inputText.text) != ""){
                self.reset()
                self.isMeasuring = false
                self.canMeasure = false
                //判断是否是合法数据
                self.lengData = 100.0 * (inputText.text! as NSString).doubleValue
                self.showPicBegin()
            }
        }
        
        let cancel = UIAlertAction.init(title:"Cancel",style:.cancel){(action:UIAlertAction)->()in
            
            print("Cancel")
            
        }
        
        msgAlertCtr.addAction(ok)
        
        msgAlertCtr.addAction(cancel)
        
        //添加textField输入框
        
        msgAlertCtr.addTextField { (textField)in
            
            //设置传入的textField为初始化UITextField
            
            inputText = textField
            
            inputText.placeholder = "Input"
            
        }
        
        //设置到当前视图
        
        self.present(msgAlertCtr, animated: true,completion:nil)
        
    }
    

        func showPicBegin() {
                session.pause()

                InfoL.isHidden = true
                restB.isHidden = true
                targetIM.isHidden = true

                arConfiguration.isLightEstimationEnabled = true//自适应灯光（室內到室外的話 畫面會比較柔和）
                arSession.run(arConfiguration, options: [.removeExistingAnchors,.resetTracking])

                //开始挂画
                //self.arIndex = 0

                showPic()
        }

}
extension ViewController:ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            if self.canMeasure {
                self.scanWorld()
            }
        }
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        if canMeasure {
            InfoL.text = "Error"
        }
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        if canMeasure {
            InfoL.text = "Stoped"
        }
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        if canMeasure {
            InfoL.text = "End"
        }
        
    }
}
