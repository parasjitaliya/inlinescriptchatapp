#!/bin/bash

# asking for ip address
read -p "enter the ip_adress of your system" IP_address

# install unzip packages
echo y | sudo apt install unzip

# unzip file
unzip *.zip

# install the Packages from the Ubuntu Repositories
sudo apt-get update
echo y | sudo apt-get install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx

# Log into an interactive Postgres session by typing
sudo -u postgres psql

# Create a Python Virtual Environment for your Project
sudo -H pip3 install --upgrade pip
echo y | sudo -H pip3 install virtualenv

# copy path of the directory
chatapp_path=`pwd`
virtualenv antenv

. antenv/bin/activate

cd /chatapp/chatroom/

# install all of the software needed to start a Django project
echo y | pip3 install -r requirements.txt

# we can migrate the initial database schema to our PostgreSQL database using the management script
echo y | python3 manage.py makemigrations
echo y | python3 manage.py migrate

# static content into the directory location 
echo yes | python3 manage.py collectstatic

# project by starting up the Django development server 
python3 manage.py runserver

deactivate

cd `echo $chatapp_path`

# create gunicorn.service file
sudo touch /etc/systemd/system/gunicorn.service
sudo chmod 777 /etc/systemd/system/gunicorn.service
sed -e "s*chatapp_path*$chatapp_path*g" -e  "s*user_name*$USER*g" gunicorn.txt > /etc/systemd/system/gunicorn.service

# start the Gunicorn service we created and enable it so that it starts at boot
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
# check the status of the process of gunicorn file
sudo systemctl status gunicorn

# create nginx file and configure Nginx to Proxy Pass to Gunicorn
sudo touch /etc/nginx/sites-available/chatapp
sudo chmod 777 /etc/nginx/sites-available/chatapp
sudo sed -e "s*chatapp_path*$chatapp_path*g" -e "s*IP_address*$IP_address*g" nginx.txt > /etc/nginx/sites-available/chatapp

# enable the file by linking it to the sites-enabled directory
sudo ln -s /etc/nginx/sites-available/chatapp /etc/nginx/sites-enabled

# test your Nginx configuration for syntax errors
sudo nginx -t
sudo ufw allow 'Nginx Full'
sudo nginx -t && sudo systemctl restart nginx


