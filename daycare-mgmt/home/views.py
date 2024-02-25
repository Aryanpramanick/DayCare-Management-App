# from datetime import date
from datetime import datetime
from django.shortcuts import render
from drf_yasg.utils import swagger_auto_schema
from django.http import HttpResponse
from rest_framework.views import APIView
from chat.models import Message
import json
from rest_framework.response import Response
from rest_framework.authentication import BasicAuthentication,SessionAuthentication
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Parent, DayCareWorker,Activity,Child,Attendance, DayPlan
from .serializers import ParentSerializer, DayCareserializer, ActivitySerializer,ChildSerializer,AttendanceSerializer, DayPlanSerializer
from django.contrib.auth.models import User
from django.http import JsonResponse

from fcm_django.models import FCMDevice
from firebase_admin import messaging
from firebase_admin._messaging_utils import UnregisteredError


# Create your views here.
# ------------------Views Section------------------#
def index(request):

    # Page from the theme 
    return render(request, 'pages/index.html')

def subscriptions(request):
    return render(request, 'pages/subscriptions.html')

def get_related_models(request):
    try:
        if request.method == "POST":
            model_id = request.POST.get('model_id')
            my_model = DayCareWorker.objects.get(id=model_id)
            activity = Activity.objects.filter(dayCareWorker=my_model)
            return JsonResponse({'activities': list(activity.values())})
    except Activity.DoesNotExist:
        return JsonResponse({'error': 'activity not found'})

#------------------API Section------------------#

class ParentByIdAPI(APIView): #TODO: Change this to a class-based view
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get a parent by id", responses={200: ParentSerializer})
    
    def get(self, request, id):
        try:
            parent = Parent.objects.get(id=id)
            serializer = ParentSerializer(parent)
            return Response(serializer.data)
        except Parent.DoesNotExist:
            return Response({'message': 'Parent not found'}, status=404)

class ParentView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Add a parent", request_body=ParentSerializer)
    def post(self, request):
        data = json.loads(request.body.decode('utf-8'))
        firstname = data['firstname']
        lastname = data['lastname']
        user = User.objects.create_user(username=data['username'], password=data['password'], email=data['email'])
        user.save()
        parent = Parent.objects.create(firstname=firstname, lastname=lastname, user=user)
        parent.save()
        return Response({"message":"new parent user created", "id": parent.id}, status=201)
        
class ActivityView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all activities", responses={200: ActivitySerializer(many=True)})
    def get(self, request):
        try:
            activity = Activity.objects.all()
            serializer = ActivitySerializer(activity,many=True)
            return Response(serializer.data,status=200)
        except Activity.DoesNotExist:
            return Response({'message': 'Activity not found'}, status=404)
    
    @swagger_auto_schema(operation_description="Add an activity", request_body=ActivitySerializer)
    def post(self, request):
        """ data = json.loads(request.body.decode('utf-8'))
        type = data['type']
        description = data['description']
        dayCareWorker = data['dayCareWorker']
        dayCareWorker = DayCareWorker.objects.get(id=dayCareWorker)
        file = data['file']
        taggedChildrenID = data['taggedChildrenID']
        instance = Activity.objects.create(type=type,file=file,description=description,dayCareWorker=dayCareWorker,taggedChildrenID=taggedChildrenID)
        instance.save() """
        #return Response({"message":"new activity created", "id": instance.id}, status=201)
        serializer = ActivitySerializer(data=request.data)
        if serializer.is_valid():
            # Add the notification part here
            children = serializer.validated_data['taggedChildrenID']
            for child in children:
                child = Child.objects.get(id=child)
                if (FCMDevice.objects.filter(user_id=child.parent.user.id).exists()):
                    token = FCMDevice.objects.get(user_id=child.parent.user.id).registration_id
                    self.sendNotification(token, child.parent.user.id)

            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    
    def sendNotification(self, token, id):
        message = messaging.Message(
            notification=messaging.Notification(
                title='New Activity',
                body='There is a new activity for your child',
            ),
            token=token
        )
        response = None
        try:
            response = messaging.send(message)
        except UnregisteredError as e:
            print("Device unregistered")
            FCMDevice.objects.get(registration_id=token).delete()
   
        print(response)


