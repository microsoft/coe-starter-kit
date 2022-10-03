import { Breadcrumb } from '..';
import { IInputs } from '../generated/ManifestTypes';
import { ItemColumns } from '../ManifestConstants';
import { MockContext, MockState } from '../__mocks__/mock-context';
import { MockDataSet, MockEntityRecord } from '../__mocks__/mock-datasets';
import { getMockParameters } from '../__mocks__/mock-parameters';
import { act } from 'react-dom/test-utils';
import { mount } from 'enzyme';

// Since requestAnimationFrame does not exist in the test DOM, mock it
window.requestAnimationFrame = jest.fn().mockImplementation((callback) => {
    callback();
});

jest.useFakeTimers();

describe('BreadCrumb', () => {
    beforeEach(() => jest.clearAllMocks());
    afterEach(() => {
        for (let i = 0; i < document.body.children.length; i++) {
            if (document.body.children[i].tagName === 'DIV') {
                document.body.removeChild(document.body.children[i]);
                i--;
            }
        }
    });

    it('renders', () => {
        const { component, context } = createComponent();
        component.init(context);
        const element = component.updateView(context);
        expect(element).toMatchSnapshot();
    });

    it('renders dummy items when no items configured', () => {
        const { component, context } = createComponent();
        // Simulate there being no items bound - which causes an error on the parameters
        context.parameters.items.error = true;
        component.init(context);
        const element = component.updateView(context);
        expect(element).toMatchSnapshot();
    });

    it('raises the onSelect event', () => {
        const { component, context } = createComponent();

        component.init(context);
        const breadcrumbElement = component.updateView(context);

        const firstCommandReference = {
            id: { guid: '1' },
            name: '1',
        } as ComponentFramework.EntityReference;

        context.parameters.items.records['1'].getNamedReference = jest.fn().mockReturnValueOnce(firstCommandReference);
        const breadCrumb = mount(breadcrumbElement);
        const breadcrumbNode = breadCrumb.find('.ms-Breadcrumb-itemLink').first();
        expect(breadcrumbNode.length).toEqual(1);

        breadcrumbNode.simulate('click');
        expect(context.parameters.items.openDatasetItem).toBeCalledTimes(1);
        expect(context.parameters.items.openDatasetItem).toBeCalledWith(firstCommandReference);
    });

    it('theme', async () => {
        const { component, context, container } = createComponent();
        context.parameters.Theme.raw = JSON.stringify({
            palette: {
                themePrimary: '#0078d4',
            },
        });
        act(() => {
            component.init(context);
            component.updateView(context);
        });

        expect(container).toMatchSnapshot();
    });
});

function createComponent() {
    const component = new Breadcrumb();
    const notifyOutputChanged = jest.fn();
    const context = new MockContext<IInputs>(getMockParameters());
    context.parameters.items = new MockDataSet([
        new MockEntityRecord('1', {
            [ItemColumns.DisplayName]: 'Item 1',
            [ItemColumns.Key]: 'item1',
            [ItemColumns.Clickable]: true,
        }),
        new MockEntityRecord('2', {
            [ItemColumns.DisplayName]: 'Item 2',
            [ItemColumns.Key]: 'item2',
        }),
        new MockEntityRecord('3', {
            [ItemColumns.Key]: 'item7',
            [ItemColumns.DisplayName]: 'Item 7',
            [ItemColumns.Clickable]: true,
        }),
        new MockEntityRecord('4', {
            [ItemColumns.Key]: 'item8',
            [ItemColumns.DisplayName]: 'Item 8',
            [ItemColumns.Clickable]: true,
        }),
    ]);
    const state = new MockState();
    const container = document.createElement('div');
    document.body.appendChild(container);
    return { component, context, container, notifyOutputChanged, state };
}
