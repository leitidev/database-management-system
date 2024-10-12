# Event Participation Database System

<p align="center">
  <img src="relational%20e%20logical/download.png" alt="ERD Diagram" width="600px">
  <br>
  <em>Entity-Relationship Diagram of the Event Participation Database</em>
</p>

## <span style="color: #0073e6;">Project Objective</span>

This project is a relational database system developed to manage event participation. The database efficiently tracks participants, events, and the relationships between them. It includes several core features, such as participant and event management, auditing, and trigger-based logging to ensure data integrity and smooth operations.

<div style="border: 1px solid #0073e6; padding: 10px;">
  <h3>Key Features</h3>
  <ul>
    <li><strong>Participant Management:</strong> Track participants' personal details and their engagement with events.</li>
    <li><strong>Event Management:</strong> Record and monitor event details such as administrators, locations, and event schedules.</li>
    <li><strong>Auditing:</strong> Track and log operations (INSERT, UPDATE, DELETE) on critical tables using triggers and log tables.</li>
    <li><strong>Participation Monitoring:</strong> Efficiently track who attends which events and log their participation.</li>
  </ul>
</div>

## <span style="color: #0073e6;">Technologies Used</span>

<ul style="list-style-type: square;">
  <li><strong>Oracle Database 19c:</strong> The backend database for storing and querying the data.</li>
  <li><strong>PL/SQL:</strong> Used to create stored procedures, triggers, functions, and exception handling.</li>
  <li><strong>SQL Developer:</strong> Tool for developing and managing Oracle databases.</li>
  <li><strong>Entity-Relationship Model (ERM):</strong> Used for designing the database architecture and relationships.</li>
</ul>


## <span style="color: #0073e6;">Challenges Faced</span>

<div style="border: 1px solid #f0ad4e; padding: 10px;">
  <ul>
    <li><strong>Handling Complex Foreign Keys:</strong> Managing foreign key relationships between multiple tables required careful planning, especially with cascading actions.</li>
    <li><strong>Trigger Optimization:</strong> Optimizing trigger performance was critical to ensure the system ran smoothly without lag.</li>
    <li><strong>Ensuring Data Integrity:</strong> Data validation, especially with multiple foreign keys, was a constant focus to avoid any inconsistencies.</li>
  </ul>
</div>

## <span style="color: #0073e6;">How to Run the Project</span>

<ol>
  <li>Clone the repository:
    <pre><code>git clone https://github.com/leitidev/database-management-system</code></pre>
  </li>
  <li>Open the project in Oracle SQL Developer.</li>
  <li>Execute the provided SQL scripts to create tables, triggers, and procedures.</li>
  <li>Test the database by inserting sample data and observing the triggers and audit logs.</li>
</ol>

## <span style="color: #0073e6;">Contributing</span>

If you would like to contribute to this project, feel free to fork the repository and submit a pull request.

<p align="center">
  <img src="https://img.shields.io/github/forks/leitidev/database-management-system" alt="Forks">
  <img src="https://img.shields.io/github/stars/leitidev/database-management-system" alt="Stars">
</p>


