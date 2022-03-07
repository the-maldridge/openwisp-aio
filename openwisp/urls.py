from django.conf.urls import include, url
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.urls import reverse_lazy
from django.views.generic import RedirectView

redirect_view = RedirectView.as_view(url=reverse_lazy('admin:index'))

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'', include('openwisp_controller.urls')),
    url(r'^api/v1/', include('openwisp_utils.api.urls')),
    url(r'^api/v1/', include('openwisp_users.api.urls')),
    # url(r'^', include('openwisp_network_topology.urls')),
    # url(r'^', include('openwisp_firmware_upgrader.urls')),
    url(r'^$', redirect_view, name='index'),
]

urlpatterns += staticfiles_urlpatterns()
