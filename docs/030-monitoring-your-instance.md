Cryptlex integrates with [New Relic](https://newrelic.com/) and [Bugsnag](https://www.bugsnag.com/) which you can use to monitor the health of your Cryptlex instance, set up alerts and get notified on errors.

### Setting up New Relic

In order to monitor the Cryptlex web API server instance you will need to create a New Relic account. The free plan offered by New Relic would suffice.

To enable New Relic monitoring just set the `NEW_RELIC_LICENSE_KEY` environment variable to the license key provided by New Relic for ASP.NET project.

### Setting up Bugsnag

In order to receive notifications when any error occurs in the Cryptlex web API server instance, you will need to create a Bugsnag account. The free plan offered by Bugsnag would suffice.

To enable Bugsnag error reporting just set the `BUGSNAG_APIKEY` environment variable to the Bugsnag API key.