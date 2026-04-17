import streamlit as st
from fetch_data import fetch_data

def get_teams_for_specified_fan_ui():

    
    if "app_user_id" not in st.session_state or "app_user_fullname" not in st.session_state:
        st.warning("Please validate the user first.")
        return

    fan_name = st.session_state.app_user_fullname
    fan_id = st.session_state.app_user_id

    st.header(f"Teams associated with {fan_name}")

    st.text_input("Fan ID", value=str(fan_id), disabled=True)

    input_parameters = {"nfl_fan_id": int(fan_id)}

    df = fetch_data("get_teams_for_specified_fan/", input_parameters)

    if df is not None and not df.empty:
        st.dataframe(df, width='stretch', hide_index=True)
    else:
        st.info("No teams found for the specified fan.")