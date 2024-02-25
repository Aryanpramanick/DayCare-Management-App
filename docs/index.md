# Project Requirements

This page includes a general overview of the project. You can find important terms, user story specifications, and information on the tech stack.

--------------------------------
## Executive Summary

There is a problem of parents constantly messaging daycare providers in hopes of knowing the status of their child. The Daycare management app is a product trying to help bridge better communication between parents and daycare workers in hopes to inform parents. The essential functionality of the app is for the daycare worker to update the parent in regards to the activity of the child. Parents and daycare providers are the main users of this app. This product will be used to keep track of a child’s activity while in the care of a daycare provider.


<details>
<summary> Project Glossary </summary>

<li> <b>Daycare Manager</b> A manager is a person who manages the daycare center and is the user who adds new parents, students, and workers to the system
<li> <b>Daycare Centre</b> The group of managers, workers, parents, and children that are part of the same system and database
<li> <b>Daycare Worker</b> A worker is a person who takes care of their assigned group of children, creates a dayplan, records the activities, and communicates with the parents
<li> <b>Parent</b> A parent is a person who has a child at the center and will be able to view their child’s day plan and activities as well as communicate with the worker assigned to their child
<li> <b>Child</b> A child is a person who is part of a workers group and supervised by them, a child will not be a user of the system, but will have a profile in the database that is linked to their parent and their daycare worker
<li> <b>Activity</b> An activity is created by a worker for check-in, sleep, eating, or other and may include an image or video, a description, and tags to one or more children
<li> <b>Feed</b> A feed includes activity items for children that the user has access to - parent will see just their child, worker will see all children in their group, manager will see all children in the center

</details>

----

## User Stories 

<details>
<summary> Management Users</summary>

<details>
<summary> US 1.01 - Add new children (2) </summary>

<b>As a</b> manager, <b>I want</b> to be able to add new children to the system, <b>so that</b> their activities can be sent to the parent.
<br><br>
Acceptance Tests
<br>
<ul>
<li>Admin can add a new child to the system</li>
<li>Admin can choose which parent and worker to assign the child to</li>
<li>Admin can not add a new child with parent void</li>
<li>Admin can not add a new child with daycare worker void</li>
<li>Admin can not add an existing child to the system</li>
</ul>

</details>

<details>
<summary> US 1.02 - Add new parents (2) </summary>

<b>As a</b> manager, <b>I want</b> to be able to add new parents to the system, <b>so that</b> they can use the app to view their child’s activity. 
<br><br>
Acceptance Tests 
<br>
<ul>
<li> Admin can add a new parent to the system
<li> Admin can not add parent if one of the required fields is void
<li> Admin can not add an existing parent to the system
</ul>
</details>

<details>
<summary> US 1.03 - Add new daycare workers (2) </summary>

<b>As a</b> manager, <b>I want</b> to be able to add new daycare workers to the system, <b>so that</b> they can use the app to upload children's activities. 

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can add new daycare workers to the system
<li> Admin cannot add daycare workers if one of the required fields is void
<li> Admin can not add an existing worker to the system
</ul>
</details>

<details>
<summary> US 1.04 - Generate credentials (1) </summary>

<b>As a</b> manager, <b>I want</b> to be able to create username and password for the parents and daycare worker, <b>so that</b> they can log into the app. 

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can have a username and password  generated for the parent/daycare worker
<li> Each user has a unique username
<li> Admin can't create a login if the parent or worker does not exist
</ul>
</details>

<details>
<summary> US 1.05 - Delete existing children (1) </summary>

<b>As a</b> manager, <b>I want</b> to be able to delete children from the system, <b>so that</b> our database is up to date.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can delete a child from the table, without deleting the parent or worker
<li> The child no longer appears in the parents list of children
</ul>
</details>

<details>
<summary> US 1.06 - Delete existing parents (1) </summary>

<b>As a</b> manager, <b>I want</b> to be able to delete existing parents from the system, <b>so that</b> our database is up to date.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can delete a parent from the table
<li> All children associated with the parent will be deleted synchronously
</ul>
</details>

<details>
<summary> US 1.07 - Delete existing workers (1) </summary>

