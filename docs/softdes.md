# Software Design

This page includes a short description of the overall architecture style of the system, its high-level system components, and their logical (what data they exchange) and control (how they invoke each other) dependencies.

--------------------------------
## Architecture Diagram

The architecture diagram outlines the layered flow of the applications from the database, to the back end framework, to the front end framework. It is important to separate these layers to maintain independence.

<a href="https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/layered-archi.png?raw=true"><img src="../images/layered-archi.png" alt="layered architecture diagram" width="700"></a>

--------------------------------
## UML Class Diagram

The UML class diagram describes the most important classes within the application.

##### Backend Classes

<a href="https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/UML-class-backend.png?raw=true"><img src="../images/UML-class-backend.png" alt="uml class diagram" width="500"></a>


##### Frontend classes

<a href="https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/UML-class-frontend.png?raw=true"><img src="../images/UML-class-frontend.png" alt="uml class diagram" width="500"></a>


--------------------------------
## UML Sequence Diagrams

Multiple sequence diagrams depicting the most important scenarios.
<br><br>
<!-- users -->

##### User Diagrams
These sequence diagrams are for users of the mobile application - parents or daycare workers.

<a href="https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/UML-sequence1.png?raw=true"><img src="../images/UML-sequence1.png" alt="uml sequence diagram part 1" width="500"></a>

<br>

##### Admin Diagrams
These sequence diagrams are for users of the administration web application - only management users.

<!-- admin -->
<a href="https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/UML-sequence2.png?raw=true"><img src="../images/UML-sequence2.png" alt="uml sequence diagram part 2" width="500"></a>

--------------------------------
## Low-Fidelity User Interface

Since we have three types of users (daycare management, daycare workers, parents), we have three prototypes for their respective user interface. Workers and parents will be using a mobile application, while daycare management will be using a web application.

<iframe style="border: 1px solid rgba(0, 0, 0, 0.1);" width="800" height="450" src="https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FWdNhbjD6I7osJfGGjZSw9V%2FLow-Fidelity-Prototype%3Fnode-id%3D0%253A1%26t%3DkPWiXYFslDru0COj-1" allowfullscreen></iframe>

##### Admin/Manager Interface

[![admin interface](images/admin-interface.png)](https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/admin-interface.png?raw=true)

##### Daycare Worker Interface

[![worker interface](images/worker-interface.png)](https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/worker-interface.png?raw=true)

##### Parent Interface

[![parent interface](images/parent-interface.png)](https://github.com/UAlberta-CMPUT401/daycare-mgmt/blob/main/docs/images/parent-interface.png?raw=true)
