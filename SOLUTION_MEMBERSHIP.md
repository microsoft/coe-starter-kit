# Solution Membership for Desktop Flows and Power Virtual Agents

## Overview

This document explains how to determine solution membership for Desktop Flows (RPA) and Power Virtual Agents (PVA/Copilot bots) in the CoE Starter Kit.

## Background

The CoE Starter Kit tracks various Power Platform resources in Dataverse tables:
- Canvas Apps (`admin_App`)
- Cloud Flows (`admin_Flow`)  
- Desktop Flows (`admin_RPA`)
- Power Virtual Agents (`admin_PVA`)
- Solutions (`admin_Solution`)

Prior to version 4.51, only Canvas Apps and Cloud Flows had many-to-many relationships with Solutions, enabling users to see which solution(s) a specific app or flow belongs to.

## What Changed

Starting with version 4.51, the CoE Starter Kit now includes:

### New Many-to-Many Relationships

1. **Desktop Flows to Solutions** (`admin_PPSolution_DesktopFlow`)
   - Links `admin_RPA` table to `admin_Solution` table
   - Intersection table: `admin_PPSolution_DesktopFlow_Table`

2. **PVA Bots to Solutions** (`admin_PPSolution_PVA`)
   - Links `admin_PVA` table to `admin_Solution` table
   - Intersection table: `admin_PPSolution_PVA_Table`

## How Solution Membership is Determined

Solution membership is populated through the inventory sync flows by querying the Power Platform APIs:

### For Desktop Flows

Desktop Flows are stored in Dataverse as `workflow` records with `category = 6`. The sync flow:

1. Queries the `workflows` table for Desktop Flows
2. For each Desktop Flow, queries the `solutioncomponent` table to find which solution(s) contain it
3. Creates records in the `admin_PPSolution_DesktopFlow_Table` intersection table to link Desktop Flows to their Solutions

### For Power Virtual Agents

PVA bots are stored in Dataverse as `bot` records. The sync flow:

1. Queries the `bots` table for PVA/Copilot bots
2. For each bot, queries the `solutioncomponent` table to find which solution(s) contain it
3. Creates records in the `admin_PPSolution_PVA_Table` intersection table to link PVA bots to their Solutions

### Solution Component Types

The `solutioncomponent` table uses component type codes to identify different types of resources:
- Component Type 29: Cloud Flows (workflows with category 0-5)
- Component Type 300: Canvas Apps
- Component Type 29: Desktop Flows (workflows with category 6)
- Component Type 380: Bots (PVA/Copilot)

## Querying Solution Membership

### Using Dataverse API/OData

**Get all solutions for a Desktop Flow:**
```
GET [org]/api/data/v9.2/admin_rpas([desktop-flow-id])?$expand=admin_PPSolution_DesktopFlow
```

**Get all Desktop Flows in a solution:**
```
GET [org]/api/data/v9.2/admin_solutions([solution-id])?$expand=admin_PPSolution_DesktopFlow
```

**Get all solutions for a PVA bot:**
```
GET [org]/api/data/v9.2/admin_pvas([pva-id])?$expand=admin_PPSolution_PVA
```

**Get all PVA bots in a solution:**
```
GET [org]/api/data/v9.2/admin_solutions([solution-id])?$expand=admin_PPSolution_PVA
```

### Using Power Fx (Canvas Apps)

**Get solutions for a Desktop Flow:**
```powerquery
LookUp(
    'Desktop flows',
    admin_rpaid = [your-desktop-flow-id]
).'Solutions (admin_PPSolution_DesktopFlow)'
```

**Get solutions for a PVA bot:**
```powerquery
LookUp(
    PVAs,
    admin_pvaid = [your-pva-id]
).'Solutions (admin_PPSolution_PVA)'
```

## Upgrade Notes

When upgrading from version 4.50 or earlier:

1. The new relationships will be created automatically when you import the updated solution
2. Run a full inventory sync to populate the solution membership data
3. Existing Desktop Flows and PVA bots will be linked to their solutions during the next sync

## Technical Implementation Details

### Schema Changes

The following XML relationship definitions were added:

**admin_RPA.xml:**
```xml
<EntityRelationship Name="admin_PPSolution_DesktopFlow">
  <EntityRelationshipType>ManyToMany</EntityRelationshipType>
  <FirstEntityName>admin_RPA</FirstEntityName>
  <SecondEntityName>admin_Solution</SecondEntityName>
  <IntersectEntityName>admin_PPSolution_DesktopFlow_Table</IntersectEntityName>
</EntityRelationship>
```

