import 'package:hvp_boxing_prototype/app/app_state.dart';
import 'package:hvp_boxing_prototype/core/clock.dart';
import 'package:hvp_boxing_prototype/data/mock/mock_auth_repository.dart';
import 'package:hvp_boxing_prototype/data/mock/mock_db.dart';
import 'package:hvp_boxing_prototype/data/mock/mock_lifecycle_repository.dart';
import 'package:hvp_boxing_prototype/data/mock/mock_membership_repository.dart';

/// Fresh mock backend with a fixed clock and no latency.
class Fixture {
  Fixture() {
    db = MockDb(
      appState: AppState(),
      clock: SimulatedClock(base: DateTime(2026, 9, 29, 10)),
      latency: Duration.zero,
    );
    lifecycle = MockLifecycleRepository(db);
    membership = MockMembershipRepository(db, lifecycle);
    auth = MockAuthRepository(db);
  }

  late final MockDb db;
  late final MockLifecycleRepository lifecycle;
  late final MockMembershipRepository membership;
  late final MockAuthRepository auth;

  static const minh = MockDb.demoMemberId;
  static const an = MockDb.otherMemberId;
  static const staff = MockDb.receptionistId;
}
