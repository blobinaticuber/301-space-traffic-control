# Analyzing the cleaned data from SQL

from pathlib import Path
import sqlite3
import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
DB_PATH = BASE_DIR / "data" / "neows.db"

def load_neows_data(db_path=DB_PATH):
    # Load data from neows SQLite tables/views into pandas DataFrames
    if not Path(db_path).exists():
        raise FileNotFoundError(f"Database not found at: {db_path}")

    with sqlite3.connect(db_path) as conn:
        df_all = pd.read_sql_query("SELECT * FROM neows_approaches", conn)
        # Example: use the cleaner view if defined
        df_clean = pd.read_sql_query("SELECT * FROM vw_neows_clean", conn)
        # Example: grouped summary
        df_daily = pd.read_sql_query("SELECT * FROM vw_daily_summary", conn)

    return df_all, df_clean, df_daily


def display_analytics():
    df_all, df_clean, df_daily = load_neows_data()
    print("Full Dataset:")
    print(df_all.head(10).to_string(index=False))
    print("Cleaned Dataset:")
    print(df_clean.head(10).to_string(index=False))
    print("\nDaily Summary:")
    print(df_daily.to_string(index=False))


if __name__ == "__main__":
    display_analytics()
