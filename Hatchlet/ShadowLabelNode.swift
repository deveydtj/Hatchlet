//
//  ShadowLabelNode.swift
//  Hatchlet
//

import SpriteKit

final class ShadowLabelNode: SKNode {
    let labelNode: SKLabelNode
    let shadowNode: SKLabelNode

    var text: String? {
        get { labelNode.text }
        set {
            labelNode.text = newValue
            shadowNode.text = newValue
        }
    }

    var fontName: String? {
        get { labelNode.fontName }
        set {
            labelNode.fontName = newValue
            shadowNode.fontName = newValue
        }
    }

    var fontSize: CGFloat {
        get { labelNode.fontSize }
        set {
            labelNode.fontSize = newValue
            shadowNode.fontSize = newValue
        }
    }

    var fontColor: UIColor? {
        get { labelNode.fontColor }
        set { labelNode.fontColor = newValue }
    }

    var shadowColor: UIColor? {
        get { shadowNode.fontColor }
        set { shadowNode.fontColor = newValue }
    }

    var horizontalAlignmentMode: SKLabelHorizontalAlignmentMode {
        get { labelNode.horizontalAlignmentMode }
        set {
            labelNode.horizontalAlignmentMode = newValue
            shadowNode.horizontalAlignmentMode = newValue
        }
    }

    var verticalAlignmentMode: SKLabelVerticalAlignmentMode {
        get { labelNode.verticalAlignmentMode }
        set {
            labelNode.verticalAlignmentMode = newValue
            shadowNode.verticalAlignmentMode = newValue
        }
    }

    var shadowOffset: CGPoint {
        didSet {
            shadowNode.position = shadowOffset
        }
    }

    var labelFrame: CGRect {
        labelNode.frame
    }

    init(
        fontNamed: String? = nil,
        text: String? = nil,
        shadowOffset: CGPoint = CGPoint(x: 2, y: -1),
        shadowColor: UIColor? = .init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.75)
    ) {
        labelNode = SKLabelNode(fontNamed: fontNamed)
        shadowNode = SKLabelNode(fontNamed: fontNamed)
        self.shadowOffset = shadowOffset
        super.init()

        shadowNode.zPosition = -1
        shadowNode.position = shadowOffset
        addChild(shadowNode)
        addChild(labelNode)

        self.shadowColor = shadowColor
        self.text = text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func runOnBoth(_ action: SKAction, withKey key: String? = nil) {
        if let key {
            labelNode.run(action, withKey: key)
            shadowNode.run(action, withKey: key)
        } else {
            labelNode.run(action)
            shadowNode.run(action)
        }
    }

    func removeActionFromAll(forKey key: String) {
        removeAction(forKey: key)
        labelNode.removeAction(forKey: key)
        shadowNode.removeAction(forKey: key)
    }

    func removeAllTextActions() {
        removeAllActions()
        labelNode.removeAllActions()
        shadowNode.removeAllActions()
    }
}
