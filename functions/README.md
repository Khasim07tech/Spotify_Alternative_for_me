# KX Wave Firebase Functions

Optional free-tier friendly backend source for Phase 8 weekly updates.

Deploy only after Firebase is configured:

```bash
cd functions
npm install
firebase deploy --only functions:refreshWeeklyRecommendations
```

The scheduled function does not stream or copy music. It refreshes lightweight recommendation job metadata from user taste profiles so the Flutter app can regenerate legal/open recommendations efficiently.
