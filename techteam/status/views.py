from os import system
from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader

# my functions
from .services import system_metrics as sm

# Create your views here.
def index(request):
    template = loader.get_template('index.html')
    context = sm.system_metrics()

    if context['packs'][0] == '':
        context['packs'] = []
    
    return HttpResponse(template.render(context, request))