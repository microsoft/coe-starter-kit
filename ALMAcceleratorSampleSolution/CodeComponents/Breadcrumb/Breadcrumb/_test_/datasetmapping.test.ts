import { getBreadcrumbItems, getItemsFromDataset } from '../components/DatasetMapping';
import { ItemColumns } from '../ManifestConstants';
import { MockDataSet, MockEntityRecord } from '../__mocks__/mock-datasets';

describe('DatasetMapping', () => {
    beforeEach(() => jest.clearAllMocks());

    it('returns correct props', () => {
        const items = [
            new MockEntityRecord('1', {
                [ItemColumns.Key]: 'item1',
                [ItemColumns.DisplayName]: 'Item 1',
                [ItemColumns.Clickable]: true,
            }),
            new MockEntityRecord('2', {
                [ItemColumns.Key]: 'item2',
                [ItemColumns.DisplayName]: 'Item 2',
                [ItemColumns.Clickable]: true,
            }),
            new MockEntityRecord('3', {
                [ItemColumns.Key]: 'item3',
                [ItemColumns.DisplayName]: 'Item 3',
            }),
            new MockEntityRecord('5', {
                [ItemColumns.Key]: 'item5',
                [ItemColumns.DisplayName]: 'Item 5',
                [ItemColumns.Clickable]: false,
            }),
            new MockEntityRecord('6', {
                [ItemColumns.Key]: 'item6',
                [ItemColumns.DisplayName]: 'Item 6',
            }),
            new MockEntityRecord('7', {
                [ItemColumns.Key]: 'item7',
                [ItemColumns.DisplayName]: 'Item 7',
                [ItemColumns.Clickable]: true,
            }),
            new MockEntityRecord('8', {
                [ItemColumns.Key]: 'item8',
                [ItemColumns.DisplayName]: 'Item 8',
                [ItemColumns.Clickable]: true,
            }),
        ];

        const onClickEvent = jest.fn();
        const actions = getItemsFromDataset(new MockDataSet(items));
        const props = getBreadcrumbItems(actions, onClickEvent);
        expect(props).toMatchSnapshot();
    });
});
