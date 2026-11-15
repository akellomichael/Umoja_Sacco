-- ************************************************************************
-- Umoja SACCO practice dataset (fictional)
-- ************************************************************************
-- SECTIN A: SELECT | WHERE | ORDER BY | LIMIT | DISTINCT


-- A1. List every branch with its name, town and opening date, oldest branch first.

SELECT 
	b.branch_name, b.town, b.opened_date
FROM sacco.branches b
ORDER BY b.opened_date;


-- A2. Which loan products charge more than 12% interest a year? Show the product 
--     name and rate, highest rate first

SELECT
	lp.product_name, lp.annual_interest_rate 
FROM sacco.loan_products lp
WHERE lp.annual_interest_rate > 12
ORDER BY lp.annual_interest_rate DESC;


-- A3. List the first name, last name and phone number of every member whose last 
--     name is Otieno, in alphabetical order of first name.

SELECT 
	CONCAT_WS(' ',m.first_name, m.last_name) AS Member_name, m.phone
FROM sacco.members m
WHERE m.last_name = 'Otieno'
ORDER BY m.first_name;



-- A4. Which payment channels have been used for loan repayments? Show each channel once.

SELECT 
	DISTINCT r.channel
FROM sacco.repayments r
ORDER BY r.channel;



-- A5. Show the 5 biggest loans (loan_id, member_id, principal). Then look closely at your 5th row: is it
--     really "the" 5th biggest loan?

select * from loans;
SELECT 
	l.loan_id, l.member_id, l.principal
FROM sacco.loans l
ORDER BY l.principal DESC
LIMIT 5;



-- A6. List all Pending or Defaulted loans worth 300,000 or more. Show loan_id, member_id, principal and
--     status, biggest first.

SELECT 
	l.loan_id, l.member_id, l.principal, l.status
FROM sacco.loans l 
WHERE l.status IN ('Defaulted', 'Pending')
	AND l.principal >= 300000
ORDER BY l.principal DESC;
	


-- A7. Which staff members work at head office, that is, have no branch? Show their id, name, role and
--     manager_id.

SELECT 
	CONCAT_WS(' ',m.first_name, m.last_name) AS staff_name, m.branch_id
FROM sacco.staff m 
WHERE m.branch_id IS NULL 
ORDER BY m.staff_id;



-- ************************************************************************************************
-- SECTION B: AGGREGATES | GROUP BY | HAVING

-- B1. How many male and how many female members does the SACCO have?

SELECT 
	COUNT(m.member_id) FILTER (WHERE m.gender = 'M') AS male,
	COUNT(m.member_id) FILTER (WHERE m.gender = 'F') AS female
FROM sacco.members m ;



-- B2. How many members does each branch have? Show branch_id and the count, biggest branch first.

SELECT 
	m.branch_id, COUNT(*) AS member_count
FROM sacco.members m  
GROUP BY m.branch_id 
ORDER BY member_count DESC;




-- B3. For each loan status, show the number of loans and the total principal.

SELECT 
	l.status,
	COUNT(*) AS loan_count,
	SUM(l.principal) AS total_principal
FROM sacco.loans l 
GROUP BY l.status 
ORDER BY total_principal DESC;


-- B4. For each product_id, show the number of loans and the average (rounded to 2 decimals), smallest
--     and largest principal.
select * from loans;

SELECT 
	l.product_id,
	COUNT(loan_id) AS number_of_loans,
	ROUND(AVG(l.principal),2) AS average,
	MAX(l.principal) AS Largers_principal,
	MIN(l.principal) AS smallest_principal
FROM sacco.loans l 
GROUP BY l.product_id
ORDER BY product_id;



-- B5. For each repayment channel, show the number of payments and the total amount paid, biggest
--     total first

SELECT 
	r.channel,
	COUNT(r.repayment_id) AS number_of_repayments,
	SUM(r.amount) AS total_paid
FROM sacco.repayments r 
GROUP BY r.channel 
ORDER BY total_paid DESC;



-- B6. Which loan officers (officer_id) have handled more than 45 loans? Most loans first

SELECT 
	l.officer_id,SUM(l.principal) AS loan_amount, COUNT(l.loan_id) AS loan_count
FROM sacco.loans l
GROUP BY l.officer_id 
HAVING COUNT(l.loan_id) > 45 
ORDER BY loan_count DESC;



-- B7. Which members have taken 3 or more loans? How many such members are there?

SELECT 
	l.member_id, COUNT(l.loan_id) AS loan_count
FROM sacco.loans l
GROUP BY l.member_id
HAVING COUNT(l.loan_id) >= 3;



-- B8. What is the total value of all deposits, and of all withdrawals? Show the number of transactions too.

SELECT 
	st.txn_type,
	SUM(st.amount) AS total_value,
	COUNT(st.txn_id) AS transaction_count