class SpecificActivityView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get an activity by id", responses={200: ActivitySerializer})
    # API view to get a specific activity by id
    def get(self, request, id):
        try:
            activity = Activity.objects.get(id=id)
        except Activity.DoesNotExist:
            return Response({'message': 'Activity not found'}, status=404)
        serializer = ActivitySerializer(activity)
        return Response(serializer.data, status=200)
    
    

    @swagger_auto_schema(operation_description="Update an activity by id", request_body=ActivitySerializer)
    def put(self, request, id):
        try:
            activity = Activity.objects.get(id=id)
        except Activity.DoesNotExist:
            return Response({'message': 'Activity not found'}, status=404)
        serializer = ActivitySerializer(activity, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)
    @swagger_auto_schema(operation_description="Delete an activity by id")
    def delete(self, request, id):
        try:
            activity = Activity.objects.get(id=id)
        except Activity.DoesNotExist:
            return Response({'message': 'Activity not found'}, status=404)
        activity.delete()
        return Response(status=204)
    @swagger_auto_schema(operation_description="Update an activity by id", request_body=ActivitySerializer)
    def patch(self, request, id):
        try:
            activity = Activity.objects.get(id=id)
        except Activity.DoesNotExist:
            return Response({'message': 'Activity not found'}, status=404)
        serializer = ActivitySerializer(activity, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)

class ListChildActivityView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all activities for a child", responses={200: ActivitySerializer(many=True)})
    def get(self, request, childID):
        try:
            activity = Activity.objects.filter(taggedChildrenID__contains=[childID])
            serializer = ActivitySerializer(activity,many=True)
            return Response(serializer.data,status=200)
        except Activity.DoesNotExist:
            return Response({'message': 'Activity not found'}, status=404)
        
class ListWorkerActivityView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all activities for a worker", responses={200: ActivitySerializer(many=True)})
    def get(self, request, workerID):
        try:
            activity = Activity.objects.filter(dayCareWorker=workerID)
            serializer = ActivitySerializer(activity,many=True)
            return Response(serializer.data,status=200)
        except Activity.DoesNotExist:
            return Response({'message': 'Activity not found'}, status=404)

class ListWorkerChildrenView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all children for a worker", responses={200: ChildSerializer(many=True)})
    def get(self, request, workerID):
        try:
            children = Child.objects.filter(dayCareWorker=workerID)
            serializer = ChildSerializer(children,many=True)
            return Response(serializer.data,status=200)
        except DayCareWorker.DoesNotExist:
            return Response({'message': 'Worker not found'}, status=404)

class ListParentChildrenView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all children for a parent", responses={200: ChildSerializer(many=True)})
    def get(self, request, parentID):
        try:
            children = Child.objects.filter(parent=parentID)
            serializer = ChildSerializer(children,many=True)
            return Response(serializer.data,status=200)
        except Parent.DoesNotExist:
            return Response({'message': 'Parent not found'}, status=404)

class SpecificChildView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get a child by id", responses={200: ChildSerializer})
    def get(self, request, id):
        try:
            child = Child.objects.get(id=id)
        except Child.DoesNotExist:
            return Response({'message': 'Child not found'}, status=404)
        serializer = ChildSerializer(child)
        return Response(serializer.data, status=200)

