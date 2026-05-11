-- Hypothesis 1: Platforms with clear campaign instructions and predictable approval processes are more attractive for small creators.

SELECT
    AVG(CAST(transparency_importance_score AS DECIMAL(3,1))) AS avg_transparency,
    COUNT(*) AS total_participants
FROM airdrop_raw_copy
WHERE LOWER(participation_status) = 'yes';

SELECT
    f.frustration,
    COUNT(*) AS total
FROM airdrop_raw_copy a
JOIN frustration_normalized f ON a.id = f.id
WHERE LOWER(a.participation_status) = 'yes'
GROUP BY f.frustration
ORDER BY total DESC;

-- Hypothesis 2: Platforms that promise higher rewards but have low approval consistency may discourage long-term participation.

SELECT
    reward_preference,
    COUNT(f.frustration) AS frustration_count,
    COUNT(*) AS total_users
FROM airdrop_raw_copy a
LEFT JOIN frustration_normalized f ON a.id = f.id
GROUP BY reward_preference
ORDER BY frustration_count DESC;

-- Hypothesis 3: Participation intensity and campaign structure may influence creator frustration levels.

-- 1. Weekly Hours vs Frustration
SELECT
    weekly_hours_spent,
    AVG(has_frustration) AS frustration_ratio,
    COUNT(*) AS total_users
FROM (
    SELECT
        a.id,
        a.weekly_hours_spent,
        CASE 
            WHEN f.id IS NOT NULL THEN 1
            ELSE 0
        END AS has_frustration
    FROM airdrop_raw_copy a
    LEFT JOIN (
        SELECT DISTINCT id FROM frustration_normalized
    ) f ON a.id = f.id
) t
GROUP BY weekly_hours_spent;

-- 2. Activity Types vs Frustration

SELECT
    at.activity_type,
    AVG(t.has_frustration) AS frustration_ratio,
    COUNT(DISTINCT t.id) AS total_users
FROM activity_types_normalized at
JOIN (
    SELECT
        a.id,
        CASE 
            WHEN f.id IS NOT NULL THEN 1
            ELSE 0
        END AS has_frustration
    FROM airdrop_raw_copy a
    LEFT JOIN (
        SELECT DISTINCT id FROM frustration_normalized
    ) f ON a.id = f.id
) t ON at.id = t.id
GROUP BY at.activity_type;

-- 3. Duration vs Frustration

SELECT
    participation_duration,
    AVG(has_frustration) AS frustration_ratio,
    COUNT(*) AS total_users
FROM (
    SELECT
        a.id,
        a.participation_duration,
        CASE 
            WHEN f.id IS NOT NULL THEN 1
            ELSE 0
        END AS has_frustration
    FROM airdrop_raw_copy a
    LEFT JOIN (
        SELECT DISTINCT id FROM frustration_normalized
    ) f ON a.id = f.id
) t
GROUP BY participation_duration;

-- Hypothesis 4: Even when rewards are smaller, platforms with higher approval probability may be perceived as more rational for consistent participation.

-- Reward vs Frustration

SELECT
    reward_preference,
    AVG(has_frustration) AS frustration_ratio,
    COUNT(*) AS total_users
FROM (
    SELECT
        a.id,
        a.reward_preference,
        CASE 
            WHEN f.id IS NOT NULL THEN 1
            ELSE 0
        END AS has_frustration
    FROM airdrop_raw_copy a
    LEFT JOIN (
        SELECT DISTINCT id FROM frustration_normalized
    ) f ON a.id = f.id
) t
GROUP BY reward_preference;

-- Fairness

SELECT
    reward_preference,

    CASE
        WHEN LOWER(fairness_opinion) LIKE '%unfair%'
            OR LOWER(fairness_opinion) LIKE '%random%'
            OR LOWER(fairness_opinion) LIKE '%inconsistent%'
            OR LOWER(fairness_opinion) LIKE '%gak jelas%'
            OR LOWER(fairness_opinion) LIKE '%tidak adil%'
        THEN 'unfair'

        WHEN LOWER(fairness_opinion) LIKE '%fair%'
            OR LOWER(fairness_opinion) LIKE '%transparent%'
        THEN 'fair'

        ELSE 'neutral'
    END AS fairness_category,

    COUNT(*) AS total_users

FROM airdrop_raw_copy
GROUP BY reward_preference, fairness_category;