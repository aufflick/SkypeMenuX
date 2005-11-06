2005-11-07 : 0.5b : Code cleanup and package
 * Buddy status feature now ready for general consumption

2005-11-06 : 0.4b : Rewrite of buddy status feature
 * Updating the menu from within the validate menuItem callback turns
   out to be a bad idea!
 * Now requires OS X 10.3 or later due to use of the ObjC thread
   synchronisation

2005-11-05 : 0.3b : Initial limited release of the buddy status feature

2005-11-03 : 0.2b : Minor enahncement release
 * Added a registered creator code to the application build
 * Moved the Quit menu options into a submenu to save vertical clutter

2005-10-29 : 0.1b : Initial release

------------ Note from initial check in --------

A quick note for the initial source checkin.

This code is licensed under the BSD license. See Credits.html for
more information.  The latest version can always be downloaded from
http://sourceforge.net/projects/skypemenux

To compile and link this code, you will need a copy of the Skype
Cocoa API.  See http://share.skype.com/ for information on downloading.

You will also need to download and compile the AGRegex library
(which in turn contains PCRE). See http://sourceforge.net/projects/agkit

You will also need to correct the library search path in the Build
preferences to match the location you have put the libraries.

To contact the author, email mark-skypemenux@aufflick.com or visit
http://sourceforge.net/projects/skypemenux

Mark Aufflick October 2005