FROM sacco.savings_transactions st 
GROUP BY st.txn_type 
ORDER BY total_value DESC;



-- ***********************************************************************************
-- SECTION C: JOINS


-- C1. List every loan with the member's full name and the product name. Show loan_id, member name,
-- 	   product name, principal and status, in loan_id order

SELECT
	l.loan_id, 
	m.first_name ||' '||m.last_name AS member_name,
	lp.product_name, l.principal, l.status
FROM sacco.members m 
JOIN sacco.loans l          USING(member_id)
JOIN sacco.loan_products lp USING(product_id) 
ORDER BY l.loan_id;
	


-- C2. Show every branch by name with its number of members, including branches that have no
--     members. Biggest first.

SELECT 
	b.branch_name,
	COUNT(m.member_id) AS members
FROM sacco.branches b 
LEFT JOIN sacco.members m USING(branch_id)
GROUP BY b.branch_name, b.branch_id
ORDER BY members DESC;



-- C3. Show every loan product with the number of times it has been used, including products never used.

SELECT 
	lp.product_name,
	COUNT(l.loan_id) AS count
FROM sacco.loan_products lp 
LEFT JOIN sacco.loans l USING(product_id)
GROUP BY lp.product_name 
ORDER BY count DESC;



-- C4. Which members have never taken a loan? Show member_id and name. How many are there?

SELECT 
	m.first_name||' '||m.last_name AS memeber_name,
	m.member_id
FROM sacco.members m 
LEFT JOIN sacco.loans l USING(member_id)
WHERE l.loan_id IS NULL
ORDER BY m.member_id ;



-- C5. List every loan officer with their branch name and the number of loans they have handled, including
--     officers with no loans. Most loans first.

SELECT 
	s.first_name||' '||s.last_name AS loan_officer,
	b.branch_name,
	COUNT(l.loan_id)               AS loans_issued
FROM sacco.staff s 
JOIN sacco.branches b     ON b.branch_id = s.branch_id
LEFT JOIN sacco.loans l   ON l.officer_id = s.staff_id
WHERE s.role = 'Loan Officer'
GROUP BY s.first_name, s.last_name, b.branch_name, b.branch_id
ORDER BY loans_issued DESC;



-- C6. Write question C3 again, this time using a RIGHT JOIN.
SELECT 
	lp.product_name,
	COUNT(l.loan_id) AS count
FROM sacco.loans l  
RIGHT JOIN sacco.loan_products lp USING(product_id)
GROUP BY lp.product_name 
ORDER BY count DESC;



-- C7. Use a FULL OUTER JOIN between branches and members to show only the rows that have no  
--     partner on one side or the other

SELECT 
	 b.branch_name, m.member_id
FROM sacco.members m 
FULL JOIN sacco.branches b USING(branch_id)
WHERE b.branch_id IS NULL 
	OR m.member_id IS NULL;



-- C8. List every staff member with their role, their manager's name and their manager's role. Include the
--     CEO, who has no manager.

SELECT 
	s.first_name||' '||s.last_name AS staff_name, 
	s.role AS staff_role, 
	m.first_name||' '||m.last_name AS manager_name, 
	m.role AS manager_role
FROM sacco.staff s
LEFT JOIN sacco.staff m ON m.staff_id = s.manager_id
ORDER BY s.staff_id;



-- C9. Which members have referred the most people? Show the referrer's id, name and number of people
--     referred, most first. How many members are tied at the top?

SELECT 
	r.member_id AS referrer_id,
	r.first_name||' '||r.last_name referrer,
	COUNT(*) AS members_referred
FROM sacco.members m 
JOIN sacco.members r ON r.member_id = m.referred_by 
GROUP BY r.member_id , r.first_name
ORDER BY members_referred DESC;



-- C10. What is the total amount repaid through each branch? (Follow the chain repayments, loans,
--      members, branches.) Biggest first.

SELECT 
	b.branch_name,
	SUM(r.amount) AS repayment_amount
FROM sacco.repayments r 
JOIN sacco.loans l    USING(loan_id)
JOIN sacco.members m  USING(member_id)
JOIN sacco.branches b USING(branch_id)
GROUP BY b.branch_id, b.branch_name
ORDER BY repayment_amount DESC;
	
	

-- C11. Management wants a grid of every branch paired with every loan product, to plan which branch
--      offers what. How many rows should the grid have? Write the query.

SELECT 
	b.branch_name,
	lp.product_name
FROM sacco.branches b 
CROSS JOIN sacco.loan_products lp
ORDER BY b.branch_id, lp.product_id;



-- C12. Staff are paid in grades, so many share the same salary. Find every pair of staff with the same role
--      and the same salary, showing each pair only once. How many pairs are there in total, and per role?

SELECT 
	s.first_name,
	s1.first_name,
	s.role,
	s.salary
