Update AgencyPaymentPanel with independent clock state and interval cleanup; derive remaining seconds from absolute deadline. Update src/i18n/locales/vi/subscription.json and en/subscription.json. Verify TypeScript and checkout behavior.
Change AgencyBillingService createPlusOrder expires_at from now + 30 minutes to now + 15 minutes. No database migration or frontend change required.
