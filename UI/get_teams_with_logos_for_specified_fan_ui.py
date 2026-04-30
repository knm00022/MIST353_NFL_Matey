import streamlit as st
from fetch_data import get_data
import base64

def get_teams_with_logos_for_specified_fan_ui():

    if "app_user_id" not in st.session_state or "app_user_fullname" not in st.session_state:
        st.warning("Please validate the user first.")
        return

    st.header(f"Teams with logos for {st.session_state.app_user_fullname}")

    fan_id = st.text_input("Fan ID", value=st.session_state.app_user_id, disabled=True)

    if st.button("Get Teams With Logos"):
        input_parameters = {"fan_id": fan_id}

        df = get_data("get_teams_with_logos_for_specified_fan/", input_parameters)

        if df is not None and not df.empty:
            for row in df.to_dict("records"):
                col1, col2 = st.columns([1, 4])

                with col1:
                    if row["TeamLogo"]:
                        logo_bytes = base64.b64decode(row["TeamLogo"])
                        st.image(logo_bytes, width=70)
                    else:
                        st.write("No logo")

                with col2:
                    st.write(f"**{row['TeamName']}**")
                    st.write(f"{row['Conference']} / {row['Division']}")
                    st.write(row["TeamColors"])
                    st.write("Primary Team ✅" if row["PrimaryTeam"] else "")

                st.divider()
        else:
            st.info("No teams found for this fan.")