class ChildView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Add a child", request_body=ChildSerializer)
    def post(self, request):
        data = json.loads(request.body.decode('utf-8'))
        firstname = data['firstname']
        lastname = data['lastname']
        dob = datetime.strptime(data["dob"], '%Y-%m-%d').date()  # from Iso8601String ('yyyy-mm-dd') to 'yyyy-mm-dd hh:mm:ss'
        share_permissions = data['share_permissions']
        worker = DayCareWorker.objects.get(id=data['dayCareWorker'])
        parent = Parent.objects.get(id=data['parent'])
        child = Child.objects.create(firstname=firstname,lastname=lastname,dob=dob,share_permissions=share_permissions,dayCareWorker=worker,parent=parent)
        child.save()
        return Response({"message":"new child created", "id": child.id}, status=201)

class SpecificWorkerView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get a worker by id", responses={200: DayCareserializer})
    def get(self, request, id):
        try:
            worker = DayCareWorker.objects.get(id=id)
        except DayCareWorker.DoesNotExist:
            return Response({'message': 'Worker not found'}, status=404)
        serializer = DayCareserializer(worker)
        return Response(serializer.data, status=200)

class WorkerView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Add a worker", request_body=DayCareserializer)
    def post(self, request):
        data = json.loads(request.body.decode('utf-8'))
        firstname = data['firstname']
        lastname = data['lastname']
        user = User.objects.create_user(username=data['username'], password=data['password'], email=data['email'])
        user.save()
        worker = DayCareWorker.objects.create(firstname=firstname, lastname=lastname, user=user)
        worker.save()
        return Response({"message":"new worker user created", "id": worker.id}, status=201)

class AttendanceView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Add an attendance", request_body=AttendanceSerializer)
    def post(self, request):
        serializer = AttendanceSerializer(data=request.data, many=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)
    
    def patch(self, request):
        data = json.loads(request.body.decode('utf-8'))
        is_partial = False
        fail_ids = []
        for item in data:
            try:
                attendance = Attendance.objects.get(id=item['id'])
                serializer = AttendanceSerializer(attendance, data=item, partial=True)
                if serializer.is_valid():
                    serializer.save()
                else:
                    return Response(serializer.errors, status=400)
            except Attendance.DoesNotExist:
                is_partial = True
                fail_ids.append(item['id'])
                continue
            
        if is_partial:
            return Response({'message': 'Attendance update partially',"id":fail_ids},status=206)
        
        return Response({'message': 'Attendance update successfully'},status=200)
    
class SpecificAttendanceView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get an attendance by id", responses={200: AttendanceSerializer})
    def get(self, request, workerID,date):
        try:
            attendance = Attendance.objects.filter(worker = workerID, time__contains=date)
        except Attendance.DoesNotExist:
            return Response({'message': 'Attendance not found'}, status=404)
        serializer = AttendanceSerializer(attendance,many=True)
        return Response(serializer.data, status=200)

