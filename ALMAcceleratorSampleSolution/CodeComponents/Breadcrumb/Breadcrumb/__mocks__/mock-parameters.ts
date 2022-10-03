/* istanbul ignore file */

import { IInputs } from '../generated/ManifestTypes';
import { MockStringProperty, MockWholeNumberProperty } from './mock-context';
import { MockDataSet } from './mock-datasets';

export function getMockParameters(): IInputs {
    return {
        AccessibilityLabel: new MockStringProperty(),
        InputEvent: new MockStringProperty(),
        Theme: new MockStringProperty(),
        items: new MockDataSet([]),
        MaxDisplayedItems: new MockWholeNumberProperty(),
        OverflowIndex: new MockWholeNumberProperty(),
    };
}
