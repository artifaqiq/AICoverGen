scp -r src root@aicovers:~/AICoverGen
scp requirements.txt root@aicovers:~/AICoverGen/requirements.txt
scp deploy/aicovers-api.nginx.conf root@aicovers:/etc/nginx/sites-enabled/aicovers-api
scp deploy/aicovers-static-files.nginx.conf root@aicovers:/etc/nginx/sites-enabled/aicovers-static-files
ssh root@aicovers "service supervisor restart"