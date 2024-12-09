/**
* @file		config.js
* @brief	
* @author	My name is CHENG XIE. I am your God! wa hahaha...
* @version	1.0
* @date		2024-12-10
*/


function default_config() {

	return {
		"General": [
			{
				name: "Number of columns",
				options: "5,6,7,8",
				default_value: "7",
			},
			{
				name: "Always show titles",
				options: "Yes,No",
				default_value: "Yes",
			},
			{
				name: "Always show highlighted titles",
				options: "Yes,No",
				default_value: "Yes",
			},
			{
				name: "Border highlight",
				options: "Yes,No",
				default_value: "No",
			},
			{
				name: "Hide button help",
				options: "Yes,No",
				default_value: "No",
			},
			{
				name: "Color Layout",
				options: "Dark Green,Light Green,Turquoise,Dark Red,Light Red,Dark Pink,Light Pink,Dark Blue,Light Blue,Orange,Yellow,Magenta,Purple,Dark Gray,Light Gray,Steel,Stone,Dark Brown,Light Brown",
				default_value: "Dark Green",
			},
			{
				name: "Color Background",
				options: "Black,Gray,Blue,Green,Red",
				default_value: "Black",
			},
			{
				name: "Enable mouse hover",
				options: "Yes,No",
				default_value: "No",
			},
		],
		"Home page": [
			{
				name: "Number of games showcased",
				options: "15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,1,2,3,4,5,6,7,8,9,10,11,12,13,14",
				default_value: "15",
			},
			//{
				//name: "Featured collection",
				//options: "Favorites,Recently Played,Recommended,Most Played,Top by Publisher,Top by Genre",
				//default_value: "Favorites",
			//},
			{
				name: "Collection 1",
				options: "Favorites,Recently Played,Recommended,Most Played,Top by Publisher,Top by Genre",
				default_value: "Recently Played",
			},
			{
				name: "Collection 2",
				options: "Favorites,Recently Played,Recommended,Most Played,Top by Publisher,Top by Genre",
				default_value: "Recommended",
			},
			{
				name: "Collection 3",
				options: "Favorites,Recently Played,Recommended,Most Played,Top by Publisher,Top by Genre",
				default_value: "Most Played",
			},
			{
				name: "Collection 4",
				options: "Favorites,Recently Played,Recommended,Most Played,Top by Publisher,Top by Genre",
				default_value: "Top by Genre",
			},
			{
				name: "Collection 5",
				options: "Favorites,Recently Played,Recommended,Most Played,Top by Publisher,Top by Genre",
				default_value: "Top by Publisher",
			},
		],
		"Game details": [
			{
				name: "Video preview",
				options: "Yes,No",
				default_value: "Yes",
			},
			{
				name: "Video preview audio",
				options: "Yes,No",
				default_value: "No",
			},
			{
				name: "Show scanlines",
				options: "Yes,No",
				default_value: "Yes",
			},
		]
	}
}
