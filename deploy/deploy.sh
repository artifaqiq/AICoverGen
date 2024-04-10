scp -r src root@aicovers:~/AICoverGen
scp requirements.txt root@aicovers:~/AICoverGen/requirements.txt
scp deploy/aicovers-api.nginx.conf root@aicovers:/etc/nginx/sites-enabled/aicovers-api
scp deploy/aicovers-static-files.nginx.conf root@aicovers:/etc/nginx/sites-enabled/aicovers-static-files
scp deploy/aicovers-api.supervisor.conf root@aicovers:/etc/supervisor/conf.d/aicovers_api.conf
scp deploy/aicovers-worker.supervisor.conf root@aicovers:/etc/supervisor/conf.d/aicovers_worker.conf
scp deploy/aicovers-webui.supervisor.conf root@aicovers:/etc/supervisor/conf.d/aicovers_webui.conf

ssh root@aicovers "service supervisor restart"