/* istanbul ignore file */

export class MockDataSet implements ComponentFramework.PropertyTypes.DataSet {
    private rows: MockEntityRecord[] = [];
    constructor(rows: MockEntityRecord[]) {
        this.rows = rows;
        this.records = {};
        rows.forEach((r) => (this.records[r.id] = r));
        this.sortedRecordIds = rows.map((r) => r.id);
        this.paging = {
            setPageSize: jest.fn(),
            totalResultCount: 0,
            firstPageNumber: 0,
            hasNextPage: false,
            hasPreviousPage: false,
            lastPageNumber: 0,
            loadExactPage: jest.fn(),
            loadNextPage: jest.fn(),
            loadPreviousPage: jest.fn(),
            pageSize: 0,
            reset: jest.fn(),
        };
    }
    addColumn = jest.fn();
    columns: ComponentFramework.PropertyHelper.DataSetApi.Column[] = [];
    error: boolean;
    errorMessage: string;
    filtering: ComponentFramework.PropertyHelper.DataSetApi.Filtering;
    linking: ComponentFramework.PropertyHelper.DataSetApi.Linking;
    loading: boolean;
    paging: ComponentFramework.PropertyHelper.DataSetApi.Paging;
    records: {
        [id: string]: ComponentFramework.PropertyHelper.DataSetApi.EntityRecord;
    };
    sortedRecordIds: string[];
    sorting: ComponentFramework.PropertyHelper.DataSetApi.SortStatus[];
    clearSelectedRecordIds = jest.fn();
    getSelectedRecordIds = jest.fn();
    getTargetEntityType = jest.fn();
    getTitle = jest.fn();
    getViewId = jest.fn();
    openDatasetItem = jest.fn();
    refresh = jest.fn();
    setSelectedRecordIds = jest.fn();
}

export class MockColumn implements ComponentFramework.PropertyHelper.DataSetApi.Column {
    name: string;
    displayName: string;
    dataType!: string;
    alias!: string;
    order!: number;
    visualSizeFactor!: number;
    isHidden?: boolean | undefined;
    isPrimary?: boolean | undefined;
    disableSorting?: boolean | undefined;
    constructor(name: string, displayName: string) {
        this.name = name;
        this.displayName = displayName;
    }
}

type valueType =
    | string
    | number
    | boolean
    | Date
    | number[]
    | ComponentFramework.EntityReference
    | ComponentFramework.EntityReference[]
    | ComponentFramework.LookupValue
    | ComponentFramework.LookupValue[];

export class MockEntityRecord implements ComponentFramework.PropertyHelper.DataSetApi.EntityRecord {
    values: Record<string, valueType>;
    id: string;
    constructor(id: string, values: Record<string, valueType>) {
        this.values = values;
        this.id = id;
    }
    getFormattedValue(columnName: string): string {
        return this.values[columnName] as string;
    }
    getRecordId(): string {
        return this.id;
    }
    getValue(columnName: string): valueType {
        return this.values[columnName];
    }
    getNamedReference = jest.fn();
}

export function getData(records: ComponentFramework.PropertyHelper.DataSetApi.EntityRecord[]): {
    sortedRecordIds: string[];
    records: Record<string, ComponentFramework.PropertyHelper.DataSetApi.EntityRecord>;
} {
    const sortedRecordIds: string[] = [];
    const recordsOut: Record<string, ComponentFramework.PropertyHelper.DataSetApi.EntityRecord> = {};

    for (const r of records) {
        sortedRecordIds.push(r.getRecordId());
        recordsOut[r.getRecordId()] = r;
    }
    return {
        sortedRecordIds: sortedRecordIds,
        records: recordsOut,
    };
}
