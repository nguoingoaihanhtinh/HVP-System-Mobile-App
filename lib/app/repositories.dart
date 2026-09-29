import '../core/clock.dart';
import '../data/mock/mock_auth_repository.dart';
import '../data/mock/mock_db.dart';
import '../data/mock/mock_lifecycle_repository.dart';
import '../data/mock/mock_membership_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/lifecycle_repository.dart';
import '../data/repositories/membership_repository.dart';
import 'app_state.dart';

/// Service locator for UC1–UC3 and UC14–UC17.
///
/// Screens only use the repository interfaces. When the Node.js API is ready,
/// add a `useApi()` that installs HTTP implementations; no screen changes.
class Repositories {
  static MockDb? _db;
  static late AuthRepository _auth;
  static late MembershipRepository _membership;
  static late LifecycleRepository _lifecycle;

  static AuthRepository get auth {
    _ensure();
    return _auth;
  }

  static MembershipRepository get membership {
    _ensure();
    return _membership;
  }

  static LifecycleRepository get lifecycle {
    _ensure();
    return _lifecycle;
  }

  /// Mock backend (the demo screen uses it directly).
  static MockDb get mockDb {
    _ensure();
    return _db!;
  }

  static MockLifecycleRepository get mockLifecycle =>
      lifecycle as MockLifecycleRepository;

  static SimulatedClock get clock => mockDb.clock;

  /// Member shown in the student screens: the logged-in member, or the demo
  /// member when a staff account opens the student UI.
  static String get currentMemberId {
    final user = auth.currentSession?.user;
    return user != null && user.isMember ? user.id : MockDb.demoMemberId;
  }

  /// Staff id recorded on receptionist actions.
  static String get currentStaffId {
    final user = auth.currentSession?.user;
    return user != null && !user.isMember ? user.id : MockDb.receptionistId;
  }

  static void useMock({MockDb? db}) {
    final mock = db ?? MockDb(appState: appState);
    final lifecycle = MockLifecycleRepository(mock);
    _db = mock;
    _auth = MockAuthRepository(mock);
    _lifecycle = lifecycle;
    _membership = MockMembershipRepository(mock, lifecycle);

    mock.appState.onCheckedIn = () {
      _lifecycle.onCheckedIn(currentMemberId);
    };
    mock.appState.onSessionCompleted = () {
      _lifecycle.onSessionCompleted(currentMemberId);
    };
  }

  static void _ensure() {
    if (_db == null) useMock();
  }
}
