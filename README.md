# swiftStreetView  
<img src="https://user-images.githubusercontent.com/55787141/86472343-9e1ee380-bd71-11ea-8b28-7e3ff3d0c3e6.png" width="80" height="80"> 

This application allows user to explore where they want, and provide some nice functionalities to have a plan of future trip or adventure.

## Why created this app

This app was mainly created to show my skill in mobile development, and acquire great opportunity to work in iOS development industry.

I've been working as web developer for 1yr anf half, and as mobile developer for half year. After some of experience with mobile development, I noticed that I'm more interested in mobile, therefore decided to focus working on it especially Swift. 

This app was developed after watching of some tutorials to have fundamental skills for Swift. 

The duration of developing this application is 1 week(7 hrs of work per day)

I have also created a simple news feed [applications](https://github.com/Soma-dev0808/swiftNewsFeed)
, so if you are interested, please check it.

 

## UI Design

<img src="https://user-images.githubusercontent.com/55787141/86478961-d1676f80-bd7d-11ea-9fbd-a91a4a5ae0e3.png" width="950" height="600"> 

In this app, since the purpose of creating this app is showing my mobile developing skill, so UI wasn't prioritized this time.

## What technology I used

* Swift
* Google Place Api (Place Auto Complete, Handle Coordinates)
* Google Map Api (Map View Handling)
* Realm (Save Location Data)

## Structure of this app

<img src="https://user-images.githubusercontent.com/55787141/86480678-0f19c780-bd81-11ea-8026-219ff084e6f2.png" width="0" height="600"> 

This app was developed based on MVC. View will show UI, and Controller handle actions such as user input and page navigation. Model will handle data and provide some methods to handle converting data.

For the navigation of app is using Navigation Controller to make it smooth to navigate pages.

## Features

* Search place
* Auto complete plane name
* Get current user's location
* Panorama view
* Save location user liked
* find near places(eg. search near air port ands find them)

## To test this application

Please clone this application, and please run
pod deintegrate
pod install
then you can already build it

## License
[MIT](https://github.com/Soma-dev0808/swiftStreetView/blob/master/LICENSE)
