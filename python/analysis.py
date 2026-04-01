# Analyzing the cleaned data from SQL

import sqlite3
import pandas as pd

DB_PATH = "../neows.db"  # update path to your SQLite database file (or use absolute path)


def load_neows_data(db_path=DB_PATH):
    # Load data from neows SQLite tables/views into pandas DataFrames
    with sqlite3.connect(db_path) as conn:
        # Example: direct table
        df_all = pd.read_sql_query("SELECT * FROM neows_approaches", conn)
        # Example: use the cleaner view if defined
        df_clean = pd.read_sql_query("SELECT * FROM vw_neows_clean", conn)
        # Example: grouped summary
        df_daily = pd.read_sql_query("SELECT * FROM vw_daily_summary", conn)

return df_all, df_clean, df_daily