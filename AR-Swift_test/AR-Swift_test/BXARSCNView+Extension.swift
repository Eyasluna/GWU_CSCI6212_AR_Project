

import ARKit
extension ARSCNView{
    //拿到三维坐标
    //参数为点->返回一个三维坐标
    func worldVector(for position:CGPoint) ->SCNVector3?{
        
        //result
        let results = hitTest(position, types: [.featurePoint])//相册与物件之间的距离用,用来搜索ARSession检测到的锚点,还有真实世界的对象而不是view里面的SceneKit里面的内容,假设找内容的话用(option)
        guard let result = results.first else {
            return nil
        }
        //-->返回相机的位置
        return SCNVector3.positionTranform(result.worldTransform)
        
    }
    
    
    
}
