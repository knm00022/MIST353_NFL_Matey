#from fastapi import params
# import streamlit as st
# import requests
# import pandas as pd
 
# FASTAPI_URL = "https://mist353-api-matey.azurewebsites.net"  # Adjust if your API is hosted elsewhere
# #"http://localhost:8000"
# #"https://mist353-api-matey.azurewebsites.net"

# def fetch_data(endpoint: str, input_params: dict, method: str = "GET"):
#     if method == "GET":
#         response = requests.get(f"{FASTAPI_URL}/{endpoint}", params=input_params)

#     elif method == "POST":
#         response = requests.post(f"{FASTAPI_URL}/{endpoint}", json=input_params) 

#         if response.status_code == 200:
#             payload = response.json()
#             rows = payload.get("data", [])
#             df = pd.DataFrame(rows)
#             return df
#         else:
#             st.error(f"Error fetching data: {response.status_code}")
#             return None
        
# def post_data(endpoint: str, input_params: dict, method: str = "POST") -> dict:
#     if method == "POST":
#         response = requests.post(f"{FASTAPI_URL}/{endpoint}", params=input_params)

#         if response.status_code == 200:
#             return response.json()
#         else:
#             st.error(f"Error posting data: {response.status_code}")
#             return {"status_message": f"Error posting data: {response.status_code}"}

import streamlit as st
import requests
import pandas as pd

#FASTAPI_URL = "https://mist353-api-matey.azurewebsites.net"
FASTAPI_URL = "http://localhost:8000" 

def get_data(endpoint: str, input_params: dict, method: str = "GET"):
    if method == "GET":
        response = requests.get(f"{FASTAPI_URL}/{endpoint}", params=input_params)
    

    if response.status_code == 200:
        payload = response.json()
        rows = payload.get("data", [])
        return pd.DataFrame(rows)
    else:
        st.error(f"Error fetching data: {response.status_code}")
        return None


def post_data(endpoint: str, input_params: dict, method: str = "POST") -> dict:
    response = requests.post(f"{FASTAPI_URL}/{endpoint}", params=input_params)

    if response.status_code == 200:
        return response.json()
    else:
        st.error(f"Error posting data: {response.status_code}")
        return {"status_message": f"Error posting data: {response.status_code}"}