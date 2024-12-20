import QtQuick 2.3
import "../Global"
import "../Lists"

FocusScope {
id: root

	//ListView model传入的数据
	property var collection

	property bool selected: ListView.isCurrentItem && ListView.view.focus

	property bool showTitles: settings.AlwaysShowTitles === "Yes"
	property bool showHighlightedTitles: showTitles
	property int titleHeight: (showTitles || showHighlightedTitles) ? vpx(36) : 0

	//GridSpacer { id: fakebox;  }

    // 动态加载器
    Loader {
        id: dynamicLoader
		anchors.fill: parent
		focus: parent.selected
		asynchronous: true

		// 根据条件切换子组件
		sourceComponent: { 
			switch (collection.shortName) {
				case "favorites":
					{
						parent.height = vpx(480); //vpx(410)
						return featuredComponent;
					}
					break;
				case "platforms":
					{
						parent.height = vpx(123)	//cellheight:87 + spacing:12 + globalMargin:30
						return platformComponent;
					}
					break;
				default:
					break;
			}
			let numColumns = settings.GridColumns;
			let spacing = (parent.width - globalMargin * 2) / numColumns * 0.08;
			let cw = (parent.width - globalMargin * 2 + spacing) / numColumns - spacing;

			// 因为会有多种分类的混合在一起，图片比例多样, 所以使用collection中的固定比例
			let ch = cw * collection.aspectRatio;

			// 列表标题高18
			parent.height = ch + titleHeight + vpx(18) + spacing + globalMargin;
			return collectionComponent;
		}

    }

	// 主页的收藏列表，播放视频
	Component {
	id: featuredComponent

		FeaturedList {
			focus: root.selected
			collection: root.collection
            height: root.height
		}
	}

	//平台列表
	Component {
	id: platformComponent

		PlatformList {
			focus: root.selected
			collection: root.collection
            height: root.height
			onActivateSelected: {
				currentCollectionIndex = currentIndex;
				gameListScreen();            
			}
			onListHighlighted: {
				mainList.currentIndex = index;
			}
		}
	}


	// 各种过滤后的游戏列表
	Component {
	id: collectionComponent
		
		HorizontalCollection {
		id: horizontalCollection
            focus: root.selected
            collection: root.collection
            visible: collection.enabled
            title: collection.title
			onActivateSelected: {
				gameDetailsScreen(gameList.currentGame(currentIndex));
			}
			onListHighlighted: {
				mainList.currentIndex = index;
			}
		}
	}

}
