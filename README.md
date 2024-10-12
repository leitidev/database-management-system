Project Objective
This project demonstrates a relational database system designed for managing event participation. The database tracks participants, events, and the interactions between them. Key features include user management, event handling, participation tracking, and auditing through triggers and logs.

Features:
Participant Management: Track personal details of participants and their engagement in events.
Event Tracking: Record event details, including location, administrators, and timelines.
Participation Logging: Monitor participant event participation with detailed logging.
Auditing: Trigger-based auditing for updates, inserts, and deletes on the main tables.

Technologies Used:
Oracle Database 19c: Backend for creating tables, functions, procedures, triggers, and data management.
PL/SQL: Used for writing stored procedures, functions, and triggers.
SQL Developer: Tool used for developing and managing the database system.
Entity-Relationship Model (ERM): Design of the database architecture, including table relationships.

Challenges Faced:
Complex Foreign Keys: Managing foreign keys between multiple tables, especially handling dependencies and cascading updates.
Trigger Performance: Optimizing triggers to ensure they do not degrade the performance of the database system.
Data Integrity: Ensuring data consistency through primary and foreign keys, as well as handling exceptions and errors properly.


Installation and Setup:
1. Clone the repository: git clone https://github.com/your-username/Database_Event_Management_Project.git
2. Open in SQL Developer: Import the SQL scripts and execute them in Oracle SQL Developer.
3. Run the scripts: Execute the provided scripts to create tables, triggers, and procedures.
