# TEMPLATE FOLDER TREE FOR SYMFONY APP
- docker files for : apache2, php8.2, mysql8.0, rabbitmq 

# Steps to init your symfony 7 project
`git clone https://github.com/eddyger/docker-symfony-mysql-rabbitmq.git your-app-name`
`cd your-app-name`
`cd docker`
`docker-compose --env-file ./config/.env.local up -d --build`
`docker exec -it app_web bash`
`cd /app`
`git config --global user.email "you@example.com"`
`git config --global user.name "Your Name"`
`symfony new Symfony --version="7.0.*" --webapp`