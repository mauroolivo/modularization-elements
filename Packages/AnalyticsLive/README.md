# AnalyticsLive

Live analytics adapter package.

Dependency shape:

```text
Feature -> AnalyticsAPI
AnalyticsLive -> ThirdPartyAnalyticsSDK + AnalyticsAPI
```

`ThirdPartyAnalyticsSDK` is a simulated SDK target used to keep third-party imports contained.
