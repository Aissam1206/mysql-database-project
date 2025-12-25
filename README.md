# mysql-database-project
MySQL database project implementing schema design, queries, views, indexes, triggers, and procedures for a Smart Library system.
# SmartLib – MySQL Database Project

## Description
SmartLib is a MySQL-based database system designed for managing a smart library.  
The project focuses on relational schema design, data integrity, and enforcing business rules directly at the database level using constraints, triggers, and stored procedures.

## Database Overview
The database models a real-world library system with the following core entities:
- Members
- Librarians
- Books
- Borrow records

It supports borrowing, returning, and tracking overdue books while ensuring consistency and correctness of data.

## Schema Design
The database includes the following tables:
- **Member**: stores library members with status management (active, inactive, suspended).
- **Librarian**: stores librarian information and employment status.
- **Book**: stores book metadata and the responsible librarian.
- **Borrow**: manages borrowing transactions, due dates, return dates, and borrow status.

The schema enforces:
- Primary and foreign keys
- UNIQUE constraints (e.g. emails, ISBN)
- CHECK constraints for valid status values
- Logical date constraints (due date after issue date, return date validation)

## Business Logic at Database Level
The project emphasizes enforcing logic directly in MySQL:

### Triggers
- **Prevent double borrowing**: a book cannot be borrowed if it is already marked as borrowed.
- **Automatic overdue handling**: borrow status is automatically updated to *Overdue* when due dates pass.

### Stored Procedures
- `sp_borrow_book`: handles borrowing logic and automatically assigns a due date.
- `sp_return_book`: updates return date and borrow status when a book is returned.

## Sample Data
The database includes realistic sample data:
- Multiple members and librarians
- Books with different publication years
- Borrow records covering returned, borrowed, and overdue cases

This data allows testing of constraints, triggers, and procedures in real scenarios.

## Technologies Used
- MySQL
- SQL (DDL, DML)
- Triggers and Stored Procedures

## What I Learned
- Designing normalized relational schemas
- Enforcing business rules using SQL constraints
- Using triggers to maintain data consistency
- Writing stored procedures to encapsulate logic
- Modeling real-world workflows at the database level

## Future Improvements
- Add indexes for performance analysis
- Expose the database through a backend API (Node.js / Express)
- Connect to a frontend interface
- Add reporting queries and views
