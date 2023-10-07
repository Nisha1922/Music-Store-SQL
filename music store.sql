/* EASY SET QUESTIONS */
/*Q1:Who is the senior most employee based on job tilte?*/
SELECT * FROM employee
ORDER BY  levels desc
limit 1;

/*Q2: Which country have the most Invoices?*/
SELECT count(billing_country) AS c,billing_country
FROM invoice
GROUP BY  billing_country
ORDER BY c desc;

/*Q3: What are top 3 values of total invoice?*/
SELECT total FROM invoice
ORDER BY total DESC
limit 3;

/*Q4: Which city has the best customers? We would like to throw a 
promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of
invoice totals. Return both the city name & sum of all invoices totals*/

SELECT billing_city,sum(total) AS invoice_total FROM invoice
GROUP BY billing_city 
ORDER BY SUM(total) desc
limit 1;

/*Q5:Who is the best customer? The customer who has spent the most
money will be declared the best customer. Write a query that
returns the person who has spent the most money.*/

SELECT c.customer_id,c.first_name,c.last_name, sum(i.total) AS total
FROM customer AS c
JOIN invoice AS i
ON c.customer_id=i.customer_id
GROUP BY 1,2,3
ORDER BY 4 desc
limit 1;

/* MODERATE SET QUESTIONS */

/*Q6: Write a query to return all the email,first name,last name 
and Genre of all the Rock Music listeners. Return your list ordered 
alphabetically by email starting with A.*/

SELECT DISTINCT c.email,c.first_name,c.last_name
FROM customer AS c JOIN invoice AS i
ON c.customer_id=i.customer_id
JOIN invoice_line AS il ON i.invoice_id=il.invoice_id
WHERE track_id IN (
SELECT track_id FROM track AS t
JOIN genre AS g ON t.genre_id=g.genre_id
WHERE g.name='Rock')
ORDER BY c.email;

/*Q7:Lets  invite the artists who have written the most rock music in 
dataset. Write a query that returns the Artist name and total
track count of the top 10 rock bands.*/

with t1 AS 
(SELECT * FROM Album AS al JOIN track AS t
ON al.album_id=t.album_id)
SELECT a.name,count(t1.genre_id) as count
FROM artist AS a JOIN t1 
ON a.artist_id=t1.artist_id
WHERE t1.genre_id IN
(SELECT g.genre_id FROM genre AS g 
JOIN track AS t ON t.genre_id=g.genre_id
WHERE g.name='Rock') 
GROUP BY a.name
ORDER BY count desc
limit 10;

/* Q8: Return all the track names that have a song length longer than the 
average song length. Return the Name and Milliseconds for each track.
Order by the song lenth with the longest songs listed first.*/

SELECT name, milliseconds 
FROM track 
WHERE milliseconds> (SELECT avg(milliseconds) FROM track)
ORDER BY milliseconds desc;

/* HARD SET QUESTIONS */

/* Q9:Find how much amount is spent by each customer on best selling
artist?
Write a query to return customer name,artist name and total money spent.*/

WITH best_selling_artist AS (
SELECT a.artist_id,a.name AS artist_name,
SUM(il.unit_price*il.quantity) AS money_earned_per_artist
FROM invoice_line AS il JOIN track AS t ON il.track_id=t.track_id
JOIN album AS al ON al.album_id=t.album_id
JOIN artist AS a ON a.artist_id=al.artist_id
GROUP BY 1
ORDER BY 3 DESC 
limit 1 )

SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice AS i JOIN customer AS c ON c.customer_id=i.customer_id
JOIN invoice_line AS il ON il.invoice_id=i.invoice_id
JOIN track AS t ON t.track_id=il.track_id
JOIN album AS al ON al.album_id=t.album_id
JOIN best_selling_artist AS bsa ON bsa.artist_id=al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC ;

/* Q10: We want to find out the most popular music Genre for each country.
We determine the most popular genre as the genre with the highest amount 
of purchases. Write a query that returns each country along with 
the top Genre. For countries where the maximum number of purchases is
shared, return all Genres. */

WITH most_popular_genre AS (
SELECT g.genre_id,g.name,COUNT(il.quantity) AS genre_purchases
FROM genre AS g 
JOIN track AS t ON g.genre_id=t.genre_id
JOIN invoice_line AS il ON t.track_id=il.track_id
GROUP BY 1
ORDER BY 3 DESC
),
  t1 AS (
SELECT c.country,mpg.name AS genre_name,
COUNT(il.quantity) AS purchase_per_genre,
ROW_NUMBER() OVER (PARTITION BY c.country
				   ORDER BY COUNT(il.quantity) DESC) AS rn
FROM customer AS c 
JOIN invoice AS i ON c.customer_id=i.customer_id
JOIN invoice_line AS il ON il. invoice_id=i.invoice_id
JOIN track AS t ON t.track_id=il.track_id
JOIN most_popular_genre AS mpg ON mpg.genre_id=t.genre_id
GROUP BY 1,2
ORDER BY 3 DESC 
	)
SELECT * FROM t1 WHERE rn=1;

/* Q11: Write a query that determines the customer that has spent the most 
on music for each country. Write a query that returns the country along 
with top customer and how much they spent. For countries where the top amount
spent is shared, provide all customers who spent this amount. */

WITH t1 AS (
SELECT c.customer_id,c.first_name,c.last_name,c.country,
SUM(il.unit_price*il.quantity) AS money_spent,
ROW_NUMBER () OVER(PARTITION BY c.country 
				   ORDER BY SUM(il.unit_price*il.quantity) DESC ) AS rn
FROM customer AS c 
JOIN invoice AS i ON c.customer_id=i.customer_id
JOIN invoice_line AS il ON il.invoice_id=i.invoice_id

GROUP BY 1,4
ORDER BY 4 ASC,5 DESC
)
SELECT * FROM t1 WHERE rn=1;


                        /* END OF PROJECT */






