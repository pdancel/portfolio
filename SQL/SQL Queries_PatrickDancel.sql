-- Included in this markdown are samples of basic to advanced queries (nested queries, joins, etc.) that I wrote. 

use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`. 
select first_name, last_name 
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name,' ', last_name) as 'Actor Name'
from actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id,first_name, last_name 
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`
select last_name 
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name, first_name
from actor
where last_name like '%LI%';

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');


-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER table actor
    add column middle_name varchar(45) AFTER first_name;
  	
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
MODIFY COLUMN middle_name blob;

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name) as count
from actor
group by last_name;	

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) 
from actor
group by last_name
having count(last_name) > 1;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

  	
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = (
    CASE
        WHEN actor.first_name = "GROUCHO" THEN "MUCHO GROUCHO"
        WHEN actor.first_name = "HARPO" AND actor.actor_id = "172" THEN "GROUCHO"
        ELSE actor.first_name
    END);

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select staff.first_name, staff.last_name, address.address
from staff
join address
on staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT first_name, last_name, SUM(amount) AS 'Total'
FROM staff
JOIN payment 
ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE '2005-08%'
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select title, count(actor_id) as '# of Actors' 
from film
join film_actor 
on film.film_id = film_actor.film_id
group by film.film_id;	

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(title) as "# of Copies"
from film
join inventory
on film.film_id = inventory.film_id
where title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- sum the purchase amount for each person 
SELECT first_name, last_name, SUM(amount)
FROM customer
JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY first_name , last_name
ORDER BY last_name ASC;

--  7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles 
-- of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title, name
FROM film AS f
JOIN language AS l 
ON f.language_id = l.language_id
WHERE title LIKE 'K%' OR title LIKE 'Q%';


-- 7b. 
select first_name, last_name 
from actor   	
where actor_id in (select actor_id 
				   from film_actor
				   where film_id = (select film_id 
				   					from film 
				   					where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email, country
FROM customer AS cust
JOIN address AS a 
ON cust.address_id = a.address_id
JOIN city AS cit 
ON a.city_id = cit.city_id
INNER JOIN country AS co 
ON cit.country_id = co.country_id
WHERE
    co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.

SELECT title, name AS category
FROM film AS f
JOIN film_category AS fc 
ON f.film_id = fc.film_id
JOIN category AS c 
ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

SELECT f.title AS 'movie', COUNT(r.rental_date) AS '# of rentals'
FROM film AS f
JOIN inventory AS i 
ON i.film_id = f.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_date) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store_id, SUM(amount) AS store_total
FROM payment AS p
JOIN staff AS s 
ON p.staff_id = s.staff_id
GROUP BY p.staff_id
ORDER BY store_total DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.


SELECT store_id, city, country
FROM store AS s
JOIN address AS a 
ON s.address_id = a.address_id
JOIN city AS c 
ON a.city_id = c.city_id
JOIN country AS co ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount) AS gross_revenue
FROM category AS c
JOIN film_category AS fc 
ON c.category_id = fc.category_id
JOIN inventory AS i 
ON fc.film_id = i.film_id
JOIN rental AS r 
ON i.inventory_id = r.inventory_id
JOIN payment AS p 
ON r.rental_id = p.rental_id
GROUP BY name
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE TABLE top_five (
    id INTEGER(11) AUTO_INCREMENT NOT NULL,
    name VARCHAR(30),
    gross_revenue DECIMAL(10 , 2 ),
    PRIMARY KEY (id)
);

insert into top_five (name, gross_revenue)
values ('Sports', 5314.21), ('Sci-Fi', 4756.98), ('Animation', 4656.30), ('Drama', 4587.39), ('Comedy', 4383.58);

SELECT *
FROM top_five;

-- create view
CREATE VIEW top_5_view AS
SELECT name, gross_revenue
FROM top_five;


-- 8b. How would you display the view that you created in 8a?
-- display view --
SELECT *
FROM top_5_view;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it. 
drop view top_5_view;				   					