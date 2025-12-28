Select * from Bank_Loan_Data;

-- Total Loan applications
SELECT COUNT(id) AS total_loan_application
FROM Bank_Loan_Data;

-- Total Loan applications in December
SELECT COUNT(id) AS MTD_total_loan_application
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021;

-- Dynamic month & year
SELECT COUNT(id) AS MTD_total_loan_application
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=(select MIN(MONTH(issue_date)) FROM Bank_Loan_Data)

AND YEAR(issue_date) = (select max(year(issue_date)) from Bank_Loan_Data)
-- Previous month application
SELECT COUNT(id) AS PMTD_total_loan_application
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021;

-- (MTD-PMTD)/MTD -- last month availbale data is december so assuming current month as december
WITH Current_month_app AS(
SELECT 
     COUNT(id) AS MTD_total_loan_application
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021),

Previous_month_app AS(
SELECT 
      COUNT(id) AS PMTD_total_loan_application
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021)

SELECT MTD_total_loan_application,
      PMTD_total_loan_application,
      CAST((c.MTD_total_loan_application-p.PMTD_total_loan_application)*1.0/p.PMTD_total_loan_application 
	  AS decimal(10,2)) AS MOM_growth
from Current_month_app c 
cross join Previous_month_app p ;

-----------------------------------------------------------------------------------------------------------
-- Total_funded_amount

SELECT SUM(loan_amount) AS total_funded_amount
FROM Bank_Loan_Data;

SELECT SUM(loan_amount) AS MTD_total_funded_amount
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date)=2021;

SELECT SUM(loan_amount) AS PMTD_total_funded_amount
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date)=2021;
--------------------------------------------------------------------------------------------------------------
-- Total_amount_recieved

SELECT SUM(total_payment) AS total_payment_recieved
FROM Bank_Loan_Data;

SELECT SUM(total_payment) AS MTD_total_payment_recieved
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date) =2021;

SELECT SUM(total_payment) AS PMTD_total_payment_recieved
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date) =2021;
------------------------------------------------------------------------------------------------------------
-- Average Interst Rate
SELECT 
      ROUND(AVG(int_rate)*100,2) AS Avg_int_rate
FROM Bank_Loan_Data;

SELECT 
      ROUND(AVG(int_rate)*100,2) AS MTD_Avg_int_rate
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date) =2021;

SELECT 
      ROUND(AVG(int_rate)*100,2) AS PMTD_Avg_int_rate
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date) =2021;
-----------------------------------------------------------------------------------------------------------------
-- Average DTI - debt to income

SELECT ROUND(AVG(dti)*100,2) as MTD_Avg_dti
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=12 AND YEAR(issue_date) =2021;

SELECT ROUND(AVG(dti)*100,2) as PMTD_Avg_dti
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=11 AND YEAR(issue_date) =2021;
-----------------------------------------------------------------------------------------------------------------

-- Good_loan Pct
SELECT 
(COUNT(CASE WHEN loan_status IN ('current', 'Fully paid') THEN id END))*100
/COUNT(id) AS good_loan_pct
FROM Bank_Loan_Data;
------------------------------------------------------------------------------------------------------------

-- Good_loan_app_cnt
SELECT COUNT(id) AS Good_loan_app
FROM Bank_Loan_Data
WHERE loan_status IN ('Fully paid', 'current')
--------------------------------------------------------------------------------------------------------------

-- Good loan funded amount
SELECT SUM(loan_amount) AS Good_loan_funded_amt
FROM Bank_Loan_Data
WHERE loan_status IN ('Fully paid', 'current');

-- Good loan recieved amount
SELECT SUM(total_payment) AS Good_loan_recieved_amt
FROM Bank_Loan_Data
WHERE loan_status IN ('Fully paid', 'current');


------------------------------------------------------------------------------------------------------------------
-- Bad loan Pct
SELECT
   (COUNT(CASE WHEN loan_status = 'charged off' THEN id END ))*100
   /COUNT(id) AS Bad_loan_pct
   FROM Bank_Loan_Data;

   -- Bad loan applications