FROM sacco.staff s
JOIN sacco.staff s1 ON s1.role = s.role
WHERE s.salary = s1.salary
	AND s.staff_id < s1.staff_id
ORDER BY s.salary DESC;



-- ********************************************************************
-- SECTION D. SET OPERATORS [UNION | UNION ALL | INTERSECT | EXCEPT]


-- D1. Build one contact list of everyone at the SACCO: staff and members, with full name, email and a
-- 	   column saying "Staff" or "Member". How many rows?

SELECT CONCAT_WS(' ',s.first_name, s.last_name) AS full_name, s.email, 'staff' AS person_type
FROM sacco.staff s
UNION ALL
SELECT CONCAT_WS(' ',m.first_name, m.last_name), m.email ,'member'
FROM sacco.members m
ORDER BY person_type DESC, full_name; 



-- D2. How many members have both taken a loan and saved money?

SELECT COUNT(*)
FROM (
	SELECT l.member_id  FROM sacco.loans l
	INTERSECT
	SELECT st.member_id FROM sacco.savings_transactions st
) AS both_sides;



-- D3. How many members have saved but never borrowed? How many have borrowed but never saved?
--     How many have done neither?
SELECT COUNT(*)
FROM (
	SELECT st.member_id FROM sacco.savings_transactions st
	EXCEPT
	SELECT l.member_id  FROM sacco.loans l
) AS Saved_never_borrowed;


SELECT COUNT(*) 
FROM (
	SELECT l.member_id  FROM sacco.loans l
	EXCEPT
	SELECT st.member_id FROM sacco.savings_transactions st
) AS Borrowed_never_saved;


SELECT 
	COUNT(*)
FROM (
	SELECT m.member_id FROM sacco.members m
	EXCEPT
	SELECT st.member_id FROM sacco.savings_transactions st
	EXCEPT
	SELECT l.member_id FROM sacco.loans l
) Neither_Borrowed_nor_saved;




-- D4. Run SELECT branch_id FROM members UNION SELECT branch_id FROM staff and then the same with
--     UNION ALL. How many rows does each give, and why are they so different?

SELECT COUNT(*)
FROM (
	SELECT branch_id FROM members
	UNION
	SELECT branch_id FROM staff
) AS union_;


SELECT COUNT(*)
FROM (
	SELECT branch_id FROM members
	UNION ALL
	SELECT branch_id FROM staff
) AS union_all;

-- UNION - Returns branch_id 1 to 8 plus 1 null = 9 rows [Removes duplicates]
-- UNION ALL - Keeps every row (600 + 42) = 642



-- ******************************************************************************************
-- SECTION E. Date & String Functions 

