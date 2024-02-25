from django.urls import path

from . import views

urlpatterns = [
    #path('', views.index, name='index'),
    path('api/message', views.ChatView.as_view(), name='messages'),
    path('api/messages_between/<int:user_id1>/<int:user_id2>', views.ReceivedMessageView.as_view(), name='received_messages'),
    #path('api/sent_messages/<int:user_id>', views.SentMessageView.as_view(), name='sent_messages'),
]