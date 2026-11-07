
// test/render.test.js — unit tests that load tools/build.js directly.
const { test } = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const os = require('os');
const path = require('path');

const { renderPage, main } = require('../tools/build');

test('a heading becomes an h1', () => {
  assert.match(renderPage('# Hello', 'x'), /<h1>Hello<\/h1>/);
});

test('the title is the one we pass in', () => {
  assert.match(renderPage('text', 'notes'), /<title>notes<\/title>/);
});

test('main returns 2 when arguments are missing', () => {
  const originalError = console.error;
  console.error = () => {};

  try {
    assert.strictEqual(main([]), 2);
  } finally {
    console.error = originalError;
  }
});

test('main reads Markdown and writes an HTML page', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'build-test-'));

  try {
    const src = path.join(dir, 'notes.md');
    const dest = path.join(dir, 'out', 'notes.html');

    fs.writeFileSync(src, '# Hello');

    assert.strictEqual(main([src, dest]), 0);

    const html = fs.readFileSync(dest, 'utf8');
    assert.match(html, /<title>Notes<\/title>/);
    assert.match(html, /<h1>Hello<\/h1>/);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});