<b>As a</b> manager, <b>I want</b> to be able to delete existing workers from the system, <b>so that</b> our database is up to date.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can delete a worker from the table
<li> Admin can not delete a worker until their children are reassigned to a new worker
</ul>
</details>

<details>
<summary> US 1.08 - View feeds for all children (8) </summary>

<b>As a</b> manager, <b>I want</b> to be able to view the feed activity for all the children, <b>so that</b> I can supervise the activities the children are taking part in.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can view feed activity for all the children, organized by their worker
<li> Admin sees the same activities that would appear on the worker's feed
</ul>
</details>

<details>
<summary> US 1.09 - Assign children to a daycare worker (2) </summary>

<b>As a</b> manager, <b>I want</b> to be able to assign a child to a worker’s group, <b>so that</b> I can manage my daycare workers and children in the system. 

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can assign child to a worker’s group
<li> Admin cannot assign parent to a worker’s group
<li> Admin cannot assign a child to a worker who already has maximum children assigned
</ul>
</details>

<details>
<summary> US 1.10 - View plans and prices (1) </summary>

<b>As a</b> manager, <b>I want</b> to be able to view subscription plans for the daycare app, <b>so that</b> I can manage the number of children and groups I have in the system

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can view a range of subscription plans which show the price and amount of children and groups allowed
</ul>
</details>

<details>
<summary> US 1.11 - Assign multiple children to a parent (2) </summary>

<b>As a</b> manager, <b>I want</b> to be able to assign multiple children to the same parent, <b>so that</b> they can view multiple children on the app.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Admin can assign multiple children to a parent
<li> Parent can see the activities of all children
</ul>
</details>

<details>
<summary> US 1.12 - Payment for services (8) </summary>

<b>As a</b> manager, <b>I want</b> to be able to make payments for my subscriptions, <b>so that</b> I can continue using the app’s functionalities.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Payment with a valid card should go through
<li> Payment with invalid card number should not go through
<li> Payment with an expired card should not go through
<li> Payment with various amounts should go through
</ul>
</details>

<details>
<summary> US 1.13 - Edit existing users (3) </summary>

<b>As a</b> manager, <b>I want</b> to be able to edit information on existing daycare workers, children and parents, <b>so that</b> the information is always up-to-date.

<br><br>
Acceptance Tests 
<br>
<ul>
<li> Admin can edit a child's information
<li> Admin can edit a daycare worker's information
<li> Admin can edit a parent's information
<li> Admin can see the update in real time
</ul>
</details>

</details> <!-- Management Users -->

<details>
<summary> Daycare Worker Users </summary>
<details>
<summary> US 2.01 - Daycare worker login (2) </summary>

<b>As a</b> daycare worker, <b>I want</b> to log in with my username and password, <b>so that</b> the system can authenticate me and I can use the app.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Daycare worker can login to the daycare management system using the correct credential
<li> Workers cannot login with false credentials
<li> When authenticated, worker will be brought to their home page
</ul>
</details>

<details>
<summary> US 2.02 - Take attendance (3) </summary>

<b>As a</b> daycare worker, <b>I want</b> to be able to take attendance for my group, <b>so that</b> I can keep a record of which children are present and absent.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Workers can mark each child as absent or present as they show up
<li> Worker can save, leave the attendance page and come back without losing their previous data
<li> When worker marks a child as present, that parent can see a check-in time on their feed
<li> When worker finishes taking attendance for their group, they can see a group check-in activity on their feed
<li> When worker finishes taking attendance, a manager/admin can see the group check-in on that worker's feed
</ul>
</details>

<details>
<summary> US 2.03 - Add new activity (3) </summary>

<b>As a</b> worker, <b>I want</b> to be able to create activities and tag children in them, <b>so that</b> the respective parents can view the activity in their feed.

<br><br>
Acceptance Tests 
<br>
<ul>
<li> Workers can create a new activity
<li> Worker can choose which children to tag in the activity
<li> Workers can see the newly added activity in their feed as one item
<li> Parents can see the newly added activity in their feed
<li> Admin can see the newly added activity in the worker's feed
</ul>
</details>

