-- Create table

CREATE TABLE airdrop_raw (
    id INT AUTO_INCREMENT PRIMARY KEY,
    submitted_at TEXT,
    participation_status TEXT,
    participation_duration TEXT,
    activity_types TEXT,
    weekly_hours_spent TEXT,
    main_motivation TEXT,
    main_frustration TEXT,
    transparency_importance_score TEXT,
    preferred_campaign_type TEXT,
    reward_preference TEXT,
    willing_to_deposit TEXT,
    avoid_reason TEXT,
    fairness_opinion TEXT,
    contact_info TEXT
);

-- Insert the dataset

LOAD DATA LOCAL INFILE 'C:/Dataset/Airdrop Hunter/clean_airdrop.csv'
INTO TABLE airdrop_raw
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
submitted_at,
participation_status,
participation_duration,
activity_types,
weekly_hours_spent,
main_motivation,
main_frustration,
transparency_importance_score,
preferred_campaign_type,
reward_preference,
willing_to_deposit,
avoid_reason,
fairness_opinion,
contact_info
);

-- Check the table to make sure that the data already in correct column

SELECT * FROM airdrop_raw;

-- I make a copy of the dataset. So, the original dataset will not change there's any mistake during data wrangling process

CREATE TABLE airdrop_raw_copy
LIKE airdrop_raw;

INSERT airdrop_raw_copy
SELECT * FROM airdrop_raw;

SELECT * FROM airdrop_raw_copy;

-- Delete empty row

SELECT * FROM airdrop_raw_copy
WHERE submitted_at = "";

DELETE FROM airdrop_raw_copy
WHERE submitted_at = "";

-- Fix typo 

UPDATE airdrop_raw_copy
SET participation_duration = '3-6 months'
WHERE participation_duration LIKE '%3?6%';

UPDATE airdrop_raw_copy
SET participation_duration = '6-12 months'
WHERE participation_duration LIKE '%6?12%';

UPDATE airdrop_raw_copy
SET weekly_hours_spent = '3-5 hours'
WHERE weekly_hours_spent LIKE '%3%';

-- Normalize multiple choice

CREATE TEMPORARY TABLE numbers (n INT);
INSERT INTO numbers VALUES (1),(2),(3),(4),(5);

CREATE TABLE activity_types_normalized AS
SELECT
    id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(activity_types, ',', n), ',', -1)) AS activity_type
FROM airdrop_raw_copy
JOIN numbers
ON CHAR_LENGTH(activity_types) 
   - CHAR_LENGTH(REPLACE(activity_types, ',', '')) >= n - 1;
   
SELECT * FROM activity_types_normalized;

CREATE TABLE frustration_normalized AS
SELECT
    id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(main_frustration, ',', n), ',', -1)) AS frustration
FROM airdrop_raw_copy
JOIN numbers
ON CHAR_LENGTH(main_frustration) 
   - CHAR_LENGTH(REPLACE(main_frustration, ',', '')) >= n - 1;

SELECT * FROM frustration_normalized;