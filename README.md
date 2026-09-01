# CourtSync – Sports Facility & Resource Management System

CourtSync is a full-stack Sports Facility and Resource Management web application developed for **SmashPoint Academy**.  
The system digitalizes sports club operations such as court reservations, tournament management, inventory tracking and membership handling through a centralized web-based platform.

Built using **Java JSP, Servlets, JDBC, SQLite, Bootstrap and Apache Tomcat**, the application follows the MVC (Model-View-Controller) architecture.

---

# Features

## Member Features

### Smart Court Reservation

- Book badminton, tennis and table tennis courts
- Prevents double-booking using real-time slot validation
- Displays unavailable slots automatically

### Personal Dashboard

- View upcoming bookings
- Track tournament registrations
- Monitor personal activity schedule

### Tournament Registration

- Register for academy events and tournaments
- View upcoming sports events

### Membership System

- Supports BASIC and PRO membership tiers
- Different access levels and privileges

### Digital Pro Shop

- Rent sports equipment such as:
  - Rackets
  - Shuttlecocks
  - Training gear

### Notices & Announcements

- View academy updates and event notifications

---

## Admin Features

### Admin Dashboard

- View total members
- Monitor bookings and active events
- Track overall system activity

### Financial Analytics

- Automatically calculates:
  - Court booking revenue
  - Tournament fees
  - Equipment rental income

### Inventory & Asset Management

- Manage sports equipment inventory
- Track equipment availability in real-time
- Automatic stock updates on rental/return

### Tournament & Event Management

- Create, update and delete events
- Manage player participation
- Filter event rosters dynamically

### Member Management

- Add/update/delete members
- Upgrade or Downgrade membership plans
- Manage player information

### Role-Based Access Control (RBAC)

- Separate ADMIN and MEMBER access
- Session-based authorization system

---

# Application Flow

## Member Flow

1. Member logs into the system
2. Server validates credentials
3. User is redirected to Member Dashboard
4. Member books courts or joins tournaments
5. Booking information is stored in the database
6. Dashboard updates dynamically

---

## Admin Flow

1. Admin logs into the system
2. Server validates ADMIN privileges
3. Admin accesses management dashboard
4. Admin manages:
   - Members
   - Courts
   - Equipment
   - Events
5. Database updates are reflected instantly across the system

---

# System Architecture

CourtSync follows the **MVC (Model-View-Controller)** design pattern.

## View Layer (Frontend)

Built using:

- HTML5
- JSP
- Bootstrap 5
- JavaScript

Responsible for:

- User interface
- Forms
- Tables
- Dashboard views

---

## Controller Layer (Servlets)

Java Servlets handle:

- HTTP requests
- Session management
- Form validation
- Routing
- Business logic

Example:

- LoginServlet
- BookCourtServlet
- AddEquipmentServlet

---

## Model Layer (Database + JDBC)

Database operations handled using:

- JDBC
- SQLite

Responsibilities:

- Data storage
- CRUD operations
- SQL query execution
- Relationship management

---

# Technologies Used

## Frontend

- HTML5
- CSS3
- Bootstrap 5
- JavaScript
- JSP

## Backend

- Java Servlets
- JDBC

## Database

- SQLite

## Server

- Apache Tomcat

## IDE

- Eclipse IDE

---

# Core Modules

- Authentication System
- Member Management
- Court Reservation System
- Tournament Management
- Equipment Rental System
- Membership Management
- Financial Tracking
- Notices & Announcements
- Role-Based Access Control

---

# Security Features

- Session-based authentication
- Role-based authorization
- Secure JDBC PreparedStatements
- Restricted admin access

---

# [DEMO](https://drive.google.com/file/d/1ta_4JZa85L5xvGL0J5S19xjGTIi43kbA/view?usp=sharing)

# Future Enhancements

- Online payment integration
- QR-based attendance
- Email notifications
- Match analytics
- Mobile responsive enhancements

---

# Author

Developed as a Java Web Development Project using JSP, Servlets, JDBC and SQLite.
