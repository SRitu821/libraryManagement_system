SELECT * FROM book;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM issuestatus;
SELECT * FROM returnstatus;


-- QUERIES
-- 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO book (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM book;

-- 2.  Update an Existing Member's Address
UPDATE members
SET member_address = '158 Main St'
WHERE member_id = 'C101';

-- 3. Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issuestatus
WHERE issued_id ='IS121';

-- 4.  Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * 
FROM issuestatus
WHERE issued_emp_id = 'E101'

-- 5. List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id,
		COUNT(*)
FROM issuestatus
GROUP BY 1 
HAVING COUNT(*) > 1;

-- CTAS (Create Table As Select)
-- 6. Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE CountIssuedBooks AS
SELECT 
	B.isbn, 
	B.book_title, 
	COUNT (Ist.issued_id) AS issuedCount
FROM 
	issuestatus AS Ist 
	JOIN Book AS B 
	ON Ist.issued_book_isbn = B.isbn 
GROUP BY B.isbn, B.book_title;

SELECT * FROM CountIssuedBooks;

-- 7. Retrieve All Books in a Specific Category:
SELECT * 
FROM Book
WHERE category = 'Classic';

-- 8. Find Total Rental Income by Category:
SELECT 
	B.category,
	SUM(B.rental_price ),
	COUNT(*)
FROM Book AS B
JOIN issuestatus AS ist 
ON B.isbn = ist.issued_book_isbn
GROUP BY 1;

-- 9. List Members Who Registered in the Last 180 Days:
SELECT * FROM Members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

SELECT CURRENT_DATE;

-- 10. List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	E1.*,
	B.branch_id,
	E2.emp_name AS Manager
FROM Employees AS e1
JOIN branch AS B
ON B.branch_id = e1.branch_id

JOIN employees AS E2
ON B.manager_id = E2.emp_id;

-- 11. Create a Table of Books with Rental Price Above a Certain Threshold 7:
CREATE TABLE Books_RentalPrice AS
SELECT * FROM Book
WHERE rental_price > 7;

SELECT * FROM Books_RentalPrice;

-- 12. Retrieve the List of Books Not Yet Returned
SELECT 
	DISTINCT ist.issued_book_name
FROM issuestatus AS ist
LEFT JOIN returnstatus AS rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL;



/* 
13. Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/ 
SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS overDuesDays
FROM issuestatus  ist
JOIN members m
	ON m.member_id = ist.issued_member_id
JOIN book b
	ON b.isbn = ist.issued_book_isbn
LEFT JOIN returnstatus rst
	ON rst.issued_id = ist.issued_id
WHERE 
	rst.return_date IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

/* 
14. Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/


CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO returnstatus(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issuestatus
    WHERE issued_id = p_issued_id;

    UPDATE book
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM book
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issuestatus
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM returnstatus
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

/* 
15.Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issuestatus as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
returnstatus as rs
ON rs.issued_id = ist.issued_id
JOIN 
book as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
/*
16. CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 YEAR.
*/


CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issuestatus
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 YEAR'
                    );

SELECT * FROM active_members;

/*
17.  Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issuestatus as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
ORDER BY no_book_issued DESC
LIMIT 3;
/*
18. Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/

SELECT 
	m.member_name,
	b.book_title,
	COUNT (rst.book_quality) AS bookQuality
FROM members AS m
JOIN issuestatus AS ist
	ON ist.issued_member_id = m.member_id
JOIN book AS b
	ON b.isbn = ist.issued_book_isbn
LEFT JOIN Returnstatus AS rst
	ON rst.issued_id = ist.issued_id
WHERE rst.book_quality = 'Damaged'
GROUP BY 1,2;

/* 
19. Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, 
and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/


CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM book
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issuestatus(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE book
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM book;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issuestatus;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM book
WHERE isbn = '978-0-375-41398-8'

/*
20. Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and
calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not 
returned within 30 days. The table should include: The number of overdue books. The total fines, with each day's 
fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number 
of overdue books Total fines
*/


-- Create a CTAS to identify overdue books and calculate fines

CREATE TABLE OverdueBooks AS
SELECT 
    m.member_id,
    COUNT(CASE 
             WHEN rst.return_id IS NULL 
                  AND CURRENT_DATE - ist.issued_date > 30 
             THEN 1 
         END) AS overdue_books,
    COUNT(ist.issued_id) AS total_books_issued,
    SUM(
        CASE 
            WHEN rst.return_id IS NULL 
                 AND CURRENT_DATE - ist.issued_date > 30 
            THEN (CURRENT_DATE - ist.issued_date - 30) * 0.50
            ELSE 0
        END
    ) AS total_fine
FROM Members m
LEFT JOIN IssueStatus ist
       ON m.member_id = ist.issued_member_id
LEFT JOIN ReturnStatus rst 
       ON ist.issued_id = rst.issued_id
GROUP BY m .member_id;

-- View result
SELECT * FROM OverdueBooks;






