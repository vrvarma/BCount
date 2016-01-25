## BCount

#Introduction
     A patient diagnosed with Leukaemia is given a book, to keep the blood count during each visit.  The nurse practicioner is supposed to enter the counts manually.  The patient onces discharged has to keep this book for each follow up, Emergency room visits.
     
     BCount is an iOS app to store, retrieve and view blood counts.  

#User Notes
1.  Sign up for an account using this [Sign Up](http://jbossews-soulbuzz.rhcloud.com/signup.html) link
2.  Install the app
3.  Upon login into the app, the user can add, delete and update blood counts.
4.  There are 4 tabs available:
    - Table View:  Where the user can add, delete and update the counts
    - Chart View:  View the line chart of the different functional points
    - Calendar View: Group the counts by day, select a date and view the counts by day
    - Settings page:  Which has an About Page, and Page Settings.  Page Settings is for the user to set the max number of rows per request.

##Developer Notes
1. The BCount project workspace has been generated using [CocoaPods] (https://cocoapods.org/) 
2. All Blood count information is stored in Core Data, user settings are archived using KeyArchiver
2. The app uses the following open-source libraries
  - [CVCalendar] (https://github.com/Mozharovsky/CVCalendar)
  - [SwiftCharts] (https://github.com/i-schuetz/SwiftCharts)
  - [IJReachabilityType] (https://github.com/Isuru-Nanayakkara/IJReachability)