SELECT COUNT(id) AS bad_loan_app
FROM Bank_Loan_Data
WHERE loan_status ='Charged off';

-- Bad loan funded amount
SELECT SUM(loan_amount) AS Bad_loan_funded_amt
FROM Bank_Loan_Data
WHERE loan_status = 'Charged off';

-- Bad loan recieved amount
SELECT SUM(total_payment) AS Bad_loan_recieved_amt
FROM Bank_Loan_Data
WHERE loan_status = 'Charged off';
----------------------------------------------------------------------------------------------------------

SELECT 
      loan_status,
	  COUNT(id) AS Total_loan_application,
	  Sum(loan_amount) AS Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec,
	  ROUND(AVG(int_rate*100),2) AS Avg_int_rate,
	  ROUND(AVG(dti *100),2) AS Avg_dti
FROM Bank_Loan_Data
GROUP BY loan_status;

-----------------------------------------------------------------------------------------------------------------
SELECT 
      loan_status,
	  COUNT(id) AS MTD_Total_loan_application,
	  Sum(loan_amount) AS MTD_Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec,
	  ROUND(AVG(int_rate*100),2) AS Avg_int_rate,
	  ROUND(AVG(dti *100),2) AS Avg_dti
FROM Bank_Loan_Data
WHERE MONTH(issue_date) =12
GROUP BY loan_status;
------------------------------------------------------------------------------------------------------------------
-- Monthwise Trend
SELECT 
      MONTH(issue_date) As Month,
      DATENAME(MONTH, issue_date) AS Month_name,
	  COUNT(id) AS Total_loan_application,
	  Sum(loan_amount) AS Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec,
	  ROUND(AVG(int_rate*100),2) AS Avg_int_rate,
	  ROUND(AVG(dti *100),2) AS Avg_dti
FROM Bank_Loan_Data
GROUP BY DATENAME(MONTH, issue_date), MONTH(issue_date) 
ORDER By MONTH(issue_date);
------------------------------------------------------------------------------------------------------------------------

-- Region Wise Performance
SELECT 
      address_state,
	  COUNT(id) AS Total_loan_application,
	  Sum(loan_amount) AS Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec,
	  ROUND(AVG(int_rate*100),2) AS Avg_int_rate,
	  ROUND(AVG(dti *100),2) AS Avg_dti
FROM Bank_Loan_Data
GROUP BY address_state
ORDER BY COUNT(id) DESC;
-------------------------------------------------------------------------------------------------------------------------
-- Term Wise Performance
SELECT 
      term,
	  COUNT(id) AS Total_loan_application,
	  Sum(loan_amount) AS Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec,
	  ROUND(AVG(int_rate*100),2) AS Avg_int_rate,
	  ROUND(AVG(dti *100),2) AS Avg_dti
FROM Bank_Loan_Data
GROUP BY term
ORDER BY COUNT(id) DESC;
------------------------------------------------------------------------------------------------------

SELECT 
      emp_length,
	  COUNT(id) AS Total_loan_application,
	  Sum(loan_amount) AS Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec,
	  ROUND(AVG(int_rate*100),2) AS Avg_int_rate,
	  ROUND(AVG(dti *100),2) AS Avg_dti
FROM Bank_Loan_Data
GROUP BY emp_length
ORDER BY COUNT(id) DESC;
-----------------------------------------------------------------------------------------------------

SELECT 
      purpose,
	  COUNT(id) AS Total_loan_application,
	  Sum(loan_amount) AS Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec
FROM Bank_Loan_Data
GROUP BY purpose
ORDER BY COUNT(id) DESC;
---------------------------------------------------------------------------------------------------------

SELECT 
      home_ownership,
	  COUNT(id) AS Total_loan_application,
	  Sum(loan_amount) AS Loan_amt_funded,
	  SUM(total_payment) AS Loan_amt_rec
FROM Bank_Loan_Data
GROUP BY home_ownership
ORDER BY COUNT(id) DESC;
--------------------------------------------------------------------------------------------------------------