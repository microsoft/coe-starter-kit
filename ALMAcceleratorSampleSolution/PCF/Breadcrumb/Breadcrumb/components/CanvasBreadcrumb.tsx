import * as React from 'react';
import { IBreadcrumbItem, ThemeProvider, createTheme, IPartialTheme, IFocusZoneProps } from '@fluentui/react';
import { Breadcrumb as CustomBreadcrumb } from '../fluentui-fork/Breadcrumb/Breadcrumb';
import { IBreadcrumbProps } from './components.types';
import { getBreadcrumbItems } from './DatasetMapping';
import { useAsync } from '@fluentui/react-hooks';

export const CanvasBreadcrumb = React.memo((props: IBreadcrumbProps): React.ReactElement => {
    const { items, themeJSON, onSelected, setFocus, ariaLabel, tabIndex, maxDisplayedItems, overflowIndex } = props;
    const theme = React.useMemo(() => {
        try {
            return themeJSON ? createTheme(JSON.parse(themeJSON) as IPartialTheme) : undefined;
        } catch (ex) {
            /* istanbul ignore next */
            console.error('Cannot parse theme', ex);
        }
    }, [themeJSON]);

    const rootRef = React.useRef<HTMLDivElement>(null);
    const async = useAsync();
    React.useEffect(() => {
        if (setFocus && setFocus !== '' && rootRef) {
            async.requestAnimationFrame(() => {
                // We can't call focus() on the imperative componentRef because of a bug in ResizeGroup
                // that causes the componentRef.current to be nulled
                // See https://github.com/microsoft/fluentui/issues/22844
                //(componentRef as React.RefObject<IBreadcrumb>).current?.focus();
                const buttons = (rootRef.current as HTMLElement).getElementsByTagName('button');
                if (buttons && buttons.length > 0) {
                    buttons[0].focus();
                }
            });
        }
    }, [setFocus, rootRef, async]);

    const focusZoneProps = React.useMemo(() => {
        return {
            tabIndex: tabIndex,
            shouldFocusInnerElementWhenReceivedFocus: true,
            handleTabKey: 1,
        } as IFocusZoneProps;
    }, [tabIndex]);

    const onClick = React.useCallback(
        (ev?: React.MouseEvent<HTMLElement, MouseEvent>, item?: IBreadcrumbItem) => {
            const selectedItem = item && items.find((i) => i.key === item?.key);
            if (selectedItem) onSelected(selectedItem);
        },
        [items, onSelected],
    );

    const breadcrumbItems: IBreadcrumbItem[] = getBreadcrumbItems(items, onClick);

    return (
        <ThemeProvider applyTo="none" theme={theme} ref={rootRef}>
            <CustomBreadcrumb
                items={breadcrumbItems}
                focusZoneProps={focusZoneProps}
                maxDisplayedItems={maxDisplayedItems}
                aria-label={ariaLabel}
                overflowIndex={overflowIndex}
            />
        </ThemeProvider>
    );
});
CanvasBreadcrumb.displayName = 'CanvasBreadCrumb';
