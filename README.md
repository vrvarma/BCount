# BCount

##Introduction
     
A patient undergoing chemo-therapy needs to keep track of blood counts and immunity indicators in order to maintain his/her's quality of life.  

During the treatment the The following counts and indicators are tracked by the doctors:
- WBC : White blood cell fights infection (4.5 - 13.5 K/μL), low value means there is an increased chance of infection
- RBC : Red blood cell (3.80 - 4.90 Mil/μL), carries nutrition to the cells; low RBC count means you may feel fatigued, dizzy, etc.
- HGB : Hemoglobin count (11.5 - 15.5 g/dL)- carries oxygen to the body; low HGB means the person is anemic, and will feel fatigued, dizzy etc.
- Platelet : Is a protein that helps blood clot (175 - 525 K/μL), low platelet count means that the patient has high changes of bleeding
- ANC : Absolute Neutrophil Count ((1.35 - 7.43 K/μL)) - is a derived value, calculated using the formula ANC = Total white blood count  x % neutrophils.  Low ANC means there is a high chance of infection.

Currently these records are maintained in a record book.

BCount is an iOS app to store, retrieve and view blood counts and Health indicators. 

##User Notes
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
2. All Blood count information is stored in Core Data, user settings are archived using KeyArchiver.
3. The app uses the following open-source libraries
  - [CVCalendar] (https://github.com/Mozharovsky/CVCalendar) : A custom visual calendar for iOS 8 written in Swift
  - [SwiftCharts] (https://github.com/i-schuetz/SwiftCharts) : An easy to use and highly customizable charts library for iOS
  - [IJReachabilityType] (https://github.com/Isuru-Nanayakkara/IJReachability) :A simple class to check for internet connection availability in Swift. Works for both 3G and WiFi connections.

##References

[Low blood counts] (http://chemocare.com/chemotherapy/side-effects/low-blood-counts.aspx)
[Hemoglobin ](http://www.mayoclinic.org/symptoms/low-hemoglobin/basics/definition/sym-20050760)
