PRAGMA journal_mode=WAL;
PRAGMA foreign_keys=ON;

CREATE TABLE IF NOT EXISTS stg_neows_raw_json(
  raw_json TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS neows_approaches(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  neo_reference_id TEXT NOT NULL,
  name TEXT,
  nasa_jpl_url TEXT,
  absolute_magnitude_h REAL,
  estimated_diameter_min_km REAL,
  estimated_diameter_max_km REAL,
  is_potentially_hazardous_asteroid INTEGER NOT NULL DEFAULT 0 CHECK(is_potentially_hazardous_asteroid IN(0,1)),
  close_approach_date TEXT NOT NULL,
  close_approach_date_full TEXT,
  relative_velocity_kph REAL,
  miss_distance_km REAL,
  orbiting_body TEXT,
  is_sentry_object INTEGER NOT NULL DEFAULT 0 CHECK(is_sentry_object IN(0,1)),
  ingested_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_neows_date ON neows_approaches(close_approach_date);
CREATE INDEX IF NOT EXISTS idx_neows_miss_km ON neows_approaches(miss_distance_km);
CREATE INDEX IF NOT EXISTS idx_neows_hazard ON neows_approaches(is_potentially_hazardous_asteroid);
CREATE INDEX IF NOT EXISTS idx_neows_neo_ref ON neows_approaches(neo_reference_id);

CREATE UNIQUE INDEX IF NOT EXISTS uq_neows_logical_row
ON neows_approaches(neo_reference_id,close_approach_date,COALESCE(close_approach_date_full,''));
