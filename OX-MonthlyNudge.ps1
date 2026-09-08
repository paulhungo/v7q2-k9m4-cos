# ATF OX Monthly Nudge — 1st of month: monthly touches + backups (runs via Task Scheduler)
& "$PSScriptRoot\Send-OXMessage.ps1" -Title "NEW MONTH - MONTHLY TOUCHES + BACKUP" -Body (@"
A new month begins. Today (1st):

1. BACK UP: ATF_Stakeholder_Register_v1.0.xlsx + workspace-data.json (copy with date in filename).
2. THIS MONTH'S MONTHLY ITEMS: Partner Spotlight post (honour one partner) - personal check-ins due list cleared - volunteer & member note ('here is what you achieved').
3. CHECK My Trackers for anything past due (red rows) - clear them in small bites.
4. Coming up this month: Wednesday Founder sittings (programme interviews) - see Key Dates in the OX app.

Report to the Founder on the last working day: KPI scorecard + relationship numbers (touches, re-engaged, new contacts).
"@)