const { test } = require('node:test');
const assert = require('node:assert/strict');
const { isDuplicate } = require('../tools/duplicates');

test('returns true when page titles match', () => {
  assert.equal(isDuplicate({ title: 'Home' }, { title: 'Home' }), true);
});

test('returns false when page titles differ', () => {
  assert.equal(isDuplicate({ title: 'Home' }, { title: 'About' }), false);
});

test('returns false when either page is missing', () => {
  assert.equal(isDuplicate(null, { title: 'Home' }), false);
  assert.equal(isDuplicate({ title: 'Home' }, null), false);
});
