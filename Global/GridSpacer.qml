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
import "../utils.js" as Utils
Image {
id: root

    property var collection
	property real aspectRatio: source ? paintedHeight / paintedWidth : 1.4175

    // This is a workaround that's necessary in order to accurately get the aspect ratio for the boxart
    // It grabs the first game and bases all the aspect ratios off that
    property var fakesource: {
		if (collection) {
			for (let i = 0; i < 5; i++) {
				let gamesource = collection.games.get(i);
				if (gamesource && gamesource.assets) {
					let boxart = Utils.boxArt(gamesource);
					if (boxart !== "") {
						return boxart;
					}
				}
			}
		}
    }

    sourceSize { width: 50; height: 50 }
    fillMode: Image.PreserveAspectFit
    source: fakesource ? fakesource : ""
    asynchronous: true
    visible: false
	width: vpx(100)
	height: vpx(100)
}
