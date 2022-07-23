boilerplate_pull_request_target() {
mkdir -p ".github/workflows"

cat << "EOF" > ".github/workflows/ci.yml"
name: CI

on:
  pull_request_target:

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: npm install
      - run: npm test
EOF

cat << "EOF" > "package.json"
{
  "name": "test",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
EOF
}

boilerplate_pull_request() {
mkdir -p ".github/workflows"

cat << "EOF" > ".github/workflows/ci.yml"
name: CI

on:
  pull_request:

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npm test
EOF
}