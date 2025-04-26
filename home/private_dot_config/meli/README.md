# meli

## Setting up a Gmail Account

See [Docs, Gmail](https://meli-email.org/documentation.html#meli.conf.5_Gmail)
- set up OAuth
- set up secrets

### Set up OAuth for Gmail
see [OAuth docs](https://support.google.com/cloud/answer/15549257?hl=en)

- we will name things meli for easier identification, but you can name things as you need/want
2) create new project
   - name: meli
3) Select project
4) Go to [Google Auth Platform / Clients](https://console.cloud.google.com/auth/clients)
5) Click "Get Started"
   - app name: meli
   - support email: john.doe@gmail.com
   - external: yes
   - contact: john.doe@gmail.com
   - agree: yes
6) create a client ("Create OAuth client")
   - type: Desktop App
   - name: meli
7) copy client id and secret to password manager
8) Add test user in Audience https://console.cloud.google.com/auth/audience
9) execute oauth2 script
```
 python3 oauth2.py --user=$EMAIL --client_id=$CLIENT_ID --client_secret=$CLIENT_SECRET --generate_oauth2_token
```
10) copy authorisation code
11) enter as verification code
12) continue, answer as safe
13) continue, allowing access
14) copy refresh token, and access token
16) fill out details in `./password_command.sh`
17) follow instructions `./password_command.sh`
