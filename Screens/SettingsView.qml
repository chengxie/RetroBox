// gameOS theme
// Copyright (C) 2018-2020 Seth Powell 
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.0
import QtQuick.Layouts 1.11
import "../config.js" as Config

FocusScope {
id: root

	property var configList: {
		let all = Config.default_config();
		let l = [];
		for (let [name, items] of Object.entries(all)) {
			l.push({ name: name, items: items });
		}
		return l;
	}

    property real itemheight: vpx(50)

    Rectangle {
    id: header

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: vpx(75)
        color: theme.primary
        z: 5

		Image {
		id: settingsicon
			source: "../assets/images/settingsicon.svg"
			//color: selected ? theme.accent : "transparent"
			width: vpx(35)
			height: vpx(35)
			anchors {
				left: parent.left; leftMargin: globalMargin
				verticalCenter: parent.verticalCenter
			}
		}

        // Platform title
        Text {
        id: headertitle
            
            text: "Settings"
            anchors {
                top: parent.top;
                left: settingsicon.right; leftMargin: vpx(15)
                right: parent.right
                bottom: parent.bottom
            }
            
            color: theme.text
            font.family: titleFont.name
            font.pixelSize: vpx(30)
            font.bold: true
            horizontalAlignment: Text.AlignHLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight

            // Mouse/touch functionality
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    previousScreen();
                }
            }
        }
    }

    ListView {
    id: pagelist
    
        focus: true
        anchors {
            top: header.bottom
            bottom: parent.bottom; bottomMargin: helpMargin
            left: parent.left; leftMargin: globalMargin
        }
        width: vpx(300)
        model: configList
        delegate: Item {
			property bool selected: ListView.isCurrentItem

			width: ListView.view.width
			height: itemheight

			// Page name
			Text {
				text: modelData.name
				color: theme.text
				font.family: subtitleFont.name
				font.pixelSize: vpx(22)
				font.bold: true
				verticalAlignment: Text.AlignVCenter
				opacity: selected ? 1 : 0.5
				width: contentWidth
				height: parent.height
				anchors {
					left: parent.left; leftMargin: vpx(25)
				}
			}

			// Mouse/touch functionality
			MouseArea {
				anchors.fill: parent
				hoverEnabled: settings.MouseHover == "Yes"
				onEntered: { sfxNav.play(); }
				onClicked: {
					sfxNav.play();
					pagelist.currentIndex = index;
					settingsList.focus = true;
				}
			}

        } 

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
        Keys.onPressed: {
            // Accept
            if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                event.accepted = true;
                sfxAccept.play();
                settingsList.focus = true;
            }
            // Back
            if (api.keys.isCancel(event) && !event.isAutoRepeat) {
                event.accepted = true;
                previousScreen();
            }
        }

    }

    Rectangle {
        anchors {
            left: pagelist.right;
            top: pagelist.top; bottom: pagelist.bottom
        }
        width: vpx(1)
        color: theme.text
        opacity: 0.5
    }

    ListView {
    id: settingsList
        
        anchors {
            top: header.bottom; bottom: parent.bottom; 
            left: pagelist.right; leftMargin: globalMargin
            right: parent.right; rightMargin: globalMargin
        }
        width: vpx(500)

        spacing: vpx(0)
        orientation: ListView.Vertical

        preferredHighlightBegin: height / 2 - itemheight
        preferredHighlightEnd: height / 2
        highlightRangeMode: ListView.ApplyRange
        highlightMoveDuration: 200
        clip: true

        model: configList[pagelist.currentIndex].items
        delegate: Item {
			property bool selected: ListView.isCurrentItem && ListView.view.focus
			property var settingList: modelData.options.split(',')
			property var value: api.memory.has(modelData.name) ? api.memory.get(modelData.name) : modelData.default_value
			property int savedIndex: settingList.findIndex(v => v === value);

			function saveSetting() {
				api.memory.set(modelData.name, settingList[savedIndex]);
			}

			function nextSetting() {
				if (savedIndex != settingList.length -1)
				savedIndex++;
				else
				savedIndex = 0;
			}

			function prevSetting() {
				if (savedIndex > 0)
				savedIndex--;
				else
				savedIndex = settingList.length -1;
			}

			width: ListView.view.width
			height: itemheight

			// Setting name
			Text {
				text: modelData.name + ": "
				color: theme.text
				font.family: subtitleFont.name
				font.pixelSize: vpx(20)
				verticalAlignment: Text.AlignVCenter
				opacity: selected ? 1 : 0.5
				width: contentWidth
				height: parent.height
				anchors {
					left: parent.left; leftMargin: vpx(25)
				}
			}
			// Setting value
			Text { 
				text: settingList[savedIndex]; 
				color: theme.text
				font.family: subtitleFont.name
				font.pixelSize: vpx(20)
				verticalAlignment: Text.AlignVCenter
				opacity: selected ? 1 : 0.5
				height: parent.height
				anchors {
					right: parent.right; rightMargin: vpx(25)
				}
			}

			Rectangle {
				anchors { 
					left: parent.left; leftMargin: vpx(25)
					right: parent.right; rightMargin: vpx(25)
					bottom: parent.bottom
				}
				color: theme.text
				opacity: selected ? 0.5 : 0
				height: vpx(1)
			}

			// Input handling
			// Next setting
			Keys.onRightPressed: {
				sfxToggle.play()
				nextSetting();
				saveSetting();
			}
			// Previous setting
			Keys.onLeftPressed: {
				sfxToggle.play();
				prevSetting();
				saveSetting();
			}

			Keys.onPressed: {
				// Accept
				if (api.keys.isAccept(event) && !event.isAutoRepeat) {
					event.accepted = true;
					sfxToggle.play()
					nextSetting();
					saveSetting();
				}
				// Back
				if (api.keys.isCancel(event) && !event.isAutoRepeat) {
					event.accepted = true;
					sfxBack.play()
					pagelist.focus = true;
				}
			}

			// Mouse/touch functionality
			MouseArea {
				anchors.fill: parent
				hoverEnabled: settings.MouseHover == "Yes"
				onEntered: { sfxNav.play(); }
				onClicked: {
					sfxToggle.play();
					if(selected){ 
						nextSetting();
						saveSetting();
					} else {
						settingsList.focus = true;
						settingsList.currentIndex = index;
					}
				}
			}
        } 

        Keys.onUpPressed: { sfxNav.play(); decrementCurrentIndex() }
        Keys.onDownPressed: { sfxNav.play(); incrementCurrentIndex() }
    }

    // Helpbar buttons
    ListModel {
        id: settingsHelpModel

        ListElement {
            name: "Back"
            button: "cancel"
        }

        ListElement {
            name: "Select"
            button: "accept"
        }
    }
    
    onFocusChanged: { if (focus) currentHelpbarModel = settingsHelpModel; }

}
