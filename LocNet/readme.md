
https://learn.microsoft.com/en-us/ef/core/modeling/relationships/one-to-one

user1@test:1234

http://localhost:5297/swagger/index.html

curl -X 'POST' 'http://localhost:5297/login' -d '{ "email": "user1@test", "password": "1234"}' -H 'accept: application/json' -H 'Content-Type: application/json'
same as 'http://localhost:5297/login?useCookies=false&useSessionCookies=false'
login json: { "email": "user1@test", "password": "1234" }

curl http://localhost:5297/projects -H "Authorization: Bearer " -v
curl http://localhost:5297/projects/F62AA12B-15D9-49A7-8817-02AC6729C0AF/entries -H "Authorization: Bearer " -v
