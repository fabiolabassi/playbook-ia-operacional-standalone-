const fs = require('node:fs');

function readPassRate(path) {
  const contents = fs.readFileSync(path, 'utf8').replace(/^\uFEFF/, '');
  const report = JSON.parse(contents);
  const results = Array.isArray(report.results)
    ? report.results
    : report.results?.results;
  if (!Array.isArray(results) || results.length === 0) {
    throw new Error(`Evaluation report has no results: ${path}`);
  }

  const passed = results.filter((result) => result && result.success === true).length;
  return { passed, total: results.length };
}

function formatRate({ passed, total }) {
  return `${passed}/${total} (${((passed / total) * 100).toFixed(1)}%)`;
}

const base = readPassRate(process.argv[2]);
const head = readPassRate(process.argv[3]);
console.log(`Base: ${formatRate(base)}; head: ${formatRate(head)}`);

if (head.passed / head.total < base.passed / base.total) {
  console.error('Regression detected: the head pass rate is lower than the base pass rate.');
  process.exitCode = 1;
}
