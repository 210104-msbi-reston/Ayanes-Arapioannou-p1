# Ayanes-Arapioannou-p1

## Project Description

There are so many electronic device manufacturers like Apple Inc has a global presence and has multiple products been produced and supplied across the world. My role as DB Developer is to design a database system, present the ER diagram for the same, normalize the tables and make It productive. Any data can be tracked at any point of time. Recommend and design appropriate various database objects like tables, views, procedures, functions, triggers, indexes. Create a list of queries in a separate table which can be fired by channel partners, distributors, production houses, Zone manager etc.

## Technologies Used

* SQL
* T-SQL
* SSIS

## Features

* Place a manufacturing order by quantiy of product
* Generates a unique serial number for each product created
* Place an order from multiple levels of distributions based on the supllier stock
* Logged product movement from where it was manufatured to customer purchase.
* Option to return defetive products back to manufacture.

To-do list:
* Order multiple type of products in one manufacturer order.
* Reroute return products
* Additional views for common queries

## Getting Started
   
* AppleTableCreation.sql to create the initial database.
* AppleIncProc.sql to create the stored procedures.
* AppleInTriggers.sql to create the triggers.
* appleProductline.txt flat file to import from SSIS.
* countries.txt flat file to import from SSIS.

## Usage

AppleIncDemoTest.sql provides instructions and procedured to execute.

## License

This project uses the following license: [GPL v3](https://opensource.org/licenses/GPL-3.0).
