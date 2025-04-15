DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


SELECT * FROM spotify
LIMIT 100;

SELECT *
FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify 
WHERE duration_min = 0;

/*Easy Level
1.Retrieve the names of all tracks that have more than 1 billion streams.
2.List all albums along with their respective artists.
3.Get the total number of comments for tracks where licensed = TRUE.
4.Find all tracks that belong to the album type single.
5.Count the total number of tracks by each artist.*/

-- 1

SELECT * FROM spotify
WHERE stream > 1000000000

-- 2

SELECT album,artist
FROM spotify ;


-- 3

SELECT SUM(comments ) AS Total_comments
FROM spotify
WHERE licensed = 'true';

-- 4

SELECT track
FROM spotify
WHERE album_type = 'single'
;

-- 5

SELECT 
	artist,
	count(*) as no_of_tracks
FROM spotify
GROUP BY artist;

/*
Medium Level
1.Calculate the average danceability of tracks in each album.
2.Find the top 5 tracks with the highest energy values.
3.List all tracks along with their views and likes where official_video = TRUE.
4.For each album, calculate the total views of all associated tracks.
5.Retrieve the track names that have been streamed on Spotify more than YouTube.*/

-- 1

SELECT 
	album,
	AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY album;

-- 2

SELECT 
	track,
	max(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5 ;

-- 3

SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
 ;

-- 4

SELECT 
	album,
	track,
	SUM(views) as total_views
FROM spotify
GROUP BY 1,2
ORDER BY 2;

-- 5 

SELECT * FROM
(SELECT 
	track,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as streamed_on_youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
GROUP BY 1) AS T1
WHERE 
	streamed_on_youtube < streamed_on_spotify
	AND 
	streamed_on_youtube > 0 
;

/*
Advanced Level
1.Find the top 3 most-viewed tracks for each artist using window functions.
2.Write a query to find tracks where the liveness score is above the average.
3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album. 
*/

-- 1
WITH artist_ranking 
as
(SELECT 
	artist,
	track,
	SUM(views) as total_views,
	DENSE_RANK( ) OVER( PARTITION BY artist ORDER BY SUM(views) DESC ) AS Rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC)
SELECT * FROM artist_ranking
WHERE rank <= 3;

-- 2

SELECT 
	track,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)

-- 3

WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1)
SELECT 
	album,
	highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY 2 DESC