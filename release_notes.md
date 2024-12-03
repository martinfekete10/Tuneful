# 1.8.0 - Notch integration, sleeker UI and others

-   New notch integration now allows you to control the music from notch. For non-notch Macs, this is available on hovering over new song notification
-   New music slider which now looks and feels native
-   Refactored the logic that fetches song information which makes the app feel snappier
-   Added more animations to the UI so the app feels more fluid
-   Fixed the bug when Spotify was opened in the background even if killed by the user
-   Fixed the bug when mini player floating preference was ignored on app restart
-   Fixed the bug when Tuneful wasn't fetching Apple Music song favorite info correctly when changing songs
-   Fixed the bug when previous song button didn't rewind the song to the beginning if some part already played for Apple Music

# 1.7.1 - Mini player improvement and various bug fixes

-   Fixed issue when Tuneful was crashing on launch if Spotify is not installed
-   Fixed notch notification appearance for Light Mode
-   Fixed accent color in settings window
-   Mini player now remembers its position after relaunching Tuneful, huge thanks to @itssali
-   Minor player manager optimisation

# 1.7.0 - Song change notifications, UI improvements and others

-   New feature to display notification when song changes. For Macbooks with notch, this is displayed as beautiful notch animation; for non-notch Macs, its shown as a small floating window
-   Redesigned settings with sleaker UI
-   Fixed coloring of playback buttons in light mode
-   Fixed menu bar playback buttons
-   Updated icon with better resolution on retina and non-retina displays

# 1.6.7 - Small fixes

-   Fixed issue when opening Apple Music via menu bar click
-   Fixed menu bar icon behvaiour when set to Hidden setting

# 1.6.6 - Better podcast handling, more native UI and more

-   When podcast is playing, 15-sec rewind buttons are displayed instead of forwads/backwards buttons
-   Updated playback buttons to use more native icons
-   Playback buttons now animate on mouse hover
-   Improved hadnling of menu bar information for podcasts
-   New keyboard shortcut to show/hide popover
-   Lowered minimum menu bar item width from 100px to 75px
-   Code is a bit more optimised to make less background calls to Spotify/Apple Music
-   Background code maintenance and cleanup

# 1.6.5 - Bug fixes and minor improvements

-   Fixed a bug where menu bar info wasn't currently updated when music player was killed
-   Fixed a bug where equaliser animation preference wasn't correctly udpated on the settings window
-   Made a small improvement to equaliser animation
-   Settings window spacing is a bit improved

# 1.6.4 - Colored menu bar equaliser

-   Menu bar equaliser animation is now colored based on album art

# 1.6.3 - Various smaller features and bug fixes

-   New option to show animated equaliser in menubar (instead of albumart/app icon) when music is playing
-   New ability to add keyboard shortcut to show/hide menu bar item
-   New option to disable popover window altogether - when enabled, music player will be opened insted of the popover window
-   Fixed bug with scrolling Open Apple Music text when Apple Music is quit
-   Smaller under the hood improvements

# 1.6.2 - Fixed blank window on launch

-   Fixed opening a blank window when starting Tuneful

# 1.6.1 - Option to disable scrolling menu bar text

-   Added new option to disable scrolling menu bar text as it may be distracting
-   Fixed bug when the text was scrolling even if the width of menu bar item was large enough

# 1.6.0 - New popover style option, menu bar customization and more

-   New minimalist popover option - you can now customize the look of the popover by selecting from 2 styles
-   New option to hide menu bar item when the music is not playing
-   New option to hide the icon/album art in the menu bar item and only display currently playing song info
-   Slight improvement to the look of a full-sized mini player, making the controls a bit wider
-   Slight improvement to the look of menu bar items
-   Fixed behaviour when closing the popover by clicking on the menu bar item, which would close and re-open the popover before - thanks to @robbiewxyz for fixing this!

# 1.5.0 - Playback controls in menu bar

-   New feature to control playback by new menu bar control buttons
-   Ability to set behaviour of mini player window to act as a normal window
-   Menu bar item width now resizes when the song information is smaller than max width set in settings to avoid empty bezels on the sides

# 1.4.0 - Scrolling menu bar text

-   Menu bar text is now scrolling if it does not fit the max width
-   New option to hide menu bar text when nothing is currently playing
-   New keyboard shortcut to quickly switch between Spotify and Apple Music
-   Ability to switch between Spotify and Apple Music from new menu bar submenu
-   Fixed an issue when incremental volume increase would break the UI on max volume
-   Fixed an issue when progress bar would not update until the mini player window is displayed for the first time
-   Minor settings improvements
-   Minor mini player improvements

# 1.3.0 - New mini player options and volume adjustments

-   New feature to customize the look of mini player - you can now choose from 2 styles
-   You can now hide mini player window by right-clicking and choosing Hide window option
-   Mini player is now easier to move around
-   Volume slider now adjusts Apple Music/Spotify instead of a system volume

# 1.2.0 - More customization and Apple Music favorites fix

-   You can now choose if you want to have a transparent background or blurred artwork of current song as a background, both in menu bar popover and mini player window
-   Fixed a bug where songs were not being added to Apple Music favorites after clicking heart button
-   Changed Add to Favorites icon from heart to star to make it consistent with Apple Music

# 1.1.0 - Keyboard shortcuts

-   New feature to setup global keyboard shortcuts to control music and toggle mini player window
-   Fixed a bug where opening settings would crash the app for some users
-   Fixed a bug where the app did not open for some users
-   Other minor bug fixes and improvements

# 1.0.0 - Song information in menu bar

-   New feature to display song information directly in menu bar
-   New settings window with ability to customize information displayed in menu bar
-   Fixed a bug where progress bar and play time were not sometimes updated
-   Popover UI tweaks
-   Other minor bug fixes and improvements

# 0.9.6 - Minor fixes

-   Fixed "About..." menu item behaviour

# 0.9.5 - UI fixes

-   New icon
-   Minor popover UI spacing improvements

# 0.9.4 - Sparkle fix v2

-   Test Sparkle update

# 0.9.3 - Sparkle fix maybe

-   Test Sparkle update

# 0.9.2 - Sparkle test

-   Test Sparkle update

# 0.9.1 - Update test

-   Test the runner and Sparkle update

# 0.9.0

-   Initial release