**admin_PVA.xml:**
```xml
<EntityRelationship Name="admin_PPSolution_PVA">
  <EntityRelationshipType>ManyToMany</EntityRelationshipType>
  <FirstEntityName>admin_PVA</FirstEntityName>
  <SecondEntityName>admin_Solution</SecondEntityName>
  <IntersectEntityName>admin_PPSolution_PVA_Table</IntersectEntityName>
</EntityRelationship>
```

### Flow Updates Required

The solution membership relationships are populated by the **CLEANUPHELPER-SolutionObjects** flow, which runs after the solution inventory sync. This flow needs to be updated to handle Desktop Flows and PVA bots.

#### Current Implementation (Apps and Flows)

The CLEANUPHELPER-SolutionObjects flow currently:

1. Queries `solutioncomponents` table for each solution:
   - `componenttype eq 300 or componenttype eq 80` for Canvas Apps
   - `componenttype eq 29` for Cloud Flows (workflows)

2. Associates/disassociates using:
   - `AssociateEntities` operation with `admin_PPSolution_Apps` relationship
   - `AssociateEntities` operation with `admin_PPSolution_Flow` relationship

#### Required Updates

The CLEANUPHELPER-SolutionObjects flow should be enhanced to:

1. **Query Desktop Flow components:**
   ```
   GET [org]/api/data/v9.2/solutioncomponents?
     $select=objectid,componenttype
     &$filter=componenttype eq 29 and _solutionid_value eq [solution-guid]
   ```
   Then filter for Desktop Flows by checking if the workflow has `category eq 6` from the workflows table.

2. **Query PVA Bot components:**
   ```
   GET [org]/api/data/v9.2/solutioncomponents?
     $select=objectid,componenttype
     &$filter=componenttype eq 380 and _solutionid_value eq [solution-guid]
   ```

3. **Associate/disassociate Desktop Flows:**
   - Use `AssociateEntities` operation with `admin_PPSolution_DesktopFlow` relationship
   - Use `DisassociateEntities` operation with `admin_PPSolution_DesktopFlow` relationship

4. **Associate/disassociate PVA Bots:**
   - Use `AssociateEntities` operation with `admin_PPSolution_PVA` relationship
   - Use `DisassociateEntities` operation with `admin_PPSolution_PVA` relationship

#### Implementation Approach

The recommended approach is to add parallel processing scopes in CLEANUPHELPER-SolutionObjects:

1. Add "List_Solutions_DesktopFlows" action to query solution components with componenttype 380
2. Add "Select_Actual_DesktopFlows" to extract objectids
3. Add "List_Solutions_PVA" action to query solution components with componenttype 380
4. Add "Select_Actual_PVA" to extract objectids
5. Add association/disassociation logic similar to existing Apps and Flows handling

### Component Type Reference

| Resource Type | Component Type Code | Additional Filter |
|--------------|---------------------|-------------------|
| Canvas App | 300 or 80 | - |
| Cloud Flow | 29 | category ne 6 |
| Desktop Flow | 29 | category eq 6 |
| PVA Bot | 380 | - |

### Example Dataverse Queries for Solution Components

**Get all solution components for a solution:**
```
GET [org]/api/data/v9.2/solutioncomponents?
  $select=objectid,componenttype
  &$filter=_solutionid_value eq [solution-guid]
  &$orderby=componenttype
```

**Get Desktop Flow components in a solution:**
```
GET [org]/api/data/v9.2/solutioncomponents?
  $select=objectid,componenttype
  &$filter=componenttype eq 29 and _solutionid_value eq [solution-guid]
```
Note: Additional filtering needed to distinguish Desktop Flows (category 6) from Cloud Flows.

**Get PVA Bot components in a solution:**
```
GET [org]/api/data/v9.2/solutioncomponents?
  $select=objectid,componenttype
  &$filter=componenttype eq 380 and _solutionid_value eq [solution-guid]
```

## Limitations and Known Issues

1. **Unmanaged vs Managed Layers**: The solution component API returns all layers. The sync flows should filter to show only the primary/active solution association.

2. **Historical Data**: Solution membership is only tracked going forward from the point of upgrade. Historical changes are not backfilled.

3. **Performance**: Querying solution components for each Desktop Flow/PVA bot adds API calls. Consider pagination and throttling limits.

4. **Default Solutions**: Desktop Flows and PVA bots in the Default Solution may not show solution membership depending on how they were created.

## Additional Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Solution Components API Reference](https://learn.microsoft.com/power-apps/developer/data-platform/reference/entities/solutioncomponent)
- [Workflow Table Reference](https://learn.microsoft.com/power-apps/developer/data-platform/reference/entities/workflow)
- [Bot Table Reference](https://learn.microsoft.com/power-apps/developer/data-platform/reference/entities/bot)

## Support

For questions or issues related to solution membership:
1. Check existing [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
2. Create a new issue using the question template
3. Include your CoE Starter Kit version and steps to reproduce
