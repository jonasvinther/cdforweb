docker rm -f nodeapp
docker run -d -p 3000:3000 --name nodeapp nodetest