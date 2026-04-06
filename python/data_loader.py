from __future__ import annotations
from pathlib import Path
import sqlite3
import pandas as pd

DB_PATH=Path.cwd().parent.resolve()/"data"/"neows.db"

NUMERIC_COLS=[
    "absolute_magnitude_h",
    "estimated_diameter_min_km",
    "estimated_diameter_max_km",
    "relative_velocity_kph",
    "miss_distance_km",
]
DATE_COLS=["close_approach_date","close_approach_date_full","ingested_at"]
BOOL_INT_COLS=["is_potentially_hazardous_asteroid","is_sentry_object"]

def _coerce_types(df:pd.DataFrame)->pd.DataFrame:
    out=df.copy()
    for c in NUMERIC_COLS:
        if c in out.columns:
            out[c]=pd.to_numeric(out[c],errors="coerce")
    for c in DATE_COLS:
        if c in out.columns:
            out[c]=pd.to_datetime(out[c],errors="coerce")
    for c in BOOL_INT_COLS:
        if c in out.columns:
            out[c]=pd.to_numeric(out[c],errors="coerce").fillna(0).astype("int64")
    return out

def _drop_exact_duplicates(df:pd.DataFrame)->pd.DataFrame:
    # Keep data deterministic for analysis
    return df.drop_duplicates().reset_index(drop=True)

def _drop_missing_core_numeric(df:pd.DataFrame,required:list[str]|None=None)->pd.DataFrame:
    req=required if required is not None else [
        "estimated_diameter_max_km",
        "relative_velocity_kph",
        "miss_distance_km",
        "absolute_magnitude_h",
    ]
    existing=[c for c in req if c in df.columns]
    if not existing:
        return df.copy()
    return df.dropna(subset=existing).reset_index(drop=True)

def load_neows_data(db_path:Path|str=DB_PATH)->tuple[pd.DataFrame,pd.DataFrame,pd.DataFrame]:
    db_path=Path(db_path)
    if not db_path.exists():
        raise FileNotFoundError(f"Database not found at: {db_path}")

    with sqlite3.connect(db_path) as conn:
        df_all=pd.read_sql_query("SELECT * FROM neows_approaches",conn)
        df_clean=pd.read_sql_query("SELECT * FROM vw_neows_clean",conn)
        df_daily=pd.read_sql_query("SELECT * FROM vw_daily_summary",conn)

    df_all=_coerce_types(df_all)
    df_clean=_coerce_types(df_clean)
    df_daily=_coerce_types(df_daily)

    df_all=_drop_exact_duplicates(df_all)
    df_clean=_drop_exact_duplicates(df_clean)
    df_clean=_drop_missing_core_numeric(df_clean)

    return df_all,df_clean,df_daily
