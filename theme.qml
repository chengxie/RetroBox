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
import SortFilterProxyModel 0.2
import QtMultimedia 5.9
import "Global"
import "Screens"
import "Lists"
import "utils.js" as Utils
import "themes.js" as Themes
import "config.js" as Config

FocusScope {
id: root

    FontLoader { id: titleFont; source:      "assets/fonts/YaHei-Bold.ttf" }
    FontLoader { id: subtitleFont; source:   "assets/fonts/YaHei-Bold.ttf" }
    FontLoader { id: bodyFont; source:       "assets/fonts/YaHei.ttf" }

    // Pull in our custom lists and define
    ListAllGames		{ id: listNone;        max: 0 }
    ListAllGames		{ id: listAllGames;	   max: 0 }
    ListCollectionGames { id: listCollectionGames; }
    ListFavorites		{ id: listFavorites;   max: settings.ShowcaseColumns }
    ListLastPlayed		{ id: listLastPlayed;  max: settings.ShowcaseColumns }
    ListMostPlayed		{ id: listMostPlayed;  max: settings.ShowcaseColumns }
    ListRecommended		{ id: listRecommended; max: settings.ShowcaseColumns }
    ListPublisher		{ id: listPublisher;   max: settings.ShowcaseColumns; publisher: randoPub }
    ListGenre			{ id: listGenre;       max: settings.ShowcaseColumns; genre: randoGenre }
	ListPlatforms		{ id: listPlatforms;   max: 0 }

    property string randoPub: (Utils.returnRandom(Utils.uniqueValuesArray('publisher')) || '')
    property string randoGenre: (Utils.returnRandom(Utils.uniqueValuesArray('genreList'))[0] || '').toLowerCase()

    // Load settings
    property var settings: {

		let config = {
			get: function (name) {
				return api.memory.has(name) ? api.memory.get(name) : this[name]
			}
		}

		let all = Config.default_config()
		for (let items of Object.values(all)) {
			for (let it of items) {
				config[it.name] = it.default_value
			}
		}

        return {
            GridColumns:                   config.get("Number of columns"),
            AlwaysShowTitles:              config.get("Always show titles"),
            AlwaysShowHighlightedTitles:   config.get("Always show highlighted titles"),
            BorderHighlight:               config.get("Border highlight"),
            HideButtonHelp:                config.get("Hide button help"),
            ColorLayout:                   config.get("Color Layout"),
			ColorBackground:               config.get("Color Background"),
            MouseHover:                    config.get("Enable mouse hover"),

			ShowcaseColumns:               config.get("Number of games showcased"),
			ShowcaseFeaturedCollection:    config.get("Featured collection"),
			ShowcaseCollection1:           config.get("Collection 1"),
			ShowcaseCollection2:           config.get("Collection 2"),
			ShowcaseCollection3:           config.get("Collection 3"),
			ShowcaseCollection4:           config.get("Collection 4"),
			ShowcaseCollection5:           config.get("Collection 5"),

			VideoPreview:                  config.get("Video preview"),
			AllowVideoPreviewAudio:        config.get("Video preview audio"),
			ShowScanlines:                 config.get("Show scanlines"),

        }
    }

	property var modelList: [
		getCollection("Favorites"),
		getCollection("Platforms"),
		getCollection(settings.ShowcaseCollection1),
		getCollection(settings.ShowcaseCollection2),
		getCollection(settings.ShowcaseCollection3),
		getCollection(settings.ShowcaseCollection4),
		getCollection(settings.ShowcaseCollection5),
	]

    function getCollection(collectionName) {
        var collection = {
            enabled: collectionName !== "None",
			aspectRatio: 1.4175
        };

        switch (collectionName) {
            case "Favorites":
                collection.search = listFavorites;
                break;
			case "Platforms":
                collection.search = listPlatforms;
				collection.aspectRatio = 0.5;
				break;
            case "Recently Played":
                collection.search = listLastPlayed;
                break;
            case "Most Played":
                collection.search = listMostPlayed;
                break;
            case "Recommended":
                collection.search = listRecommended;
                break;
            case "Top by Publisher":
                collection.search = listPublisher;
                break;
            case "Top by Genre":
                collection.search = listGenre;
                break;
            case "None":
                collection.search = listNone;
                break;
            default:
                collection.search = listAllGames;
                break;
        }

		collection.index = collection.search.games.count > 0 ? 0 : -1;
        collection.title = collection.search.collection.name;
		collection.shortName = collection.search.collection.shortName;
        return collection;
    }

    // Collections
    property int currentCollectionIndex: 0
    property int currentGameIndex: 0
    property var currentCollection: api.collections.get(currentCollectionIndex)    
    property var currentGame

    // Stored variables for page navigation
    property int storedHomePrimaryIndex: 0
    property int storedCollectionGameIndex: -1
	property int showcaseHeaderMenuIndex: -1

    // Reset the stored game index when changing collections
    onCurrentCollectionIndexChanged: storedCollectionGameIndex = -1

    // Filtering options
    property bool showFavs: false
    property var sortByFilter: ["title", "lastPlayed", "playCount", "rating"]
    property int sortByIndex: 0
    property var orderBy: Qt.AscendingOrder
	property bool searchAllGames: true
    property string searchTerm: ""
    property bool steam: currentCollection.name === "Steam"
    function steamExists() {
        for (i = 0; i < api.collections.count; i++) {
            if (api.collections.get(i).name === "Steam") {
                return true;
            }
            return false;
        }
    }

    // Functions for switching currently active collection
    function toggleFavs() {
        showFavs = !showFavs;
    }

    function cycleSort() {
        if (sortByIndex < sortByFilter.length - 1) {
            sortByIndex++;
		} else {
            sortByIndex = 0;
		}
		
		switch (sortByFilter[sortByIndex]) {
			case "title":
				orderBy = Qt.AscendingOrder;
				break;
			case "lastPlayed":
			case "playCount":
				orderBy = Qt.DescendingOrder;
				break;
		}
    }

    function toggleOrderBy() {
        if (orderBy === Qt.AscendingOrder)
            orderBy = Qt.DescendingOrder;
        else
            orderBy = Qt.AscendingOrder;
    }

    // Launch the current game
    function launchGame(game) {
        if (game !== null) {
            //if (game.collections.get(0).name === "Steam")
                launchGameScreen();
			
            saveCurrentState(game);
            game.launch();
        } else {
            //if (currentGame.collections.get(0).name === "Steam")
                launchGameScreen();

            saveCurrentState(currentGame);
            currentGame.launch();
        }
    }

    // Save current states for returning from game
    function saveCurrentState(game) {
        api.memory.set('savedState', root.state);
        api.memory.set('savedCollection', currentCollectionIndex);
        api.memory.set('lastState', JSON.stringify(lastState));
        api.memory.set('storedHomePrimaryIndex', storedHomePrimaryIndex);
        api.memory.set('storedCollectionGameIndex', storedCollectionGameIndex);

        const savedGameIndex = api.allGames.toVarArray().findIndex(g => g === game);
        api.memory.set('savedGame', savedGameIndex);
        api.memory.set('To Game', 'True');
    }

    // Handle loading settings when returning from a game
    property bool fromGame: api.memory.has('To Game');
    function returnedFromGame() {
        lastState                   = JSON.parse(api.memory.get('lastState'));
        currentCollectionIndex      = api.memory.get('savedCollection');
        storedHomePrimaryIndex      = api.memory.get('storedHomePrimaryIndex');
        storedCollectionGameIndex   = api.memory.get('storedCollectionGameIndex');

        currentGame                 = api.allGames.get(api.memory.get('savedGame'));
        root.state                  = api.memory.get('savedState');

        // Remove these from memory so as to not clog it up
        api.memory.unset('savedState');
        api.memory.unset('savedGame');
        api.memory.unset('lastState');
        api.memory.unset('storedHomePrimaryIndex');
        api.memory.unset('storedCollectionGameIndex');

        // Remove this one so we only have it when we come back from the game and not at Pegasus launch
        api.memory.unset('To Game');
    }

    // Theme settings
	property var theme: Themes.get(settings.ColorBackground, settings.ColorLayout)
    property real globalMargin: vpx(30)
    property real helpMargin: buttonbar.height
    property int transitionTime: 100

    // State settings
    states: [
        State {
            name: "gamelist_screen";
        },
		State {
			name: "search_screen";
		},
        State {
            name: "showcase_screen";
        },
        State {
            name: "gamedetails_screen";
        },
        State {
            name: "settings_screen";
        },
        State {
            name: "launchgame_screen";
        }
    ]

    property var lastState: []

    // Screen switching functions
    function showcaseScreen() {
        sfxAccept.play();
        lastState.push(state);
        root.state = "showcase_screen";
    }

    function gameListScreen() {
        sfxAccept.play();
        lastState.push(state);
        searchTerm = "";
        root.state = "gamelist_screen";
    }

	function searchScreen() {
		sfxAccept.play();
        lastState.push(state);
        searchTerm = "";
		storedCollectionGameIndex = -1;
        root.state = "search_screen";
	}

    function settingsScreen() {
        sfxAccept.play();
        lastState.push(state);
        root.state = "settings_screen";
    }

    function gameDetailsScreen(game) {
        sfxAccept.play();

        // Push the new game
        if (game !== null) {
            currentGame = game;
		}

        // Save the state before pushing the new one
        lastState.push(state);
        root.state = "gamedetails_screen";
    }

    function launchGameScreen() {
        sfxAccept.play();
        lastState.push(state);
        root.state = "launchgame_screen";
    }

    function previousScreen() {
        sfxBack.play();
        state = lastState[lastState.length - 1];
        lastState.pop();
    }

    // Set default state to the platform screen
    Component.onCompleted: { 
        root.state = "showcase_screen";
        if (fromGame)
            returnedFromGame();
    }

    // Background
    Rectangle {
        anchors.fill: parent
        color: theme.primary
        //Image { source: "assets/images/backgrounds/halo.jpg"; fillMode: Image.PreserveAspectFit; anchors.fill: parent;  opacity: 0.3 }
		//gradient: Gradient {
			//GradientStop { position: 1.0; color: Qt.rgba(1/255.0, 2/255.0, 67/255.0, 1.0) }
			//GradientStop { position: 0.66; color: Qt.rgba(1/255.0, 73/255.0, 183/255.0, 1.0) }
			//GradientStop { position: 0.33; color: Qt.rgba(1/255.0, 93/255.0, 194/255.0, 1.0) }
			//GradientStop { position: 0.0; color: Qt.rgba(3/255.0, 162/255.0, 254/255.0, 1.0) }
		//}
    }

    ScreenLoader  {
        focus: (root.state === "showcase_screen")
        sourceComponent: ShowcaseView { focus: true }
    }

    ScreenLoader  {
        focus: (root.state === "gamelist_screen")
        sourceComponent: GameListView { focus: true }
    }

    ScreenLoader  {
        focus: (root.state === "search_screen")
        sourceComponent: SearchView { focus: true }
    }

    ScreenLoader  {
        focus: (root.state === "gamedetails_screen")
        sourceComponent: GameDetailsView { focus: true; game: currentGame }
    }

    ScreenLoader  {
        focus: (root.state === "launchgame_screen")
        sourceComponent: LaunchGameView { focus: true }
    }

    ScreenLoader  {
        focus: (root.state === "settings_screen")
        sourceComponent: SettingsView { focus: true }
    }
    
    // Button help
    property var currentHelpbarModel
    ButtonHelpBar {
    id: buttonbar
        anchors {
            left: parent.left; right: parent.right
            bottom: parent.bottom
        }
        height: vpx(50)
        visible: settings.HideButtonHelp === "No"
    }

    ///////////////////
    // SOUND EFFECTS //
    ///////////////////
    SoundEffect {
        id: sfxNav
        source: "assets/sfx/navigation.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxBack
        source: "assets/sfx/back.wav"
        volume: 1.0
    }

    SoundEffect {
        id: sfxAccept
        source: "assets/sfx/accept.wav"
    }

    SoundEffect {
        id: sfxToggle
        source: "assets/sfx/toggle.wav"
    }
    
}

