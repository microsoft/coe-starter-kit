# Implementation Guide: Enhanced Connection References and Environment Variables Features

## Overview

This document provides comprehensive guidance on implementing the enhancement requests for Connection References and Environment Variables in the CoE Starter Kit Power Platform Admin View.

**Issue Reference**: [Feature Request - Connection References and Environment variables should be fully featured](https://github.com/microsoft/coe-starter-kit/issues/)

## Current State Analysis

### Connection References (admin_ConnectionReference)
The CoE Starter Kit currently has:
- ✅ Entity: `admin_ConnectionReference` with basic tracking
- ✅ Data collection flows that inventory connection references
- ⚠️ Limited visibility - currently accessible only through Flow relationships
- ⚠️ Display Name shows connector service name, not the actual connection reference display name
- ⚠️ Owner information not accurately reflected (shows service account)
- ❌ No direct relationship to Solutions shown in views

### Connection Reference Identity (admin_ConnectionReferenceIdentity)  
- ✅ Entity: `admin_ConnectionReferenceIdentity` for tracking connection identities
- ✅ Already has a dedicated menu item in the Users group (line 69-73 in AppModuleSiteMap.xml)
- ✅ Includes fields for connector, environment, account name, and creator tracking

### Environment Variables
- ❌ No dedicated entity for tracking Environment Variable Definitions
- ❌ Not currently inventoried by the CoE Starter Kit
- ❌ No menu item in Power Platform Admin View
- ❌ No owner reassignment capability

## Requirements Summary

### Connection References
1. ✅ **Menu Item**: Add dedicated menu item (high priority - improves discoverability)
2. ✅ **Display Names**: Show actual connection reference display name (high priority - critical usability)
3. ✅ **Owner Information**: Show correct owner from Dataverse (high priority - needed for offboarding)
4. ✅ **Solution Relationship**: Display which solution contains the connection reference (medium priority)

### Environment Variables
1. ✅ **Menu Item**: Add dedicated menu item (high priority)
2. ✅ **Entity Creation**: Create tracking entity for environment variable definitions (high priority)
3. ✅ **Display Fields**: Show DisplayName, SchemaName, Owner, and other metadata (high priority)
4. ✅ **Solution Relationship**: Display which solution contains the variable (medium priority)
5. ✅ **Owner Reassignment**: Enable owner changes (medium priority - needed for offboarding)

## Implementation Steps

### Phase 1: Enhanced Connection References (Estimated: 2-3 days)

#### Step 1.1: Add Missing Fields to admin_ConnectionReference Entity
The entity already exists but needs additional fields to track solution relationships:

```xml
<!-- Add to Entity.xml -->
<attribute PhysicalName="admin_Solution">
  <Type>lookup</Type>
  <Name>admin_solution</Name>
  <LogicalName>admin_solution</LogicalName>
  <RequiredLevel>none</RequiredLevel>
  <DisplayMask>ValidForAdvancedFind|ValidForForm|ValidForGrid</DisplayMask>
  <!-- Additional configuration for lookup to admin_Solution -->
</attribute>

<attribute PhysicalName="admin_ActualOwner">
  <Type>lookup</Type>
  <Name>admin_actualowner</Name>
  <LogicalName>admin_actualowner</LogicalName>
  <RequiredLevel>none</RequiredLevel>
  <DisplayMask>ValidForAdvancedFind|ValidForForm|ValidForGrid</DisplayMask>
  <!-- Lookup to systemuser to track actual owner from Dataverse -->
</attribute>
```

**File Location**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ConnectionReference/Entity.xml`

#### Step 1.2: Create Enhanced View for Connection References
Create a new "Active Connection References" view that shows:
- Display Name (actual connection reference name, not connector service name)
- Connector (related connector)
- Actual Owner (from Dataverse)
- Solution (which solution it belongs to)
- Environment
- Created On
- Modified On

**File Location**: Create new file in `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ConnectionReference/SavedQueries/`

```xml
<?xml version="1.0" encoding="utf-8"?>
<savedqueries xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <savedquery>
    <IsCustomizable>1</IsCustomizable>
    <CanBeDeleted>1</CanBeDeleted>
    <isquickfindquery>0</isquickfindquery>
    <isprivate>0</isprivate>
    <isdefault>1</isdefault>
    <savedqueryid>{NEW-GUID-HERE}</savedqueryid>
    <layoutxml>
      <grid name="resultset" jump="admin_displayname" select="1" icon="1" preview="1">
        <row name="result" id="admin_connectionreferenceid">
          <cell name="admin_displayname" width="200" />
          <cell name="admin_connector" width="150" />
          <cell name="admin_actualowner" width="150" />
          <cell name="admin_solution" width="150" />
          <cell name="admin_environment" width="150" />
          <cell name="createdon" width="125" />
        </row>
      </grid>
    </layoutxml>
    <querytype>0</querytype>
    <fetchxml>
      <fetch version="1.0" mapping="logical">
        <entity name="admin_connectionreference">
          <attribute name="admin_connectionreferenceid" />
          <attribute name="admin_displayname" />
          <attribute name="admin_connector" />
          <attribute name="admin_actualowner" />
          <attribute name="admin_solution" />
          <attribute name="createdon" />
          <order attribute="admin_displayname" descending="false" />
          <filter type="and">
            <condition attribute="statecode" operator="eq" value="0" />
          </filter>
          <link-entity name="admin_connector" to="admin_connector" from="admin_connectorid" link-type="outer" alias="connector">
            <attribute name="admin_displayname" />
          </link-entity>
          <link-entity name="admin_solution" to="admin_solution" from="admin_solutionid" link-type="outer" alias="solution">
            <attribute name="admin_displayname" />
          </link-entity>
        </entity>
      </fetch>
    </fetchxml>
    <IntroducedVersion>1.0</IntroducedVersion>
    <LocalizedNames>
      <LocalizedName description="Active Connection References" languagecode="1033" />
    </LocalizedNames>
  </savedquery>
</savedqueries>
```

#### Step 1.3: Add Connection References Menu Item to Sitemap
Update the Power Platform Admin View sitemap to add a dedicated menu item for Connection References in the "Monitor" group.

**File Location**: `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModuleSiteMaps/admin_PowerPlatformAdminView/AppModuleSiteMap.xml`

Add after line 29 (after Connectors SubArea):
```xml
<SubArea Id="NewSubArea_ConnectionReferences" 
         VectorIcon="/WebResources/admin_ConnectorIcon" 
         Icon="/WebResources/admin_ConnectorIcon" 
         Entity="admin_connectionreference" 
         Client="All,Outlook,OutlookLaptopClient,OutlookWorkstationClient,Web" 
         AvailableOffline="true" 
         PassParams="false" 
         Sku="All,OnPremise,Live,SPLA">
  <Titles>
    <Title LCID="1033" Title="Connection References" />
  </Titles>
</SubArea>
```

#### Step 1.4: Update Inventory Flows
Update the existing inventory flows to capture:
- Actual owner information from the connectionreference entity in Dataverse (not just the flow creator)
- Solution relationship (which solution the connection reference belongs to)
- Proper display name from the connectionreference metadata

**Files to Update**:
- Look for flows in `CenterofExcellenceCoreComponents/SolutionPackage/src/Workflows/` that handle connection reference inventory
- These typically start with `AdminSyncTemplatev4` or similar naming

**Key API Calls Needed**:
```
GET https://api.powerplatform.com/environments/{environmentId}/connectionReferences?api-version=2020-10-01
```

The response includes:
- `properties.displayName` - the actual display name
- `properties.createdBy` - the actual creator
- `properties.modifiedBy` - the actual modifier  
- `properties.connectionReferenceLogicalName` - the schema name
- Solution information through solutionid property

#### Step 1.5: Update Forms
Update the main form for Connection References to include the new fields prominently.

**File Location**: `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_ConnectionReference/FormXml/main/`

### Phase 2: Environment Variables Implementation (Estimated: 3-5 days)

#### Step 2.1: Create admin_EnvironmentVariableDefinition Entity
Create a new custom entity to track Environment Variable Definitions.

**File Location**: Create new directory `CenterofExcellenceCoreComponents/SolutionPackage/src/Entities/admin_EnvironmentVariableDefinition/`

**Entity Structure**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<Entity>
  <Name LocalizedName="Environment Variable Definition" OriginalName="Environment Variable Definition">admin_EnvironmentVariableDefinition</Name>
  <EntityInfo>
    <entity Name="admin_EnvironmentVariableDefinition">
      <LocalizedNames>
        <LocalizedName description="Environment Variable Definition" languagecode="1033" />
      </LocalizedNames>
      <LocalizedCollectionNames>
        <LocalizedCollectionName description="Environment Variable Definitions" languagecode="1033" />
      </LocalizedCollectionNames>
      <Descriptions>
        <Description description="Tracks environment variable definitions across environments for governance" languagecode="1033" />
      </Descriptions>
      <attributes>
        <!-- Primary Key -->
        <attribute PhysicalName="admin_EnvironmentVariableDefinitionId">
          <Type>primarykey</Type>
          <Name>admin_environmentvariabledefinitionid</Name>
          <!-- Standard primary key configuration -->
        </attribute>
        
        <!-- Display Name (Primary Name Field) -->
        <attribute PhysicalName="admin_DisplayName">
          <Type>nvarchar</Type>
          <Name>admin_displayname</Name>
          <LogicalName>admin_displayname</LogicalName>
          <RequiredLevel>required</RequiredLevel>
          <DisplayMask>PrimaryName|ValidForAdvancedFind|ValidForForm|ValidForGrid|RequiredForForm</DisplayMask>
          <MaxLength>100</MaxLength>
          <!-- Display name from Dataverse -->
        </attribute>
        
        <!-- Schema Name -->
        <attribute PhysicalName="admin_SchemaName">
          <Type>nvarchar</Type>
          <Name>admin_schemaname</Name>
          <MaxLength>100</MaxLength>
          <!-- Logical/Schema name -->
        </attribute>
        
        <!-- Type (String, Number, JSON, Data Source, etc.) -->
        <attribute PhysicalName="admin_Type">
          <Type>picklist</Type>
          <Name>admin_type</Name>
          <!-- Option set for different types -->
        </attribute>
        
        <!-- Current Value -->
        <attribute PhysicalName="admin_CurrentValue">
          <Type>nvarchar</Type>
          <Name>admin_currentvalue</Name>
          <MaxLength>2000</MaxLength>
          <!-- Current value (from environmentvariablevalue table) -->
        </attribute>
        
        <!-- Default Value -->
        <attribute PhysicalName="admin_DefaultValue">
          <Type>nvarchar</Type>
          <Name>admin_defaultvalue</Name>
          <MaxLength>2000</MaxLength>
          <!-- Default value defined in the definition -->
        </attribute>
        
        <!-- Description -->
        <attribute PhysicalName="admin_Description">
          <Type>ntext</Type>
          <Name>admin_description</Name>
          <MaxLength>2000</MaxLength>
        </attribute>
        
        <!-- Environment Lookup -->
        <attribute PhysicalName="admin_Environment">
          <Type>lookup</Type>
          <Name>admin_environment</Name>
          <!-- Link to admin_Environment -->
        </attribute>
        
        <!-- Solution Lookup -->
        <attribute PhysicalName="admin_Solution">
          <Type>lookup</Type>
          <Name>admin_solution</Name>
          <!-- Link to admin_Solution -->
        </attribute>
        
        <!-- Actual Owner (from Dataverse) -->
        <attribute PhysicalName="admin_ActualOwner">
          <Type>lookup</Type>
          <Name>admin_actualowner</Name>
          <!-- Link to systemuser -->
        </attribute>
        
        <!-- Dataverse ID (for reference) -->
        <attribute PhysicalName="admin_DataverseId">
          <Type>nvarchar</Type>
          <Name>admin_dataverseid</Name>
          <MaxLength>100</MaxLength>
          <!-- The actual environmentvariabledefinitionid from Dataverse -->
        </attribute>
        
        <!-- Is Managed -->
        <attribute PhysicalName="admin_IsManaged">
          <Type>bit</Type>
          <Name>admin_ismanaged</Name>
          <!-- Whether it's from a managed solution -->
        </attribute>
        
        <!-- Standard Owner field for reassignment -->
        <attribute PhysicalName="OwnerId">
          <Type>owner</Type>
          <Name>ownerid</Name>
          <!-- Standard ownership for reassignment capability -->
        </attribute>
      </attributes>
      
      <OwnershipTypeMask>UserOwned</OwnershipTypeMask>
      <!-- Additional entity configuration -->
    </entity>
  </EntityInfo>
</Entity>
```

#### Step 2.2: Create Views for Environment Variables
Create standard views:

1. **Active Environment Variables** (default view)
2. **Environment Variables by Solution**
3. **Environment Variables by Owner**
4. **Quick Find Active Environment Variables**

**Example Active View**:
```xml
<savedquery>
  <layoutxml>
    <grid name="resultset" jump="admin_displayname" select="1" icon="1" preview="1">
      <row name="result" id="admin_environmentvariabledefinitionid">
        <cell name="admin_displayname" width="200" />
        <cell name="admin_schemaname" width="200" />
        <cell name="admin_type" width="100" />
        <cell name="admin_actualowner" width="150" />
        <cell name="admin_solution" width="150" />
        <cell name="admin_environment" width="150" />
        <cell name="admin_currentvalue" width="200" />
      </row>
    </grid>
  </layoutxml>
  <fetchxml>
    <fetch version="1.0" mapping="logical">
      <entity name="admin_environmentvariabledefinition">
        <attribute name="admin_environmentvariabledefinitionid" />
        <attribute name="admin_displayname" />
        <attribute name="admin_schemaname" />
        <attribute name="admin_type" />
        <attribute name="admin_actualowner" />
        <attribute name="admin_solution" />
        <attribute name="admin_currentvalue" />
        <order attribute="admin_displayname" descending="false" />
        <filter type="and">
          <condition attribute="statecode" operator="eq" value="0" />
        </filter>
      </entity>
    </fetch>
  </fetchxml>
  <LocalizedNames>
    <LocalizedName description="Active Environment Variables" languagecode="1033" />
  </LocalizedNames>
</savedquery>
```

#### Step 2.3: Create Forms
Create main form, quick create form, and card form for the new entity.

**Key Tabs**:
1. **General** - Display Name, Schema Name, Type, Description
2. **Values** - Current Value, Default Value
3. **Relationships** - Environment, Solution, Owner
4. **Advanced** - Dataverse ID, Is Managed, Created/Modified info

#### Step 2.4: Add Environment Variables Menu Item to Sitemap
Add to the "Monitor" group in the Power Platform Admin View sitemap.

**File Location**: `CenterofExcellenceCoreComponents/SolutionPackage/src/AppModuleSiteMaps/admin_PowerPlatformAdminView/AppModuleSiteMap.xml`

Add after the Connection References SubArea (from Step 1.3):
```xml
<SubArea Id="NewSubArea_EnvironmentVariables" 
         VectorIcon="/WebResources/admin_EnvironmentVariableIcon" 
         Icon="/WebResources/admin_EnvironmentVariableIcon" 
         Entity="admin_environmentvariabledefinition" 
         Client="All,Outlook,OutlookLaptopClient,OutlookWorkstationClient,Web" 
         AvailableOffline="true" 
         PassParams="false" 
         Sku="All,OnPremise,Live,SPLA">
  <Titles>
    <Title LCID="1033" Title="Environment Variables" />
  </Titles>
</SubArea>
```

#### Step 2.5: Create Inventory Flow for Environment Variables
Create a new cloud flow to inventory environment variable definitions.

**Flow Name**: `AdminSyncTemplatev4 - Environment Variables`

**Key Steps**:
1. **Trigger**: Scheduled (runs daily, or can be triggered by the main sync flow)
2. **Get Environments**: List all environments from the inventory
3. **For Each Environment**:
   a. Call Dataverse API to get environmentvariabledefinition records
   b. For each definition, get associated environmentvariablevalue (current value)
   c. Map to admin_EnvironmentVariableDefinition entity
   d. Upsert record in CoE environment
4. **Error Handling**: Log errors to admin_SyncFlowErrors

**API Endpoints**:
```
GET https://[orgUrl]/api/data/v9.2/environmentvariabledefinitions
GET https://[orgUrl]/api/data/v9.2/environmentvariablevalues
```

**Key OData Queries**:
```
/environmentvariabledefinitions?$select=environmentvariabledefinitionid,schemaname,displayname,type,defaultvalue,description,_ownerid_value,ismanaged&$expand=solution($select=solutionid,uniquename,friendlyname)

/environmentvariablevalues?$select=environmentvariablevalueid,value,_environmentvariabledefinitionid_value&$filter=_environmentvariabledefinitionid_value eq [GUID]
```

**Mapping**:
- `displayname` → `admin_displayname`
- `schemaname` → `admin_schemaname`
- `type` → `admin_type` (map numeric values to option set)
- `defaultvalue` → `admin_defaultvalue`
- `description` → `admin_description`
- `_ownerid_value` → `admin_actualowner` (lookup)
- Solution from expand → `admin_solution` (lookup)
- `value` from environmentvariablevalue → `admin_currentvalue`
- `ismanaged` → `admin_ismanaged`

#### Step 2.6: Owner Reassignment Configuration
The entity is created with `UserOwned` ownership type, which automatically enables owner reassignment through:
- The "Assign" button in the command bar
- Bulk reassignment workflows  
- The standard Dataverse owner reassignment UI

**Additional Considerations**:
- Create a custom button/action to reassign owners in the actual environment (not just in the CoE inventory)
- This would require calling the Dataverse API to update the owner in the source environment

### Phase 3: Testing and Documentation (Estimated: 1-2 days)

#### Step 3.1: Testing Checklist
- [ ] Connection References appear in dedicated menu item
- [ ] Connection Reference views show correct display names (not connector service names)
- [ ] Connection Reference views show actual owner (not service account)
- [ ] Connection Reference views show solution relationships
- [ ] Environment Variables appear in dedicated menu item
- [ ] Environment Variable inventory flow successfully collects data
- [ ] Environment Variable views show all required fields
- [ ] Owner reassignment works for both Connection References and Environment Variables
- [ ] Solution relationships are correctly displayed
- [ ] Quick Find works for both entities
- [ ] Forms display all information correctly
- [ ] Performance is acceptable with large datasets

#### Step 3.2: Documentation Updates
Update the following documentation:
- **Setup Guide**: Add steps for enabling Environment Variable inventory
- **User Guide**: Document the new Connection References and Environment Variables features
- **API Reference**: Document any new environment variables or configuration options
- **Release Notes**: Add details about the new features

## Technical Considerations

### Data Model Relationships

```
admin_Solution
    ↓ (1:N)
admin_ConnectionReference
    ↓ (N:1)
admin_Connector

admin_Solution  
    ↓ (1:N)
admin_EnvironmentVariableDefinition
    
admin_Environment
    ↓ (1:N)
admin_ConnectionReference, admin_EnvironmentVariableDefinition
```

### Performance Optimization
- Add indexes on commonly filtered/sorted fields (display name, solution, owner)
- Consider pagination in inventory flows for large environments
- Implement incremental sync (only update changed records)

### Security
- Respect existing CoE Starter Kit security roles
- Environment Variables may contain sensitive data - ensure proper field-level security
- Consider masking sensitive values in views (show only [VALUE SET] indicator)

### API Limits
- Connection Reference and Environment Variable APIs are subject to Dataverse API limits
- Implement retry logic with exponential backoff
- Consider batching operations where possible

## Migration Path for Existing Implementations

For organizations already using the CoE Starter Kit:

1. **Backup**: Export existing admin_ConnectionReference data
2. **Schema Update**: Apply new fields to admin_ConnectionReference entity
3. **Data Migration**: Run inventory flows to populate new fields
4. **Sitemap Update**: Merge sitemap changes (existing customizations preserved)
5. **New Entity**: Deploy admin_EnvironmentVariableDefinition entity
6. **Initial Inventory**: Run new Environment Variables inventory flow
7. **Validation**: Verify data accuracy and completeness
8. **Go Live**: Enable new menu items for users

## Alternative Approaches Considered

### Alternative 1: Use Out-of-Box Dataverse Tables
**Pros**: No custom entities needed, direct access to source data
**Cons**: 
- Requires Dataverse licenses for all admins
- No cross-environment aggregation
- Cannot add custom fields for CoE governance
- **Decision**: Not recommended - goes against CoE Starter Kit architecture

### Alternative 2: Use Power BI for Visualization Only
**Pros**: Rich visualization, no model-driven app changes needed
**Cons**:
- No owner reassignment capability
- No integration with other CoE features
- Limited filtering and interaction
- **Decision**: Complementary approach, but doesn't meet all requirements

### Alternative 3: External Database with Power Apps Portal
**Pros**: Fully customizable, separate from Dataverse limits
**Cons**:
- Significantly more complex infrastructure
- Additional licensing costs
- Security and authentication complexity
- **Decision**: Not recommended - over-engineered for the requirements

## Success Criteria

✅ **Connection References**:
- Dedicated menu item in Power Platform Admin View
- Display actual connection reference names (not connector service names)  
- Show correct owner information (not always service account)
- Display solution relationships

✅ **Environment Variables**:
- Dedicated menu item in Power Platform Admin View
- Full inventory of environment variable definitions across all environments
- Display name, schema name, owner, type, current value, default value, solution
- Owner reassignment capability enabled

✅ **General**:
- Solution follows CoE Starter Kit patterns and conventions
- Documentation complete and clear
- Performance acceptable with large datasets (100+ environments, 1000+ variables)
- Backward compatible with existing CoE Starter Kit deployments

## Resources

### Microsoft Documentation
- [Environment Variable Definitions](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/environmentvariables)
- [Connection References](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/create-connection-reference)
- [CoE Starter Kit Documentation](https://learn.microsoft.com/en-us/power-platform/guidance/coe/starter-kit)
- [Dataverse Web API](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview)

### Community Resources
- [CoE Starter Kit GitHub](https://github.com/microsoft/coe-starter-kit)
- [Power Platform Community](https://powerusers.microsoft.com/)

## Support and Contribution

This is a community-driven enhancement. Contributions are welcome!

### How to Contribute
1. Fork the repository
2. Create a feature branch
3. Implement changes following this guide
4. Test thoroughly
5. Submit a pull request with:
   - Description of changes
   - Screenshots of new UI elements
   - Test results
   - Documentation updates

### Getting Help
- [GitHub Issues](https://github.com/microsoft/coe-starter-kit/issues)
- [Power Platform Community Forums](https://powerusers.microsoft.com/t5/Power-Apps-Governance-and/bd-p/Admin_PowerApps)

---

**Last Updated**: December 2024
**Version**: 1.0
**Status**: Draft Implementation Guide
