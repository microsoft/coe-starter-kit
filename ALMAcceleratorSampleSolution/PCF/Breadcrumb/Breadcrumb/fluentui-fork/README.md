# Fluent UI Fork

This folder contains forked components of the fluentui library.

## Why custom versions?

The following issues are addressed with this custom set of components:

### ISSUE 1: FocusZone positive tabindex

Canvas Apps set positive tabindexes for it's components, making it important to use positive tabindexes for fluent ui components otherwise the tab order will be inconsistent - DOM order vs explicit positive tabindex.

The FocusZone component assumes that all components will not use positive tabindexes and sets the default tabindex to zero when impelementing the floating tabindex pattern.
The forked version, setts the tabindex provided to the component props.

The Breadcrumb, CommandBar & Pivot components do not provide a facility to provide a custom implementation of the focus zone, so it is forked to use the custom focus zone that allows setting positive tabindexes.
