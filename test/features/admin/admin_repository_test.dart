import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futsal_app/core/constants/app_constants.dart';
import 'package:futsal_app/features/admin/data/admin_repository.dart';
import 'package:futsal_app/features/owner/domain/owner_application.dart';

void main() {
  test('approving an application creates an owner profile and updates status',
      () async {
    final firestore = FakeFirebaseFirestore();
    final repository = AdminRepository(firestore);

    final application = OwnerApplication(
      uid: 'owner-1',
      ownerName: 'Test Owner',
      email: 'owner@example.com',
      businessName: 'Test Futsal',
      registrationNumber: 'REG-1',
      phoneNumber: '01700000000',
      address: 'Dhaka',
      latitude: 23.8,
      longitude: 90.4,
      documents: const OwnerDocuments(
        idProofUrl: 'id.jpg',
        businessRegistrationUrl: 'business.jpg',
        venueProofUrl: 'venue.jpg',
      ),
      status: AppConstants.statusPending,
    );

    await firestore.collection(AppConstants.usersCollection).doc('owner-1').set({
      ...application.toMap(),
      'role': AppConstants.roleOwner,
      'approvalStatus': AppConstants.statusPending,
    });
    await firestore
        .collection(AppConstants.ownerApplicationsCollection)
        .doc('owner-1')
        .set(application.toMap());

    await repository.approveApplication(
      application: application,
      adminUid: 'admin-1',
    );

    final ownerDoc =
        await firestore.collection(AppConstants.ownersCollection).doc('owner-1').get();
    expect(ownerDoc.exists, isTrue);
    expect(ownerDoc.data()?['isActive'], isTrue);
    expect(ownerDoc.data()?['approvedBy'], 'admin-1');

    final applicationDoc = await firestore
        .collection(AppConstants.ownerApplicationsCollection)
        .doc('owner-1')
        .get();
    expect(applicationDoc.data()?['status'], AppConstants.statusApproved);

    final userDoc = await firestore
        .collection(AppConstants.usersCollection)
        .doc('owner-1')
        .get();
    expect(userDoc.data()?['approvalStatus'], AppConstants.statusApproved);
  });

  test('rejecting an application stores the reason', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = AdminRepository(firestore);
    await firestore
        .collection(AppConstants.ownerApplicationsCollection)
        .doc('owner-2')
        .set({'status': AppConstants.statusPending});
    await firestore.collection(AppConstants.usersCollection).doc('owner-2').set({
      'approvalStatus': AppConstants.statusPending,
    });

    await repository.rejectApplication(
      uid: 'owner-2',
      reason: 'Documents unclear',
      adminUid: 'admin-1',
    );

    final applicationDoc = await firestore
        .collection(AppConstants.ownerApplicationsCollection)
        .doc('owner-2')
        .get();
    expect(applicationDoc.data()?['status'], AppConstants.statusRejected);
    expect(applicationDoc.data()?['rejectionReason'], 'Documents unclear');
  });
}
