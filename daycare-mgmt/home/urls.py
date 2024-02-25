from django.urls import path
from .views import get_related_models

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('subscriptions', views.subscriptions, name='subscriptions'),
    path('api/activity', views.ActivityView.as_view(), name='activity'),
    path('api/activity/<int:id>', views.SpecificActivityView.as_view(), name='specific_activity'),
    #path('api/activity/worker/<int:workerID>', views.ListWorkerActivtyView.as_view(), name='worker_activity'),
    path('api/child/<int:id>', views.SpecificChildView.as_view(), name='specific_child'),
    path('api/child/<int:childID>/activities', views.ListChildActivityView.as_view(), name='child_activity'),
    path('api/parent', views.ParentView.as_view(), name='parent'),
    path('api/attendance', views.AttendanceView.as_view(), name='attendance'),
    path('api/attendance/<int:attendanceID>', views.ModifyAttendanceView.as_view(), name='attendance_by_worker'),
    path('api/attendance/<int:workerID>/<str:date>', views.SpecificAttendanceView.as_view(), name='specific_attendance'),
    path('api/parent/<int:id>', views.ParentByIdAPI.as_view(), name='specific_parent'),
    path('api/parent/<int:parentID>/children', views.ListParentChildrenView.as_view(), name='child_by_parent'),
    path('api/worker', views.WorkerView.as_view(), name='worker'),
    path('api/worker/<int:id>', views.SpecificWorkerView.as_view(), name='specific_worker'),
    path('api/worker/<int:workerID>/children', views.ListWorkerChildrenView.as_view(), name='child_by_worker'),
    path('api/worker/<int:workerID>/activities', views.ListWorkerActivityView.as_view(), name='child_by_worker'),
    path('api/login', views.LoginAPI.as_view(), name='login'),
    path('api/child', views.ChildView.as_view(), name='child'),
    path('get_related_models/', get_related_models, name='get_related_models'),
    path('api/worker/<int:workerID>/parents', views.ListWorkerParentsView.as_view(), name='worker_activity'),
    path('api/parent/<int:parentID>/workers', views.ListParentWorkersView.as_view(), name='parent_workers'),
    path('api/dayplan/<int:workerID>/<str:date>', views.FetchDayPlansByWorker.as_view(), name='worker_activity'),
    path('api/dayplan', views.DayPlanView.as_view(), name='dayplan'),
    path('api/dayplan/<int:id>', views.SpecificDayPlanView.as_view(), name='specific_dayplan'),
    path('api/bind_device/<int:user_id>/<str:token>/', views.BindDeviceAsView.as_view(), name='bind_device'),
    path('api/unbind_device/<int:user_id>/<str:token>/', views.RemoveDeviceAsView.as_view(), name='unbind_device')
]
