# from get_db_connection import get_db_connection

# def get_teams_for_specified_fan(fan_id: int):
#     conn = get_db_connection()
#     cursor = conn.cursor(as_dict=True)

#     cursor.execute("exec procGetTeamsForSpecifiedFan %s", (fan_id,))
#     rows = cursor.fetchall()
#     conn.close()

#     results = [
#         {
#             "TeamName": row["TeamName"],
#             "Conference": row["Conference"],
#             "Division": row["Division"],
#             "TeamColors": row["TeamColors"],
#             "PrimaryTeam": row["PrimaryTeam"]
#         }
#         for row in rows
#     ]

#     return {"data": results}