-- E1. For each member show: a display name made of the first name and the last name in capitals ("John
--     OWINO"), their initials ("JO"), and the number of letters in their full name without the space

SELECT 
	m.first_name||' '|| UPPER(m.last_name)     AS display_name,
	LEFT(m.first_name, 1)||LEFT(m.last_name, 1) AS initials,
	LENGTH(m.first_name||m.last_name)           AS letter_count
FROM members m;



-- E2. Mobile numbers start with a 4-digit prefix, such as 0712. Which prefixes are most common among
--     members? Show the top 5

SELECT 
	DISTINCT LEFT(m.phone, 4) AS prefix,
	COUNT(*) AS member_count
FROM sacco.members m
GROUP BY prefix
ORDER BY member_count DESC
LIMIT 5;



-- E3. Show the 5 oldest members with their date of birth and their age today (30 September 2026). Then
--     count how many members are under 30.

SELECT 
	m.first_name, m.date_of_birth,
	DATE_PART('year', AGE('2026-09-30',m.date_of_birth)) AS age
FROM sacco.members m 
ORDER BY age DESC
LIMIT 5;

SELECT 
	COUNT(*)
FROM sacco.members m 
WHERE DATE_PART('year', AGE('2026-09-30',m.date_of_birth))  < 30;



-- E4. How many new members joined each year?

SELECT 
	DATE_PART('year',m.join_date) AS year,  -- EXTRACT(YEAR FROM join_date) AS year
	COUNT(*) AS members 
FROM sacco.members m
GROUP BY 1
ORDER BY year;



-- E5. For 2025 only, show each month (as YYYY-MM), the number of loans paid out and the total amount
--     paid out.

SELECT 
	TO_CHAR(l.disbursed_date, 'YYYY-MM') AS month,
	COUNT(*) AS loan_count,
	SUM(l.principal) AS total_amount
FROM sacco.loans l
WHERE l.disbursed_date >= DATE '2025-01-01'
	AND l.disbursed_date < DATE '2026-01-01'
GROUP BY 1
ORDER BY month;



-- E6. How many days does it take from applying for a loan to receiving the money? Show the average (1
--     decimal), shortest and longest wait for each product.

SELECT p.product_name,
 ROUND(AVG(l.disbursed_date - l.applied_date), 1) AS avg_days,
 MIN(l.disbursed_date - l.applied_date) AS Min,
 MAX(l.disbursed_date - l.applied_date) AS Max
FROM sacco.loans l
JOIN sacco.loan_products p USING(product_id)
WHERE l.disbursed_date IS NOT NULL
GROUP BY 1
ORDER BY avg_days DESC;



-- E7. On which day of the week are the most repayments made?

SELECT 
	TO_CHAR(r.payment_date, 'FMDay') AS day_of_week, --EXTRACT(DOW FROM r.payment_date) AS day_of_week,
	COUNT(*) AS repayments
FROM sacco.repayments r
GROUP BY 1
ORDER BY repayments DESC;



-- E8. Which staff have worked at the SACCO for at least 8 years (by 30 September 2026)? Show name,
--     hire date and completed years, longest-serving first

SELECT 
	s.first_name||' '||s.last_name AS full_name,
	DATE_PART('year', AGE('2026-09-30',s.hire_date)) AS years_worked
FROM sacco.staff s
WHERE DATE_PART('year', AGE('2026-09-30',s.hire_date)) >= 8           -- WHERE hire_date <= DATE '2026-09-30' - INTERVAL '8 years'
ORDER BY 2 DESC;





-- *******************************************************************************************
-- SECTION F. Putting It All Together.

-- F1. For each branch, show the number of members, the number of loans and the total principal paid
--     out (leave Pending loans out of the total). Include Thika. Biggest total first. Careful: check your
--     member counts against question C2.

SELECT 
	b.branch_name,
	COUNT(m.member_id) AS number_of_members, 
	COUNT(l.loan_id)   AS number_of_loans, 
	SUM(CASE WHEN l.status != 'Pending' THEN l.principal ELSE 0 END)   AS disbursed
FROM sacco.loans l
JOIN sacco.members m USING(member_id)
RIGHT JOIN sacco.branches b USING(branch_id)
GROUP BY 1
ORDER BY 3 DESC;



-- F2. For each loan product show: number of loans, number of different borrowers, average principal
--     (whole shillings), number of defaulted loans and the default rate as a percentage (1 decimal).
--     Include the unused product. Highest default rate first.

SELECT 
	lp.product_name, 
	COUNT(l.loan_id) 			AS loans,
	COUNT(DISTINCT l.member_id) AS borrowers,
	ROUND(AVG(l.principal), 0)  AS avg_principal,
	SUM(CASE WHEN l.status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted,
	ROUND(SUM(CASE WHEN l.status = 'Defaulted' THEN 1 ELSE 0 END)
		/ NULLIF(COUNT(l.loan_id), 0), 1) AS default_rate
FROM sacco.loan_products lp 
LEFT JOIN sacco.loans l USING(product_id)
GROUP BY 1
ORDER BY 6 DESC NULLS LAST;
	


-- F3. List members who joined in 2026 but have not saved anything yet, with their join date and branch
--     name, earliest first.

SELECT 
	m.first_name||' '||m.last_name AS full_name,
	m.join_date,
	b.branch_name
FROM sacco.branches b
JOIN sacco.members m USING(branch_id) 
LEFT JOIN sacco.savings_transactions st USING(member_id)
WHERE m.join_date >='2026-01-01' 
	AND st.txn_id IS NULL
ORDER BY 2;


-- F4. For Active loans, show the 5 with the largest outstanding balance: loan_id, member name, total due
--     (rounded to whole shillings), amount repaid so far, and balance.

SELECT 
	l.loan_id,
	m.first_name||' '||m.last_name AS full_name,
	ROUND(l.principal * (1 + (l.interest_rate/100) * (l.term_months/12)),2) AS total_due,
	COALESCE(SUM(r.amount),0) AS amount_repaid,
	ROUND(l.principal * (1 + (l.interest_rate/100) * (l.term_months/12)),2) 
		- COALESCE(SUM(r.amount),0) AS balance
FROM sacco.members m
JOIN sacco.loans l Using(member_id)
JOIN sacco.repayments r USING(loan_id)
GROUP BY 1,2
HAVING l.status = 'Active'
ORDER BY 5 DESC
LIMIT 5;



-- F5. For each branch, show the branch manager's name, their salary and how many staff report directly
--      to them. Largest team first.

select * from staff;
select * from branches;

SELECT 
	b.branch_name, 
	mgr.first_name||' '||mgr.last_name AS manager, 
	mgr.salary, 
	COUNT(team.staff_id) AS team_size
FROM sacco.branches b 
JOIN staff mgr ON mgr.staff_id = b.manager_id 
LEFT JOIN staff team ON team.manager_id = mgr.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;
















