# Visual Preview: Environment Indicator

## Dashboard with Environment Indicator

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Power Platform Admin View                                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ╔═══════════════════════════════════════════════════════════════╗ 🌍  │
│  ║  CoE Environment                                              ║     │
│  ║  your-environment-name                                        ║     │
│  ╚═══════════════════════════════════════════════════════════════╝     │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                    │
│  │   Makers    │  │Environments │  │   Makers    │                    │
│  │   (Apps)    │  │   by Type   │  │  (Flows)    │                    │
│  │             │  │             │  │             │                    │
│  │   [Chart]   │  │   [Chart]   │  │   [Chart]   │                    │
│  │             │  │             │  │             │                    │
│  └─────────────┘  └─────────────┘  └─────────────┘                    │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                    │
│  │    Apps     │  │   Flows     │  │Environments │                    │
│  │  by Status  │  │  by Status  │  │with Capacity│                    │
│  │             │  │             │  │             │                    │
│  │   [Chart]   │  │   [Chart]   │  │   [Chart]   │                    │
│  │             │  │             │  │             │                    │
│  └─────────────┘  └─────────────┘  └─────────────┘                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Color Scheme
- **Banner Background**: Blue gradient (#0078d4 → #106ebe)
- **Text Color**: White
- **Font**: Segoe UI, 20px bold for environment name
- **Spacing**: 16px padding around banner content

## Behavior
- **On Load**: Automatically fetches and displays the current environment name
- **Update Frequency**: Static display (updates on page refresh)
- **Error Handling**: Shows "Error loading environment name" if unable to retrieve info
- **Fallback**: Shows "Unknown Environment" if context is unavailable

## User Experience
1. User opens Power Platform Admin View app
2. Dashboard loads with environment indicator at the top
3. User immediately sees which environment they're in
4. User can proceed with confidence knowing their working context

## Responsive Design
The banner is responsive and will:
- Span full width of the dashboard section
- Maintain readability on different screen sizes
- Scale text appropriately for mobile/tablet views (if applicable)