<details>
<summary> US 2.04 - Upload photos and videos (5) </summary>

<b>As a</b> worker, <b>I want</b> to be able to take or upload photos and videos, <b>so that</b> the respective parents can view it in their feed.

<br><br>
Acceptance Tests 
<br>
<ul>
<li> When creating an activity, worker can choose to upload a photo or video
<li> Workers can access their mobile camera to take a photo or video
<li> Workers can upload a photo or video from their phone
<li> The photo or video appears as part of the activity item in the feed
</ul>
</details>

<details>
<summary> US 2.05 - Add description to activity (1) </summary>

<b>As a</b> worker, <b>I want</b> to be able to write a short description for an activity, <b>so that</b> the parents can view it with the activity in their feed.

<br><br>
Acceptance Tests 
<br>
<ul>
<li> When creating an activity, worker can choose to write a description
<li> The description appears as part of the activity item in the feed
</ul>
</details>

<details>
<summary> US 2.06 - Send messages to parents (3) </summary>

<b>As a</b> worker, <b>I want</b> to be able to send messages to the parents of children in my group, <b>so that</b> I can communicate with them throughout the day.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Worker can send a message to a parent
<li> Parent can see the message that was sent to them in real time
<li> Worker can see messages from the parent
</ul>
</details>

<details>
<summary> US 2.07 - Add activities to day plan (2) </summary>

<b>As a</b> worker, <b>I want</b> to be able to add activities in my day plan, <b>so that</b> I can plan the time with my children more efficiently.

<br><br>
Acceptance Tests 
<br>
<ul>
<li> Worker can add an activity in day plan
<li> Worker can see the new activity appear in the day plan in real time
<li> Worker can switch to day plans of previous days or future days
</ul>
</details>

<details>
<summary> US 2.08 - Tag children with sharing permission (3) </summary>

<b>As a</b> worker, <b>I want</b> to be able to tag children in group activities only if their parents have given persmission, <b>so that</b> I can maintain the child's privacy if the parent wishes.

<br><br>
Acceptance Tests 
<br>
<ul>
<li> Worker can tag multiple children if their parents have given sharing permission
<li> Worker can not tag a child without sharing permission if they tag multiple children
<li> Worker can tag a child without group persmissions if they are the only child tagged
</ul>
</details>


</details> <!-- daycare worker users -->

<details>
<summary> Parent Users </summary>

<details>
<summary> US 3.01 - Parent Login (2) </summary>

<b>As a</b> parent, <b>I want</b> to log in with my username and password, <b>so that</b> the system can authenticate me and I can use the app.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Parent can login with correct credentials
<li> Parent cannot login if credentials are false
<li> Parent is redirected to home page when authenticated
</ul>
</details>

<details>
<summary> US 3.02 - View child’s feed (5) </summary>

<b>As a</b> parent, <b>I want</b> to be able to view my child’s activities as a feed, <b>so that</b> I see what my child is doing during the day.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Parents can view their child’s activities in a feed
<li> Parents cannot view the feed for children that aren't theirs
</ul>
</details>

<details>
<summary> US 3.03 - Receive Notifications (3) </summary>

<b>As a</b> parent, <b>I want</b> to receive notifications of new activities regarding my child, <b>so that</b> I know what my child is doing right away.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> As an activity is created that has the child tagged, the parent receives a notification
<li> Parent won’t receive notifications for children that are not theirs, or that their child is not tagged in
</ul>
</details>

<details>
<summary> US 3.04 - Send messages to worker (3) </summary>

<b>As a</b> parent, <b>I want</b> to be able to chat with the daycare worker assigned to my child, <b>so that</b> I can ask them questions throughout the day.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Parent can send messages with the daycare worker assigned to their child
<li> Parent cannot send messages to other daycare workers that are not assigned to their child
</ul>
</details>

<details>
<summary> US 3.05 - Switch children’s feed (5) </summary>

<b>As a</b> parent, <b>I want</b> to be able to switch between my children’s feeds, <b>so that</b> I can view activities for more than one child at the same daycare.

<br><br>
Acceptance Tests 
<br>
<ul>
<li> Parents can view a feed for more than one child on the same account by easily switching between their profiles
</ul>
</details>

