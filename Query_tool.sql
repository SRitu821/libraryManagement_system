-- Library Management system

-- Creating all the tables

-- Branch Table 
DROP TABLE IF EXISTS Branch;
CREATE TABLE Branch 
				(
					branch_id VARCHAR(10) PRIMARY KEY,	
					manager_id VARCHAR(10),	
					branch_address VARCHAR(50),	
					contact_no VARCHAR(20)
				);

-- Book table
DROP TABLE IF EXISTS Book;
CREATE TABLE Book
				(
					isbn VARCHAR(20) PRIMARY KEY,
					book_title VARCHAR(70),
					category VARCHAR(20),
					rental_price FLOAT,
					status VARCHAR(10),
					author VARCHAR(40),
					publisher VARCHAR(30)
				);
				
-- Employee table
DROP TABLE IF EXISTS Employees ;
CREATE TABLE Employees 
					(
						emp_id VARCHAR(10) PRIMARY KEY ,
						emp_name VARCHAR(30),
						position VARCHAR(15),
						salary INT,
						branch_id VARCHAR(25)
					)

-- Issued Table
DROP TABLE IF EXISTS IssueStatus ;
CREATE TABLE IssueStatus 
					(
						issued_id VARCHAR(10) PRIMARY KEY,
						issued_member_id VARCHAR(10),
						issued_book_name VARCHAR(70),
						issued_date DATE,
						issued_book_isbn VARCHAR(20),
						issued_emp_id VARCHAR(10)
					);

-- Member Table
DROP TABLE IF EXISTS Members;
CREATE TABLE Members 
					(
						member_id VARCHAR(10) PRIMARY KEY,
						member_name	VARCHAR(25),
						member_address	VARCHAR(70),
						reg_date DATE			
					);

-- Return Table
DROP TABLE IF EXISTS ReturnStatus;
CREATE TABLE ReturnStatus
					( 
						return_id VARCHAR(10) PRIMARY KEY,
						issued_id VARCHAR(10),
						return_book_name VARCHAR(70),
						return_date DATE,
						return_book_isbn VARCHAR(20)	
					); 





-- FOREIGN KEYS 
ALTER TABLE IssueStatus 
ADD CONSTRAINT fk_members 
FOREIGN KEY (issued_member_id) 
REFERENCES Members(member_id); 

ALTER TABLE IssueStatus 
ADD CONSTRAINT fk_books 
FOREIGN KEY (issued_book_isbn) 
REFERENCES Book(isbn); 

ALTER TABLE IssueStatus 
ADD CONSTRAINT fk_employees 
FOREIGN KEY (issued_emp_id) 
REFERENCES Employees(emp_id); 

ALTER TABLE Employees 
ADD CONSTRAINT fk_branch 
FOREIGN KEY (branch_id) 
REFERENCES Branch(branch_id); 

ALTER TABLE returnstatus 
ADD CONSTRAINT fk_issueStatus 
FOREIGN KEY (issued_id) 
REFERENCES IssueStatus(issued_id);




					