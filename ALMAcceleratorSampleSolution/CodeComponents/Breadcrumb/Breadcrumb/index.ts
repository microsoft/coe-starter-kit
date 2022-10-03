import * as React from 'react';
import { IInputs, IOutputs } from './generated/ManifestTypes';
import { CanvasBreadcrumb } from './components/CanvasBreadcrumb';
import { InputEvents, ManifestPropertyNames } from './ManifestConstants';
import { IBreadcrumbProps, ICustomBreadcrumbItem } from './components/components.types';
import { ContextEx } from './ContextExtended';
import { getItemsFromDataset } from './components/DatasetMapping';

export class Breadcrumb implements ComponentFramework.ReactControl<IInputs, IOutputs> {
    context: ComponentFramework.Context<IInputs>;
    inputEvent?: string | null;
    items: ICustomBreadcrumbItem[];
    focusKey = '';
    public init(context: ComponentFramework.Context<IInputs>): void {
        this.context = context;
        this.context.mode.trackContainerResize(true);
    }

    public updateView(context: ComponentFramework.Context<IInputs>): React.ReactElement {
        const inputEvent = this.context.parameters.InputEvent.raw;
        const eventChanged = inputEvent && this.inputEvent !== inputEvent;

        if (eventChanged && inputEvent.startsWith(InputEvents.SetFocus)) {
            // Simulate SetFocus until this is unlocked by the platform
            this.focusKey = inputEvent;
        }

        const dataset = context.parameters.items;
        const datasetChanged = context.updatedProperties.indexOf(ManifestPropertyNames.dataset) > -1 || !this.items;

        if (datasetChanged) {
            this.items = getItemsFromDataset(dataset);
        }

        const ariaLabel = context.parameters?.AccessibilityLabel.raw ?? '';
        let maxDisplayedItems = context.parameters?.MaxDisplayedItems.raw ?? this.items.length;
        maxDisplayedItems =
            maxDisplayedItems === 0 || maxDisplayedItems > this.items.length ? this.items.length : maxDisplayedItems;

        // If overflowIndex is greater than total item then setting to Zero to avoid breaking of control.
        let overflowIndex = context.parameters?.OverflowIndex.raw ?? 0;
        overflowIndex = overflowIndex >= maxDisplayedItems ? 0 : overflowIndex;

        // The test harness provides width/height as strings
        const allocatedWidth = parseInt(context.mode.allocatedWidth as unknown as string);
        const allocatedHeight = parseInt(context.mode.allocatedHeight as unknown as string);
        const tabIndex = (context as unknown as ContextEx).accessibility?.assignedTabIndex ?? undefined;

        const props: IBreadcrumbProps = {
            width: allocatedWidth,
            height: allocatedHeight,
            items: this.items,
            onSelected: this.onSelect,
            themeJSON: context.parameters?.Theme.raw ?? '',
            setFocus: this.focusKey,
            tabIndex: tabIndex,
            ariaLabel: ariaLabel,
            maxDisplayedItems: maxDisplayedItems,
            overflowIndex: overflowIndex,
        };
        return React.createElement(CanvasBreadcrumb, props);
    }

    public getOutputs(): IOutputs {
        return {} as IOutputs;
    }

    onSelect = (item?: ICustomBreadcrumbItem): void => {
        if (item && item.data) {
            this.context.parameters.items.openDatasetItem(item.data.getNamedReference());
        }
    };

    public destroy(): void {
        // noop
    }
}
