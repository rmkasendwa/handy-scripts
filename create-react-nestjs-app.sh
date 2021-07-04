#!/bin/bash
echo "Enter the project name: "
read PROJECT_NAME
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"
git init

echo "Capturing current node version..."
echo `node --version` >> .node-version
echo `node --version` >> .nvmrc

echo "Writing package.json file..."
cat > package.json <<EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "keywords": [],
  "author": "",
  "scripts": {
    "build:client": "cd frontend && npm run build",
    "build:server": "cd backend && npm run build",
    "build:bundle": "rm -rf dist && mv backend/dist dist && mv frontend/build dist/public",
    "build": "concurrently --names \"Frontend,Backend\" -c \"blue.bold,magenta.bold\" \"npm run build:client\" \"npm run build:server\" && npm run build:bundle",
    "build:debug:client": "cd frontend && npm run build:debug",
    "build:debug": "concurrently --names \"Frontend,Backend\" -c \"blue.bold,magenta.bold\" \"npm run build:debug:client\" \"npm run build:server\" && npm run build:bundle",
    "format": "prettier --write \"./(backend|frontend)/**/*.{js,jsx,ts,tsx,html,htm,json,css,scss,md}\"",
    "heroku-prebuild": "npm i -g @nestjs/cli && npm run build",
    "install:client": "cd frontend && npm install",
    "install:server": "cd backend && npm install",
    "install:dependencies": "npm install && concurrently --names \"Frontend,Backend\" -c \"blue.bold,magenta.bold\" \"npm run install:client\" \"npm run install:server\"",
    "postinstall": "concurrently --names \"Frontend,Backend\" -c \"blue.bold,magenta.bold\" \"npm run install:client\" \"npm run install:server\"",
    "start:client": "cd frontend && npm start",
    "start:server": "cd backend && npm run start:dev",
    "start": "concurrently --names \"Frontend,Backend\" -c \"blue.bold,magenta.bold\" \"npm run start:client\" \"npm run start:server\""
  },
  "lint-staged": {
    "./(backend|frontend)/**/*.{js,jsx,ts,tsx,html,htm,json,css,scss,md}": [
      "eslint --fix",
      "prettier --write"
    ]
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ],
    "overrides": [
      {
        "files": [
          "**/*.stories.*"
        ],
        "rules": {
          "import/no-anonymous-default-export": "off"
        }
      }
    ]
  },
  "importSort": {
    ".js, .jsx, .ts, .tsx": {
      "style": "module",
      "parser": "typescript"
    }
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^4.24.0",
    "@typescript-eslint/parser": "^4.24.0",
    "concurrently": "^6.1.0",
    "eslint": "^7.26.0",
    "eslint-config-prettier": "^8.3.0",
    "eslint-plugin-eslint-comments": "^3.2.0",
    "eslint-plugin-import": "^2.23.3",
    "eslint-plugin-jsx-a11y": "^6.4.1",
    "eslint-plugin-prettier": "^3.4.0",
    "eslint-plugin-react": "^7.23.2",
    "eslint-plugin-react-hooks": "^4.2.0",
    "eslint-plugin-sort-keys-fix": "^1.1.1",
    "husky": "^6.0.0",
    "import-sort-style-module": "^6.0.0",
    "lint-staged": "^11.0.0",
    "prettier": "^2.3.0",
    "prettier-plugin-import-sort": "0.0.7",
    "prettier-plugin-sort-json": "0.0.2",
    "typescript": "^4.3.2"
  }
}
EOF

echo "Writing .gitignore file..."
cat > .gitignore <<EOF
dist
!/dist
nbproject
target
temp
package
package-lock.json
node_modules
builds
coverage
sandbox
__sandbox
temp
tests
cypress
.env
.history
.idea
.orig
.sass-cache
EOF

echo "Writing .eslintrc.js file..."
cat > .eslintrc.js <<EOF
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint/eslint-plugin', 'sort-keys-fix'],
  extends: [
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
    'plugin:react/recommended',
    'plugin:react-hooks/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'plugin:import/typescript',
    'plugin:jsx-a11y/recommended',
    'plugin:eslint-comments/recommended',
    'prettier',
  ],
  root: true,
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['.eslintrc.js'],
  rules: {
    'no-unused-vars': 'off',
    '@typescript-eslint/no-unused-vars': ['error'],
    '@typescript-eslint/no-var-requires': 'off',
    '@typescript-eslint/interface-name-prefix': 'off',
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'off',
    'react/prop-types': 'off',
    'react/jsx-uses-react': 'off',
    'react/react-in-jsx-scope': 'off',
  },
  settings: {
    react: {
      version: 'detect',
    },
  },
};
EOF

echo "Writing .huskyrc.js file..."
cat > .huskyrc.js <<EOF
module.exports = {
  hooks: {
    'pre-commit': 'lint-staged',
  },
};
EOF

echo "Writing .prettierrc.js file..."
cat > .prettierrc.js <<EOF
module.exports = {
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  jsonRecursiveSort: true,
  printWidth: 80,
  tabWidth: 2,
  endOfLine: 'auto',
};
EOF

echo "Writing .prettierignore file..."
cat > .prettierignore <<EOF
node_modules
dist
lib
builds
coverage
sandbox
temp
__sandbox
__testdata
EOF

echo "Writing README.md file..."
cat > README.md <<EOF
# Getting Started

## Available Scripts

In the root directory, you can run:

### \`npm install\`

Installs dependencies for both the frontend and backend.

### \`npm start\`

Starts both the frontend and backend in watch mode.

### \`npm run build\`

Builds the full stack to the dist folder with frontend static files in dist/public and the backend files in the root of dist.

## Learn More

You can get more details from backend/readme.md and frontend/readme.md
EOF

echo "Updating global nestjs installation..."
npm i -g @nestjs/cli

echo "Installing backend application..."
git clone https://github.com/nestjs/typescript-starter.git backend
rm ./backend/.eslintrc.js
rm ./backend/.prettierrc

echo "Installing frontend application..."
npx create-react-app frontend --template typescript
cd frontend && npm install node-sass
rm yarn.lock
cd ..

echo "Installing dependencies..."
npm install

echo "Done! press enter to exit"
read a