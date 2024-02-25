from django.test import TestCase
from home.models import User, Parent, DayCareWorker, Child, Activity, Attendance, DayPlan
import datetime

class TestParentClass(TestCase):
    def setUp(self):
        super().setUp()
        Parent.objects.create(firstname="John",
                               lastname="Doe",
                                user=User.objects.create_user(username="johndoe",
                                                              password="password"))
        
    def test_parent_str(self):
        parent = Parent.objects.get(firstname="John")
        self.assertEqual(str(parent), "John Doe")

    def test_parent_from_id(self):
        parent = Parent.objects.get(firstname="John")
        self.assertEqual(Parent.ParentFromId(parent.id), parent)


class TestDayCareWorkerClass(TestCase):
    def setUp(self) -> None:
        super().setUp()
        DayCareWorker.objects.create(firstname="Jane",
                                        lastname="Doe",
                                        user=User.objects.create_user(username="janedoe",
                                                                        password="password"))
        

    def test_daycareworker_str(self):
        daycareworker = DayCareWorker.objects.get(firstname="Jane")
        self.assertEqual(str(daycareworker), "Jane Doe")
        

class TestChildClass(TestCase):
    def setUp(self) -> None:
        super().setUp()
        Parent.objects.create(firstname="John",
                               lastname="Doe",
                                user=User.objects.create_user(username="johndoe",
                                                              password="password"))

        DayCareWorker.objects.create(firstname="Jane",
                                        lastname="Doe",
                                        user=User.objects.create_user(username="janedoe",
                                                                        password="password"))

        Child.objects.create(firstname="John",
                                lastname="Doe",
                                dob="2020-01-01",
                                share_permissions=False,
                                parent=Parent.objects.get(firstname="John"))
        
    def test_child_str(self):
        child = Child.objects.get(firstname="John")
        self.assertEqual(str(child), "John Doe")
    

class TestActivityClass(TestCase):
    def setUp(self) -> None:
        super().setUp()
        DayCareWorker.objects.create(firstname="Jane",
                                        lastname="Doe",
                                        user=User.objects.create_user(username="janedoe",
                                                                        password="password"))
        
        Parent.objects.create(firstname="Bob",
                               lastname="Doe",
                                user=User.objects.create_user(username="johndoe",
                                                              password="password"))
        
        Child.objects.create(firstname="John",
                                lastname="Doe",
                                dob="2020-01-01",
                                share_permissions=False,
                                parent=Parent.objects.get(firstname="Bob"))
        
        Activity.objects.create(title="Test Activity",
                                time=datetime.datetime.now(),
                                file=None,
                                description="Test Description",
                                dayCareWorker=DayCareWorker.objects.get(firstname="Jane"),
                                taggedChildrenID=[i for i in range(1)],
                                likedParentID=[i for i in range(1)])
        
    def test_activity_str(self):
        activity = Activity.objects.get(title="Test Activity")
        self.assertEqual(str(activity), "Test Activity")


class TestAttendanceClass(TestCase):
    def setUp(self) -> None:
        super().setUp()
        Parent.objects.create(firstname="Bob",
                               lastname="Doe",
                                user=User.objects.create_user(username="johndoe",
                                                              password="password"))

        Child.objects.create(firstname="John",
                                lastname="Doe",
                                dob="2020-01-01",
                                share_permissions=False,
                                parent=Parent.objects.get(firstname="Bob"))
        
        DayCareWorker.objects.create(firstname="Jane",
                                        lastname="Doe",
                                        user=User.objects.create_user(username="janedoe",
                                                                        password="password"))
        
        Activity.objects.create(title="Test Activity",
                                time=datetime.datetime.now(),
                                file=None,
                                description="Test Description",
                                dayCareWorker=DayCareWorker.objects.get(firstname="Jane"),
                                taggedChildrenID=[i for i in range(1)],
                                likedParentID=[i for i in range(1)])


        Attendance.objects.create(child=Child.objects.get(firstname="John"),
                                    time=datetime.datetime.now(),
                                    worker=DayCareWorker.objects.get(firstname="Jane"),
                                    present=True) 

    def test_attendance_str(self):
        attendance = Attendance.objects.get(child=Child.objects.get(firstname="John"))
        self.assertEqual(str(attendance), str(attendance.child.firstname) + " " + str(attendance.child.lastname) + " " + str(attendance.time))


class TestDayPlanClass(TestCase):
    def setUp(self) -> None:
        super().setUp()
        DayCareWorker.objects.create(firstname="Jane",
                                        lastname="Doe",
                                        user=User.objects.create_user(username="janedoe",
                                                                        password="password"))
        
        DayPlan.objects.create(dayCareWorker=DayCareWorker.objects.get(firstname="Jane"),
                                date=datetime.datetime.now(),
                                title="Test Day Plan",
                                note="Test Note",
                                tabColor=0)
    
    def test_dayplan_str(self):
        dayplan = DayPlan.objects.get(dayCareWorker=DayCareWorker.objects.get(firstname="Jane"))
        self.assertEqual(str(dayplan), str(dayplan.date) + " with " + str(dayplan.dayCareWorker))