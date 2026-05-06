import '../../models/mock_service.dart';
import '../../models/service_model.dart';

const List<MockService> mockBarberServices = [
  MockService(
    id: 'bs1',
    name: 'حلاقة شعر + لحية',
    price: 40,
    durationMinutes: 30,
  ),
  MockService(id: 'bs2', name: 'حلاقة شعر', price: 25, durationMinutes: 20),
  MockService(id: 'bs3', name: 'حلاقة أطفال', price: 20, durationMinutes: 20),
];


const List<ServiceModel> mockServices = [
  ServiceModel(id: 's1', name: 'حلاقة شعر', durationMinutes: 30, price: 25),
  ServiceModel(id: 's2', name: 'حلاقة ذقن', durationMinutes: 15, price: 10),
  ServiceModel(id: 's3', name: 'ماسك أسود', durationMinutes: 0, price: 10),
  ServiceModel(id: 's4', name: 'ماسك أبيض', durationMinutes: 0, price: 10),
  ServiceModel(id: 's5', name: 'شمع', durationMinutes: 0, price: 8),
  ServiceModel(
    id: 'child_haircut',
    name: 'حلاقة أطفال',
    durationMinutes: 25,
    price: 20,
  ),
];
