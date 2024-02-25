"""core URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin, auth
from django.urls import include, path, re_path
from django.conf import settings
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from django.conf.urls.static import static
from home.models import Child, Parent, DayCareWorker, Activity
from chat.models import Message
# from home.admin import ModelListAdminSite
# model_list_admin_site = ModelListAdminSite(name='model-list-admin')    
# model_list_admin_site.register(Child)
# model_list_admin_site.register(Parent)
# model_list_admin_site.register(DayCareWorker)
# model_list_admin_site.register(Activity)
# model_list_admin_site.register(auth.models.User)
# model_list_admin_site.register(Message)
# from home.admin import CustomAdmin
# model_list_admin_site



schema_view = get_schema_view(
   openapi.Info(
      title="Daycare Management API",
      default_version='v1',
      description="Daycare Management API",
      terms_of_service="https://www.google.com/policies/terms/",
      contact=openapi.Contact(email="testing@api.com"),
      license=openapi.License(name="BSD License"),
   ),
   public=True,
   permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    re_path(r'^playground/$', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    re_path(r'^docs/$', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    path('', include('home.urls')),
    path("admin/", admin.site.urls),
    path("", include('admin_soft.urls')),
    path('', include('chat.urls')),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
