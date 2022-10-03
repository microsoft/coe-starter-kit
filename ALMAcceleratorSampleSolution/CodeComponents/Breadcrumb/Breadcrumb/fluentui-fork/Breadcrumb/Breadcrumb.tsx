/* eslint-disable */
/* istanbul ignore file */
import * as React from 'react';
import { styled } from '@fluentui/react';
import { BreadcrumbBase } from './Breadcrumb.base';
import { getStyles } from './Breadcrumb.styles';
import type { IBreadcrumbProps, IBreadcrumbStyleProps, IBreadcrumbStyles } from './Breadcrumb.types';

export const Breadcrumb: React.FunctionComponent<IBreadcrumbProps> = styled<
  IBreadcrumbProps,
  IBreadcrumbStyleProps,
  IBreadcrumbStyles
>(BreadcrumbBase, getStyles, undefined, { scope: 'Breadcrumb' });
