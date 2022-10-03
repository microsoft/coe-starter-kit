export interface ICustomBreadcrumbItem {
    id: string;
    text: string;
    key: string;
    clickable?: boolean;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    data: any;
}

export interface IBreadcrumbProps {
    width?: number;
    height?: number;
    items: ICustomBreadcrumbItem[];
    onSelected: (item: ICustomBreadcrumbItem) => void;
    themeJSON?: string;
    ariaLabel?: string;
    setFocus?: string;
    tabIndex?: number;
    maxDisplayedItems?: number;
    overflowIndex?: number;
}
