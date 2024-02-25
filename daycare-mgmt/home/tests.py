from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.contrib.auth.models import User
from .models import Parent,Activity,Child,DayCareWorker,DayPlan
from datetime import date,time
from rest_framework.test import APIClient
# Create your tests here.
# ------------------- Endpoint Tests ---------------------
# Test for get parent by id
class TestParentView(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.username1 = "Test"
        self.password1 = "Test"
        self.user1 = User.objects.create_user(username=self.username1 ,password=self.password1)
        self.user1.save()
        self.parent1 = Parent.objects.create(firstname = "Test", lastname = "Last",user=self.user1)
        self.parent1.save()
        
    def test_get_parent(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.get('/api/parent/%d' % self.parent1.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['firstname'], "Test")
        self.assertEqual(response.data['lastname'], "Last")

#testing get daycareworker by id
class TestWorkerView(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.username1 = "Test"
        self.password1 = "Test"
        self.user1 = User.objects.create_user(username=self.username1 ,password=self.password1)
        self.user1.save()
        self.worker1 = DayCareWorker.objects.create(firstname="Test",lastname="Worker",user=self.user1)
        self.worker1.save()

    def test_get_worker(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.get('/api/worker/%d' % self.worker1.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['firstname'], "Test")
        self.assertEqual(response.data['lastname'], "Worker")

# Test for get child by id
class TestChildView(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.username1 = "Test"
        self.password1 = "Test"
        self.user1 = User.objects.create_user(username=self.username1 ,password=self.password1)
        self.user1.save()
        self.parent1 = Parent.objects.create(firstname = "Test", lastname = "Last",user=self.user1)
        self.parent1.save()
        self.daycare1 = DayCareWorker.objects.create(firstname="Test",lastname="Worker",user=self.user1)
        self.child1 = Child.objects.create(firstname="Test",lastname="Child",dob=date.fromisoformat('2012-12-04'),parent=self.parent1,dayCareWorker=self.daycare1)
        self.child1.save()

    def test_get_child(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.get('/api/child/%d' % self.child1.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['firstname'], "Test")
        self.assertEqual(response.data['lastname'], "Child")
        self.assertEqual(response.data['parent'], self.parent1.id)
        self.assertEqual(response.data['dob'], "2012-12-04")
        
# Test for getting all activities by id
class TestActivityView(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.username1 = "Test"
        self.password1 = "Test"
        self.user1 = User.objects.create_user(username=self.username1 ,password=self.password1)
        self.user1.save()
        self.daycare1 = DayCareWorker.objects.create(firstname="Test",lastname="Worker",user=self.user1)
        self.daycare1.save()
        self.username2 = "Test2"
        self.password2 = "Test2"
        self.user2 = User.objects.create_user(username=self.username2,password=self.password2)
        self.user2.save()
        self.parent1 = Parent.objects.create(firstname = "Test", lastname = "Last",user=self.user2)
        self.parent1.save()
        self.child1 = Child.objects.create(firstname="Test",lastname="Child",dob=date.fromisoformat('2012-12-04'),parent=self.parent1,dayCareWorker=self.daycare1)
        self.child1.save()
        self.child2 = Child.objects.create(firstname="Test2",lastname="Child2",dob=date.fromisoformat('2012-12-04'),parent=self.parent1,dayCareWorker=self.daycare1)
        self.child2.save()
        self.array = [self.child1.id,self.child2.id]
        self.activity1 = Activity.objects.create(title="Test",time=date.fromisoformat('2012-12-04'),file="Test",description="Test",dayCareWorker=self.daycare1,taggedChildrenID=self.array)
        self.activity1.save()

    def test_get_activity_u1(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.get('/api/activity/%d' % self.activity1.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['title'], "Test")
        self.assertEqual(response.data['time'], '2012-12-04T00:00:00-07:00')
        self.assertEqual(response.data['file'], "/media/Test")
        self.assertEqual(response.data['description'], "Test")
        self.assertEqual(response.data['dayCareWorker'], self.daycare1.id)
        self.assertEqual(response.data['taggedChildrenID'], self.array)
    
    def test_get_activity_u2(self):
        self.client.login(username=self.username2, password=self.password2)
        response = self.client.get('/api/activity/%d' % self.activity1.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['title'], "Test")
        self.assertEqual(response.data['time'], '2012-12-04T00:00:00-07:00')
        self.assertEqual(response.data['file'], "/media/Test")
        self.assertEqual(response.data['description'], "Test")
        self.assertEqual(response.data['dayCareWorker'], self.daycare1.id)
        self.assertEqual(response.data['taggedChildrenID'], self.array)
        
# Testing for all login actions
class TestLoginView(APITestCase):
    def setUp(self):
        self.user1 = User.objects.create_user(username="TestP",password="TestP",email="TestP@test.com")
        self.user1.save()
        self.user2 = User.objects.create_user(username="TestW",password="TestW", email="TestW@test.com")
        self.user2.save()
        self.parent1 = Parent.objects.create(firstname = "Test", lastname = "Parent",user=self.user1)
        self.parent1.save()
        self.daycare1 = DayCareWorker.objects.create(firstname="Test",lastname="Worker",user=self.user2)
        self.daycare1.save()
    #testing for invalid login with wrong account type
    def test_invalid_login(self):
        response = self.client.post('/api/login',{"username":"TestP","password":"TestP","accountType":"worker"},format='json')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data['message'], "DayCareWorker does not exist")
        response = self.client.post('/api/login',{"username":"TestW","password":"TestW","accountType":"parent"},format='json')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data['message'], "Parent does not exist")
    #testing for invalid login with wrong password
    def test_invalid_password(self):
        response = self.client.post('/api/login',{"username":"TestP","password":"TestP2","accountType":"parent"},format='json')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data['message'], "Parent Login Failed")
        response = self.client.post('/api/login',{"username":"TestW","password":"TestW2","accountType":"worker"},format='json')
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.data['message'], "DayCareWorker Login Failed")
    #testing for vaild parent login
    def test_parent_login(self):
        response = self.client.post('/api/login',{"username":"TestP","password":"TestP","accountType":"parent"},format='json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['id'], self.parent1.id)
        self.assertEqual(response.data['message'], "Login Successful")
    #testing for vaild worker login
    def test_worker_login(self):
        response = self.client.post('/api/login',{'username':'TestW','password':'TestW','accountType':'worker'},format='json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['id'], self.daycare1.id)
        self.assertEqual(response.data['message'], "Login Successful")
        
# Testing returning mutiple DayPlan fetching by date and worker id
class TestDayplanFetchView(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.username1 = "Test"
        self.password1 = "Test"
        self.user1 = User.objects.create_user(username=self.username1 ,password=self.password1)
        self.user1.save()
        self.daycare1 = DayCareWorker.objects.create(firstname="Test",lastname="Worker",user=self.user1)
        self.daycare1.save()
        self.dayplan1 = DayPlan.objects.create(dayCareWorker=self.daycare1,date=date.fromisoformat("2012-11-11"),title="Test1",note="Test1",startTime=time.fromisoformat("12:00:00"),endTime=time.fromisoformat("13:00:00"))
        self.dayplan1.save()
        self.dayplan2 = DayPlan.objects.create(dayCareWorker=self.daycare1,date=date.fromisoformat("2012-11-11"),title="Test2",note="Test2",startTime=time.fromisoformat("13:00:00"),endTime=time.fromisoformat("14:00:00"))
        self.dayplan2.save()
        
    def test_dayplan_fetch(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.get('/api/dayplan/%d/%s' % (self.daycare1.id,self.dayplan1.date))
        self.assertEqual(response.status_code, 200)
        list = [self.dayplan1,self.dayplan2]
        count = 0
        for res in response.data:
            self.assertEqual(res['date'], "2012-11-11")
            self.assertEqual(res['dayCareWorker'], self.daycare1.id)
            self.assertEqual(res['title'], list[count].title)
            self.assertEqual(res['note'],  list[count].note)
            self.assertEqual(res['startTime'], list[count].startTime.strftime("%H:%M:%S"))
            self.assertEqual(res['endTime'], list[count].endTime.strftime("%H:%M:%S"))
            count += 1
            
# Testing specific DayPlan endpoints
class TestSpecificDayplanView(APITestCase):
    def setUp(self):
        self.client = APIClient()
        self.username1 = "Test"
        self.password1 = "Test"
        self.user1 = User.objects.create_user(username=self.username1 ,password=self.password1)
        self.user1.save()
        self.daycare1 = DayCareWorker.objects.create(firstname="Test",lastname="Worker",user=self.user1)
        self.daycare1.save()
        self.dayplan1 = DayPlan.objects.create(dayCareWorker=self.daycare1,date=date.fromisoformat("2012-11-11"),title="Test1",note="Test1",startTime=time.fromisoformat("12:00:00"),endTime=time.fromisoformat("13:00:00"))
        self.dayplan1.save()
        
    def test_dayplan_get(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.get('/api/dayplan/%d' % self.dayplan1.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['date'], "2012-11-11")
        self.assertEqual(response.data['dayCareWorker'], self.daycare1.id)
        self.assertEqual(response.data['title'], self.dayplan1.title)
        self.assertEqual(response.data['note'],  self.dayplan1.note)
        self.assertEqual(response.data['startTime'], self.dayplan1.startTime.strftime("%H:%M:%S"))
        self.assertEqual(response.data['endTime'], self.dayplan1.endTime.strftime("%H:%M:%S"))
        
    def test_dayplan_patch(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.patch('/api/dayplan/%d' % self.dayplan1.id,{"date":"2012-11-12","dayCareWorker":self.daycare1.id,"startTime":"13:00:00","endTime":"14:00:00"},format='json')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['date'], "2012-11-12")
        self.assertEqual(response.data['dayCareWorker'], self.daycare1.id)
        self.assertEqual(response.data['title'], "Test1")
        self.assertEqual(response.data['note'],  "Test1")
        self.assertEqual(response.data['startTime'], "13:00:00")
        self.assertEqual(response.data['endTime'], "14:00:00")
        
    def test_dayplan_delete(self):
        self.client.login(username=self.username1, password=self.password1)
        response = self.client.delete('/api/dayplan/%d' % self.dayplan1.id)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['message'], "DayPlan deleted")