from django.test import TestCase

from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from .models import Message
import datetime
from rest_framework.test import APIClient
# Create your tests here.

class TestMessageView(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.username1 = "Test"
        self.password1 = "Test"
        self.user1 = User.objects.create_user(username=self.username1 ,password=self.password1)
        self.user1.save()
        self.username2 = "Test2"
        self.password2 = "Test2"
        self.user2 = User.objects.create_user(username=self.username2,password=self.password2)
        self.user2.save()
        self.message1 = Message.objects.create(sender=self.user1,receiver=self.user2,content="Test")
        self.message1.save()
        self.message2 = Message.objects.create(sender=self.user2,receiver=self.user1,content="Test2")
        self.message2.save()
        
    def test_get_message_u1(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.get('/api/messages_between/%d/%d' % (self.user1.id, self.user2.id))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data[0]['content'], "Test")
        
    def test_get_message_u2(self):
        self.client.login(username=self.username2, password=self.password2)
        response = self.client.get('/api/messages_between/%d/%d' % (self.user2.id, self.user1.id))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data[1]['content'], "Test2")


