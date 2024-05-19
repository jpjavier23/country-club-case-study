/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0
LIMIT 0 , 1000;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) AS cnt_name
FROM Facilities
WHERE membercost = 0
LIMIT 0, 1000;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0 
	AND (membercost < monthlymaintenance * 0.2)
LIMIT 0, 1000;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE name LIKE '% 2'
LIMIT 0, 1000;

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	ELSE 'cheap' END AS affordability
FROM Facilities
LIMIT 0, 1000;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = 
	(SELECT max(joindate) 
	FROM Members)
LIMIT 0, 1000;

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name as facility_name, CONCAT_WS(' ', m.firstname, m.surname) as name
FROM Bookings as b,
      Facilities as f,
      Members as m
WHERE b.memid = m.memid
	AND b.facid = f.facid
	AND f.name LIKE 'Tennis%'
ORDER BY name
LIMIT 0, 1000;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name as facility_name, 
	CONCAT_WS(' ', m.firstname, m.surname) as name,
	CASE
		WHEN m.memid = 0 THEN f.guestcost * b.slots
		ELSE f.membercost * b.slots
	END AS cost
FROM Bookings as b
JOIN Facilities as f
ON b.facid = f.facid
JOIN Members as m
ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
ORDER BY cost DESC
LIMIT 0, 12;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT (SELECT name
        FROM Facilities
        WHERE sub.facid = Facilities.facid) AS facility_name,
		(SELECT CONCAT_WS(' ', firstname, surname)
         FROM Members
         WHERE sub.memid = Members.memid) AS name,
		cost
FROM (SELECT b.facid as facid,
      b.memid as memid,
      CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
      	ELSE f.membercost * b.slots
      END AS cost
    FROM Bookings as b
    JOIN Facilities as f
    ON b.facid = f.facid
    WHERE b.starttime LIKE '2012-09-14%') AS sub
ORDER BY cost DESC
LIMIT 0, 12;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

q10_table = con.execute('SELECT facility_name, SUM(cost) AS total_revenue FROM (SELECT f.name AS facility_name, b.memid AS id, CASE WHEN b.memid = 0 THEN f.guestcost * b.slots ELSE f.membercost * b.slots END AS cost FROM Bookings as b JOIN Facilities as f ON b.facid = f.facid) AS sub GROUP BY facility_name ORDER BY total_revenue ASC LIMIT 0, 3')
q10 = pd.DataFrame(q10_table.fetchall(), columns = q10_table.keys())
q10

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

q11_table = con.execute('SELECT (m1.surname || ", " || m1.firstname) AS name, CASE WHEN m1.recommendedby IS NULL THEN "none" ELSE (m2.surname || ", " || m2.firstname) END AS referred_by FROM Members AS m1 FULL JOIN Members AS m2 ON m2.memid = m1.recommendedby WHERE name IS NOT NULL ORDER BY name')
q11 = pd.DataFrame(q11_table.fetchall(), columns = q11_table.keys())
q11

/* Q12: Find the facilities with their usage by member, but not guests */

q12_table = con.execute('SELECT facility_name, name, COUNT(name) AS facility_use FROM (SELECT b.starttime as time, b.slots AS n_slot, f.name AS facility_name, b.memid AS id, (m.surname || ", " || m.firstname) as name FROM Bookings AS b JOIN Facilities AS f ON b.facid = f.facid JOIN Members AS m ON b.memid = m.memid WHERE b.memid <> 0) AS sub GROUP BY facility_name, name ORDER BY time;')
q12 = pd.DataFrame(q12_table.fetchall())
q12

/* Q13: Find the facilities usage by month, but not guests */

q13_table = con.execute('SELECT facility_name, month, COUNT(month) AS facility_use FROM (SELECT b.starttime as time, CASE WHEN b.starttime LIKE "2012-07%" THEN "07" WHEN b.starttime LIKE "2012-08%" THEN "08" WHEN b.starttime LIKE "2012-09%" THEN "09" END AS month, b.slots AS n_slot, f.name AS facility_name, b.memid AS id, (m.surname || ", " || m.firstname) as name FROM Bookings AS b JOIN Facilities AS f ON b.facid = f.facid JOIN Members AS m ON b.memid = m.memid WHERE b.memid <> 0) AS sub GROUP BY facility_name, month ORDER BY facility_name, month;')
q13 = pd.DataFrame(q13_table.fetchall())
q13
