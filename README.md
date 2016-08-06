# iFlight website

**iFlight** is the website for booking airline ticket service
One product from team: MiddleGuys
URL: **https://iflight.herokuapp.com/**

## About
* iFlight is a website that helps people find and compare domestic airlines price: Vietnam Airline, Jetstar, Vietjet Air
* It also can help us track the price and notice when the price match our requirement
* Welcome AI bots support to answer customer questions

## Vision Statements
* Finding and booking easier with best UX
* Cheap price alert
* Customer service is supported by AI bots

## User Stories
## REQUIRED
**User**

- [ ] Basically, system has 3 roles user: administrator, normal user and guest (who don’t have an account). In the following description, the term “user” can understand as normal user and guest
- [ ] Administrator is created by system
- [ ] Normal user is created by guest
- [ ] Sign up / Sign in / Sign out / Remember Signing in / Support recover password
- [ ] Booking history: User can check their booking or reservation history (for normal user only)
- [ ] Tracking searching behaviour: the next time user visit website, he/she can see the suggestion price for his/her favourite itineraries
- [ ] An administrator page to manage the orders from users

**Searching**

- [ ] User will get the price data from 3 airlines after he/she input his/her itinerary. Notice: this price data have to be absolutely precise at that time user searches.
- [ ] The flights result will showed as asynchronization. It means we will use multiple thread for crawling data. When one airline return the price data, we will show the data on our flights result page.
- [ ] In case of having any error occurs in searching process, we will show the message to user.

**Booking**

- [ ] User can enter their information to reserve ticket
- [ ] Return CODE book when the booking process is successful
- [ ] Error handler if booking process is failed
- [ ] Sending an email to user after booking

**Notification**

- [ ] In the flights result page (from searching step), use can use notification feature.
- [ ] User can receive the notification when the price of their favourite itinerary meet their expectation
- [ ] User can unsubscribe the notification anytime he/she want

**AI Bot**

- [ ] AI Bot receive the question from user and answer it automatically
- [ ] In case the bot can’t answer the question, sending the notification to the administrator or customer service staff
- [ ] AI Bot can learn new knowledge

## OPTIONAL
**User**

- [ ] Login by Facebook
- [ ] User can upload avatar when sign up

**Searching**

- [ ] Retry crawling handler: if the first time crawling is failed, the system can retry one (or two or three) more time(s).
- [ ] Searching result can be shared in social network: focus on Facebook first

## Prototype
![Booking step 1](/prototype/booking-step-1.png)
![Booking step 2](/prototype/booking-step-2.png)
![Booking step 3](/prototype/booking-step-3.png)
![Booking step 4](/prototype/booking-step-4.png)
![Alert notification](/prototype/alert.png)
![Bot chat](/prototype/bot.png)

## Notes

## License

    Copyright [2016] [MiddleGuys]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.# README