class ModifyAttendanceView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    def delete(self, request, attendanceID):
        try:
            attendance = Attendance.objects.get(id=attendanceID)
        except Attendance.DoesNotExist:
            return Response({'message': 'Attendance not found'}, status=404)
        attendance.delete()
        return Response(status=204)
    def patch(self, request, attendanceID):
        try:
            attendance = Attendance.objects.get(id=attendanceID)
        except Attendance.DoesNotExist:
            return Response({'message': 'Attendance not found'}, status=404)
        data = json.loads(request.body.decode('utf-8'))
        serializer = AttendanceSerializer(attendance, data=data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        return Response(serializer.errors, status=400)

class LoginAPI(APIView): # TODO: Refine to a proper login API
    permission_classes = [AllowAny]
    # parser_classes = [FormParser]
    def post(self, request):
        # print("here")
        data = json.loads(request.body.decode('utf-8'))
        username = data.get('username')
        password = data.get('password')
        accountType = data.get('accountType')
        # print(username, password, accountType)
        if accountType == "parent":
            try:
                # print("parent login")
                fetch_user = User.objects.get(username=username)
                parent = Parent.objects.get(user=fetch_user)
                if fetch_user .check_password(password) and parent is not None:
                    # Success Code
                    response = Response({"id": parent.id,"message":"Login Successful"})
                    response.status_code = 200
                    return response
                else:
                    # Error Code
                    return Response({'message': 'Parent Login Failed'}, status=400)
            except Parent.DoesNotExist:
                return Response({'message': 'Parent does not exist'}, status=400)
        elif accountType == "worker":
            try:
                # print("worker login")
                fetch_user = User.objects.get(username=username)
                worker = DayCareWorker.objects.get(user=fetch_user)
                if fetch_user .check_password(password) and worker is not None:
                    # Success Code
                    response = Response({"id": worker.id,"message":"Login Successful"})
                    response.status_code = 200
                    return response
                else:
                    # Error Code
                    return Response({'message': 'DayCareWorker Login Failed'}, status=400)
            except DayCareWorker.DoesNotExist:
                return Response({'message': 'DayCareWorker does not exist'}, status=400)
        else:
            return Response({'message': 'Login Failedm Type not specific'}, status=400)

class ListWorkerParentsView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all parents for a worker", responses={200: ParentSerializer(many=True)})
    def get(self, request, workerID):
        try:
            worker = DayCareWorker.objects.get(id=workerID)
            children = Child.objects.filter(dayCareWorker=workerID)
            parents = []
            for child in children:
                parents.append(child.parent)
            parents = list(set(parents))
            result = []
            for parent in parents:
                obj = dict()
                messages1 = Message.objects.filter(sender_id=worker.user.id, receiver_id=parent.user.id)
                messages2 = Message.objects.filter(sender_id=parent.user.id, receiver_id=worker.user.id)
                messages = messages1 | messages2
                messages = messages.order_by('timestamp')
                last_message = messages.last()
                obj['id'] = parent.id
                obj['firstname'] = parent.firstname
                obj['lastname'] = parent.lastname
                obj['user'] = parent.user.id
                if last_message is None:
                    obj['last_message'] = ""
                    obj['last_message_timestamp'] = ""
                else:
                    obj['last_message'] = last_message.content
                    obj['last_message_timestamp'] = last_message.timestamp
                result.append(obj)
            return JsonResponse(result,status=200,safe=False)
        except DayCareWorker.DoesNotExist:
            return Response({'message': 'Worker not found'}, status=404)
        
class ListParentWorkersView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all workers for a parent", responses={200: DayCareserializer(many=True)})
    def get(self, request, parentID):
        try:
            parent = Parent.objects.get(id=parentID)
            children = Child.objects.filter(parent=parentID)
            workers = []
            for child in children:
                workers.append(child.dayCareWorker)
            workers = list(set(workers))
            result = []
            for worker in workers:
                obj = dict()
                messages1 = Message.objects.filter(sender_id=parent.user.id, receiver_id=worker.user.id)
                messages2 = Message.objects.filter(sender_id=worker.user.id, receiver_id=parent.user.id)
                messages = messages1 | messages2
                messages = messages.order_by('timestamp')
                last_message = messages.last()
                obj['id'] = worker.id
                obj['firstname'] = worker.firstname
                obj['lastname'] = worker.lastname
                obj['user'] = worker.user.id
                if last_message is None:
                    obj['last_message'] = ""
                    obj['last_message_timestamp'] = ""
                else:
                    obj['last_message'] = last_message.content
                    obj['last_message_timestamp'] = last_message.timestamp
                result.append(obj)
            return JsonResponse(result,status=200,safe=False)
        except Parent.DoesNotExist:
            return Response({'message': 'Parent not found'}, status=404)
        
# APIView for frontend to fetch dayplans for a specific date
class FetchDayPlansByWorker(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get all dayplans for a specific date", responses={200: DayPlanSerializer(many=True)})
    def get(self, request, workerID, date):
        try:
            date_obj = datetime.strptime(date, '%Y-%m-%d')
            worker = DayCareWorker.objects.get(id=workerID)
            dayplans = DayPlan.objects.filter(date=date_obj,dayCareWorker=worker).order_by('startTime')
            serializer = DayPlanSerializer(dayplans,many=True)
            return Response(serializer.data,status=200)
        except DayPlan.DoesNotExist:
            return Response({'message': 'DayPlan not found'}, status=404)


# Generic APIView for dayplans
class DayPlanView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Add a dayplan", request_body=DayPlanSerializer)
    # def post(self, request):
    #     data = json.loads(request.body.decode('utf-8'))
    #     date = datetime.strptime(data["date"], '%Y-%m-%d').date()  # from Iso8601String ('yyyy-mm-dd') to 'yyyy-mm-dd hh:mm:ss'
    #     worker = DayCareWorker.objects.get(id=data['dayCareWorker'])
    #     sTime = datetime.strptime(data["startTime"], '%H:%M').time()
    #     eTime = datetime.strptime(data["endTime"], '%H:%M').time()
    #     dayplan = DayPlan.objects.create(date=date,dayCareWorker=worker,title=data['title'],startTime=sTime,endTime=eTime,note=data['description'])
    #     dayplan.save()
    #     return Response({"message":"new dayplan created", "id": dayplan.id}, status=201)
    def post(self, request):
        serializer = DayPlanSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=201)
        else:
            return Response(serializer.errors, status=400)
    
# Specific APIView for dayplans
class SpecificDayPlanView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(operation_description="Get a dayplan by id", responses={200: DayPlanSerializer})
    # Update a dayplan by id
    def patch(self, request, id):
        try:
            dayplan = DayPlan.objects.get(id=id)
        except DayPlan.DoesNotExist:
            return Response({'message': 'DayPlan not found'}, status=404)
        serializer = DayPlanSerializer(dayplan, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=200)
        else:
            return Response(serializer.errors, status=400)
    # Delete a dayplan by id
    def delete(self, request, id):
        try:
            dayplan = DayPlan.objects.get(id=id)
        except DayPlan.DoesNotExist:
            return Response({'message': 'DayPlan not found'}, status=404)
        dayplan.delete()
        return Response({'message': 'DayPlan deleted'}, status=200)
    # Get a dayplan by id
    def get(self, request, id):
        try:
            dayplan = DayPlan.objects.get(id=id)
        except DayPlan.DoesNotExist:
            return Response({'message': 'DayPlan not found'}, status=404)
        serializer = DayPlanSerializer(dayplan)
        return Response(serializer.data, status=200)
    
# APIView to bind the FCM token to the user
class BindDeviceAsView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(description="Register a device")
    def get(self, request, user_id, token):
        device = None

        # Only allow one device per user
        if (FCMDevice.objects.filter(user_id=user_id).exists()):
            if (FCMDevice.objects.get(user_id=user_id).registration_id == token):
                print("Device already registered for user " + str(user_id))
                return Response("Device already registered")
            device = FCMDevice.objects.get(user_id=user_id)
        else:
            device = FCMDevice()

        device.registration_id = token
        device.user = User.objects.get(id=user_id)
        device.save()

        response = messaging.subscribe_to_topic(token, "chat")
        messaging.subscribe_to_topic(token, "dayplan")

        print("Response: " + str(response.success_count))

        print("Device registered for user " + str(user_id))
        return Response("Device registered")

# APIView to remove the FCM token from the user (logout)
class RemoveDeviceAsView(APIView):
    authentication_classes = [SessionAuthentication, BasicAuthentication]
    permission_classes = [IsAuthenticated]
    
    @swagger_auto_schema(description="Remove a device")
    def get(self, request, user_id, token):
        if (FCMDevice.objects.filter(user_id=user_id).exists()):
            if (FCMDevice.objects.get(user_id=user_id).registration_id == token):
                FCMDevice.objects.get(user_id=user_id).delete()
                print("Device removed for user " + str(user_id))
                return Response("Device removed")
            else:
                print("Device not registered for user " + str(user_id))
                return Response("Device not registered")
        else:
            print("Device not registered for user " + str(user_id))
            return Response("Device not registered")