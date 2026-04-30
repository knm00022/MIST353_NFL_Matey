teams = [
    'Baltimore Ravens',
    'Cincinnati Bengals',
    'Cleveland Browns',
    'Pittsburgh Steelers',
    'New England Patriots',
    'Tampa Bay Buccaneers'
]

for team in teams:
    filename = f"TeamLogos/{team.replace(' ', '_')}.png"

    with open(filename, "rb") as image_file:
        logo_data = image_file.read()

    hex_logo = logo_data.hex()

    print(f"""
UPDATE Team
SET TeamLogo = 0x{hex_logo}
WHERE TeamName = '{team}';
GO
""")