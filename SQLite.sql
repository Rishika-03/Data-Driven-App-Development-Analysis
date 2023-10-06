--Problem Statement: Stakeholder for this analysis is an App developer who wantsto decide what type of app to be build based on Data driven insights.
-- 1) Which App cateogories or genres are most popular?
-- 2) How pricing affects the app? 
-- 3) How to maximise ratings?

CREATE TABLE applestore_description_combined AS
SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4

**Exploratory Data Analysis**

-- Checking number of unique apps in both AppleStore tables 
SELECT COUNT(DISTINCT id) As UniqueAppid
FROM AppleStore

SELECT COUNT(DISTINCT id) As UniqueAppid
FROM applestore_description_combined
-- INSIGHTS: Gives number of unique apps present in the app store 

-- Checking for missing values in key feilds 
SELECT COUNT(*) AS MissingValues 
FROM AppleStore
WHERE track_name ISNULL or user_rating ISNULL or prime_genre ISNULL

SELECT COUNT(*) AS MissingValues 
FROM applestore_description_combined
WHERE app_desc ISNULL
--INSIGHTS: No Null values are present in key columns of the database.

-- Number of apps per Genre 
SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP by prime_genre
ORDER by NumApps DESC
--INSIGHTS: Games as a genre has more than 3000 apps, followed by Entertainment and Education.
--          Such genres already has lot of apps and could be challenging for new apps as the market may already be saturated.
--          However, it also suggest high user demands in these genres.

-- Overview of App ratings 
SELECT min(user_rating) as MinRating,
       max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore
--INSIGHTS: Min rating = 0
--          Max rating = 5
--          Avg rating = 3.526
--          The developed app should aim average rating higher than 3.5 to standout.

**Data Analysis** 
--Determine whether Paid apps have higher ratings than Free apps 
SELECT CASE
            when price > 0 then 'Paid'
            else 'Free'
       End as App_type ,
       avg(user_rating) as Avg_Rating
from AppleStore
GROUP by App_type
--INSIGHTS: Average rating of paid apps are slightly higher than the free apps. 
--          Avg rating of paid apps = 3.720
--          Avg rating of free apps = 3.376

--Check if apps with more supported languages have higher ratings 
SELECT CASE
           when lang_num < 10 then '<10 languages'
           WHEN lang_num BETWEEN 10 and 30 THEN '10-30 languages'
           ELSE '>30 languages'
       end as language_count,
       avg(user_rating) as Avg_rating
FROM AppleStore
GROUP by language_count
ORDER by Avg_rating desc 
--INSIGHTS: More supported languages does not ensure higher average rating. 
--          Supported language count between 10 and 30 reports highest average rating with 4.130 value.

--Determine genres with low ratings 
SELECT prime_genre, 
       avg(user_rating) as Avg_rating
FROM AppleStore
GROUP by prime_genre
ORDER by Avg_rating 
LIMIT 10

--INSIGHTS: Genres like Catalogs, Finance, Book, Navigation, Lifestyle, etc have lowest average rating.
--          Such genres require better apps and could be a good market oppurtunity. 

--Check if there exists any correlation between length of app description and user ratings 
SELECT CASE
           when length(b.app_desc) < 500 THEN 'Short'
           WHEN length(b.app_desc) BETWEEN 500 and 1000 THEN 'Medium'
           else 'Long'
       end as description_length,
       avg(a.user_rating) as Avg_rating
FROM AppleStore as a 
join applestore_description_combined as b
on a.id = b.id
GROUP by description_length
order by Avg_rating desc
--INSIGHTS: Average rating of long description is higher whereas apps with short description has lowest average rating with 2.533 as value.
--          Indicates users likes to know more about the apps and their functioning, to have better understanding of it before actually using them.

--Determine the top-rated apps for each genre 
SELECT prime_genre,
       track_name,
       user_rating
FROM (
       SELECT prime_genre,
              track_name,
              user_rating,
              RANK() OVER(PARTITION by prime_genre ORDER by user_rating desc , rating_count_tot desc) as rank
       FROM AppleStore
  ) as a 
  WHERE a.rank = 1
  --INSIGHTS: Shows apps with highest rating for each genre.
  --          Indicates kind of apps liked by the user in each genre, could be used to understand more about the general interest and likeness of users.
  