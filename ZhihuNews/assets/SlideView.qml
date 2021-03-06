import bb.cascades 1.2
import "controls"

Page {
    id: viewRoot
    property variant dataModel
    property variant indexPath
    
    property variant ctrls : new Array("ctrl1", "ctrl2", "ctrl3")
    property int width : _display.width
    property int slideThreshold : _display.width/4
    property bool atBeginning : false    
    property bool atEnd : false
    
    property int fontSize : 30
    property string theme
    property variant title_color
    property variant info_color
    property variant background_color
    property string styleUrl
    
    onIndexPathChanged: {
        getCtrl(ctrls[1]).controls[0].indexPath = indexPath;
        if (indexPath == undefined)
        {
            getCtrl(ctrls[0]).controls[0].indexPath = undefined;
            getCtrl(ctrls[2]).controls[0].indexPath = undefined;
            return ;
        }
        checkBothSide();
        _app.setNewsRead(indexPath);
    }
    
    function checkBothSide() {
        var next = dataModel.after(indexPath);
        if (next.length>0)
        {
            getCtrl(ctrls[2]).controls[0].indexPath = next;
            atEnd = false;
        }
        else 
        {
            atEnd = true;
        }
        var pre = dataModel.before(indexPath);
        if (pre.length>0)
        {
            getCtrl(ctrls[0]).controls[0].indexPath = pre;
            atBeginning = false;
        }
        else 
        {
            atBeginning = true;
        }
    }
    
    function getCtrl(str) {
        switch (str)
        {
            case "ctrl1":
                return ctrl1;
            case "ctrl2":
                return ctrl2;
            case "ctrl3":
                return ctrl3;
        }
    }
    
    function newLeftSlideList()
    {
        var tmp = [];
        tmp[0] = ctrls[1];
        tmp[1] = ctrls[2];
        tmp[2] = ctrls[0];
        return tmp;
    }
    
    function newRightSlideList()
    {
        var tmp = [];
        tmp[0] = ctrls[2];
        tmp[1] = ctrls[0];
        tmp[2] = ctrls[1];
        return tmp;
    }
    
    function resetPosition() {
        getCtrl(ctrls[0]).layoutProperties.positionX = -width;
        getCtrl(ctrls[1]).layoutProperties.positionX = 0;
        getCtrl(ctrls[2]).layoutProperties.positionX = width;
    }
    
    function leftSlide() {
        //tip qml里的数组变化必须通过这种形式
        ctrls = newLeftSlideList();
        getCtrl(ctrls[0]).layoutProperties.positionX = -width;
        getCtrl(ctrls[1]).layoutProperties.positionX = 0;
        var tmp = getCtrl(ctrls[2]);
        tmp.visible = false;
        tmp.layoutProperties.positionX = width;
        tmp.visible = true;
    }
    
    function rightSlide() {
        ctrls = newRightSlideList();
        var tmp = getCtrl(ctrls[0]);
        tmp.visible = false;
        tmp.layoutProperties.positionX = -width;
        tmp.visible = true;
        getCtrl(ctrls[1]).layoutProperties.positionX = 0;
        getCtrl(ctrls[2]).layoutProperties.positionX = width;
    }
    
    Container {
        layout: DockLayout {

        }
        MotionHandler {
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
            
            onSlideLeftRight: {
                if (offset>0 && !atBeginning)    //右划
                {
                    getCtrl(ctrls[0]).layoutProperties.positionX = -width+offset;
                    getCtrl(ctrls[1]).layoutProperties.positionX = offset;
                }
                else if (offset<0 && !atEnd)    //左划
                {
                    getCtrl(ctrls[1]).layoutProperties.positionX = offset;
                    getCtrl(ctrls[2]).layoutProperties.positionX = width+offset;
                }
            }
            
            onSlideLeftRightFinished: {
                if (offset>slideThreshold)    //右划
                {
                    if (atBeginning)
                    {
                        qmlRoot.promptMsg(qsTr("At Beginning"));
                    }
                    else 
                    {
                        rightSlide();
                        indexPath = dataModel.before(indexPath);
                    }
                }
                else if (offset<-slideThreshold)    //左划
                {
                    if (atEnd)
                    {
                        qmlRoot.promptMsg(qsTr("At End"));
                    }
                    else 
                    {
                        leftSlide();
                        indexPath = dataModel.after(indexPath);
                    }
                }
                else 
                {
                    resetPosition();
                }
            }
            
            onClick: {
                setContainer.visible = false;
            }
            
            Container {
                id: viewContainer
                layout: AbsoluteLayout {
                
                }        
                background: background_color  
                Container {
                    id: ctrl1
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: - width
                    }
                    preferredWidth: width
                    ArticleView {
                        dataModel: viewRoot.dataModel
                        title_color : viewRoot.title_color
                        background_color: viewRoot.background_color
                        info_color: viewRoot.info_color
                        styleUrl: viewRoot.styleUrl
                        fontSize: viewRoot.fontSize
                    }
                }
                Container {
                    id: ctrl2
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 0
                    }
                    preferredWidth: width
                    ArticleView {
                        dataModel: viewRoot.dataModel
                        title_color : viewRoot.title_color
                        background_color: viewRoot.background_color
                        info_color: viewRoot.info_color
                        styleUrl: viewRoot.styleUrl
                        fontSize: viewRoot.fontSize
                    }
                }
                Container {
                    id: ctrl3
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: width
                    }
                    preferredWidth: width
                    ArticleView {
                        dataModel: viewRoot.dataModel
                        title_color : viewRoot.title_color
                        background_color: viewRoot.background_color
                        info_color: viewRoot.info_color
                        styleUrl: viewRoot.styleUrl
                        fontSize: viewRoot.fontSize
                    }
                }
            }
        }
        
        Container {
            id: setContainer
            verticalAlignment: VerticalAlignment.Bottom
            background: Color.create("#ffffff")
            preferredWidth: width
            visible: false
            Container {
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                
                }
                horizontalAlignment: HorizontalAlignment.Fill
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.0                    
                    }                    
                    layout: DockLayout {

                    }
                    Label {
                        text: "A"
                        textStyle.fontSize: FontSize.Small
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Right
                        textStyle.textAlign: TextAlign.Center
                        //textStyle.color: Color.create("#fffbf2")
                    }
                }
                
                Slider {
                    id: fontSizeSetter
                    fromValue: 20.0
                    toValue: 70.0
                    value: fontSize
                    onValueChanged: {
                        fontSize = Math.round(value);
                    }
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 4.0
                    
                    }
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                }
                Container {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1.0
                    
                    }
                    layout: DockLayout {

                    }
                    Label {
                        text: "A"
                        textStyle.fontSize: FontSize.XLarge
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Left
                        //textStyle.color: Color.create("#fffbf2")
                    }
                }
            }
            Container {
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                SegmentedControl {
                    id: themeSetter
                    Option {
                        text: qsTr("Bright")
                        value: "bright"
                        imageSource: "asset:///icon/bright.png"
                    }
                    Option {
                        text: qsTr("Dark")
                        value: "dark"
                        imageSource: "asset:///icon/dark.png"
                    }
                    Option {
                        text: qsTr("Sepia")
                        value: "custom"
                        imageSource: "asset:///icon/custom.png"
                    }
                    onSelectedIndexChanged: {
                        theme = themeSetter.selectedValue;
                    }
                }
            }
            Divider {
                opacity: 0.0
            }
        }
    }
    
    
    actions: [
        ActionItem {
            onTriggered: {
                qmlRoot.closeArticle();
                indexPath = undefined;
            }
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "asset:///icon/ic_previous.png"
            title: qsTr("Back")
        },
        InvokeActionItem {
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            onTriggered: {
                var e = dataModel.data(indexPath);
                var text = e.title + "\n" + e.share_url;
                data = _app.encodeQString(text);
                console.log(data);
            }
            ActionBar.placement: ActionBarPlacement.OnBar
        },
        ActionItem {
            title: qsTr("Open In Brower")
            onTriggered: {
                _appInvoker.openBrowser(dataModel.data(indexPath).share_url);
            }
            imageSource: "asset:///icon/ic_browser.png"
            ActionBar.placement: ActionBarPlacement.OnBar
        }/*,
        ActionItem {
            title: qsTr("Theme")
            onTriggered: {
                setContainer.visible = true;
            }
            imageSource: "asset:///icon/ic_theme.png"
            ActionBar.placement: ActionBarPlacement.OnBar
        }*/
    ]
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onCreationCompleted: {
    }
}
