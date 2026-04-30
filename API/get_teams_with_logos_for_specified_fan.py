from get_db_connection import get_db_connection
import base64

def get_teams_with_logos_for_specified_fan(fan_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(as_dict=True)

    cursor.execute(
        "exec procGetTeamsWithLogosForSpecifiedFan %s",
        (fan_id,)
    )

    rows = cursor.fetchall()
    conn.close()

    results = [
        {
            "TeamName": row["TeamName"],
            "Conference": row["Conference"],
            "Division": row["Division"],
            "TeamColors": row["TeamColors"],
            "PrimaryTeam": row["PrimaryTeam"],
            "TeamLogo": base64.b64encode(row["TeamLogo"]).decode("utf-8") if row["TeamLogo"] else None
        }
        for row in rows
    ]

    return {"data": results}