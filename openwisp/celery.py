import os

from celery import Celery
from django.conf import settings

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'openwisp2.settings')

app = Celery('openwisp2')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

from celery.signals import setup_logging
from logging.config import dictConfig

@setup_logging.connect
def config_loggers(*args, **kwargs):
    dictConfig(settings.LOGGING)
