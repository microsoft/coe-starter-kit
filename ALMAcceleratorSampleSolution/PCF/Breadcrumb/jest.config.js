/* eslint-disable */
const path = require('path');
module.exports = {
    preset: 'ts-jest',
    testEnvironment: 'jsdom',
    transform: {
        // transform files with ts-jest
        '^.+\\.(js|ts)$': 'ts-jest',
    },
    // transformIgnorePatterns: [
    //     // allow fluent ui transformation when running tests
    //     // this is because we are using path based imports
    //     'node_modules/(?!(@fluentui/react/lib|@fluentui/style-utilities/lib|@fluentui/react-hooks/lib))',
    // ],

    globals: {
        'ts-jest': {
            tsconfig: {
                // allow js in typescript
                allowJs: true,
            },
        },
    },
    coveragePathIgnorePatterns: ['BreadCrumb/fluentui-fork'],
    snapshotSerializers: ['@fluentui/jest-serializer-merge-styles'],
    setupFiles: [path.resolve(path.join(__dirname, 'config', 'tests.js'))],
};