<details>
<summary> US 3.06 - View child's dayplan (3) </summary>

<b>As a</b> parent, <b>I want</b> to be able to view my child's day plan created by their worker, <b>so that</b> I can view the planned activities for that day.

<br><br>
Acceptance Tests 
<br> 
<ul>
<li> Parents can view the day plan for their child
<li> Parents can view future day plans for their child
</ul>
</details>

</details> <!-- parent users -->

<details>
<summary>MoSCoW </summary>

<b>M</b>ust Have

<ul>
<li> US 1.01 - Add new children
<li> US 1.02 - Add new parents
<li> US 1.03 - Add new daycare workers
<li> US 1.04 - Generate credentials
<li> US 1.08 - View feeds for all children
<li> US 1.09 - Assign children to a  daycare worker
<li> US 2.03 - Add new activity
<li> US 2.04 - Upload photo and videos
<li> US 2.05 - Add description to activity
<li> US 3.01 - Parent Login
<li> US 3.02 - View child’s feed
</ul>

<b>S</b>hould Have

<ul>
<li> US 2.01 - Daycare worker Login
<li> US 2.02 - Take attendance
<li> US 2.06 - Send messages to parents
<li> US 3.03 - Receive Notifications
<li> US 3.04 - Send messages to worker
<li> US 2.08 - Tag children with sharing permission
</ul>

<b>C</b>ould Have

<ul>
<li> US 1.05 - Delete existing children
<li> US 1.06 - Delete existing parents
<li> US 1.07 - Delete existing workers
<li> US 1.10 - View plans and prices
<li> US 1.11 - Assign multiple children to a parent
<li> US 1.13 - Edit existing users
<li> US 2.07 - Add activities to day plan
<li> US 3.06 - View child’s dayplan
</ul>

<b>W</b>ould Like but Won't Get

<ul>
<li> US 1.12 - Payment for services
<li> US 3.05 - Switch children’s feed
</ul>

</details>

----

## Resources

<details>
<summary>Similar Projects</summary>
<br>

<ul>
<li> <a href="https://www.himama.com/">Hi Mama</a> - Daycare management app on the market
<li> <a href="">Whatsapp </a> - Messaging functionality
<li> <a href="">Instagram</a> - Feed functionality
<li> <a href="">SnapChat</a> - Photo functionality (for taking photos)
</details>




<details>
<summary>Relevant Open-Source Projects </summary>
<br>
<ul>
<li> <a href="https://github.com/Perceive-Software-Solutions/feed">Perceive Software Solutions</a> - Feed Functionality
<li> <a href="https://appseed.us/product/material-dashboard/django/">Django Material Dashboard</a> - Admin Dashboard
<li> <a href="https://www.creative-tim.com/product/black-dashboard-django">Django Black Dashboard</a>  - Admin Dashboard Alternative (BS4 Version)
</ul>
</details>


<details>
<summary>Technical Resources</summary>
<br>

<h4>Database: Postgresql</h4>
<li> <a href="https://www.postgresql.org/"> Postgresql Documentation</a>

<h4>Back-end: Django + Django REST Framework</h4>
<li> <a href="https://docs.djangoproject.com/en/4.1/">Django documentation</a>
<li> <a href="https://docs.djangoproject.com/en/4.1/ref/contrib/admin/">The Django admin site</a>
<li> <a href="https://www.django-rest-framework.org/">Django REST Framwork</a>

<h4> Front-end: Flutter </h4>
<li> <a href="https://docs.flutter.dev/">Flutter Documentation</a>

<h4>Deployment: Docker + Google Cloud + Cybera</h4>
<li> <a href="https://docs.docker.com/language/java/deploy/">Docker Deployment </a>
<li> <a href="https://cloud.google.com/docs">Google Cloud </a>
<li> <a href="https://wiki.cybera.ca/display/RAC/Rapid+Access+Cloud+Guide%3A+Part+1">Cybera </a>
<li> <a href="https://www.digitalocean.com/community/tutorials/how-to-set-up-django-with-postgres-nginx-and-gunicorn-on-ubuntu-20-04">Deployment on Ubuntu</a>

</details>
