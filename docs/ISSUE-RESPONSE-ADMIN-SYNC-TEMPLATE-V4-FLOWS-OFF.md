# Triage Response: Admin \| Sync Template v4 flows not turning on (follow-up to #10840)

**Summary**: Customer cannot configure CoE Starter Kit core components and reports that the **Admin \| Sync Template v4** flows remain off. This affects the Core Components inventory flows.

**Closest prior issues**: microsoft/coe-starter-kit#10840 (original thread with setup guidance).

**Root-cause hypotheses**
- Connections for Admin \| Sync Template v4 flows are not authenticated/using an account without required licenses or roles (Power Apps Premium/Power Automate per user, Power Platform Admin role, Dataverse System Administrator).
- Flows were imported without selecting **Enable processes (workflows/business rules)** in the import wizard, so they stay disabled.
- Setup/Upgrade Wizard or manual connection references were not completed (creator kit prerequisite, environment variables like `admin_TenantID`/`admin_EnvironmentID` not set), causing the driver to fail and auto-disable.
- DLP policies block required connectors (Power Platform for Admins, Power Platform for Makers, Dataverse).

**Repro steps**
1. Go to Power Automate in the CoE environment.
2. Open solution **Center of Excellence – Core Components**.
3. Check flows starting with **Admin \| Sync Template v4** (Driver, Environments, Apps, Flows, AI Usage, etc.) and note status and last error.
4. Open **Connections** and verify the Admin connectors are authenticated with the service account.

**Fix plan**
- **Short-term mitigation**
  - Re-run the setup steps from the official doc: https://learn.microsoft.com/power-platform/guidance/coe/setup-core-components (map all connections, select **Enable processes**, then turn on the Driver and dependent v4 flows).
  - Ensure the service account has: Power Apps/Power Automate Premium license, Power Platform Admin (Entra ID) + Dataverse System Administrator in the CoE environment.
  - If flows show connection errors, re-authenticate the Admin connectors and turn the flows on manually.
- **Durable fix**
  - Verify Creator Kit is installed before running the Setup Wizard (prerequisite).
  - Confirm environment variables `admin_TenantID`, `admin_EnvironmentID`, and `admin_FullInventory` are set correctly; run **Admin \| Sync Template v4 (Driver)** once after fixes.
  - Review DLP policies so Dataverse + Power Platform Admin/Maker connectors are in the same group and not blocked.
  - Leave the Driver scheduled; use Full Inventory only temporarily if data is stale.
- **Licensing/DLP caveats**
  - Trials or restricted DLP policies can prevent the Admin connectors from running; validate licensing and connector grouping if flows auto-disable.

**Next actions**
- Follow the short-term steps above and re-run **Admin \| Sync Template v4 (Driver)**.
- If issues persist, share screenshots of the flow run error, solution version, and connection references for the Admin connectors. We cannot schedule Teams calls; support here is best-effort via GitHub issues.

**If details are missing, ask the customer to provide:**
- Describe the issue
- Expected behavior
- What solution are you experiencing the issue with?
- What solution version are you using?
- What app or flow are you having the issue with?
- What method are you using to get inventory and telemetry?
- Steps to reproduce
- Any other relevant information?
