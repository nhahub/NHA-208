import os
import streamlit as st
from dotenv import load_dotenv

# Import the ETL function
from etl_olist import run_olist_etl

# --------------------------------------------------
# 1) Load .env (in case we want to use DB values later)
# --------------------------------------------------
load_dotenv()

# --------------------------------------------------
# 2) Resolve base directory and logo path
#    (so the logo works even when app is started from a shortcut)
# --------------------------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOGO_PATH = os.path.join(BASE_DIR, "olist_logo.png")

# --------------------------------------------------
# 3) Streamlit page configuration
# --------------------------------------------------
st.set_page_config(
    page_title="Olist E-commerce ETL",
    page_icon="🛒",
    layout="wide"
)

# Simple CSS to match the dark dashboard style
st.markdown(
    """
    <style>
        .stApp {
            background-color: #0b1b2b;
            color: #ffffff;
        }
        .big-title {
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 0.3rem;
        }
        .subtitle {
            font-size: 1.0rem;
            color: #d0d7e2;
        }
        .card {
            background-color: #152238;
            padding: 1.2rem 1.5rem;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.35);
            margin-bottom: 1rem;
        }
    </style>
    """,
    unsafe_allow_html=True
)

# --------------------------------------------------
# 4) Header: logo + title (top-left)
# --------------------------------------------------

# Logo on the left, above the title
# "olist_logo.png" must be in the same folder as this script
st.image(LOGO_PATH, width=200)

# Title and subtitle under the logo, left-aligned
st.markdown(
    """
    <div class="big-title">Olist E-commerce – ETL Uploader</div>
    <div class="subtitle">
        Run the ETL pipeline to load the latest Olist raw files into the Data Warehouse,
        then refresh your Power BI dashboard.
    </div>
    """,
    unsafe_allow_html=True
)

st.markdown("")  # small spacing

# --------------------------------------------------
# 5) Batch configuration card (raw folder path + button)
# --------------------------------------------------
with st.container():
    st.markdown('<div class="card">', unsafe_allow_html=True)

    st.subheader("Batch Configuration")

    default_folder = r"D:\data\raw"
    raw_folder = st.text_input(
        "Raw data folder path (where the 9 Olist CSV files are located):",
        value=default_folder
    )

    st.caption("Example: D:\\data\\raw — must contain all Olist CSV files.")

    run_button = st.button("🚀 Run ETL for Current Batch", use_container_width=True)

    st.markdown("</div>", unsafe_allow_html=True)

# --------------------------------------------------
# 6) Run ETL when the user clicks the button
# --------------------------------------------------
if run_button:
    # Basic validation for the folder path
    if not os.path.isdir(raw_folder):
        st.error(f"Folder does not exist: {raw_folder}")
    else:
        st.info(f"Starting ETL using folder: {raw_folder}")

        with st.spinner("ETL process in progress... please wait ⏳"):
            try:
                # run_olist_etl will raise an exception if something goes wrong
                run_olist_etl(raw_folder)
                success = True
                message = "ETL process finished successfully."
            except Exception as e:
                success = False
                message = f"ETL process FAILED with unexpected error: {e}"

        if success:
            st.success(message)
            st.balloons()
        else:
            st.error(message)

# --------------------------------------------------
# 7) Small note at the bottom for the user
# --------------------------------------------------
st.markdown(
    """
    ---
    ✅ After ETL finishes successfully, open your **Power BI** Olist dashboard and hit **Refresh**  
    to see the new batch reflected in all pages (Executive Summary, Financial Performance, Seller, Customers, ...).
    """,
    unsafe_allow_html=True
)
