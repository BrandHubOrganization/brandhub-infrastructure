# Payment dialog

Extract existing checkout panel to components/AgencyPaymentPanel.tsx; reuse it in legacy checkout and shared Dialog on plans. Scope dialog to user/agency, invalidate subscription query after fulfillment. Reuse current locale strings; no new keys. Verify responsive light/dark, keyboard close and reopen.
