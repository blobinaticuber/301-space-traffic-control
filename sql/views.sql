CREATE VIEW IF NOT EXISTS vw_neows_clean AS
SELECT
  id,neo_reference_id,name,nasa_jpl_url,absolute_magnitude_h,
  estimated_diameter_min_km,estimated_diameter_max_km,
  is_potentially_hazardous_asteroid,close_approach_date,close_approach_date_full,
  relative_velocity_kph,miss_distance_km,orbiting_body,is_sentry_object,ingested_at
FROM neows_approaches
WHERE miss_distance_km IS NOT NULL
  AND miss_distance_km>0
  AND relative_velocity_kph IS NOT NULL
  AND relative_velocity_kph>0
  AND estimated_diameter_min_km IS NOT NULL
  AND estimated_diameter_max_km IS NOT NULL
  AND estimated_diameter_min_km>=0
  AND estimated_diameter_max_km>=estimated_diameter_min_km;

CREATE VIEW IF NOT EXISTS vw_nearest_approaches AS
SELECT
  close_approach_date,neo_reference_id,name,miss_distance_km,relative_velocity_kph,
  estimated_diameter_min_km,estimated_diameter_max_km,is_potentially_hazardous_asteroid,nasa_jpl_url
FROM vw_neows_clean
ORDER BY close_approach_date ASC,miss_distance_km ASC;

CREATE VIEW IF NOT EXISTS vw_daily_summary AS
SELECT
  close_approach_date,
  COUNT(*) AS approach_count,
  AVG(miss_distance_km) AS avg_miss_distance_km,
  MIN(miss_distance_km) AS min_miss_distance_km,
  MAX(miss_distance_km) AS max_miss_distance_km,
  AVG(relative_velocity_kph) AS avg_relative_velocity_kph,
  SUM(CASE WHEN is_potentially_hazardous_asteroid=1 THEN 1 ELSE 0 END) AS hazardous_count
FROM vw_neows_clean
GROUP BY close_approach_date
ORDER BY close_approach_date ASC;
