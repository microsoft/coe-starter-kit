// This is undocumented - but needed since canvas apps sets non-zero tabindexes
// so we must use the tabindex provided by the context for accessibility purposes
export interface ContextEx {
    accessibility: {
        assignedTabIndex: number;
        assignedTooltip?: string;
    };
}
