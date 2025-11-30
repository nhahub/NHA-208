import os
import sys
import pandas as pd
import hashlib   # currently not used, but kept in case you need it later
import urllib
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# =================================================================
# 1) Load database credentials from .env and create engine
# =================================================================
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

if not all([DB_USER, DB_PASS, DB_HOST, DB_PORT, DB_NAME]):
    print("Error: Database credentials are not set correctly in .env file.")
    sys.exit(1)

# Encode password for URL usage
encoded_pass = urllib.parse.quote(DB_PASS)

# Create a global SQLAlchemy engine that will be reused by all functions
try:
    engine = create_engine(
        f"mysql+pymysql://{DB_USER}:{encoded_pass}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    print(f"Connected to MySQL database [{DB_NAME}] successfully.\n")
except Exception as e:
    print(f"Error creating database engine: {e}")
    sys.exit(1)


# =================================================================
# 2) Generic cleaning function for all CSV files
# =================================================================
def read_and_clean_csv(file_path: str) -> pd.DataFrame | None:
    """
    Read a CSV file and apply light, generic cleaning:
      - strip column names
      - strip whitespace from string columns
      - normalize 'nan' / 'NaN' / 'NULL' / 'None' / '' to proper missing values
      - drop fully duplicated rows
    Returns a cleaned DataFrame or None if the file cannot be read.
    """
    print(f"[READ] Loading file: {file_path}")

    try:
        df = pd.read_csv(file_path)
    except Exception as e:
        print(f"  -> Error reading CSV: {e}")
        return None

    # Normalize column names (remove leading / trailing spaces)
    df.columns = [c.strip() for c in df.columns]

    # Clean string columns and standardize missing-like values
    for col in df.select_dtypes(include=["object"]).columns:
        # Ensure string type and strip spaces
        df[col] = df[col].astype(str).str.strip()
        # Replace common “fake nulls” with proper pandas NA
        df[col] = df[col].replace(["nan", "NaN", "NULL", "None", ""], pd.NA)

    # Drop fully duplicated rows
    before = len(df)
    df.drop_duplicates(inplace=True)
    after = len(df)
    if after < before:
        print(f"  -> Dropped {before - after} fully duplicate rows.")

    print(f"  -> {len(df)} rows ready for staging.")
    return df


# =================================================================
# 3) Load DataFrame into a staging table
# =================================================================
def load_staging(df: pd.DataFrame, table_name: str) -> None:
    """
    Truncate the given staging table and load the DataFrame into it.
    This function runs in a single transaction.
    """
    print(f"[LOAD] Loading {len(df)} rows into {table_name}...")

    try:
        with engine.begin() as conn:
            conn.execute(text("SET FOREIGN_KEY_CHECKS = 0;"))
            conn.execute(text(f"TRUNCATE TABLE {table_name};"))
            conn.execute(text("SET FOREIGN_KEY_CHECKS = 1;"))

            df.to_sql(table_name, con=conn, if_exists="append", index=False)

        print(f"  -> Done loading {table_name}.")
    except Exception as e:
        print(f"  -> Error loading {table_name}: {e}")
        # Re-raise so the caller (run_olist_etl) can handle it
        raise


# =================================================================
# 4) Main ETL for all Olist CSV files
# =================================================================
def run_olist_etl(raw_folder: str) -> tuple[bool, str]:
    """
    Orchestrate the full Olist ETL:
      - loop over all expected Olist CSV files under `raw_folder`
      - clean and load them into their staging tables
      - call the incremental stored procedure to update the DW

    Returns:
        (success_flag, message_text)
    so that callers like Streamlit can display a clear status.
    """
    try:
        print(f"=== Starting Olist ETL batch from folder: {raw_folder} ===\n")

        files_map = {
            "olist_customers_dataset.csv": "staging_customers",
            "olist_geolocation_dataset.csv": "staging_geolocation",
            "olist_order_items_dataset.csv": "staging_order_items",
            "olist_order_payments_dataset.csv": "staging_order_payments",
            "olist_order_reviews_dataset.csv": "staging_order_reviews",
            "olist_orders_dataset.csv": "staging_orders",
            "olist_products_dataset.csv": "staging_products",
            "olist_sellers_dataset.csv": "staging_sellers",
            "product_category_name_translation.csv": "staging_product_category_translation",
        }

        # Loop through each expected CSV and push it to its staging table
        for csv_file, staging_table in files_map.items():
            file_path = os.path.join(raw_folder, csv_file)

            if not os.path.exists(file_path):
                print(f"[WARN] File not found: {file_path}, skipping...")
                continue

            df = read_and_clean_csv(file_path)

            if df is None or df.empty:
                print(f"[SKIP] No data to load for {csv_file}")
                continue

            load_staging(df, staging_table)

        # Run the incremental stored procedure once all staging tables are loaded
        print("\n[DW LOAD] Calling stored procedure sp_LoadOlist_DW_Incremental() ...")

        with engine.begin() as conn:
            conn.execute(text("CALL sp_LoadOlist_DW_Incremental();"))

        print("  -> Data warehouse loaded successfully!")

        msg = f"ETL completed successfully for raw folder: {raw_folder}"
        return True, msg

    except Exception as e:
        error_msg = f"ETL process FAILED: {e}"
        print(error_msg)
        return False, error_msg


# =================================================================
# 5) Standalone execution (for CLI/testing)
# =================================================================
if __name__ == "__main__":
    RAW_FOLDER = r"E:\Data Analysis\DEPI - Data Analysis\Final Project\Olist Datasets"
    success, message = run_olist_etl(RAW_FOLDER)
    print(message)
