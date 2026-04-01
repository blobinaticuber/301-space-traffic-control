#!/usr/bin/env bash
set -euo pipefail

if [[ -f ".env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

NASA_API_KEY="${NASA_API_KEY:-}"
NASA_API_BASE_URL="${NASA_API_BASE_URL:-https://api.nasa.gov/neo/rest/v1}"
DB_PATH="${DB_PATH:-data/neows.db}"
RAW_DIR="${RAW_DIR:-data/raw}"
WINDOW_MODE="${WINDOW_MODE:-future}"
START_DATE="${START_DATE:-}"
END_DATE="${END_DATE:-}"

if [[ -z "$NASA_API_KEY" || "$NASA_API_KEY" == "your_api_key" ]]; then
  echo "ERROR: Set NASA_API_KEY in .env"
  exit 1
fi

for cmd in curl jq sqlite3 date; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Missing dependency: $cmd"
    exit 1
  fi
done

mkdir -p "$(dirname "$DB_PATH")" "$RAW_DIR" sql

calc_dates() {
  local mode="$1"
  if [[ -n "$START_DATE" && -n "$END_DATE" ]]; then
    echo "$START_DATE|$END_DATE"
    return
  fi
  local today start end
  today="$(date +%F)"
  if [[ "$mode" == "past" ]]; then
    start="$(date -d "$today -6 days" +%F)"
    end="$today"
  else
    start="$today"
    end="$(date -d "$today +6 days" +%F)"
  fi
  echo "$start|$end"
}

IFS='|' read -r RANGE_START RANGE_END < <(calc_dates "$WINDOW_MODE")

URL="${NASA_API_BASE_URL}/feed?start_date=${RANGE_START}&end_date=${RANGE_END}&api_key=${NASA_API_KEY}"
STAMP="$(date +%Y%m%d_%H%M%S)"
RAW_JSON="${RAW_DIR}/neows_feed_${RANGE_START}_${RANGE_END}_${STAMP}.json"
RAW_NDJSON="${RAW_DIR}/neows_approaches_${RANGE_START}_${RANGE_END}_${STAMP}.ndjson"

echo "Fetching NeoWs feed: ${RANGE_START} -> ${RANGE_END}"
curl -fsSL "$URL" -o "$RAW_JSON"

jq -c '
  .near_earth_objects
  | to_entries[]
  | .key as $date
  | .value[]
  | {
      neo_reference_id: (.neo_reference_id // null),
      name: (.name // null),
      nasa_jpl_url: (.nasa_jpl_url // null),
      absolute_magnitude_h: (.absolute_magnitude_h // null),
      estimated_diameter_min_km: (.estimated_diameter.kilometers.estimated_diameter_min // null),
      estimated_diameter_max_km: (.estimated_diameter.kilometers.estimated_diameter_max // null),
      is_potentially_hazardous_asteroid: (.is_potentially_hazardous_asteroid // false),
      close_approach_date: $date,
      close_approach_date_full: ((.close_approach_data[0].close_approach_date_full) // null),
      relative_velocity_kph: ((.close_approach_data[0].relative_velocity.kilometers_per_hour | tonumber?) // null),
      miss_distance_km: ((.close_approach_data[0].miss_distance.kilometers | tonumber?) // null),
      orbiting_body: ((.close_approach_data[0].orbiting_body) // null),
      is_sentry_object: (.is_sentry_object // false)
    }
' "$RAW_JSON" > "$RAW_NDJSON"

sqlite3 "$DB_PATH" < sql/schema.sql

sqlite3 "$DB_PATH" <<SQL
.mode tabs
.import $RAW_NDJSON stg_neows_raw_json
SQL

sqlite3 "$DB_PATH" <<'SQL'
INSERT INTO neows_approaches(
  neo_reference_id,name,nasa_jpl_url,absolute_magnitude_h,
  estimated_diameter_min_km,estimated_diameter_max_km,
  is_potentially_hazardous_asteroid,close_approach_date,close_approach_date_full,
  relative_velocity_kph,miss_distance_km,orbiting_body,is_sentry_object,ingested_at
)
SELECT
  json_extract(raw_json,'$.neo_reference_id'),
  json_extract(raw_json,'$.name'),
  json_extract(raw_json,'$.nasa_jpl_url'),
  CAST(json_extract(raw_json,'$.absolute_magnitude_h') AS REAL),
  CAST(json_extract(raw_json,'$.estimated_diameter_min_km') AS REAL),
  CAST(json_extract(raw_json,'$.estimated_diameter_max_km') AS REAL),
  CASE LOWER(COALESCE(json_extract(raw_json,'$.is_potentially_hazardous_asteroid'),'false'))
    WHEN 'true' THEN 1 ELSE 0 END,
  json_extract(raw_json,'$.close_approach_date'),
  json_extract(raw_json,'$.close_approach_date_full'),
  CAST(json_extract(raw_json,'$.relative_velocity_kph') AS REAL),
  CAST(json_extract(raw_json,'$.miss_distance_km') AS REAL),
  json_extract(raw_json,'$.orbiting_body'),
  CASE LOWER(COALESCE(json_extract(raw_json,'$.is_sentry_object'),'false'))
    WHEN 'true' THEN 1 ELSE 0 END,
  datetime('now')
FROM stg_neows_raw_json
WHERE json_valid(raw_json)=1
  AND json_extract(raw_json,'$.neo_reference_id') IS NOT NULL;

DELETE FROM stg_neows_raw_json;
SQL

sqlite3 "$DB_PATH" < sql/views.sql

echo "Done."
echo "DB: $DB_PATH"
echo "Raw JSON: $RAW_JSON"
echo "Flattened NDJSON: $RAW_NDJSON"
echo "Try:"
echo "  sqlite3 $DB_PATH \"SELECT * FROM vw_nearest_approaches LIMIT 20;\""
