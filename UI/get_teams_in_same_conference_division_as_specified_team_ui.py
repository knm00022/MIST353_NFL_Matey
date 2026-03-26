import streamlit as st
from fetch_data import fetch_data

def get_teams_in_same_conference_division_as_specified_team_ui():
    st.header("Get Teams in Same Conference and Division as Specified Team")

    team_name = st.text_input("Enter Team Name:")

    if st.button("Fetch Teams"):
        if not team_name.strip():
            st.warning("Please enter a team name.")
        else:
            input_params = {}
            input_params["team_name"] = team_name.strip()
            #define fetch_data function and call it with input_params
            df = fetch_data("get_teams_in_same_conference_division_as_specified_team/", input_params)

            if df is not None and not df.empty:
                st.subheader(f"Teams in the same conference and division as {team_name}:")
                st.dataframe(df, use_container_width=True, hide_index=True)
            else:
                st.info(f"No teams found in the same conference and division as {team_name}. Please check the team name and try again.")
    