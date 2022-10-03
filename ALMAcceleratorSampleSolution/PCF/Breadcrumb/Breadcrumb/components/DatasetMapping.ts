import { IBreadcrumbItem } from '@fluentui/react';
import { ItemColumns } from '../ManifestConstants';
import { ICustomBreadcrumbItem } from './components.types';

export function getItemsFromDataset(dataset: ComponentFramework.PropertyTypes.DataSet): ICustomBreadcrumbItem[] {
    if (dataset.error || dataset.paging.totalResultCount === undefined) {
        // Dataset is not defined so return dummy items
        return [getDummyAction('1'), getDummyAction('2'), getDummyAction('3')];
    }
    const keyIndex: Record<string, number> = {};
    return dataset.sortedRecordIds.map((id) => {
        const record = dataset.records[id];
        // Prevent duplicate keys by appending the duplicate index
        let key = record.getValue(ItemColumns.Key) as string;
        if (keyIndex[key] !== undefined) {
            keyIndex[key]++;
            key += `_${keyIndex[key]}`;
        } else keyIndex[key] = 1;
        return {
            id: record.getRecordId(),
            key: key,
            text: record.getFormattedValue(ItemColumns.DisplayName),
            clickable: record.getValue(ItemColumns.Clickable) as boolean,
            data: record,
        } as ICustomBreadcrumbItem;
    });
}

export function getBreadcrumbItems(
    items: ICustomBreadcrumbItem[],
    onClick: (ev?: React.MouseEvent<HTMLElement>, item?: ICustomBreadcrumbItem) => void,
): IBreadcrumbItem[] {
    return items.map((item) =>
        item.clickable === false
            ? {
                  id: item.id,
                  key: item.key,
                  text: item.text,
              }
            : {
                  id: item.id,
                  key: item.key,
                  text: item.text,
                  onClick: onClick,
              },
    ) as IBreadcrumbItem[];
}

function getDummyAction(key: string): ICustomBreadcrumbItem {
    return {
        id: key,
        key: key,
        text: 'Item ' + key,
        clickable: true,
    } as ICustomBreadcrumbItem;
}
