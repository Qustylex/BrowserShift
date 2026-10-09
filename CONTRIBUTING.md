# Contributing

1. Every pull request must pass `pytest`.
2. Never commit real browser profiles, histories, cookies, or credentials.
3. Use synthetic fixtures under `tests/fixtures/`.
4. New adapters must declare capabilities explicitly and honestly.
5. No function may report success when an operation has failed.
6. Keep UI code separate from migration logic.