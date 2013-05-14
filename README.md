OpenWatch for iOS
=================

[OpenWatch](http://openwatch.net) is a new social muckraking network. It's our mission to build a new model of participatory, open-source and actionable journalism. 

With our mobile tools for media creation and our web platform for collaborative investigations, OpenWatch gives everyone in the world the power to create meaningful media. We're building a global army of investigators who can capture media, investigate stories, and challenge corrupt authorities. For everything from chemical weapons in Syria to government corruption in Virginia, from drone assassinations in China to the ritual murder of children in Gabon, OpenWatch is there to give a unique and actionable perspective.

Downloading the Source
----------------------
When downloading the source make sure to clone the repository with:

    $ git clone git@github.com:OpenWatch/OpenWatch-iOS.git --recursive
 
Or if you didn't use the `--recursive` flag when cloning you can do:

	$ cd /path/to/OpenWatch-iOS
    $ git submodule update --init --recursive
    
This will ensure you have all of the required submodules. 

Setup
----------------------
Install [mogenerator](https://github.com/rentzsch/mogenerator). This will regenerate the generated Core Data model files.

Create `./OpenWatch/OWAPIKeys.h` with the following content:

		#define TESTFLIGHT_APP_TOKEN @"your_testflight_token"
		#define USERVOICE_API_KEY @"your_uservoice_api_key"
		#define USERVOICE_API_SECRET @"your_uservoice_api_secret"

Running
----------------------

To run the software you'll need to use hardware that supports a camera and hardware accelerated video recording (basically all iOS devices made after the iPhone 3GS). You'll also need an active [iOS developer account](https://developer.apple.com/devcenter/ios/index.action), and the most recent version of [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12). It also requires iOS 6+ at the moment.

License
=========

	Software License Agreement (GPLv3+)
	
	Copyright (c) 2013, The OpenWatch Corporation, Inc. All rights reserved.
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

If you would like to relicense this code to distribute it on the App Store, 
please contact us at [team@openwatch.net](mailto:team@openwatch.net).

This software additionally references or incorporates the following sources
of intellectual property, the license terms for which are set forth
in the sources themselves (check the Submodules directory for more information):

* AFNetworking
* BButton
* Browser-View-Controller
* BSKeyboardControls
* DWTagList
* EGOTableViewPullRefresh
* JSONKit
* MagicalRecord
* MBProgressHUD
* MWFeedParser
* SDURLCache
* SSKeychain
* SuggestionsList
* TestFlight
* TheAmazingAudioEngine
* TUSafariActivity
* UserVoice
* WEPopover

----------------------------------------------------------------------------------

Any original media assets that we have created (in the Media folder) are provided under the [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported](http://creativecommons.org/licenses/by-nc-sa/3.0/) license:

* Attribution — You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).
* Noncommercial — You may not use this work for commercial purposes.
* Share Alike — If you alter, transform, or build upon this work, you may distribute the resulting work only under the same or similar license to this one.

Attributions
---------------------

* [Play Icon](http://thenounproject.com/noun/play/#icon-No4683) - [José Manuel de Laá Artacho](http://thenounproject.com/josemdelaa/#)
* [Eye Icon](http://thenounproject.com/noun/eye/#icon-No5968) - [Sergi Delgado](http://thenounproject.com/sergidelgado/)
* Other Icons from Glyphish
* Check the Submodules folder for the rest!


