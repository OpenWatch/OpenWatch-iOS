OpenWatch for iOS
=================
[Download on the App Store](http://itunes.apple.com/us/app/openwatch-social-muckraking/id642680756?ls=1&mt=8)

![Screenshot](https://s3.amazonaws.com/openwatch-static/static/assets/img/iphone.png)

[OpenWatch](http://openwatch.net) is a global citizen journalism project with the goal of building a more transparent and less corrupt society.

This app will allow you to stream video and photos directly to the web! It's the easiest possible way to get your media online. Use this application to record any events you witness, your encounters with the police, border agents, or other authority figures, or to just record anything you find interesting. Your recordings will appear online to be used in public interest investigations and news stories.

A low quality video stream is sent the OpenWatch.net web server while you're filming, in case your phone is deliberately or accidentally broken while you're filming, and then a high quality version is synced online once you're finished recording, giving you the advantages of a streaming service like uStream, but all of the high-quality video ability of your phone's local video camera.

OpenWatch can also send you alerts and special assignments, so you can become the top reporter for events in your local community. Top contributors may even be offered special missions and paid opportunities.

This is the first version of the application, so please let us know if you find any bugs or have any feedback to give us. OpenWatch is Free and Open Source software.

Localization
------------

![Translations](https://www.transifex.com/projects/p/openwatch/resource/localizablestrings/chart/image_png)

If you would like to contribute/improve a translation:

 1. Visit our [Transifex project page](https://www.transifex.net/projects/p/openwatch/) and make an account if you don't have one already.
 2. Go to the resources for [Localizable.strings](https://www.transifex.com/projects/p/openwatch/resource/localizablestrings/) to add a new language or improve an existing translation. 
 3. [Open an issue on Github](https://github.com/OpenWatch/OpenWatch-iOS/issues) notifying us of your translation.
 
 Thank you!

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


