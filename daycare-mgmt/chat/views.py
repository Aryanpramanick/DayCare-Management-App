from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Message
from drf_yasg.utils import swagger_auto_schema
from .serializers import MessageSerializer
from django.contrib.auth.models import User

from firebase_admin import messaging
from firebase_admin._messaging_utils import UnregisteredError
from fcm_django.models import FCMDevice

# Create your views here.

class ChatView(APIView):
    def sendMessage(self, serializer):
        if (FCMDevice.objects.filter(user_id=serializer.data['receiver']).exists()):
            token = FCMDevice.objects.get(user_id=serializer.data['receiver']).registration_id
            print(token)

            message = messaging.Message(
                notification=messaging.Notification(
                    title=User.objects.get(id=serializer.data['sender']).username,
                    body=serializer.data['content'],
                ),
                token=token,
            )
            try:
                response = messaging.send(message)
            except UnregisteredError as e:
                print("Device unregistered")
                FCMDevice.objects.get(user_id=serializer.data['receiver']).delete()
            print('Successfully sent message:', response)


    @swagger_auto_schema(description="Post a message",request_body=MessageSerializer)
    def post(self, request):
        serializer = MessageSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            self.sendMessage(serializer)
            return Response(serializer.data)
        return Response(serializer.errors)

class ReceivedMessageView(APIView):
    @swagger_auto_schema(description="Get all messages received by a user",responses={200: MessageSerializer(many=True)})
    def get(self, request, user_id1, user_id2):
        messages1 = Message.objects.filter(sender_id=user_id1, receiver_id=user_id2)
        messages2 = Message.objects.filter(sender_id=user_id2, receiver_id=user_id1)
        messages = messages1 | messages2
        messages = messages.order_by('timestamp')
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)
