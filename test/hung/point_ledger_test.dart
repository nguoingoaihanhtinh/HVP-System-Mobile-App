import 'package:flutter_test/flutter_test.dart';
import 'package:hvp_boxing_prototype/data/models/point_transaction.dart';

import 'test_helpers.dart';

void main() {
  test('duplicate idempotency key returns the existing row, no double credit',
      () {
    final f = Fixture();
    final before = f.db.appState.dpBalance;

    final first = f.db.ledger.post(
        memberId: Fixture.minh,
        type: PointType.dp,
        source: 'TEST',
        idempotencyKey: 'dp:test:1',
        requestedAmount: 40,
        countsTowardCap: true);
    final second = f.db.ledger.post(
        memberId: Fixture.minh,
        type: PointType.dp,
        source: 'TEST',
        idempotencyKey: 'dp:test:1',
        requestedAmount: 40,
        countsTowardCap: true);

    expect(first.duplicate, isFalse);
    expect(second.duplicate, isTrue);
    expect(second.transaction.id, first.transaction.id);
    expect(f.db.appState.dpBalance, before + 40);
    expect(f.db.ledger.forMember(Fixture.minh), hasLength(1));
  });

  test('same key on a different point type is a different row', () {
    final f = Fixture();
    f.db.ledger.post(
        memberId: Fixture.minh,
        type: PointType.dp,
        source: 'TEST',
        idempotencyKey: 'k',
        requestedAmount: 1,
        countsTowardCap: false);
    final marks = f.db.ledger.post(
        memberId: Fixture.minh,
        type: PointType.marks,
        source: 'TEST',
        idempotencyKey: 'k',
        requestedAmount: 1,
        countsTowardCap: false);
    expect(marks.duplicate, isFalse);
  });

  test('monthly cap trims the amount and marks it CAPPED', () {
    final f = Fixture();
    f.db.ledger.countTowardCap(Fixture.an, PointType.dp, 1180);

    final posted = f.db.ledger.post(
        memberId: Fixture.an,
        type: PointType.dp,
        source: 'TEST',
        idempotencyKey: 'dp:test:cap',
        requestedAmount: 50,
        countsTowardCap: true);

    expect(posted.transaction.requestedAmount, 50);
    expect(posted.transaction.amount, 20);
    expect(posted.transaction.capStatus, CapStatus.capped);
    expect(f.db.ledger.capRoom(Fixture.an, PointType.dp), 0);
  });

  test('exempt sources ignore the cap', () {
    final f = Fixture();
    f.db.ledger.countTowardCap(Fixture.an, PointType.marks, 150);
    final posted = f.db.ledger.post(
        memberId: Fixture.an,
        type: PointType.marks,
        source: 'EARLY_RENEWAL',
        idempotencyKey: 'renewal:x',
        requestedAmount: 50,
        countsTowardCap: false);
    expect(posted.transaction.amount, 50);
    expect(posted.transaction.capStatus, CapStatus.exempt);
  });
}
