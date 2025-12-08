# Orphaned Resources - CoE Starter Kit vs PPAC Advisor

## Question

Why are there different numbers of orphaned resources showing in the CoE Starter Kit compared to the Power Platform Admin Center (PPAC) Advisor?

## Answer

The CoE Starter Kit and PPAC Advisor may show different counts of orphaned resources due to differences in their calculation methodologies, data sources, and timing of data collection.

### Key Differences

#### 1. **Definition of "Orphaned"**

**CoE Starter Kit:**
- Uses the `cr5d5_appisorphaned` field (for Canvas Apps) and similar fields for other resource types
- Marks resources as orphaned when:
  - The owner account no longer exists in Azure AD
  - The owner has been deleted or disabled
  - The owner has left the organization
- The orphaned status is updated during sync flows (e.g., `CLEANUP HELPER - Check Deleted v4` flows)

**PPAC Advisor:**
- Uses its own internal logic to determine orphaned resources
- May have different timing for detecting when users are removed
- May use additional criteria for determining orphaned status
- Focuses on resources that need administrative attention

#### 2. **Data Synchronization Timing**

**CoE Starter Kit:**
- Orphaned status is calculated during scheduled sync flows
- Runs on a schedule configured by the admin (daily, weekly, etc.)
- There may be a delay between when a user is removed and when resources are marked as orphaned
- Depends on when the last full inventory and cleanup flows ran

**PPAC Advisor:**
- Updates in near real-time or on Microsoft's internal schedule
- May detect orphaned resources more quickly
- Data is calculated server-side by Microsoft

#### 3. **Resource Types Included**

**CoE Starter Kit:**
- Canvas Apps (`admin_App` entity)
- Cloud Flows (`admin_Flow` entity)
- Model-Driven Apps
- Custom Connectors
- AI Builder Models (`admin_AiBuilderModel` entity)
- Desktop Flows (RPA)
- Power Virtual Agents (Chatbots)
- Power Pages (Portals)
- Solutions

**PPAC Advisor:**
- May include or exclude certain resource types
- Focuses on resources that require remediation
- May filter out certain types of orphaned resources that are considered low-risk

#### 4. **Scope of Detection**

**CoE Starter Kit:**
- Scans all environments included in your CoE setup
- Depends on which environments are configured for inventory collection
- May miss environments that were excluded from sync

**PPAC Advisor:**
- Scans all environments in your tenant automatically
- Includes all environments by default
- May have broader visibility across the tenant

### Common Scenarios for Discrepancies

1. **Timing Differences**
   - User was recently removed, CoE hasn't run cleanup flows yet
   - CoE sync flows run on schedule (e.g., daily), while PPAC updates more frequently

2. **Different Filtering**
   - CoE may count all resources with missing owners
   - PPAC may only show resources requiring immediate action

3. **Resource State**
   - CoE counts may include soft-deleted resources
   - PPAC may exclude resources that are already in recycle bin

4. **Environment Coverage**
   - CoE only processes environments where sync flows have successfully run
   - PPAC has visibility to all environments in the tenant

5. **Owner Reassignment**
   - Resources that had owners reassigned may still be marked as orphaned in CoE if cleanup didn't run
   - PPAC reflects current ownership state

### Troubleshooting Steps

1. **Check CoE Sync Flow Status**
   - Verify that all sync flows are running successfully
   - Check the `Admin | Sync Template v4 (Driver)` flow run history
   - Ensure cleanup flows like `CLEANUP - Admin | Sync Template v4 (Check Deleted)` are running

2. **Run Full Inventory**
   - Trigger a full inventory collection to ensure all environments are scanned
   - Allow adequate time for all sync and cleanup flows to complete

3. **Verify Environment Coverage**
   - Compare the list of environments in CoE vs. PPAC
   - Ensure all environments are included in your CoE inventory

4. **Check Orphaned Objects Cleanup Flow**
   - Look at the `CLEANUP - Admin | Sync Template v3 (Orphaned Makers)` and `CLEANUP - Admin | Sync Template v3 (Orphaned Users)` flows
   - These flows update the orphaned status for resources

5. **Review Time Stamps**
   - Check `modifiedon` dates in CoE entities to see when data was last updated
   - Compare with when you're viewing PPAC Advisor

### Best Practices

1. **Use CoE as Primary Source**
   - CoE provides more detailed information and historical tracking
   - Better for reporting and compliance workflows

2. **Use PPAC for Quick Checks**
   - PPAC Advisor is useful for quick health checks
   - Good for identifying urgent issues that need immediate attention

3. **Schedule Regular Sync**
   - Run inventory and cleanup flows at least daily
   - More frequent syncs = more accurate orphaned resource counts

4. **Cross-Reference Both Sources**
   - Use both tools to get a complete picture
   - Investigate significant discrepancies

5. **Document Your CoE Schedule**
   - Keep track of when sync flows run
   - Be aware of the data freshness when making decisions

### Related Resources

- [CoE Starter Kit Documentation](https://learn.microsoft.com/power-platform/guidance/coe/starter-kit)
- [Power Platform Admin Center Advisor](https://learn.microsoft.com/power-platform/admin/advisor)
- [CoE Inventory and Cleanup Flows](https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components)

### Additional Notes

The CoE Starter Kit is designed to provide comprehensive governance and monitoring capabilities with customizable logic. The orphaned resource detection can be extended or modified to match your organization's specific definition of "orphaned."

If you need the counts to match exactly, consider:
- Adjusting your CoE cleanup flow schedule to run more frequently
- Customizing the orphaned detection logic in CoE flows to match PPAC criteria
- Adding custom fields to track additional metadata about resource ownership

Remember: Neither count is necessarily "wrong" - they represent different views of the same data at different points in time with different criteria. The important thing is understanding what each tool is measuring and using them appropriately for your governance needs.
