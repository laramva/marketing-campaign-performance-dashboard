-- 1. Criar o banco do projeto
CREATE DATABASE IF NOT EXISTS marketing_campaigns;

-- 2. Usar esse banco
USE marketing_campaigns;

-- 3. Criar a tabela onde vamos importar o CSV
DROP TABLE IF EXISTS facebook_ads_clean;

CREATE TABLE facebook_ads_clean (
    fb_campaign_id      INT,
    age_range           VARCHAR(20),
    gender              VARCHAR(5),
    interest            INT,
    impressions         INT,
    clicks              INT,
    spent               DECIMAL(10,4),
    total_conversion    INT,
    approved_conversion INT,
    cpc                 DECIMAL(10,4)
);

ALTER TABLE facebook_ads_clean 
ADD COLUMN cpm DECIMAL(10,4),
ADD COLUMN ctr DECIMAL(10,4),
ADD COLUMN conversion_rate DECIMAL(10,4),
ADD COLUMN cost_per_conversion DECIMAL(10,4),
ADD COLUMN revenue DECIMAL(10,4),
ADD COLUMN roas DECIMAL(10,4);

USE marketing_campaigns;

SELECT COUNT(*) AS total_linhas
FROM facebook_ads_clean;

SELECT *
FROM facebook_ads_clean
LIMIT 10;

SELECT
    MIN(spent) AS min_spent,
    MAX(spent) AS max_spent,
    AVG(spent) AS avg_spent,
    SUM(spent) AS total_spent
FROM facebook_ads_clean;

SELECT
    SUM(clicks) / SUM(impressions) AS ctr,
    SUM(total_conversion) / SUM(clicks) AS conversion_rate,
    SUM(approved_conversion) / SUM(total_conversion) AS approval_rate
FROM facebook_ads_clean;

SELECT
    fb_campaign_id,
    age_range,
    gender,
    interest,
    impressions,
    clicks,
    spent,
    spent / NULLIF(clicks, 0) AS cpc,
    (spent / impressions) * 1000 AS cpm,
    spent / NULLIF(approved_conversion, 0) AS cpa
FROM facebook_ads_clean;

SELECT
    fb_campaign_id,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spent) AS spent,
    SUM(total_conversion) AS total_conversion,
    SUM(approved_conversion) AS approved_conversion,
    SUM(spent) / NULLIF(SUM(clicks), 0) AS cpc,
    (SUM(spent) / SUM(impressions)) * 1000 AS cpm,
    SUM(spent) / NULLIF(SUM(approved_conversion), 0) AS cpa,
    SUM(clicks) / SUM(impressions) AS ctr,
    SUM(approved_conversion) / NULLIF(SUM(clicks), 0) AS approval_rate
FROM facebook_ads_clean
GROUP BY fb_campaign_id;

SELECT
    age_range,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spent) AS spent,
    SUM(approved_conversion) AS approved_conversion,
    SUM(spent) / NULLIF(SUM(approved_conversion), 0) AS cpa,
    SUM(clicks) / SUM(impressions) AS ctr
FROM facebook_ads_clean
GROUP BY age_range
ORDER BY cpa;

SELECT
    gender,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spent) AS spent,
    SUM(approved_conversion) AS approved_conversion,
    SUM(spent) / NULLIF(SUM(approved_conversion), 0) AS cpa,
    SUM(clicks) / SUM(impressions) AS ctr
FROM facebook_ads_clean
GROUP BY gender
ORDER BY cpa;

DROP TABLE IF EXISTS campaign_metrics;

CREATE TABLE campaign_metrics AS
SELECT
    fb_campaign_id,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(spent) AS spent,
    SUM(total_conversion) AS total_conversion,
    SUM(approved_conversion) AS approved_conversion,
    SUM(spent) / NULLIF(SUM(clicks), 0) AS cpc,
    (SUM(spent) / SUM(impressions)) * 1000 AS cpm,
    SUM(spent) / NULLIF(SUM(approved_conversion), 0) AS cpa,
    SUM(clicks) / SUM(impressions) AS ctr,
    SUM(approved_conversion) / NULLIF(SUM(clicks), 0) AS approval_rate
FROM facebook_ads_clean
GROUP BY fb_campaign_id;

SELECT * FROM campaign_metrics;

USE marketing_campaigns;

-- apaga se já existir, pra não dar conflito
DROP TABLE IF EXISTS campaign_metrics;

-- cria a tabela com as métricas consolidadas por campanha
CREATE TABLE campaign_metrics AS
SELECT
    fb_campaign_id,
    SUM(impressions)          AS impressions,
    SUM(clicks)               AS clicks,
    SUM(spent)                AS spent,
    SUM(total_conversion)     AS total_conversion,
    SUM(approved_conversion)  AS approved_conversion,
    SUM(spent) / NULLIF(SUM(clicks), 0)              AS cpc,
    (SUM(spent) / SUM(impressions)) * 1000           AS cpm,
    SUM(spent) / NULLIF(SUM(approved_conversion), 0) AS cpa,
    SUM(clicks) / SUM(impressions)                   AS ctr,
    SUM(approved_conversion) / NULLIF(SUM(clicks), 0) AS approval_rate
FROM facebook_ads_clean
GROUP BY fb_campaign_id;

SELECT *
FROM campaign_metrics
LIMIT 10;

USE marketing_campaigns;

SELECT
    SUM(impressions)              AS total_impressions,
    SUM(clicks)                   AS total_clicks,
    SUM(spent)                    AS total_spent,
    SUM(total_conversion)         AS total_conversions,
    SUM(approved_conversion)      AS total_approved_conversions,
    AVG(cpc)                      AS avg_cpc,
    AVG(cpm)                      AS avg_cpm,
    AVG(cpa)                      AS avg_cpa,
    AVG(ctr)                      AS avg_ctr,
    AVG(approval_rate)            AS avg_approval_rate
FROM campaign_metrics;

SELECT
    fb_campaign_id,
    impressions,
    clicks,
    spent,
    total_conversion,
    approved_conversion,
    cpa
FROM campaign_metrics
WHERE approved_conversion > 0
ORDER BY cpa ASC
LIMIT 5;

SELECT
    fb_campaign_id,
    impressions,
    clicks,
    spent,
    total_conversion,
    approved_conversion,
    cpa
FROM campaign_metrics
WHERE approved_conversion > 0
ORDER BY cpa DESC
LIMIT 5;

SELECT
    age_range,
    gender,
    SUM(impressions) AS impressions,
    SUM(clicks)      AS clicks,
    SUM(spent)       AS spent,
    SUM(approved_conversion) AS approved_conversion,
    SUM(spent) / NULLIF(SUM(approved_conversion),0) AS cpa,
    SUM(clicks) / SUM(impressions) AS ctr
FROM facebook_ads_clean
GROUP BY age_range, gender
ORDER BY cpa;








