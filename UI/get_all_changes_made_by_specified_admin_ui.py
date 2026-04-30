import streamlit as st
from fetch_data import get_data


def get_all_changes_made_by_specified_admin_ui():
    

    if "app_user_id" not in st.session_state or "app_user_fullname" not in st.session_state:
        st.warning("Please validate the user first.")
        return

    if st.session_state.app_user_role != "NFLAdmin":
        st.warning("Only NFL Admins can view this.")
        return

    admin_name = st.session_state.app_user_fullname
    st.header(f"Changes made by {admin_name}")

    admin_id = st.text_input("Admin ID", value=st.session_state.app_user_id, disabled=True)

    input_parameters = {"nfl_admin_id": admin_id}

    if st.button("Get My Changes"):
        df = get_data("get_all_changes_made_by_specified_admin/", input_parameters)

        if df is not None and not df.empty:
            st.dataframe(df, width="stretch", hide_index=True)
        else:
            st.info("No changes found for this admin.")