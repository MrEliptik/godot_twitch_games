# Configuration

## Twitch

- Create an Application on: https://dev.twitch.tv/console/apps/create (tip: don`t use the name twitch on your app name)
- http://localhost:18297 is the OAuth Redirect URL
- Generate a secret
- When you start the application and it does not find a config.cfg file, it will show a config screen to you
- Fill it out and click the create button
- Then you should have a config.cfg file that looks like the example below

#### config.cfg example:
```
[twitch_auth]

client_id=    "kjjust2nhexampleybnotreal2928y"
client_secret="kjjust2nhexampleybnotreal2928y"
initial_channel="yourchannel"
```
