import streamlit as st
from fetch_data import post_data
from datetime import datetime

def schedule_game_ui():
    st.header("Schedule a Game")

    # Fetch all teams and stadiums
    parameters = {}
    teams_df = post_data("get_all_teams/", parameters)
    stadiums_df = post_data("get_all_stadiums/", parameters)

    # Safety check
    if teams_df is None or teams_df.empty:
        st.error("Teams could not be loaded")
        return

    if stadiums_df is None or stadiums_df.empty:
        st.error("Stadiums could not be loaded")
        return

    GAME_ROUNDS = ["Wild Card", "Divisional", "Conference", "Super Bowl"]

    # Create dropdowns
    team_options = dict(zip(teams_df["team_name"], teams_df["team_id"]))
    stadium_options = dict(zip(stadiums_df["stadium_name"], stadiums_df["stadium_id"]))

    home_team_name = st.selectbox("Select Home Team:", options=team_options.keys())
    away_team_name = st.selectbox("Select Away Team:", options=team_options.keys())
    stadium_name = st.selectbox("Select Stadium:", options=stadium_options.keys())
    game_round = st.selectbox("Select Game Round:", GAME_ROUNDS)
    







    # home_team_id = st.number_input("Enter Home Team ID:", min_value=1, step=1)
    # away_team_id = st.number_input("Enter Away Team ID:", min_value=1, step=1)
    # game_round = st.selectbox("Enter Game Round:", ["Wild Card", "Divisional", "Conference", "Super Bowl"])
    # game_date = st.date_input("Enter Game Date:")
    # game_time = st.time_input("Enter Game Time:")
    # stadium_id = st.number_input("Enter Stadium ID:", min_value=1, step=1)
    # nfl_admin_id = st.number_input("Enter NFL Admin ID:", min_value=1, step=1)

    # if st.button("Schedule Game"):
    #     result = post_data(
    #         "schedule_game/",
    #         {
    #             "home_team_id": home_team_id,
    #             "away_team_id": away_team_id,
    #             "game_round": game_round,
    #             "game_date": game_date.isoformat(),
    #             "game_time": game_time.isoformat(),
    #             "stadium_id": stadium_id,
    #             "nfl_admin_id": nfl_admin_id
    #         }
    #     )

    #     st.write(result)
    

   