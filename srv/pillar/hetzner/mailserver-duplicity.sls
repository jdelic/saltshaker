
# override the duplicity schedule for mail so the mail server can receive mail from the other servers
# when they process their cron
duplicity-backup:
    daily-cron-schedule: 30 4 * * *
