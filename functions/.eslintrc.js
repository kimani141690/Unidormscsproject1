module.exports = {
  env: {
    node: true, // This allows ESLint to recognize Node.js globals
    commonjs: true, // This allows ESLint to recognize CommonJS globals
    es2021: true,
  },
  extends: 'eslint:recommended',
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    indent: ['error', 2],
    'linebreak-style': ['error', 'unix'],
    quotes: ['error', 'single'],
    semi: ['error', 'always'],
  },
};
