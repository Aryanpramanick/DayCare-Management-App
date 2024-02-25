from django.contrib import admin
from .models import Child, Activity, Parent, DayCareWorker,Activity,Attendance
from django.urls import path
from django.contrib.admin import AdminSite
from django.template.response import TemplateResponse
# Register your models here.
from django.contrib import admin
from django.urls import reverse
from django.utils.html import format_html

admin.site.register(Child)
admin.site.register(Parent)
admin.site.register(DayCareWorker)
admin.site.register(Activity)
admin.site.register(Attendance)
# class ModelListAdminSite(AdminSite):
#     site_title = 'My Custom Admin Site'
#     site_header = 'My Custom Admin Site'

#     def index(self, request, extra_context=None):
#         app_list = self.get_app_list(request)
#         my_models = DayCareWorker.objects.all()
#         context = dict(
#             self.each_context(request),
#             title=self.index_title,
#             my_models=my_models,
#             app_list=app_list,
#             **(extra_context or {}),
#         )
#         return admin.sites.AdminSite.index(self, request, context)
#     def get_urls(self):
#         urls = super().get_urls()   
#         # Add your custom URL patterns here
#         return urls

