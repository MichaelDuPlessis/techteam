#!/bin/bash

. ./server-env/bin/activate # activating virtual enviroment
# installing dependencies
pip install uwsgi
pip install Django
# runnung server
cd techteam
uwsgi --http :8000 --module techteam.wsgi # run server
