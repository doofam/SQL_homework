USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT * FROM actor; 
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name, ' ', last_name) AS "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name="Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country; 
SELECT country_id, country FROM country 
WHERE country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD description BLOB;
SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP description; 
SELECT * FROM actor; 

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) as count FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as count FROM actor
GROUP BY last_name HAVING count >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT * FROM actor WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
UPDATE actor SET first_name = "Harpo" WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = "Groucho" WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT * FROM address;
SELECT * FROM staff;

SELECT s.first_name, s.last_name, a.address 
FROM staff s
JOIN address a USING(address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT * FROM payment;

SELECT s.first_name, s.last_name, SUM(p.amount) AS total_amount
FROM staff s
JOIN payment p USING(staff_id)
WHERE p.payment_date >= "2005-08-01 00:00:00" 
AND p.payment_date < "2005-09-01 00:00:00"
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT * FROM film_actor;
SELECT * FROM film; 

SELECT f.film_id, f.title, COUNT(fa.actor_id) AS actor_count
FROM film_actor fa
INNER JOIN film f USING(film_id)
GROUP BY film_id; 

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT * FROM inventory;

SELECT f.title, COUNT(i.inventory_id) AS inventory_count
FROM film f
INNER JOIN inventory i USING(film_id)
WHERE f.title = "Hunchback Impossible"
GROUP BY film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT * FROM payment;
SELECT * FROM customer;

SELECT c.first_name, c.last_name, SUM(p.amount) AS total_amount_paid
FROM customer c
JOIN payment p USING(customer_id)
GROUP BY customer_id
ORDER BY c.last_name; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT * FROM film;
SELECT * FROM language;

SELECT f.title 
FROM film f
JOIN language l using(language_id)  
WHERE (f.title LIKE "K%" OR f.title LIKE "Q%")
AND l.name = "English";

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT * FROM film_actor;
SELECT * FROM film;
SELECT * FROM actor;

SELECT a.first_name, a.last_name
FROM film_actor
JOIN film f USING(film_id)
JOIN actor a USING(actor_id)
WHERE f.title = "Alone Trip";

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT * FROM customer; -- has address_id
SELECT * FROM address; -- has city_id
SELECT * FROM city; -- has country_id
SELECT * FROM country; -- has country_id, country

SELECT customer.first_name, customer.last_name, customer.email, country.country 
FROM customer 
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT * FROM category; -- category_id
SELECT * FROM film_category; -- category_id, film_id
SELECT * FROM film; -- film_id

SELECT f.title, c.name AS category
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental; -- rental_id, inventory_id
SELECT * FROM inventory; -- inventory_id, film_id
SELECT * FROM film; -- film_id, title 

SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id 
GROUP BY f.film_id 
ORDER BY rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store; -- store_id
SELECT * FROM inventory; -- store_id, film_id
SELECT * FROM film; -- film_id, replacement_cost

SELECT s.store_id, SUM(f.replacement_cost) AS cost
FROM store s 
JOIN inventory i ON s.store_id = i.store_id
JOIN film f ON i.film_id = f.film_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store; -- address_id
SELECT * FROM address; -- city_id
SELECT * FROM city; -- country_id
SELECT * FROM country;

SELECT store.store_id, city.city, country.country
FROM store 
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category; -- category_id
SELECT * FROM film_category; -- category_id, film_id
SELECT * FROM inventory; -- film_id, inventory_id
SELECT * FROM rental; -- inventory_id, rental_id
SELECT * FROM payment; -- rental_id, amount

SELECT c.name, SUM(p.amount) AS gross_revenue
FROM category c 
JOIN film_category f ON c.category_id = f.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.category_id
ORDER BY gross_revenue DESC
LIMIT 5; 

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS 
SELECT c.name, SUM(p.amount) AS gross_revenue
FROM category c 
JOIN film_category f ON c.category_id = f.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.category_id
ORDER BY gross_revenue DESC
LIMIT 5; 

-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW top_five_genres;
SELECT * FROM top_five_genres; 

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;
