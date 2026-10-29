--
-- PostgreSQL database dump
--

\restrict 4xxYm31diX1GUbZLWUQjKeBJhHyXxutiaCe1vyrEu5cp1fsoxRYuudFGzO98Ibb

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.workspaces DROP CONSTRAINT IF EXISTS workspaces_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspaces DROP CONSTRAINT IF EXISTS workspaces_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_templates DROP CONSTRAINT IF EXISTS workspace_templates_source_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_templates DROP CONSTRAINT IF EXISTS workspace_templates_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_templates DROP CONSTRAINT IF EXISTS workspace_templates_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_members DROP CONSTRAINT IF EXISTS workspace_members_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_members DROP CONSTRAINT IF EXISTS workspace_members_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_members DROP CONSTRAINT IF EXISTS workspace_members_client_profile_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_members DROP CONSTRAINT IF EXISTS workspace_members_added_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_media_packages DROP CONSTRAINT IF EXISTS workspace_media_packages_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_media_packages DROP CONSTRAINT IF EXISTS workspace_media_packages_package_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_invitations DROP CONSTRAINT IF EXISTS workspace_invitations_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_invitations DROP CONSTRAINT IF EXISTS workspace_invitations_invited_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_hashtags DROP CONSTRAINT IF EXISTS workspace_hashtags_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_hashtags DROP CONSTRAINT IF EXISTS workspace_hashtags_deleted_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_hashtags DROP CONSTRAINT IF EXISTS workspace_hashtags_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_hashtags DROP CONSTRAINT IF EXISTS workspace_hashtags_added_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_drive_folders DROP CONSTRAINT IF EXISTS workspace_drive_folders_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_drive_folders DROP CONSTRAINT IF EXISTS workspace_drive_folders_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_credit_usage DROP CONSTRAINT IF EXISTS workspace_credit_usage_agency_id_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_credit_usage DROP CONSTRAINT IF EXISTS workspace_credit_usage_agency_id_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_credit_limits DROP CONSTRAINT IF EXISTS workspace_credit_limits_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspace_credit_limits DROP CONSTRAINT IF EXISTS workspace_credit_limits_agency_id_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_system_roles DROP CONSTRAINT IF EXISTS user_system_roles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_system_roles DROP CONSTRAINT IF EXISTS user_system_roles_granted_by_fkey;
ALTER TABLE IF EXISTS ONLY public.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_strikes DROP CONSTRAINT IF EXISTS user_strikes_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_strikes DROP CONSTRAINT IF EXISTS user_strikes_removed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.user_strikes DROP CONSTRAINT IF EXISTS user_strikes_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.user_strikes DROP CONSTRAINT IF EXISTS user_strikes_converted_to_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_refresh_tokens DROP CONSTRAINT IF EXISTS user_refresh_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_oauth_providers DROP CONSTRAINT IF EXISTS user_oauth_providers_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_notifications DROP CONSTRAINT IF EXISTS user_notifications_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_notifications DROP CONSTRAINT IF EXISTS user_notifications_notification_id_fkey;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.third_party_collaborators DROP CONSTRAINT IF EXISTS third_party_collaborators_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.third_party_collaborators DROP CONSTRAINT IF EXISTS third_party_collaborators_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tasks DROP CONSTRAINT IF EXISTS tasks_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tasks DROP CONSTRAINT IF EXISTS tasks_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.task_content_operations DROP CONSTRAINT IF EXISTS task_content_operations_edited_by_fkey;
ALTER TABLE IF EXISTS ONLY public.subscription_provider_checks DROP CONSTRAINT IF EXISTS subscription_provider_checks_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subscription_plan_changes DROP CONSTRAINT IF EXISTS subscription_plan_changes_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subscription_plan_changes DROP CONSTRAINT IF EXISTS subscription_plan_changes_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.subscription_plan_changes DROP CONSTRAINT IF EXISTS subscription_plan_changes_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subscription_operational_issues DROP CONSTRAINT IF EXISTS subscription_operational_issues_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subscription_operational_issues DROP CONSTRAINT IF EXISTS subscription_operational_issues_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_usage_entries DROP CONSTRAINT IF EXISTS storage_usage_entries_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_usage_entries DROP CONSTRAINT IF EXISTS storage_usage_entries_reservation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_usage_entries DROP CONSTRAINT IF EXISTS storage_usage_entries_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_reservations DROP CONSTRAINT IF EXISTS storage_reservations_agency_id_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_reservations DROP CONSTRAINT IF EXISTS storage_reservations_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_objects DROP CONSTRAINT IF EXISTS storage_objects_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_objects DROP CONSTRAINT IF EXISTS storage_objects_agency_id_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_objects DROP CONSTRAINT IF EXISTS storage_objects_agency_id_reservation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.storage_objects DROP CONSTRAINT IF EXISTS storage_objects_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.sanction_reviews DROP CONSTRAINT IF EXISTS sanction_reviews_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.sanction_reviews DROP CONSTRAINT IF EXISTS sanction_reviews_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_states DROP CONSTRAINT IF EXISTS repository_drive_states_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_states DROP CONSTRAINT IF EXISTS repository_drive_states_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_states DROP CONSTRAINT IF EXISTS repository_drive_states_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_operations DROP CONSTRAINT IF EXISTS repository_drive_operations_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_objects DROP CONSTRAINT IF EXISTS repository_drive_objects_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_generations DROP CONSTRAINT IF EXISTS repository_drive_generations_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.package_negotiation_events DROP CONSTRAINT IF EXISTS package_negotiation_events_workspace_media_package_id_fkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_health_targets DROP CONSTRAINT IF EXISTS monitoring_health_targets_server_id_fkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_health_targets DROP CONSTRAINT IF EXISTS monitoring_health_targets_collector_id_fkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_collectors DROP CONSTRAINT IF EXISTS monitoring_collectors_server_id_fkey;
ALTER TABLE IF EXISTS ONLY public.media_packages DROP CONSTRAINT IF EXISTS media_packages_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.media_campaigns DROP CONSTRAINT IF EXISTS media_campaigns_workspace_media_package_id_fkey;
ALTER TABLE IF EXISTS ONLY public.material_quota_releases DROP CONSTRAINT IF EXISTS material_quota_releases_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.material_quota_releases DROP CONSTRAINT IF EXISTS material_quota_releases_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_suppressions DROP CONSTRAINT IF EXISTS mail_suppressions_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_suppressions DROP CONSTRAINT IF EXISTS mail_suppressions_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_deliveries DROP CONSTRAINT IF EXISTS mail_deliveries_batch_id_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_batches DROP CONSTRAINT IF EXISTS mail_batches_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_batches DROP CONSTRAINT IF EXISTS mail_batches_sent_by_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_batches DROP CONSTRAINT IF EXISTS mail_batches_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_attachments DROP CONSTRAINT IF EXISTS mail_attachments_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.mail_attachments DROP CONSTRAINT IF EXISTS mail_attachments_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workspaces DROP CONSTRAINT IF EXISTS fk_workspaces_media_package;
ALTER TABLE IF EXISTS ONLY public.monitoring_health_results DROP CONSTRAINT IF EXISTS fk_monitoring_result_owner;
ALTER TABLE IF EXISTS ONLY public.media_packages DROP CONSTRAINT IF EXISTS fk_media_packages_source_template;
ALTER TABLE IF EXISTS ONLY public.media_packages DROP CONSTRAINT IF EXISTS fk_media_packages_agency;
ALTER TABLE IF EXISTS ONLY public.ai_video_jobs DROP CONSTRAINT IF EXISTS fk_ai_video_jobs_reservation;
ALTER TABLE IF EXISTS ONLY public.agency_invitations DROP CONSTRAINT IF EXISTS fk_agency_inv_workspace_id;
ALTER TABLE IF EXISTS ONLY public.credit_usage_periods DROP CONSTRAINT IF EXISTS credit_usage_periods_agency_id_subscription_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_usage_periods DROP CONSTRAINT IF EXISTS credit_usage_periods_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_reservation_allocations DROP CONSTRAINT IF EXISTS credit_reservation_allocations_agency_id_reservation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_reservation_allocations DROP CONSTRAINT IF EXISTS credit_reservation_allocations_agency_id_grant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_operations DROP CONSTRAINT IF EXISTS credit_operations_agency_id_reversal_of_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_operations DROP CONSTRAINT IF EXISTS credit_operations_agency_id_reservation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_operations DROP CONSTRAINT IF EXISTS credit_operations_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_operations DROP CONSTRAINT IF EXISTS credit_operations_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_grants DROP CONSTRAINT IF EXISTS credit_grants_trial_owner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_grants DROP CONSTRAINT IF EXISTS credit_grants_agency_id_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_grants DROP CONSTRAINT IF EXISTS credit_grants_agency_id_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_grants DROP CONSTRAINT IF EXISTS credit_grants_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_entries DROP CONSTRAINT IF EXISTS credit_entries_agency_id_operation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.credit_entries DROP CONSTRAINT IF EXISTS credit_entries_agency_id_grant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.creator_credit_usage DROP CONSTRAINT IF EXISTS creator_credit_usage_creator_id_fkey;
ALTER TABLE IF EXISTS ONLY public.creator_credit_usage DROP CONSTRAINT IF EXISTS creator_credit_usage_agency_id_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_request_completion_jobs DROP CONSTRAINT IF EXISTS content_request_completion_jobs_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_request_completion_jobs DROP CONSTRAINT IF EXISTS content_request_completion_jobs_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY public.content_moderation_reviews DROP CONSTRAINT IF EXISTS content_moderation_reviews_reviewed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.content_moderation_reviews DROP CONSTRAINT IF EXISTS content_moderation_reviews_author_id_fkey;
ALTER TABLE IF EXISTS ONLY public.client_profiles DROP CONSTRAINT IF EXISTS client_profiles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_versions DROP CONSTRAINT IF EXISTS campaign_versions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_versions DROP CONSTRAINT IF EXISTS campaign_versions_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_review_events DROP CONSTRAINT IF EXISTS campaign_review_events_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_review_events DROP CONSTRAINT IF EXISTS campaign_review_events_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_deployments DROP CONSTRAINT IF EXISTS campaign_deployments_requested_by_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_deployments DROP CONSTRAINT IF EXISTS campaign_deployments_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_collaborators DROP CONSTRAINT IF EXISTS campaign_collaborators_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_collaborators DROP CONSTRAINT IF EXISTS campaign_collaborators_media_campaign_id_fkey;
ALTER TABLE IF EXISTS ONLY public.campaign_collaborators DROP CONSTRAINT IF EXISTS campaign_collaborators_collaborator_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_payments DROP CONSTRAINT IF EXISTS billing_payments_agency_id_attempt_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_payment_events DROP CONSTRAINT IF EXISTS billing_payment_events_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_payment_attempts DROP CONSTRAINT IF EXISTS billing_payment_attempts_agency_id_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_outbox_events DROP CONSTRAINT IF EXISTS billing_outbox_events_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_orders DROP CONSTRAINT IF EXISTS billing_orders_plan_version_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_orders DROP CONSTRAINT IF EXISTS billing_orders_plan_scope_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_orders DROP CONSTRAINT IF EXISTS billing_orders_payer_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_orders DROP CONSTRAINT IF EXISTS billing_orders_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_order_fulfillments DROP CONSTRAINT IF EXISTS billing_order_fulfillments_agency_id_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_migration_reviews DROP CONSTRAINT IF EXISTS billing_migration_reviews_resolved_by_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_migration_reviews DROP CONSTRAINT IF EXISTS billing_migration_reviews_resolved_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_migration_reviews DROP CONSTRAINT IF EXISTS billing_migration_reviews_owner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_audit_events DROP CONSTRAINT IF EXISTS billing_audit_events_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.billing_audit_events DROP CONSTRAINT IF EXISTS billing_audit_events_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_video_jobs DROP CONSTRAINT IF EXISTS ai_video_jobs_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_video_jobs DROP CONSTRAINT IF EXISTS ai_video_jobs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_video_jobs DROP CONSTRAINT IF EXISTS ai_video_jobs_usage_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_usages DROP CONSTRAINT IF EXISTS ai_credit_usages_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_usages DROP CONSTRAINT IF EXISTS ai_credit_usages_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_usages DROP CONSTRAINT IF EXISTS ai_credit_usages_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_reservations DROP CONSTRAINT IF EXISTS ai_credit_reservations_price_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_reservations DROP CONSTRAINT IF EXISTS ai_credit_reservations_agency_id_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_reservations DROP CONSTRAINT IF EXISTS ai_credit_reservations_agency_id_period_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_reservations DROP CONSTRAINT IF EXISTS ai_credit_reservations_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_operation_prices DROP CONSTRAINT IF EXISTS ai_credit_operation_prices_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_ledgers DROP CONSTRAINT IF EXISTS ai_credit_ledgers_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_creator_limits DROP CONSTRAINT IF EXISTS ai_credit_creator_limits_set_by_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_creator_limits DROP CONSTRAINT IF EXISTS ai_credit_creator_limits_creator_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_creator_limits DROP CONSTRAINT IF EXISTS ai_credit_creator_limits_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_caption_generations DROP CONSTRAINT IF EXISTS ai_caption_generations_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ai_caption_generations DROP CONSTRAINT IF EXISTS ai_caption_generations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscriptions DROP CONSTRAINT IF EXISTS agency_subscriptions_plan_version_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscriptions DROP CONSTRAINT IF EXISTS agency_subscriptions_plan_scope_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscriptions DROP CONSTRAINT IF EXISTS agency_subscriptions_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_plan_version_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_plan_scope_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_agency_id_subscription_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_agency_id_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_storage_usage DROP CONSTRAINT IF EXISTS agency_storage_usage_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_storage_reservations DROP CONSTRAINT IF EXISTS agency_storage_reservations_workspace_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_storage_reservations DROP CONSTRAINT IF EXISTS agency_storage_reservations_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_storage_reservations DROP CONSTRAINT IF EXISTS agency_storage_reservations_actor_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_resource_usage DROP CONSTRAINT IF EXISTS agency_resource_usage_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_members DROP CONSTRAINT IF EXISTS agency_members_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_members DROP CONSTRAINT IF EXISTS agency_members_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_invitations DROP CONSTRAINT IF EXISTS agency_invitations_invited_by_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_invitations DROP CONSTRAINT IF EXISTS agency_invitations_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_drive_connections DROP CONSTRAINT IF EXISTS agency_drive_connections_connected_by_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_drive_connections DROP CONSTRAINT IF EXISTS agency_drive_connections_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_credit_wallets DROP CONSTRAINT IF EXISTS agency_credit_wallets_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_creator_credit_limits DROP CONSTRAINT IF EXISTS agency_creator_credit_limits_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_creator_credit_limits DROP CONSTRAINT IF EXISTS agency_creator_credit_limits_creator_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agency_creator_credit_limits DROP CONSTRAINT IF EXISTS agency_creator_credit_limits_agency_id_fkey;
ALTER TABLE IF EXISTS ONLY public.agencies DROP CONSTRAINT IF EXISTS agencies_owner_id_fkey;
ALTER TABLE IF EXISTS ONLY public.admin_report_exports DROP CONSTRAINT IF EXISTS admin_report_exports_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.admin_notifications DROP CONSTRAINT IF EXISTS admin_notifications_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.admin_email_outbox DROP CONSTRAINT IF EXISTS admin_email_outbox_notification_id_fkey;
ALTER TABLE IF EXISTS ONLY public.admin_account_operations DROP CONSTRAINT IF EXISTS admin_account_operations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account_activation_tokens DROP CONSTRAINT IF EXISTS account_activation_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.account_activation_tokens DROP CONSTRAINT IF EXISTS account_activation_tokens_created_by_fkey;
DROP TRIGGER IF EXISTS trg_workspaces_updated_at ON public.workspaces;
DROP TRIGGER IF EXISTS trg_workspace_members_updated_at ON public.workspace_members;
DROP TRIGGER IF EXISTS trg_workspace_media_packages_updated_at ON public.workspace_media_packages;
DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS trg_user_subscriptions_updated_at ON public.user_subscriptions;
DROP TRIGGER IF EXISTS trg_transactions_updated_at ON public.transactions;
DROP TRIGGER IF EXISTS trg_package_negotiation_immutable ON public.package_negotiation_events;
DROP TRIGGER IF EXISTS trg_package_negotiation_events_append_only ON public.package_negotiation_events;
DROP TRIGGER IF EXISTS trg_media_packages_updated_at ON public.media_packages;
DROP TRIGGER IF EXISTS trg_media_campaigns_updated_at ON public.media_campaigns;
DROP TRIGGER IF EXISTS trg_credit_price_history ON public.ai_credit_operation_prices;
DROP TRIGGER IF EXISTS trg_collaborators_updated_at ON public.third_party_collaborators;
DROP TRIGGER IF EXISTS trg_client_profiles_updated_at ON public.client_profiles;
DROP TRIGGER IF EXISTS trg_campaign_partner_usage ON public.campaign_collaborators;
DROP TRIGGER IF EXISTS trg_campaign_collaborator_mark_used ON public.campaign_collaborators;
DROP TRIGGER IF EXISTS trg_audit_logs_no_update ON public.audit_logs;
DROP TRIGGER IF EXISTS trg_audit_logs_no_delete ON public.audit_logs;
DROP TRIGGER IF EXISTS trg_ai_credit_ledgers_updated_at ON public.ai_credit_ledgers;
DROP TRIGGER IF EXISTS trg_ai_credit_creator_limits_updated_at ON public.ai_credit_creator_limits;
DROP TRIGGER IF EXISTS trg_agencies_updated_at ON public.agencies;
DROP TRIGGER IF EXISTS credit_operations_no_truncate ON public.credit_operations;
DROP TRIGGER IF EXISTS credit_operations_immutable ON public.credit_operations;
DROP TRIGGER IF EXISTS credit_entries_no_truncate ON public.credit_entries;
DROP TRIGGER IF EXISTS credit_entries_immutable ON public.credit_entries;
DROP TRIGGER IF EXISTS billing_plan_version_no_truncate ON public.billing_plan_versions;
DROP TRIGGER IF EXISTS billing_plan_version_immutable ON public.billing_plan_versions;
DROP TRIGGER IF EXISTS billing_period_overlap ON public.agency_subscription_periods;
DROP TRIGGER IF EXISTS billing_audit_no_truncate ON public.billing_audit_events;
DROP TRIGGER IF EXISTS billing_audit_immutable ON public.billing_audit_events;
DROP INDEX IF EXISTS public.uq_workspaces_duplication_request;
DROP INDEX IF EXISTS public.uq_workspaces_agency_identity_billing;
DROP INDEX IF EXISTS public.uq_workspace_hashtags_active_tag;
DROP INDEX IF EXISTS public.uq_workspace_credit_request;
DROP INDEX IF EXISTS public.uq_workspace_credit_allocation_order;
DROP INDEX IF EXISTS public.uq_plan_change_pending;
DROP INDEX IF EXISTS public.uq_pending_agency_subscription_order;
DROP INDEX IF EXISTS public.uq_one_future_period;
DROP INDEX IF EXISTS public.uq_one_current_period;
DROP INDEX IF EXISTS public.uq_media_campaigns_agreement;
DROP INDEX IF EXISTS public.uq_mail_suppressions_system_email;
DROP INDEX IF EXISTS public.uq_mail_suppressions_agency_email;
DROP INDEX IF EXISTS public.uq_credit_trial_once;
DROP INDEX IF EXISTS public.uq_credit_topup_once;
DROP INDEX IF EXISTS public.uq_credit_provider_job;
DROP INDEX IF EXISTS public.uq_credit_period_once;
DROP INDEX IF EXISTS public.uq_ai_video_jobs_reservation;
DROP INDEX IF EXISTS public.ix_workspace_hashtags_list;
DROP INDEX IF EXISTS public.ix_storage_provider_capacity;
DROP INDEX IF EXISTS public.ix_customer_drive_state_expiry;
DROP INDEX IF EXISTS public.ix_customer_drive_account;
DROP INDEX IF EXISTS public.idx_workspaces_source_workspace;
DROP INDEX IF EXISTS public.idx_workspaces_agency_id;
DROP INDEX IF EXISTS public.idx_workspace_templates_agency_id;
DROP INDEX IF EXISTS public.idx_workspace_inv_workspace_id;
DROP INDEX IF EXISTS public.idx_workspace_credit_period;
DROP INDEX IF EXISTS public.idx_workspace_credit_actor;
DROP INDEX IF EXISTS public.idx_wm_workspace_id;
DROP INDEX IF EXISTS public.idx_wm_unique_user;
DROP INDEX IF EXISTS public.idx_wm_unique_client;
DROP INDEX IF EXISTS public.idx_wm_one_manager;
DROP INDEX IF EXISTS public.idx_users_reactivate;
DROP INDEX IF EXISTS public.idx_users_email;
DROP INDEX IF EXISTS public.idx_users_clean_period;
DROP INDEX IF EXISTS public.idx_user_sub_status_period;
DROP INDEX IF EXISTS public.idx_user_strikes_live;
DROP INDEX IF EXISTS public.idx_user_strikes_history;
DROP INDEX IF EXISTS public.idx_user_notifications_unread;
DROP INDEX IF EXISTS public.idx_user_notifications_inbox;
DROP INDEX IF EXISTS public.idx_transactions_user_id;
DROP INDEX IF EXISTS public.idx_tasks_workspace_id;
DROP INDEX IF EXISTS public.idx_task_content_snapshots_task_id;
DROP INDEX IF EXISTS public.idx_task_content_operations_task_id;
DROP INDEX IF EXISTS public.idx_subscription_provider_due;
DROP INDEX IF EXISTS public.idx_subscription_issues_subject;
DROP INDEX IF EXISTS public.idx_subscription_issues_open;
DROP INDEX IF EXISTS public.idx_storage_res_expiry;
DROP INDEX IF EXISTS public.idx_storage_res_agency;
DROP INDEX IF EXISTS public.idx_storage_entries_scope;
DROP INDEX IF EXISTS public.idx_storage_agency_status;
DROP INDEX IF EXISTS public.idx_sanction_one_pending;
DROP INDEX IF EXISTS public.idx_rt_user_id;
DROP INDEX IF EXISTS public.idx_rt_expires_at;
DROP INDEX IF EXISTS public.idx_package_negotiation_history;
DROP INDEX IF EXISTS public.idx_oauth_user_id;
DROP INDEX IF EXISTS public.idx_monitoring_targets_service;
DROP INDEX IF EXISTS public.idx_monitoring_targets_server;
DROP INDEX IF EXISTS public.idx_monitoring_targets_environment_kind;
DROP INDEX IF EXISTS public.idx_monitoring_targets_collector;
DROP INDEX IF EXISTS public.idx_monitoring_servers_environment;
DROP INDEX IF EXISTS public.idx_monitoring_enrollments_expiry;
DROP INDEX IF EXISTS public.idx_monitoring_collectors_server;
DROP INDEX IF EXISTS public.idx_moderation_queue;
DROP INDEX IF EXISTS public.idx_moderation_author;
DROP INDEX IF EXISTS public.idx_media_packages_is_template;
DROP INDEX IF EXISTS public.idx_media_packages_agency_id;
DROP INDEX IF EXISTS public.idx_media_packages_agency_available;
DROP INDEX IF EXISTS public.idx_media_campaigns_wmp_id;
DROP INDEX IF EXISTS public.idx_material_releases_date;
DROP INDEX IF EXISTS public.idx_mail_deliveries_due;
DROP INDEX IF EXISTS public.idx_mail_deliveries_batch;
DROP INDEX IF EXISTS public.idx_mail_batches_workspace;
DROP INDEX IF EXISTS public.idx_mail_batches_due;
DROP INDEX IF EXISTS public.idx_mail_attachments_workspace;
DROP INDEX IF EXISTS public.idx_grant_spend;
DROP INDEX IF EXISTS public.idx_credit_video_reconciliation;
DROP INDEX IF EXISTS public.idx_credit_entries_agency_time;
DROP INDEX IF EXISTS public.idx_content_req_completion_jobs_created;
DROP INDEX IF EXISTS public.idx_collaborators_agency_id;
DROP INDEX IF EXISTS public.idx_client_profiles_user_id;
DROP INDEX IF EXISTS public.idx_campaign_review_events_campaign_created;
DROP INDEX IF EXISTS public.idx_campaign_deployments_status_created;
DROP INDEX IF EXISTS public.idx_billing_outbox_due;
DROP INDEX IF EXISTS public.idx_billing_orders_history;
DROP INDEX IF EXISTS public.idx_audit_user_time;
DROP INDEX IF EXISTS public.idx_audit_resource;
DROP INDEX IF EXISTS public.idx_audit_agency_time;
DROP INDEX IF EXISTS public.idx_ai_video_jobs_workspace;
DROP INDEX IF EXISTS public.idx_ai_video_jobs_open;
DROP INDEX IF EXISTS public.idx_ai_reservation_reconcile;
DROP INDEX IF EXISTS public.idx_ai_credit_usages_user_month;
DROP INDEX IF EXISTS public.idx_ai_credit_usages_agency_month;
DROP INDEX IF EXISTS public.idx_ai_caption_generations_workspace;
DROP INDEX IF EXISTS public.idx_ai_caption_generations_task;
DROP INDEX IF EXISTS public.idx_agency_sub_due;
DROP INDEX IF EXISTS public.idx_agency_members_agency_id;
DROP INDEX IF EXISTS public.idx_agency_inv_unique_pending;
DROP INDEX IF EXISTS public.idx_agency_inv_agency_id;
DROP INDEX IF EXISTS public.idx_agencies_owner_id;
DROP INDEX IF EXISTS public.idx_admin_report_exports_expiry;
DROP INDEX IF EXISTS public.idx_admin_notifications_history;
DROP INDEX IF EXISTS public.idx_admin_notifications_due;
DROP INDEX IF EXISTS public.idx_admin_email_outbox_notification;
DROP INDEX IF EXISTS public.idx_admin_email_due;
DROP INDEX IF EXISTS public.idx_activation_tokens_open;
ALTER TABLE IF EXISTS ONLY public.workspaces DROP CONSTRAINT IF EXISTS workspaces_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_templates DROP CONSTRAINT IF EXISTS workspace_templates_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_members DROP CONSTRAINT IF EXISTS workspace_members_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_media_packages DROP CONSTRAINT IF EXISTS workspace_media_packages_workspace_id_key;
ALTER TABLE IF EXISTS ONLY public.workspace_media_packages DROP CONSTRAINT IF EXISTS workspace_media_packages_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_invitations DROP CONSTRAINT IF EXISTS workspace_invitations_workspace_id_invited_email_key;
ALTER TABLE IF EXISTS ONLY public.workspace_invitations DROP CONSTRAINT IF EXISTS workspace_invitations_token_key;
ALTER TABLE IF EXISTS ONLY public.workspace_invitations DROP CONSTRAINT IF EXISTS workspace_invitations_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_hashtags DROP CONSTRAINT IF EXISTS workspace_hashtags_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_drive_folders DROP CONSTRAINT IF EXISTS workspace_drive_folders_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_drive_folders DROP CONSTRAINT IF EXISTS workspace_drive_folders_agency_id_ordinal_key;
ALTER TABLE IF EXISTS ONLY public.workspace_credit_usage DROP CONSTRAINT IF EXISTS workspace_credit_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.workspace_credit_limits DROP CONSTRAINT IF EXISTS workspace_credit_limits_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_phone_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.user_system_roles DROP CONSTRAINT IF EXISTS user_system_roles_user_id_key;
ALTER TABLE IF EXISTS ONLY public.user_system_roles DROP CONSTRAINT IF EXISTS user_system_roles_pkey;
ALTER TABLE IF EXISTS ONLY public.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_user_id_key;
ALTER TABLE IF EXISTS ONLY public.user_subscriptions DROP CONSTRAINT IF EXISTS user_subscriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.user_strikes DROP CONSTRAINT IF EXISTS user_strikes_pkey;
ALTER TABLE IF EXISTS ONLY public.user_refresh_tokens DROP CONSTRAINT IF EXISTS user_refresh_tokens_token_hash_key;
ALTER TABLE IF EXISTS ONLY public.user_refresh_tokens DROP CONSTRAINT IF EXISTS user_refresh_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.user_refresh_tokens DROP CONSTRAINT IF EXISTS user_refresh_tokens_jti_key;
ALTER TABLE IF EXISTS ONLY public.user_oauth_providers DROP CONSTRAINT IF EXISTS user_oauth_providers_provider_provider_id_key;
ALTER TABLE IF EXISTS ONLY public.user_oauth_providers DROP CONSTRAINT IF EXISTS user_oauth_providers_pkey;
ALTER TABLE IF EXISTS ONLY public.user_notifications DROP CONSTRAINT IF EXISTS user_notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.user_notifications DROP CONSTRAINT IF EXISTS uq_user_notification;
ALTER TABLE IF EXISTS ONLY public.monitoring_health_targets DROP CONSTRAINT IF EXISTS uq_monitoring_target_collector;
ALTER TABLE IF EXISTS ONLY public.content_moderation_reviews DROP CONSTRAINT IF EXISTS uq_moderation_post_version;
ALTER TABLE IF EXISTS ONLY public.campaign_versions DROP CONSTRAINT IF EXISTS uq_campaign_versions_campaign_version;
ALTER TABLE IF EXISTS ONLY public.campaign_versions DROP CONSTRAINT IF EXISTS ukk0pnt9rnkhmegtd08lnloiscq;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_pkey;
ALTER TABLE IF EXISTS ONLY public.transactions DROP CONSTRAINT IF EXISTS transactions_payos_tx_id_key;
ALTER TABLE IF EXISTS ONLY public.third_party_collaborators DROP CONSTRAINT IF EXISTS third_party_collaborators_pkey;
ALTER TABLE IF EXISTS ONLY public.tasks DROP CONSTRAINT IF EXISTS tasks_pkey;
ALTER TABLE IF EXISTS ONLY public.task_content_snapshots DROP CONSTRAINT IF EXISTS task_content_snapshots_pkey;
ALTER TABLE IF EXISTS ONLY public.task_content_operations DROP CONSTRAINT IF EXISTS task_content_operations_task_id_sequence_number_key;
ALTER TABLE IF EXISTS ONLY public.task_content_operations DROP CONSTRAINT IF EXISTS task_content_operations_pkey;
ALTER TABLE IF EXISTS ONLY public.system_storage_pools DROP CONSTRAINT IF EXISTS system_storage_pools_pkey;
ALTER TABLE IF EXISTS ONLY public.subscription_provider_checks DROP CONSTRAINT IF EXISTS subscription_provider_checks_pkey;
ALTER TABLE IF EXISTS ONLY public.subscription_plans DROP CONSTRAINT IF EXISTS subscription_plans_pkey;
ALTER TABLE IF EXISTS ONLY public.subscription_plans DROP CONSTRAINT IF EXISTS subscription_plans_name_key;
ALTER TABLE IF EXISTS ONLY public.subscription_plan_changes DROP CONSTRAINT IF EXISTS subscription_plan_changes_pkey;
ALTER TABLE IF EXISTS ONLY public.subscription_operational_issues DROP CONSTRAINT IF EXISTS subscription_operational_issues_pkey;
ALTER TABLE IF EXISTS ONLY public.subscription_operational_issues DROP CONSTRAINT IF EXISTS subscription_operational_issues_fingerprint_key;
ALTER TABLE IF EXISTS ONLY public.subscription_observation_jobs DROP CONSTRAINT IF EXISTS subscription_observation_jobs_pkey;
ALTER TABLE IF EXISTS ONLY public.storage_usage_entries DROP CONSTRAINT IF EXISTS storage_usage_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.storage_usage_entries DROP CONSTRAINT IF EXISTS storage_usage_entries_operation_key_key;
ALTER TABLE IF EXISTS ONLY public.storage_reservations DROP CONSTRAINT IF EXISTS storage_reservations_upload_id_key;
ALTER TABLE IF EXISTS ONLY public.storage_reservations DROP CONSTRAINT IF EXISTS storage_reservations_pkey;
ALTER TABLE IF EXISTS ONLY public.storage_reservations DROP CONSTRAINT IF EXISTS storage_reservations_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.storage_objects DROP CONSTRAINT IF EXISTS storage_objects_pkey;
ALTER TABLE IF EXISTS ONLY public.storage_objects DROP CONSTRAINT IF EXISTS storage_objects_backend_bucket_object_key_key;
ALTER TABLE IF EXISTS ONLY public.storage_objects DROP CONSTRAINT IF EXISTS storage_objects_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.seed_runs DROP CONSTRAINT IF EXISTS seed_runs_run_id_key;
ALTER TABLE IF EXISTS ONLY public.seed_runs DROP CONSTRAINT IF EXISTS seed_runs_pkey;
ALTER TABLE IF EXISTS ONLY public.sanction_reviews DROP CONSTRAINT IF EXISTS sanction_reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_states DROP CONSTRAINT IF EXISTS repository_drive_states_pkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_operations DROP CONSTRAINT IF EXISTS repository_drive_operations_pkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_objects DROP CONSTRAINT IF EXISTS repository_drive_objects_pkey;
ALTER TABLE IF EXISTS ONLY public.repository_drive_objects DROP CONSTRAINT IF EXISTS repository_drive_objects_file_id_key;
ALTER TABLE IF EXISTS ONLY public.repository_drive_generations DROP CONSTRAINT IF EXISTS repository_drive_generations_pkey;
ALTER TABLE IF EXISTS ONLY public.package_negotiation_events DROP CONSTRAINT IF EXISTS package_negotiation_events_workspace_media_package_id_terms_key;
ALTER TABLE IF EXISTS ONLY public.package_negotiation_events DROP CONSTRAINT IF EXISTS package_negotiation_events_pkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_servers DROP CONSTRAINT IF EXISTS monitoring_servers_pkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_health_targets DROP CONSTRAINT IF EXISTS monitoring_health_targets_pkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_health_results DROP CONSTRAINT IF EXISTS monitoring_health_results_pkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_enrollments DROP CONSTRAINT IF EXISTS monitoring_enrollments_pkey;
ALTER TABLE IF EXISTS ONLY public.monitoring_collectors DROP CONSTRAINT IF EXISTS monitoring_collectors_pkey;
ALTER TABLE IF EXISTS ONLY public.media_packages DROP CONSTRAINT IF EXISTS media_packages_pkey;
ALTER TABLE IF EXISTS ONLY public.media_campaigns DROP CONSTRAINT IF EXISTS media_campaigns_pkey;
ALTER TABLE IF EXISTS ONLY public.material_quota_releases DROP CONSTRAINT IF EXISTS material_quota_releases_pkey;
ALTER TABLE IF EXISTS ONLY public.material_audit_receipts DROP CONSTRAINT IF EXISTS material_audit_receipts_pkey;
ALTER TABLE IF EXISTS ONLY public.mail_suppressions DROP CONSTRAINT IF EXISTS mail_suppressions_workspace_id_email_lower_key;
ALTER TABLE IF EXISTS ONLY public.mail_suppressions DROP CONSTRAINT IF EXISTS mail_suppressions_pkey;
ALTER TABLE IF EXISTS ONLY public.mail_send_quota DROP CONSTRAINT IF EXISTS mail_send_quota_pkey;
ALTER TABLE IF EXISTS ONLY public.mail_deliveries DROP CONSTRAINT IF EXISTS mail_deliveries_pkey;
ALTER TABLE IF EXISTS ONLY public.mail_deliveries DROP CONSTRAINT IF EXISTS mail_deliveries_event_key_key;
ALTER TABLE IF EXISTS ONLY public.mail_batches DROP CONSTRAINT IF EXISTS mail_batches_pkey;
ALTER TABLE IF EXISTS ONLY public.mail_attachments DROP CONSTRAINT IF EXISTS mail_attachments_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_usage_periods DROP CONSTRAINT IF EXISTS credit_usage_periods_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_usage_periods DROP CONSTRAINT IF EXISTS credit_usage_periods_agency_id_starts_at_kind_key;
ALTER TABLE IF EXISTS ONLY public.credit_usage_periods DROP CONSTRAINT IF EXISTS credit_usage_periods_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.credit_reservation_allocations DROP CONSTRAINT IF EXISTS credit_reservation_allocations_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_operations DROP CONSTRAINT IF EXISTS credit_operations_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_operations DROP CONSTRAINT IF EXISTS credit_operations_agency_id_operation_key_key;
ALTER TABLE IF EXISTS ONLY public.credit_operations DROP CONSTRAINT IF EXISTS credit_operations_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.credit_grants DROP CONSTRAINT IF EXISTS credit_grants_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_grants DROP CONSTRAINT IF EXISTS credit_grants_agency_id_source_type_source_key_key;
ALTER TABLE IF EXISTS ONLY public.credit_grants DROP CONSTRAINT IF EXISTS credit_grants_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.credit_entries DROP CONSTRAINT IF EXISTS credit_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.credit_entries DROP CONSTRAINT IF EXISTS credit_entries_operation_id_grant_id_key;
ALTER TABLE IF EXISTS ONLY public.creator_credit_usage DROP CONSTRAINT IF EXISTS creator_credit_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.content_request_completion_jobs DROP CONSTRAINT IF EXISTS content_request_completion_jobs_pkey;
ALTER TABLE IF EXISTS ONLY public.content_moderation_reviews DROP CONSTRAINT IF EXISTS content_moderation_reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.client_profiles DROP CONSTRAINT IF EXISTS client_profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.campaign_versions DROP CONSTRAINT IF EXISTS campaign_versions_pkey;
ALTER TABLE IF EXISTS ONLY public.campaign_review_events DROP CONSTRAINT IF EXISTS campaign_review_events_pkey;
ALTER TABLE IF EXISTS ONLY public.campaign_deployments DROP CONSTRAINT IF EXISTS campaign_deployments_pkey;
ALTER TABLE IF EXISTS ONLY public.campaign_deployments DROP CONSTRAINT IF EXISTS campaign_deployments_campaign_id_key;
ALTER TABLE IF EXISTS ONLY public.campaign_collaborators DROP CONSTRAINT IF EXISTS campaign_collaborators_pkey;
ALTER TABLE IF EXISTS ONLY public.campaign_collaborators DROP CONSTRAINT IF EXISTS campaign_collaborators_media_campaign_id_collaborator_id_key;
ALTER TABLE IF EXISTS ONLY public.brandhub_schema_migrations DROP CONSTRAINT IF EXISTS brandhub_schema_migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_plan_versions DROP CONSTRAINT IF EXISTS billing_plan_versions_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_plan_versions DROP CONSTRAINT IF EXISTS billing_plan_versions_id_scope_key;
ALTER TABLE IF EXISTS ONLY public.billing_plan_versions DROP CONSTRAINT IF EXISTS billing_plan_versions_code_version_key;
ALTER TABLE IF EXISTS ONLY public.billing_payments DROP CONSTRAINT IF EXISTS billing_payments_provider_merchant_account_provider_referen_key;
ALTER TABLE IF EXISTS ONLY public.billing_payments DROP CONSTRAINT IF EXISTS billing_payments_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_payments DROP CONSTRAINT IF EXISTS billing_payments_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.billing_payment_events DROP CONSTRAINT IF EXISTS billing_payment_events_provider_merchant_account_event_key_key;
ALTER TABLE IF EXISTS ONLY public.billing_payment_events DROP CONSTRAINT IF EXISTS billing_payment_events_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_payment_attempts DROP CONSTRAINT IF EXISTS billing_payment_attempts_provider_merchant_account_provider_key;
ALTER TABLE IF EXISTS ONLY public.billing_payment_attempts DROP CONSTRAINT IF EXISTS billing_payment_attempts_provider_merchant_account_payment__key;
ALTER TABLE IF EXISTS ONLY public.billing_payment_attempts DROP CONSTRAINT IF EXISTS billing_payment_attempts_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_payment_attempts DROP CONSTRAINT IF EXISTS billing_payment_attempts_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.billing_outbox_events DROP CONSTRAINT IF EXISTS billing_outbox_events_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_outbox_events DROP CONSTRAINT IF EXISTS billing_outbox_events_event_key_key;
ALTER TABLE IF EXISTS ONLY public.billing_orders DROP CONSTRAINT IF EXISTS billing_orders_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_orders DROP CONSTRAINT IF EXISTS billing_orders_agency_id_kind_idempotency_key_key;
ALTER TABLE IF EXISTS ONLY public.billing_orders DROP CONSTRAINT IF EXISTS billing_orders_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.billing_order_fulfillments DROP CONSTRAINT IF EXISTS billing_order_fulfillments_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_order_fulfillments DROP CONSTRAINT IF EXISTS billing_order_fulfillments_order_id_benefit_type_key;
ALTER TABLE IF EXISTS ONLY public.billing_migration_reviews DROP CONSTRAINT IF EXISTS billing_migration_reviews_source_table_source_id_key;
ALTER TABLE IF EXISTS ONLY public.billing_migration_reviews DROP CONSTRAINT IF EXISTS billing_migration_reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_audit_events DROP CONSTRAINT IF EXISTS billing_audit_events_pkey;
ALTER TABLE IF EXISTS ONLY public.audit_logs DROP CONSTRAINT IF EXISTS audit_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_video_jobs DROP CONSTRAINT IF EXISTS ai_video_jobs_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_usages DROP CONSTRAINT IF EXISTS ai_credit_usages_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_reservations DROP CONSTRAINT IF EXISTS ai_credit_reservations_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_reservations DROP CONSTRAINT IF EXISTS ai_credit_reservations_job_id_key;
ALTER TABLE IF EXISTS ONLY public.ai_credit_reservations DROP CONSTRAINT IF EXISTS ai_credit_reservations_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.ai_credit_operation_prices DROP CONSTRAINT IF EXISTS ai_credit_operation_prices_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_operation_prices DROP CONSTRAINT IF EXISTS ai_credit_operation_prices_operation_revision_key;
ALTER TABLE IF EXISTS ONLY public.ai_credit_ledgers DROP CONSTRAINT IF EXISTS ai_credit_ledgers_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_ledgers DROP CONSTRAINT IF EXISTS ai_credit_ledgers_agency_id_month_key;
ALTER TABLE IF EXISTS ONLY public.ai_credit_creator_limits DROP CONSTRAINT IF EXISTS ai_credit_creator_limits_pkey;
ALTER TABLE IF EXISTS ONLY public.ai_credit_creator_limits DROP CONSTRAINT IF EXISTS ai_credit_creator_limits_agency_id_creator_id_key;
ALTER TABLE IF EXISTS ONLY public.ai_caption_generations DROP CONSTRAINT IF EXISTS ai_caption_generations_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscriptions DROP CONSTRAINT IF EXISTS agency_subscriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscriptions DROP CONSTRAINT IF EXISTS agency_subscriptions_agency_id_key;
ALTER TABLE IF EXISTS ONLY public.agency_subscriptions DROP CONSTRAINT IF EXISTS agency_subscriptions_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_subscription_id_starts_at_key;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_order_id_key;
ALTER TABLE IF EXISTS ONLY public.agency_subscription_periods DROP CONSTRAINT IF EXISTS agency_subscription_periods_agency_id_id_key;
ALTER TABLE IF EXISTS ONLY public.agency_storage_usage DROP CONSTRAINT IF EXISTS agency_storage_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_storage_reservations DROP CONSTRAINT IF EXISTS agency_storage_reservations_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_storage_reservations DROP CONSTRAINT IF EXISTS agency_storage_reservations_material_id_key;
ALTER TABLE IF EXISTS ONLY public.agency_storage_reservations DROP CONSTRAINT IF EXISTS agency_storage_reservations_agency_id_actor_id_request_key_key;
ALTER TABLE IF EXISTS ONLY public.agency_resource_usage DROP CONSTRAINT IF EXISTS agency_resource_usage_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_members DROP CONSTRAINT IF EXISTS agency_members_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_members DROP CONSTRAINT IF EXISTS agency_members_agency_id_user_id_key;
ALTER TABLE IF EXISTS ONLY public.agency_invitations DROP CONSTRAINT IF EXISTS agency_invitations_token_key;
ALTER TABLE IF EXISTS ONLY public.agency_invitations DROP CONSTRAINT IF EXISTS agency_invitations_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_drive_connections DROP CONSTRAINT IF EXISTS agency_drive_connections_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_drive_connections DROP CONSTRAINT IF EXISTS agency_drive_connections_connection_id_key;
ALTER TABLE IF EXISTS ONLY public.agency_credit_wallets DROP CONSTRAINT IF EXISTS agency_credit_wallets_pkey;
ALTER TABLE IF EXISTS ONLY public.agency_creator_credit_limits DROP CONSTRAINT IF EXISTS agency_creator_credit_limits_pkey;
ALTER TABLE IF EXISTS ONLY public.agencies DROP CONSTRAINT IF EXISTS agencies_pkey;
ALTER TABLE IF EXISTS ONLY public.admin_report_exports DROP CONSTRAINT IF EXISTS admin_report_exports_pkey;
ALTER TABLE IF EXISTS ONLY public.admin_notifications DROP CONSTRAINT IF EXISTS admin_notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.admin_email_outbox DROP CONSTRAINT IF EXISTS admin_email_outbox_pkey;
ALTER TABLE IF EXISTS ONLY public.admin_email_outbox DROP CONSTRAINT IF EXISTS admin_email_outbox_event_key_key;
ALTER TABLE IF EXISTS ONLY public.admin_account_operations DROP CONSTRAINT IF EXISTS admin_account_operations_pkey;
ALTER TABLE IF EXISTS ONLY public.account_activation_tokens DROP CONSTRAINT IF EXISTS account_activation_tokens_token_hash_key;
ALTER TABLE IF EXISTS ONLY public.account_activation_tokens DROP CONSTRAINT IF EXISTS account_activation_tokens_pkey;
ALTER TABLE IF EXISTS public.audit_logs ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.workspaces;
DROP TABLE IF EXISTS public.workspace_templates;
DROP TABLE IF EXISTS public.workspace_members;
DROP TABLE IF EXISTS public.workspace_media_packages;
DROP TABLE IF EXISTS public.workspace_invitations;
DROP TABLE IF EXISTS public.workspace_hashtags;
DROP TABLE IF EXISTS public.workspace_drive_folders;
DROP TABLE IF EXISTS public.workspace_credit_usage;
DROP TABLE IF EXISTS public.workspace_credit_limits;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_system_roles;
DROP TABLE IF EXISTS public.user_subscriptions;
DROP TABLE IF EXISTS public.user_strikes;
DROP TABLE IF EXISTS public.user_refresh_tokens;
DROP TABLE IF EXISTS public.user_oauth_providers;
DROP TABLE IF EXISTS public.user_notifications;
DROP TABLE IF EXISTS public.transactions;
DROP TABLE IF EXISTS public.third_party_collaborators;
DROP TABLE IF EXISTS public.tasks;
DROP TABLE IF EXISTS public.task_content_snapshots;
DROP TABLE IF EXISTS public.task_content_operations;
DROP TABLE IF EXISTS public.system_storage_pools;
DROP TABLE IF EXISTS public.subscription_provider_checks;
DROP TABLE IF EXISTS public.subscription_plans;
DROP TABLE IF EXISTS public.subscription_plan_changes;
DROP TABLE IF EXISTS public.subscription_operational_issues;
DROP TABLE IF EXISTS public.subscription_observation_jobs;
DROP TABLE IF EXISTS public.storage_usage_entries;
DROP TABLE IF EXISTS public.storage_reservations;
DROP TABLE IF EXISTS public.storage_objects;
DROP TABLE IF EXISTS public.seed_runs;
DROP TABLE IF EXISTS public.sanction_reviews;
DROP TABLE IF EXISTS public.repository_drive_states;
DROP TABLE IF EXISTS public.repository_drive_operations;
DROP TABLE IF EXISTS public.repository_drive_objects;
DROP TABLE IF EXISTS public.repository_drive_generations;
DROP TABLE IF EXISTS public.package_negotiation_events;
DROP TABLE IF EXISTS public.monitoring_servers;
DROP TABLE IF EXISTS public.monitoring_health_targets;
DROP TABLE IF EXISTS public.monitoring_health_results;
DROP TABLE IF EXISTS public.monitoring_enrollments;
DROP TABLE IF EXISTS public.monitoring_collectors;
DROP TABLE IF EXISTS public.media_packages;
DROP TABLE IF EXISTS public.media_campaigns;
DROP TABLE IF EXISTS public.material_quota_releases;
DROP TABLE IF EXISTS public.material_audit_receipts;
DROP TABLE IF EXISTS public.mail_suppressions;
DROP TABLE IF EXISTS public.mail_send_quota;
DROP TABLE IF EXISTS public.mail_deliveries;
DROP TABLE IF EXISTS public.mail_batches;
DROP TABLE IF EXISTS public.mail_attachments;
DROP TABLE IF EXISTS public.credit_usage_periods;
DROP TABLE IF EXISTS public.credit_reservation_allocations;
DROP TABLE IF EXISTS public.credit_operations;
DROP TABLE IF EXISTS public.credit_grants;
DROP TABLE IF EXISTS public.credit_entries;
DROP TABLE IF EXISTS public.creator_credit_usage;
DROP TABLE IF EXISTS public.content_request_completion_jobs;
DROP TABLE IF EXISTS public.content_moderation_reviews;
DROP TABLE IF EXISTS public.client_profiles;
DROP TABLE IF EXISTS public.campaign_versions;
DROP TABLE IF EXISTS public.campaign_review_events;
DROP TABLE IF EXISTS public.campaign_deployments;
DROP TABLE IF EXISTS public.campaign_collaborators;
DROP TABLE IF EXISTS public.brandhub_schema_migrations;
DROP TABLE IF EXISTS public.billing_plan_versions;
DROP TABLE IF EXISTS public.billing_payments;
DROP TABLE IF EXISTS public.billing_payment_events;
DROP TABLE IF EXISTS public.billing_payment_attempts;
DROP TABLE IF EXISTS public.billing_outbox_events;
DROP TABLE IF EXISTS public.billing_orders;
DROP TABLE IF EXISTS public.billing_order_fulfillments;
DROP TABLE IF EXISTS public.billing_migration_reviews;
DROP TABLE IF EXISTS public.billing_audit_events;
DROP SEQUENCE IF EXISTS public.audit_logs_id_seq;
DROP TABLE IF EXISTS public.audit_logs;
DROP TABLE IF EXISTS public.ai_video_jobs;
DROP TABLE IF EXISTS public.ai_credit_usages;
DROP TABLE IF EXISTS public.ai_credit_reservations;
DROP TABLE IF EXISTS public.ai_credit_operation_prices;
DROP TABLE IF EXISTS public.ai_credit_ledgers;
DROP TABLE IF EXISTS public.ai_credit_creator_limits;
DROP TABLE IF EXISTS public.ai_caption_generations;
DROP TABLE IF EXISTS public.agency_subscriptions;
DROP TABLE IF EXISTS public.agency_subscription_periods;
DROP TABLE IF EXISTS public.agency_storage_usage;
DROP TABLE IF EXISTS public.agency_storage_reservations;
DROP TABLE IF EXISTS public.agency_resource_usage;
DROP TABLE IF EXISTS public.agency_members;
DROP TABLE IF EXISTS public.agency_invitations;
DROP TABLE IF EXISTS public.agency_drive_connections;
DROP TABLE IF EXISTS public.agency_credit_wallets;
DROP TABLE IF EXISTS public.agency_creator_credit_limits;
DROP TABLE IF EXISTS public.agencies;
DROP TABLE IF EXISTS public.admin_report_exports;
DROP TABLE IF EXISTS public.admin_notifications;
DROP TABLE IF EXISTS public.admin_email_outbox;
DROP TABLE IF EXISTS public.admin_account_operations;
DROP TABLE IF EXISTS public.account_activation_tokens;
DROP FUNCTION IF EXISTS public.set_updated_at();
DROP FUNCTION IF EXISTS public.protect_package_negotiation_history();
DROP FUNCTION IF EXISTS public.prevent_audit_log_mutation();
DROP FUNCTION IF EXISTS public.mark_collaborator_usage_on_link();
DROP FUNCTION IF EXISTS public.guard_package_negotiation_history();
DROP FUNCTION IF EXISTS public.guard_credit_price_history();
DROP FUNCTION IF EXISTS public.guard_campaign_partner_usage();
DROP FUNCTION IF EXISTS public.billing_reject_ledger_mutation();
DROP FUNCTION IF EXISTS public.billing_guard_plan_version();
DROP FUNCTION IF EXISTS public.billing_guard_period_overlap();
DROP CAST IF EXISTS (public.workspaceindustry AS character varying);
DROP CAST IF EXISTS (character varying AS public.workspaceindustry);
DROP CAST IF EXISTS (character varying AS public.userstatus);
DROP CAST IF EXISTS (character varying AS public.transactiontype);
DROP CAST IF EXISTS (character varying AS public.transactionstatus);
DROP CAST IF EXISTS (character varying AS public.tasktype);
DROP CAST IF EXISTS (character varying AS public.subscriptionstatus);
DROP CAST IF EXISTS (character varying AS public.subscriptionplanname);
DROP CAST IF EXISTS (character varying AS public.packagenegotiationstatus);
DROP CAST IF EXISTS (character varying AS public.oauthprovider);
DROP CAST IF EXISTS (character varying AS public.memberrole);
DROP CAST IF EXISTS (character varying AS public.invitationstatus);
DROP CAST IF EXISTS (character varying AS public.entitystatus);
DROP CAST IF EXISTS (character varying AS public.cooperationstatus);
DROP CAST IF EXISTS (character varying AS public.companysize);
DROP CAST IF EXISTS (character varying AS public.collaboratortype);
DROP CAST IF EXISTS (character varying AS public.campaignstatus);
DROP CAST IF EXISTS (character varying AS public.auditaction);
DROP CAST IF EXISTS (character varying AS public.agencymemberrole);
DROP CAST IF EXISTS (character varying AS public.agencycategory);
DROP CAST IF EXISTS (public.userstatus AS character varying);
DROP CAST IF EXISTS (public.transactiontype AS character varying);
DROP CAST IF EXISTS (public.transactionstatus AS character varying);
DROP CAST IF EXISTS (public.tasktype AS character varying);
DROP CAST IF EXISTS (public.subscriptionstatus AS character varying);
DROP CAST IF EXISTS (public.subscriptionplanname AS character varying);
DROP CAST IF EXISTS (public.packagenegotiationstatus AS character varying);
DROP CAST IF EXISTS (public.oauthprovider AS character varying);
DROP CAST IF EXISTS (public.memberrole AS character varying);
DROP CAST IF EXISTS (public.invitationstatus AS character varying);
DROP CAST IF EXISTS (public.entitystatus AS character varying);
DROP CAST IF EXISTS (public.cooperationstatus AS character varying);
DROP CAST IF EXISTS (public.companysize AS character varying);
DROP CAST IF EXISTS (public.collaboratortype AS character varying);
DROP CAST IF EXISTS (public.campaignstatus AS character varying);
DROP CAST IF EXISTS (public.auditaction AS character varying);
DROP CAST IF EXISTS (public.agencymemberrole AS character varying);
DROP CAST IF EXISTS (public.agencycategory AS character varying);
DROP TYPE IF EXISTS public.workspaceindustry;
DROP TYPE IF EXISTS public.workspace_member_role;
DROP TYPE IF EXISTS public.workspace_industry;
DROP TYPE IF EXISTS public.userstatus;
DROP TYPE IF EXISTS public.user_status;
DROP TYPE IF EXISTS public.transactiontype;
DROP TYPE IF EXISTS public.transactionstatus;
DROP TYPE IF EXISTS public.transaction_type;
DROP TYPE IF EXISTS public.transaction_status;
DROP TYPE IF EXISTS public.tasktype;
DROP TYPE IF EXISTS public.task_type;
DROP TYPE IF EXISTS public.subscriptionstatus;
DROP TYPE IF EXISTS public.subscriptionplanname;
DROP TYPE IF EXISTS public.subscription_status;
DROP TYPE IF EXISTS public.subscription_plan_name;
DROP TYPE IF EXISTS public.packagenegotiationstatus;
DROP TYPE IF EXISTS public.package_negotiation_status;
DROP TYPE IF EXISTS public.oauthprovider;
DROP TYPE IF EXISTS public.oauth_provider;
DROP TYPE IF EXISTS public.memberrole;
DROP TYPE IF EXISTS public.invitationstatus;
DROP TYPE IF EXISTS public.invitation_status;
DROP TYPE IF EXISTS public.entitystatus;
DROP TYPE IF EXISTS public.entity_status;
DROP TYPE IF EXISTS public.cooperationstatus;
DROP TYPE IF EXISTS public.cooperation_status;
DROP TYPE IF EXISTS public.companysize;
DROP TYPE IF EXISTS public.company_size;
DROP TYPE IF EXISTS public.collaboratortype;
DROP TYPE IF EXISTS public.collaborator_type;
DROP TYPE IF EXISTS public.campaignstatus;
DROP TYPE IF EXISTS public.campaign_status;
DROP TYPE IF EXISTS public.auditaction;
DROP TYPE IF EXISTS public.audit_action;
DROP TYPE IF EXISTS public.agencymemberrole;
DROP TYPE IF EXISTS public.agencycategory;
DROP TYPE IF EXISTS public.agency_member_role;
DROP TYPE IF EXISTS public.agency_category;
DROP EXTENSION IF EXISTS pgcrypto;
--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: agency_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agency_category AS ENUM (
    'MARKETING',
    'FNB',
    'FASHION',
    'BEAUTY',
    'TECHNOLOGY',
    'REAL_ESTATE',
    'EDUCATION',
    'HEALTHCARE',
    'RETAIL',
    'FINANCE',
    'ENTERTAINMENT',
    'OTHER'
);


--
-- Name: agency_member_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agency_member_role AS ENUM (
    'OWNER',
    'MEMBER',
    'CLIENT'
);


--
-- Name: agencycategory; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agencycategory AS ENUM (
    'BEAUTY',
    'EDUCATION',
    'ENTERTAINMENT',
    'FASHION',
    'FINANCE',
    'FNB',
    'HEALTHCARE',
    'MARKETING',
    'OTHER',
    'REAL_ESTATE',
    'RETAIL',
    'TECHNOLOGY'
);


--
-- Name: agencymemberrole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agencymemberrole AS ENUM (
    'CLIENT',
    'MEMBER',
    'OWNER'
);


--
-- Name: audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.audit_action AS ENUM (
    'LOGIN',
    'LOGOUT',
    'TOKEN_REFRESH',
    'PASSWORD_RESET',
    'CREATE',
    'UPDATE',
    'DELETE',
    'ROLE_CHANGE',
    'PERMISSION_CHANGE',
    'VIEW',
    'EXPORT'
);


--
-- Name: auditaction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.auditaction AS ENUM (
    'CREATE',
    'DELETE',
    'DOWNLOAD_LINK_ISSUED',
    'EXPORT',
    'LOGIN',
    'LOGOUT',
    'PASSWORD_RESET',
    'PERMISSION_CHANGE',
    'ROLE_CHANGE',
    'TOKEN_REFRESH',
    'UPDATE',
    'VIEW'
);


--
-- Name: campaign_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.campaign_status AS ENUM (
    'DRAFT',
    'APPROVED',
    'IN_PROGRESS',
    'COMPLETED'
);


--
-- Name: campaignstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.campaignstatus AS ENUM (
    'APPROVED',
    'COMPLETED',
    'DRAFT',
    'IN_PROGRESS'
);


--
-- Name: collaborator_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collaborator_type AS ENUM (
    'NEWSPAPER',
    'BANNER',
    'TV',
    'OTHER'
);


--
-- Name: collaboratortype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collaboratortype AS ENUM (
    'BANNER',
    'NEWSPAPER',
    'OTHER',
    'TV'
);


--
-- Name: company_size; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.company_size AS ENUM (
    'SIZE_1_10',
    'SIZE_11_50',
    'SIZE_51_200',
    'SIZE_201_500',
    'SIZE_500_PLUS'
);


--
-- Name: companysize; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.companysize AS ENUM (
    'SIZE_11_50',
    'SIZE_1_10',
    'SIZE_201_500',
    'SIZE_500_PLUS',
    'SIZE_51_200'
);


--
-- Name: cooperation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cooperation_status AS ENUM (
    'CONTACTED',
    'NEGOTIATING',
    'CONFIRMED',
    'LIVE'
);


--
-- Name: cooperationstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cooperationstatus AS ENUM (
    'CONFIRMED',
    'CONTACTED',
    'LIVE',
    'NEGOTIATING'
);


--
-- Name: entity_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entity_status AS ENUM (
    'ACTIVE',
    'SOFT_DELETED',
    'INACTIVE'
);


--
-- Name: entitystatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entitystatus AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SOFT_DELETED'
);


--
-- Name: invitation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invitation_status AS ENUM (
    'PENDING',
    'ACCEPTED',
    'EXPIRED',
    'REVOKED'
);


--
-- Name: invitationstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invitationstatus AS ENUM (
    'ACCEPTED',
    'EXPIRED',
    'PENDING',
    'REVOKED'
);


--
-- Name: memberrole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.memberrole AS ENUM (
    'CLIENT',
    'CREATOR',
    'MANAGER',
    'OWNER'
);


--
-- Name: oauth_provider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oauth_provider AS ENUM (
    'GOOGLE',
    'FACEBOOK'
);


--
-- Name: oauthprovider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oauthprovider AS ENUM (
    'GOOGLE'
);


--
-- Name: package_negotiation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.package_negotiation_status AS ENUM (
    'DRAFT',
    'CLIENT_REQUESTED_CHANGE',
    'AGENCY_COUNTERED',
    'APPROVED'
);


--
-- Name: packagenegotiationstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.packagenegotiationstatus AS ENUM (
    'AGENCY_COUNTERED',
    'APPROVED',
    'CLIENT_REQUESTED_CHANGE',
    'DRAFT'
);


--
-- Name: subscription_plan_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_plan_name AS ENUM (
    'BASIC',
    'PRO',
    'ENTERPRISE'
);


--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_status AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'CANCELLED',
    'TRIALING'
);


--
-- Name: subscriptionplanname; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscriptionplanname AS ENUM (
    'BASIC',
    'ENTERPRISE',
    'PRO'
);


--
-- Name: subscriptionstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscriptionstatus AS ENUM (
    'ACTIVE',
    'CANCELLED',
    'EXPIRED',
    'TRIALING'
);


--
-- Name: task_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.task_type AS ENUM (
    'POST'
);


--
-- Name: tasktype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tasktype AS ENUM (
    'EVENT_PLAN',
    'LIVESTREAM',
    'POST',
    'PRESS_RECOMMENDATION',
    'SURVEY'
);


--
-- Name: transaction_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transaction_status AS ENUM (
    'PENDING',
    'COMPLETED',
    'FAILED',
    'REFUNDED'
);


--
-- Name: transaction_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transaction_type AS ENUM (
    'UPGRADE_PLAN',
    'BUY_CREDIT'
);


--
-- Name: transactionstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactionstatus AS ENUM (
    'COMPLETED',
    'FAILED',
    'PENDING',
    'REFUNDED'
);


--
-- Name: transactiontype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactiontype AS ENUM (
    'BUY_CREDIT',
    'UPGRADE_PLAN'
);


--
-- Name: user_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_status AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'DELETED',
    'DEACTIVATED',
    'FLAGGED',
    'PENDING_VERIFICATION'
);


--
-- Name: userstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.userstatus AS ENUM (
    'ACTIVE',
    'DEACTIVATED',
    'DELETED',
    'FLAGGED',
    'PENDING_VERIFICATION',
    'SUSPENDED'
);


--
-- Name: workspace_industry; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workspace_industry AS ENUM (
    'FNB',
    'FASHION',
    'BEAUTY',
    'TECHNOLOGY',
    'REAL_ESTATE',
    'EDUCATION',
    'HEALTHCARE',
    'SERVICES',
    'RETAIL',
    'OTHER'
);


--
-- Name: workspace_member_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workspace_member_role AS ENUM (
    'MANAGER',
    'CREATOR',
    'CLIENT'
);


--
-- Name: workspaceindustry; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workspaceindustry AS ENUM (
    'BEAUTY',
    'EDUCATION',
    'FASHION',
    'FNB',
    'HEALTHCARE',
    'OTHER',
    'REAL_ESTATE',
    'RETAIL',
    'SERVICES',
    'TECHNOLOGY'
);


--
-- Name: CAST (public.agencycategory AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.agencycategory AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.agencymemberrole AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.agencymemberrole AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.auditaction AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.auditaction AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.campaignstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.campaignstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.collaboratortype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.collaboratortype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.companysize AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.companysize AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.cooperationstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.cooperationstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.entitystatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.entitystatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.invitationstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.invitationstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.memberrole AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.memberrole AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.oauthprovider AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.oauthprovider AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.packagenegotiationstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.packagenegotiationstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.subscriptionplanname AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.subscriptionplanname AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.subscriptionstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.subscriptionstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.tasktype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.tasktype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.transactionstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.transactionstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.transactiontype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.transactiontype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.userstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.userstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.agencycategory); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.agencycategory) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.agencymemberrole); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.agencymemberrole) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.auditaction); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.auditaction) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.campaignstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.campaignstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.collaboratortype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.collaboratortype) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.companysize); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.companysize) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.cooperationstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.cooperationstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.entitystatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.entitystatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.invitationstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.invitationstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.memberrole); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.memberrole) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.oauthprovider); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.oauthprovider) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.packagenegotiationstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.packagenegotiationstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.subscriptionplanname); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.subscriptionplanname) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.subscriptionstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.subscriptionstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.tasktype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.tasktype) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.transactionstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.transactionstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.transactiontype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.transactiontype) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.userstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.userstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.workspaceindustry); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.workspaceindustry) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.workspaceindustry AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.workspaceindustry AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: billing_guard_period_overlap(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.billing_guard_period_overlap() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 PERFORM 1 FROM agency_subscriptions WHERE id=NEW.subscription_id AND agency_id=NEW.agency_id FOR UPDATE;
 IF EXISTS(SELECT 1 FROM agency_subscription_periods p WHERE p.subscription_id=NEW.subscription_id AND p.id<>NEW.id
   AND tstzrange(p.starts_at,p.ends_at,'[)') && tstzrange(NEW.starts_at,NEW.ends_at,'[)')) THEN
  RAISE EXCEPTION 'Subscription periods cannot overlap' USING ERRCODE='23514';
 END IF;
 RETURN NEW;
END $$;


--
-- Name: billing_guard_plan_version(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.billing_guard_plan_version() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF TG_OP = 'DELETE' OR TG_OP = 'TRUNCATE' THEN
    RAISE EXCEPTION 'Plan versions are immutable; disable sale instead' USING ERRCODE = '23514';
  END IF;
  IF (to_jsonb(NEW) - 'is_sellable' - 'billing_scope')
       IS DISTINCT FROM (to_jsonb(OLD) - 'is_sellable' - 'billing_scope') THEN
    RAISE EXCEPTION 'Create a new plan version to change price or benefits' USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END $$;


--
-- Name: billing_reject_ledger_mutation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.billing_reject_ledger_mutation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN RAISE EXCEPTION 'Billing journal is append-only; use a reversal entry' USING ERRCODE='23514'; END $$;


--
-- Name: guard_campaign_partner_usage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.guard_campaign_partner_usage() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE partner_active BOOLEAN;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.collaborator_id = OLD.collaborator_id THEN
        RETURN NEW;
    END IF;
    SELECT is_active INTO partner_active FROM third_party_collaborators
    WHERE id = NEW.collaborator_id FOR UPDATE;
    IF partner_active IS FALSE THEN
        RAISE EXCEPTION 'Inactive collaborator cannot be assigned' USING ERRCODE = '23514';
    END IF;
    UPDATE third_party_collaborators
    SET first_used_at = CURRENT_TIMESTAMP, version = version + 1
    WHERE id = NEW.collaborator_id AND first_used_at IS NULL;
    RETURN NEW;
END;
$$;


--
-- Name: guard_credit_price_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.guard_credit_price_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN RAISE EXCEPTION 'Credit price versions are append-only'; END $$;


--
-- Name: guard_package_negotiation_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.guard_package_negotiation_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Preserve existing parent hard-delete cascades without opening direct event deletion.
    IF TG_OP = 'DELETE' AND pg_trigger_depth() > 1 THEN RETURN OLD; END IF;
    RAISE EXCEPTION 'Package negotiation history is append-only' USING ERRCODE = '23514';
END;
$$;


--
-- Name: mark_collaborator_usage_on_link(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_collaborator_usage_on_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE active BOOLEAN;
BEGIN
    SELECT is_active INTO active
      FROM third_party_collaborators
     WHERE id = NEW.collaborator_id
     FOR UPDATE;
    IF active IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'collaborator does not exist';
    END IF;
    IF NOT active THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'collaborator is inactive';
    END IF;
    UPDATE third_party_collaborators
       SET first_used_at = COALESCE(first_used_at, NOW()),
           version = version + 1
     WHERE id = NEW.collaborator_id;
    RETURN NEW;
END;
$$;


--
-- Name: prevent_audit_log_mutation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_audit_log_mutation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'audit_logs is append-only and cannot be updated or deleted';
END;
$$;


--
-- Name: protect_package_negotiation_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_package_negotiation_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE parent_exists BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        -- Permit FK cascade only after the parent selection has been deleted.
        EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I.workspace_media_packages WHERE id = $1)',
                       TG_TABLE_SCHEMA)
            INTO parent_exists USING OLD.workspace_media_package_id;
        IF NOT parent_exists THEN
            RETURN OLD;
        END IF;
    END IF;
    RAISE EXCEPTION 'package_negotiation_events is append-only';
END;
$_$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_activation_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_activation_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash character(64) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    revoked_at timestamp with time zone,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT account_activation_tokens_check CHECK ((expires_at > created_at))
);


--
-- Name: admin_account_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_account_operations (
    user_id uuid NOT NULL,
    operation_id uuid NOT NULL,
    payload_hash character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: admin_email_outbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_email_outbox (
    id uuid NOT NULL,
    event_key character varying(150) NOT NULL,
    recipient character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sent_at timestamp with time zone,
    next_attempt_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    notification_id uuid,
    failed_at timestamp with time zone,
    last_error character varying(255)
);


--
-- Name: admin_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_notifications (
    id uuid NOT NULL,
    title character varying(200) NOT NULL,
    content character varying(5000) NOT NULL,
    type character varying(20) NOT NULL,
    target_type character varying(10) NOT NULL,
    target_values text[] DEFAULT '{}'::text[] NOT NULL,
    action_url character varying(500),
    status character varying(12) NOT NULL,
    scheduled_at timestamp with time zone,
    sent_at timestamp with time zone,
    recipient_count integer,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    row_version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT admin_notifications_check CHECK ((((status)::text <> 'SCHEDULED'::text) OR (scheduled_at IS NOT NULL))),
    CONSTRAINT admin_notifications_check1 CHECK ((((target_type)::text = 'ALL'::text) OR (cardinality(target_values) > 0))),
    CONSTRAINT admin_notifications_content_check CHECK (((char_length(btrim((content)::text)) >= 10) AND (char_length(btrim((content)::text)) <= 5000))),
    CONSTRAINT admin_notifications_status_check CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'SCHEDULED'::character varying, 'SENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT admin_notifications_target_type_check CHECK (((target_type)::text = ANY ((ARRAY['ALL'::character varying, 'BY_PLAN'::character varying, 'BY_ROLE'::character varying])::text[]))),
    CONSTRAINT admin_notifications_title_check CHECK (((char_length(btrim((title)::text)) >= 5) AND (char_length(btrim((title)::text)) <= 200))),
    CONSTRAINT admin_notifications_type_check CHECK (((type)::text = ANY ((ARRAY['SYSTEM'::character varying, 'MAINTENANCE'::character varying, 'UPDATE'::character varying, 'PROMOTION'::character varying])::text[])))
);


--
-- Name: admin_report_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_report_exports (
    id uuid NOT NULL,
    report_type character varying(20) NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    timezone character varying(40) NOT NULL,
    as_of timestamp with time zone NOT NULL,
    row_count integer NOT NULL,
    file_name character varying(120) NOT NULL,
    file_size integer NOT NULL,
    content bytea,
    token_hash character(64) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT admin_report_exports_check CHECK ((period_end >= period_start)),
    CONSTRAINT admin_report_exports_check1 CHECK ((expires_at > created_at)),
    CONSTRAINT admin_report_exports_report_type_check CHECK (((report_type)::text = ANY ((ARRAY['REVENUE'::character varying, 'USER'::character varying, 'PLATFORM'::character varying])::text[])))
);


--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agencies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    owner_id uuid NOT NULL,
    logo_url character varying(255),
    banner_url character varying(255),
    description text,
    category public.agency_category,
    company_size public.company_size,
    website character varying(255),
    phone character varying(30),
    location character varying(255),
    brand_color character varying(9),
    logo_icon character varying(50),
    tagline character varying(140),
    founded_year integer,
    facebook_url character varying(255),
    linkedin_url character varying(255),
    instagram_url character varying(255),
    status public.entity_status DEFAULT 'ACTIVE'::public.entity_status NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agency_creator_credit_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_creator_credit_limits (
    agency_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    cap bigint,
    version bigint DEFAULT 0 NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT agency_creator_credit_limits_cap_check CHECK ((cap >= 0)),
    CONSTRAINT agency_creator_credit_limits_version_check CHECK ((version >= 0))
);


--
-- Name: agency_credit_wallets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_credit_wallets (
    agency_id uuid NOT NULL,
    available_credits bigint DEFAULT 0 NOT NULL,
    reserved_credits bigint DEFAULT 0 NOT NULL,
    opening_balance_state text DEFAULT 'PENDING'::text NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT agency_credit_wallets_available_credits_check CHECK ((available_credits >= 0)),
    CONSTRAINT agency_credit_wallets_opening_balance_state_check CHECK ((opening_balance_state = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text]))),
    CONSTRAINT agency_credit_wallets_reserved_credits_check CHECK ((reserved_credits >= 0)),
    CONSTRAINT agency_credit_wallets_version_check CHECK ((version >= 0))
);


--
-- Name: agency_drive_connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_drive_connections (
    agency_id uuid NOT NULL,
    connection_id uuid NOT NULL,
    connected_by uuid NOT NULL,
    account_id text NOT NULL,
    account_email text NOT NULL,
    refresh_token_ciphertext text NOT NULL,
    root_folder_id text NOT NULL,
    connected boolean DEFAULT true NOT NULL,
    capacity_revision bigint DEFAULT 0 NOT NULL,
    quota_full_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    disconnecting boolean DEFAULT false NOT NULL,
    granted_scope text DEFAULT ''::text NOT NULL
);


--
-- Name: agency_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    invited_email character varying(255) NOT NULL,
    invited_by uuid NOT NULL,
    token character varying(255) NOT NULL,
    note character varying(500),
    workspace_id uuid,
    role public.workspace_member_role,
    status public.invitation_status DEFAULT 'PENDING'::public.invitation_status NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agency_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.agency_member_role DEFAULT 'MEMBER'::public.agency_member_role NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agency_resource_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_resource_usage (
    agency_id uuid NOT NULL,
    used_bytes bigint DEFAULT 0 NOT NULL,
    reserved_bytes bigint DEFAULT 0 NOT NULL,
    active_workspaces bigint DEFAULT 0 NOT NULL,
    internal_members bigint DEFAULT 0 NOT NULL,
    active_clients bigint DEFAULT 0 NOT NULL,
    inventory_state text DEFAULT 'PENDING'::text NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    reconciled_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT agency_resource_usage_active_clients_check CHECK ((active_clients >= 0)),
    CONSTRAINT agency_resource_usage_active_workspaces_check CHECK ((active_workspaces >= 0)),
    CONSTRAINT agency_resource_usage_internal_members_check CHECK ((internal_members >= 0)),
    CONSTRAINT agency_resource_usage_inventory_state_check CHECK ((inventory_state = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text]))),
    CONSTRAINT agency_resource_usage_reserved_bytes_check CHECK ((reserved_bytes >= 0)),
    CONSTRAINT agency_resource_usage_used_bytes_check CHECK ((used_bytes >= 0)),
    CONSTRAINT agency_resource_usage_version_check CHECK ((version >= 0))
);


--
-- Name: agency_storage_reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_storage_reservations (
    id uuid NOT NULL,
    agency_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    material_id character varying(64) NOT NULL,
    request_key character varying(128) NOT NULL,
    fingerprint character varying(64) NOT NULL,
    provider character varying(32) NOT NULL,
    reserved_bytes bigint NOT NULL,
    committed_bytes bigint,
    derivative boolean DEFAULT false NOT NULL,
    state character varying(16) NOT NULL,
    phase character varying(24) DEFAULT 'CREATED'::character varying NOT NULL,
    pool_hold_bytes bigint DEFAULT 0 NOT NULL,
    staging_cleaned_at timestamp with time zone,
    claim_token uuid,
    claim_until timestamp with time zone,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT agency_storage_reservations_check CHECK (((committed_bytes >= 0) AND (committed_bytes <= reserved_bytes))),
    CONSTRAINT agency_storage_reservations_pool_hold_bytes_check CHECK ((pool_hold_bytes >= 0)),
    CONSTRAINT agency_storage_reservations_provider_check CHECK (((provider)::text = ANY ((ARRAY['SYSTEM_GDRIVE'::character varying, 'SYSTEM_S3'::character varying, 'USER_GDRIVE'::character varying])::text[]))),
    CONSTRAINT agency_storage_reservations_reserved_bytes_check CHECK ((reserved_bytes > 0)),
    CONSTRAINT agency_storage_reservations_state_check CHECK (((state)::text = ANY ((ARRAY['RESERVED'::character varying, 'COMMITTED'::character varying, 'RELEASED'::character varying, 'EXPIRED'::character varying])::text[])))
);


--
-- Name: agency_storage_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_storage_usage (
    agency_id uuid NOT NULL,
    used_bytes bigint DEFAULT 0 NOT NULL,
    reserved_bytes bigint DEFAULT 0 NOT NULL,
    inventory_verified_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT agency_storage_usage_reserved_bytes_check CHECK ((reserved_bytes >= 0)),
    CONSTRAINT agency_storage_usage_used_bytes_check CHECK ((used_bytes >= 0))
);


--
-- Name: agency_subscription_periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_subscription_periods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    subscription_id uuid NOT NULL,
    plan_version_id uuid NOT NULL,
    order_id uuid NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    plan_billing_scope text DEFAULT 'AGENCY'::text NOT NULL,
    CONSTRAINT agency_subscription_periods_check CHECK ((ends_at > starts_at)),
    CONSTRAINT agency_subscription_periods_plan_billing_scope_check CHECK ((plan_billing_scope = 'AGENCY'::text)),
    CONSTRAINT agency_subscription_periods_status_check CHECK ((status = ANY (ARRAY['FUTURE'::text, 'CURRENT'::text, 'ENDED'::text])))
);


--
-- Name: agency_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    plan_version_id uuid NOT NULL,
    status text DEFAULT 'ACTIVE'::text NOT NULL,
    current_period_start timestamp with time zone DEFAULT now() NOT NULL,
    current_period_end timestamp with time zone,
    migration_state text DEFAULT 'REVIEW_REQUIRED'::text NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    plan_billing_scope text DEFAULT 'AGENCY'::text NOT NULL,
    CONSTRAINT agency_subscriptions_check CHECK (((current_period_end IS NULL) OR (current_period_end > current_period_start))),
    CONSTRAINT agency_subscriptions_migration_state_check CHECK ((migration_state = ANY (ARRAY['REVIEW_REQUIRED'::text, 'READY'::text]))),
    CONSTRAINT agency_subscriptions_plan_billing_scope_check CHECK ((plan_billing_scope = 'AGENCY'::text)),
    CONSTRAINT agency_subscriptions_status_check CHECK ((status = ANY (ARRAY['ACTIVE'::text, 'EXPIRED'::text, 'SUSPENDED'::text]))),
    CONSTRAINT agency_subscriptions_version_check CHECK ((version >= 0))
);


--
-- Name: ai_caption_generations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_caption_generations (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    user_id uuid NOT NULL,
    task_id uuid,
    request jsonb NOT NULL,
    variants jsonb NOT NULL,
    context jsonb DEFAULT '{}'::jsonb NOT NULL,
    credits bigint DEFAULT 0 NOT NULL,
    chosen_type character varying(20),
    chosen_action character varying(10),
    final_text text,
    chosen_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ai_caption_generations_chosen_action_check CHECK (((chosen_action)::text = ANY ((ARRAY['INSERT'::character varying, 'REPLACE'::character varying])::text[])))
);


--
-- Name: ai_credit_creator_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_credit_creator_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    monthly_limit integer NOT NULL,
    set_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_credit_ledgers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_credit_ledgers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    month character varying(7) NOT NULL,
    used_amount integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_credit_operation_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_credit_operation_prices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    operation character varying(40) NOT NULL,
    revision bigint NOT NULL,
    unit_credits bigint NOT NULL,
    enabled boolean NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ai_credit_operation_prices_operation_check CHECK (((operation)::text = ANY ((ARRAY['CONTENT_GENERATE'::character varying, 'CAPTION_VARIANTS'::character varying, 'HASHTAG_GENERATE'::character varying, 'AMBASSADOR_GENERATE'::character varying, 'CHARACTER_SHEET'::character varying, 'COMMERCIAL_IMAGE'::character varying, 'VIDEO_GENERATE'::character varying])::text[]))),
    CONSTRAINT ai_credit_operation_prices_revision_check CHECK ((revision > 0)),
    CONSTRAINT ai_credit_operation_prices_unit_credits_check CHECK ((unit_credits >= 0))
);


--
-- Name: ai_credit_reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_credit_reservations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    job_id uuid NOT NULL,
    agency_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    period_id uuid NOT NULL,
    action text NOT NULL,
    model text NOT NULL,
    rate_version text NOT NULL,
    status text NOT NULL,
    reserved_amount bigint NOT NULL,
    charged_amount bigint DEFAULT 0 NOT NULL,
    provider_job_id text,
    deadline timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    settled_at timestamp with time zone,
    request_key character varying(128) NOT NULL,
    payload_hash character varying(64) NOT NULL,
    price_id uuid,
    unit_credits bigint NOT NULL,
    units integer NOT NULL,
    successful_units integer,
    execution_state character varying(16) DEFAULT 'READY'::character varying NOT NULL,
    execution_response jsonb,
    execution_updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ai_credit_reservations_charged_amount_check CHECK ((charged_amount >= 0)),
    CONSTRAINT ai_credit_reservations_check CHECK ((charged_amount <= reserved_amount)),
    CONSTRAINT ai_credit_reservations_check1 CHECK ((deadline > created_at)),
    CONSTRAINT ai_credit_reservations_check2 CHECK (((status = 'SETTLED'::text) OR (charged_amount = 0))),
    CONSTRAINT ai_credit_reservations_check3 CHECK (((status <> ALL (ARRAY['SETTLED'::text, 'RELEASED'::text])) OR (settled_at IS NOT NULL))),
    CONSTRAINT ai_credit_reservations_execution_state_check CHECK (((execution_state)::text = ANY ((ARRAY['READY'::character varying, 'RUNNING'::character varying, 'WAITING'::character varying, 'SUCCEEDED'::character varying, 'FAILED'::character varying, 'UNKNOWN'::character varying])::text[]))),
    CONSTRAINT ai_credit_reservations_payload_hash_check CHECK (((payload_hash)::text ~ '^[a-f0-9]{64}$'::text)),
    CONSTRAINT ai_credit_reservations_reserved_amount_check CHECK ((reserved_amount >= 0)),
    CONSTRAINT ai_credit_reservations_status_check CHECK ((status = ANY (ARRAY['RESERVED'::text, 'UNKNOWN'::text, 'SETTLED'::text, 'RELEASED'::text]))),
    CONSTRAINT ai_credit_reservations_unit_credits_check CHECK ((unit_credits >= 0)),
    CONSTRAINT ai_credit_reservations_units_check CHECK ((units > 0)),
    CONSTRAINT ck_ai_credit_frozen_amount CHECK (((reserved_amount)::numeric = ((unit_credits)::numeric * (units)::numeric))),
    CONSTRAINT ck_ai_credit_outcome CHECK ((((status = ANY (ARRAY['RESERVED'::text, 'UNKNOWN'::text])) AND (successful_units IS NULL) AND (settled_at IS NULL)) OR ((status = 'SETTLED'::text) AND (successful_units IS NOT NULL) AND (successful_units > 0) AND (successful_units <= units) AND (settled_at IS NOT NULL) AND ((charged_amount)::numeric = ((unit_credits)::numeric * (successful_units)::numeric))) OR ((status = 'RELEASED'::text) AND (successful_units IS NOT NULL) AND (successful_units = 0) AND (charged_amount = 0) AND (settled_at IS NOT NULL)))),
    CONSTRAINT ck_ai_credit_price_source CHECK ((((action = ANY (ARRAY['CONTENT_GENERATE'::text, 'AMBASSADOR_GENERATE'::text, 'COMMERCIAL_IMAGE'::text, 'VIDEO_GENERATE'::text])) AND (price_id IS NOT NULL)) OR ((action = ANY (ARRAY['CAPTION_VARIANTS'::text, 'HASHTAG_GENERATE'::text, 'CHARACTER_SHEET'::text])) AND (price_id IS NULL) AND (unit_credits = 0) AND (rate_version = 'FREE_V1'::text))))
);


--
-- Name: ai_credit_usages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_credit_usages (
    id uuid NOT NULL,
    agency_id uuid NOT NULL,
    user_id uuid NOT NULL,
    workspace_id uuid,
    feature character varying(40) NOT NULL,
    credits integer NOT NULL,
    month character varying(7) NOT NULL,
    reference character varying(120),
    refunded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ai_credit_usages_credits_check CHECK ((credits >= 0))
);


--
-- Name: ai_video_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_video_jobs (
    id character varying(64) NOT NULL,
    workspace_id uuid NOT NULL,
    user_id uuid NOT NULL,
    usage_id uuid,
    prompt text NOT NULL,
    style_key character varying(40),
    ambassador_id character varying(80),
    aspect_ratio character varying(5) NOT NULL,
    status character varying(12) DEFAULT 'PENDING'::character varying NOT NULL,
    video_url text,
    error_code character varying(60),
    refunded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    s3_key character varying(300),
    reservation_id uuid,
    CONSTRAINT ai_video_jobs_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PROCESSING'::character varying, 'COMPLETED'::character varying, 'FAILED'::character varying])::text[]))),
    CONSTRAINT ck_ai_video_jobs_accounting_source CHECK (((usage_id IS NULL) OR (reservation_id IS NULL)))
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    agency_id uuid,
    user_id uuid NOT NULL,
    action public.audit_action NOT NULL,
    resource_type character varying(50) NOT NULL,
    resource_id character varying(255),
    ip_address character varying(45),
    user_agent character varying(512),
    old_value jsonb,
    new_value jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: billing_audit_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_audit_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    actor_id uuid,
    action text NOT NULL,
    resource_id uuid,
    before_value jsonb,
    after_value jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: billing_migration_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_migration_reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_table text NOT NULL,
    source_id uuid NOT NULL,
    owner_id uuid,
    candidate_agency_ids uuid[] DEFAULT '{}'::uuid[] NOT NULL,
    reason text NOT NULL,
    status text DEFAULT 'PENDING'::text NOT NULL,
    resolved_agency_id uuid,
    resolved_by uuid,
    resolution_note text,
    resolved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT billing_migration_reviews_check CHECK (((status <> 'RESOLVED'::text) OR ((resolved_by IS NOT NULL) AND (resolved_at IS NOT NULL) AND (resolution_note IS NOT NULL) AND (length(btrim(resolution_note)) > 0)))),
    CONSTRAINT billing_migration_reviews_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'RESOLVED'::text])))
);


--
-- Name: billing_order_fulfillments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_order_fulfillments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    order_id uuid NOT NULL,
    benefit_type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT billing_order_fulfillments_benefit_type_check CHECK ((benefit_type = ANY (ARRAY['SUBSCRIPTION_PERIOD'::text, 'CREDIT_GRANT'::text])))
);


--
-- Name: billing_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    payer_user_id uuid NOT NULL,
    kind text NOT NULL,
    status text DEFAULT 'PENDING_PAYMENT'::text NOT NULL,
    idempotency_key text NOT NULL,
    payload_hash text NOT NULL,
    amount numeric(18,0) NOT NULL,
    currency character(3) DEFAULT 'VND'::bpchar NOT NULL,
    product_snapshot jsonb NOT NULL,
    plan_version_id uuid,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    expires_at timestamp with time zone NOT NULL,
    paid_at timestamp with time zone,
    fulfilled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    plan_billing_scope text DEFAULT 'AGENCY'::text NOT NULL,
    CONSTRAINT billing_orders_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT billing_orders_check CHECK ((expires_at > created_at)),
    CONSTRAINT billing_orders_check1 CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT billing_orders_check2 CHECK ((((kind = 'SUBSCRIPTION'::text) AND (plan_version_id IS NOT NULL)) OR ((kind = 'CREDIT_TOPUP'::text) AND (plan_version_id IS NULL) AND (period_start IS NULL)))),
    CONSTRAINT billing_orders_check3 CHECK (((status <> 'FULFILLED'::text) OR ((paid_at IS NOT NULL) AND (fulfilled_at IS NOT NULL)))),
    CONSTRAINT billing_orders_currency_check CHECK ((currency = 'VND'::bpchar)),
    CONSTRAINT billing_orders_idempotency_key_check CHECK (((length(idempotency_key) >= 1) AND (length(idempotency_key) <= 200))),
    CONSTRAINT billing_orders_kind_check CHECK ((kind = ANY (ARRAY['SUBSCRIPTION'::text, 'CREDIT_TOPUP'::text]))),
    CONSTRAINT billing_orders_payload_hash_check CHECK ((length(payload_hash) = 64)),
    CONSTRAINT billing_orders_plan_billing_scope_check CHECK ((plan_billing_scope = 'AGENCY'::text)),
    CONSTRAINT billing_orders_product_snapshot_check CHECK ((jsonb_typeof(product_snapshot) = 'object'::text)),
    CONSTRAINT billing_orders_status_check CHECK ((status = ANY (ARRAY['PENDING_PAYMENT'::text, 'PAID'::text, 'FULFILLED'::text, 'EXPIRED'::text, 'CANCELLED'::text, 'REVIEW_REQUIRED'::text])))
);


--
-- Name: billing_outbox_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_outbox_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    event_key text NOT NULL,
    event_type text NOT NULL,
    payload jsonb NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    available_at timestamp with time zone DEFAULT now() NOT NULL,
    published_at timestamp with time zone,
    last_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT billing_outbox_events_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT billing_outbox_events_payload_check CHECK ((jsonb_typeof(payload) = 'object'::text))
);


--
-- Name: billing_payment_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_payment_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    order_id uuid NOT NULL,
    provider text DEFAULT 'SEEPAY'::text NOT NULL,
    merchant_account text NOT NULL,
    provider_order_code text NOT NULL,
    payment_link_id text,
    status text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT billing_payment_attempts_status_check CHECK ((status = ANY (ARRAY['PENDING'::text, 'SUCCEEDED'::text, 'FAILED'::text, 'UNKNOWN'::text])))
);


--
-- Name: billing_payment_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_payment_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider text NOT NULL,
    merchant_account text NOT NULL,
    event_key text NOT NULL,
    payload_hash text NOT NULL,
    order_id uuid,
    status text DEFAULT 'RECEIVED'::text NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    processed_at timestamp with time zone,
    last_error text,
    CONSTRAINT billing_payment_events_payload_hash_check CHECK ((length(payload_hash) = 64)),
    CONSTRAINT billing_payment_events_status_check CHECK ((status = ANY (ARRAY['RECEIVED'::text, 'PROCESSED'::text, 'REVIEW_REQUIRED'::text])))
);


--
-- Name: billing_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    attempt_id uuid NOT NULL,
    provider text NOT NULL,
    merchant_account text NOT NULL,
    provider_reference text NOT NULL,
    amount numeric(18,0) NOT NULL,
    currency character(3) NOT NULL,
    paid_at timestamp with time zone NOT NULL,
    verification_state text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT billing_payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT billing_payments_verification_state_check CHECK ((verification_state = ANY (ARRAY['VERIFIED'::text, 'REVIEW_REQUIRED'::text])))
);


--
-- Name: billing_plan_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_plan_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    version integer NOT NULL,
    display_name text NOT NULL,
    price_monthly numeric(18,0),
    currency character(3) DEFAULT 'VND'::bpchar NOT NULL,
    max_active_workspaces integer NOT NULL,
    max_internal_members integer NOT NULL,
    max_clients integer NOT NULL,
    storage_limit_bytes bigint NOT NULL,
    monthly_ai_credits bigint NOT NULL,
    max_concurrent_ai_jobs integer NOT NULL,
    version_retention_days integer NOT NULL,
    trash_retention_days integer NOT NULL,
    activity_retention_days integer NOT NULL,
    features jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_sellable boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    billing_scope text GENERATED ALWAYS AS (
CASE
    WHEN (code = 'PERSONAL'::text) THEN 'USER'::text
    ELSE 'AGENCY'::text
END) STORED,
    CONSTRAINT billing_plan_versions_activity_retention_days_check CHECK ((activity_retention_days >= 0)),
    CONSTRAINT billing_plan_versions_check CHECK (((NOT is_sellable) OR (price_monthly IS NOT NULL))),
    CONSTRAINT billing_plan_versions_check1 CHECK (((code <> 'BASIC'::text) OR (price_monthly = (0)::numeric))),
    CONSTRAINT billing_plan_versions_code_check CHECK ((code = ANY (ARRAY['PERSONAL'::text, 'BASIC'::text, 'PLUS'::text, 'ENTERPRISE'::text]))),
    CONSTRAINT billing_plan_versions_currency_check CHECK ((currency = 'VND'::bpchar)),
    CONSTRAINT billing_plan_versions_features_check CHECK ((jsonb_typeof(features) = 'object'::text)),
    CONSTRAINT billing_plan_versions_max_active_workspaces_check CHECK ((max_active_workspaces >= 0)),
    CONSTRAINT billing_plan_versions_max_clients_check CHECK ((max_clients >= 0)),
    CONSTRAINT billing_plan_versions_max_concurrent_ai_jobs_check CHECK ((max_concurrent_ai_jobs >= 1)),
    CONSTRAINT billing_plan_versions_max_internal_members_check CHECK ((max_internal_members >= 1)),
    CONSTRAINT billing_plan_versions_monthly_ai_credits_check CHECK ((monthly_ai_credits >= 0)),
    CONSTRAINT billing_plan_versions_price_monthly_check CHECK ((price_monthly >= (0)::numeric)),
    CONSTRAINT billing_plan_versions_storage_limit_bytes_check CHECK ((storage_limit_bytes >= 0)),
    CONSTRAINT billing_plan_versions_trash_retention_days_check CHECK ((trash_retention_days >= 0)),
    CONSTRAINT billing_plan_versions_version_check CHECK ((version > 0)),
    CONSTRAINT billing_plan_versions_version_retention_days_check CHECK ((version_retention_days >= 0))
);


--
-- Name: COLUMN billing_plan_versions.billing_scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_plan_versions.billing_scope IS 'Derived from product code; Personal belongs to a user, Agency tiers belong to an agency.';


--
-- Name: brandhub_schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brandhub_schema_migrations (
    version text NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL,
    description text NOT NULL
);


--
-- Name: campaign_collaborators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_collaborators (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    media_campaign_id uuid NOT NULL,
    collaborator_id uuid NOT NULL,
    cooperation_status public.cooperation_status DEFAULT 'CONTACTED'::public.cooperation_status NOT NULL,
    updated_by uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: campaign_deployments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_deployments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    content_version integer NOT NULL,
    requested_by uuid NOT NULL,
    status character varying(16) DEFAULT 'PENDING'::character varying NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_error_code character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT campaign_deployments_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'FAILED'::character varying, 'SUCCEEDED'::character varying])::text[])))
);


--
-- Name: campaign_review_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_review_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    content_version integer NOT NULL,
    actor_id uuid NOT NULL,
    actor_side character varying(16) NOT NULL,
    event_type character varying(16) NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT campaign_review_events_actor_side_check CHECK (((actor_side)::text = ANY ((ARRAY['AGENCY'::character varying, 'CLIENT'::character varying])::text[]))),
    CONSTRAINT campaign_review_events_event_type_check CHECK (((event_type)::text = ANY ((ARRAY['FEEDBACK'::character varying, 'APPROVE'::character varying])::text[])))
);


--
-- Name: campaign_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    content_version integer NOT NULL,
    snapshot jsonb NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: client_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    display_name character varying(255) NOT NULL,
    company character varying(255),
    industry character varying(100),
    logo_url character varying(500),
    banner_url character varying(500),
    phone character varying(50),
    website character varying(255),
    location character varying(255),
    description text,
    social_links jsonb,
    note text,
    contact_name character varying(255),
    contact_email character varying(255),
    company_size character varying(50),
    instagram_url character varying(500),
    tax_code character varying(50),
    address character varying(500),
    tagline character varying(255),
    founded_year integer,
    budget_range character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: content_moderation_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_moderation_reviews (
    id uuid NOT NULL,
    post_id character varying(64) NOT NULL,
    content_version bigint NOT NULL,
    content_hash character(64) NOT NULL,
    workspace_id uuid,
    author_id uuid NOT NULL,
    source character varying(20) NOT NULL,
    reason character varying(2000) NOT NULL,
    status character varying(10) DEFAULT 'PENDING'::character varying NOT NULL,
    decision_note character varying(2000),
    strike_level character varying(10),
    strike_category character varying(100),
    reviewed_by uuid,
    reviewed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    row_version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT content_moderation_reviews_check CHECK ((((status)::text = 'PENDING'::text) = ((reviewed_at IS NULL) AND (reviewed_by IS NULL)))),
    CONSTRAINT content_moderation_reviews_check1 CHECK ((((status)::text <> 'APPROVED'::text) OR (char_length(btrim((decision_note)::text)) >= 10))),
    CONSTRAINT content_moderation_reviews_check2 CHECK ((((status)::text <> 'BLOCKED'::text) OR ((strike_level IS NOT NULL) AND (decision_note IS NOT NULL)))),
    CONSTRAINT content_moderation_reviews_content_version_check CHECK ((content_version > 0)),
    CONSTRAINT content_moderation_reviews_source_check CHECK (((source)::text = ANY ((ARRAY['FLAGGED_AUTHOR'::character varying, 'COMPLIANCE'::character varying, 'COPYRIGHT'::character varying])::text[]))),
    CONSTRAINT content_moderation_reviews_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'BLOCKED'::character varying])::text[]))),
    CONSTRAINT content_moderation_reviews_strike_level_check CHECK (((strike_level)::text = ANY ((ARRAY['YELLOW'::character varying, 'ORANGE'::character varying, 'RED'::character varying])::text[])))
);


--
-- Name: TABLE content_moderation_reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.content_moderation_reviews IS 'FR 3.10.4. BLOCK records the strike through the admin account journal with operation id = review id, so retries never add a second strike.';


--
-- Name: content_request_completion_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_request_completion_jobs (
    campaign_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: creator_credit_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.creator_credit_usage (
    agency_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    period_id uuid NOT NULL,
    used bigint DEFAULT 0 NOT NULL,
    reserved bigint DEFAULT 0 NOT NULL,
    CONSTRAINT creator_credit_usage_reserved_check CHECK ((reserved >= 0)),
    CONSTRAINT creator_credit_usage_used_check CHECK ((used >= 0))
);


--
-- Name: credit_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    operation_id uuid NOT NULL,
    grant_id uuid NOT NULL,
    available_delta bigint DEFAULT 0 NOT NULL,
    reserved_delta bigint DEFAULT 0 NOT NULL,
    consumed_delta bigint DEFAULT 0 NOT NULL,
    expired_delta bigint DEFAULT 0 NOT NULL,
    revoked_delta bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT credit_entries_check CHECK (((available_delta <> 0) OR (reserved_delta <> 0) OR (consumed_delta <> 0) OR (expired_delta <> 0) OR (revoked_delta <> 0)))
);


--
-- Name: credit_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_grants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    source_type text NOT NULL,
    source_key text NOT NULL,
    order_id uuid,
    period_id uuid,
    trial_owner_id uuid,
    amount bigint NOT NULL,
    available bigint NOT NULL,
    reserved bigint DEFAULT 0 NOT NULL,
    consumed bigint DEFAULT 0 NOT NULL,
    expired bigint DEFAULT 0 NOT NULL,
    revoked bigint DEFAULT 0 NOT NULL,
    valid_from timestamp with time zone NOT NULL,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_credit_grants_period_expiry CHECK (((source_type <> 'PERIOD'::text) OR (expires_at IS NOT NULL))),
    CONSTRAINT ck_credit_grants_topup_no_expiry CHECK (((source_type <> 'TOPUP'::text) OR (expires_at IS NULL))),
    CONSTRAINT credit_grants_amount_check CHECK ((amount > 0)),
    CONSTRAINT credit_grants_available_check CHECK ((available >= 0)),
    CONSTRAINT credit_grants_check CHECK ((expires_at > valid_from)),
    CONSTRAINT credit_grants_check1 CHECK (((amount)::numeric = (((((available)::numeric + (reserved)::numeric) + (consumed)::numeric) + (expired)::numeric) + (revoked)::numeric))),
    CONSTRAINT credit_grants_check2 CHECK (((source_type = 'TRIAL'::text) = (trial_owner_id IS NOT NULL))),
    CONSTRAINT credit_grants_check3 CHECK (((source_type <> 'TOPUP'::text) OR (order_id IS NOT NULL))),
    CONSTRAINT credit_grants_check4 CHECK (((source_type <> 'PERIOD'::text) OR (period_id IS NOT NULL))),
    CONSTRAINT credit_grants_consumed_check CHECK ((consumed >= 0)),
    CONSTRAINT credit_grants_expired_check CHECK ((expired >= 0)),
    CONSTRAINT credit_grants_reserved_check CHECK ((reserved >= 0)),
    CONSTRAINT credit_grants_revoked_check CHECK ((revoked >= 0)),
    CONSTRAINT credit_grants_source_type_check CHECK ((source_type = ANY (ARRAY['TRIAL'::text, 'PERIOD'::text, 'TOPUP'::text, 'OPENING'::text, 'ADJUSTMENT'::text, 'DEV_SEED'::text])))
);


--
-- Name: credit_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_operations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    operation_key text NOT NULL,
    kind text NOT NULL,
    actor_id uuid,
    reservation_id uuid,
    reversal_of uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT credit_operations_kind_check CHECK ((kind = ANY (ARRAY['GRANT'::text, 'RESERVE'::text, 'SETTLE'::text, 'RELEASE'::text, 'EXPIRE'::text, 'REVERSAL'::text])))
);


--
-- Name: credit_reservation_allocations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_reservation_allocations (
    agency_id uuid NOT NULL,
    reservation_id uuid NOT NULL,
    grant_id uuid NOT NULL,
    amount bigint NOT NULL,
    charged bigint DEFAULT 0 NOT NULL,
    released bigint DEFAULT 0 NOT NULL,
    ordinal integer NOT NULL,
    CONSTRAINT credit_reservation_allocations_amount_check CHECK ((amount > 0)),
    CONSTRAINT credit_reservation_allocations_charged_check CHECK ((charged >= 0)),
    CONSTRAINT credit_reservation_allocations_check CHECK ((((charged)::numeric + (released)::numeric) <= (amount)::numeric)),
    CONSTRAINT credit_reservation_allocations_ordinal_check CHECK ((ordinal >= 0)),
    CONSTRAINT credit_reservation_allocations_released_check CHECK ((released >= 0))
);


--
-- Name: credit_usage_periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_usage_periods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    kind text NOT NULL,
    subscription_period_id uuid,
    CONSTRAINT credit_usage_periods_check CHECK ((ends_at > starts_at)),
    CONSTRAINT credit_usage_periods_check1 CHECK (((kind = 'PAID'::text) = (subscription_period_id IS NOT NULL))),
    CONSTRAINT credit_usage_periods_kind_check CHECK ((kind = ANY (ARRAY['BASIC_CALENDAR'::text, 'PAID'::text])))
);


--
-- Name: mail_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_attachments (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    uploaded_by uuid NOT NULL,
    name character varying(255) NOT NULL,
    content_type character varying(100) NOT NULL,
    size bigint NOT NULL,
    s3_key character varying(500) NOT NULL,
    kind character varying(16) DEFAULT 'FILE'::character varying NOT NULL,
    bound boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mail_attachments_kind_check CHECK (((kind)::text = ANY ((ARRAY['FILE'::character varying, 'IMAGE'::character varying])::text[])))
);


--
-- Name: mail_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_batches (
    id uuid NOT NULL,
    workspace_id uuid,
    workspace_name character varying(255),
    template_id character varying(64) NOT NULL,
    template_name character varying(120) NOT NULL,
    sent_by uuid NOT NULL,
    sender_email character varying(255) NOT NULL,
    sender_name character varying(255),
    kind character varying(16) DEFAULT 'SEND'::character varying NOT NULL,
    status character varying(16) NOT NULL,
    subject character varying(200) NOT NULL,
    body_html text NOT NULL,
    attachments jsonb,
    scheduled_at timestamp with time zone,
    timezone character varying(64) DEFAULT 'Asia/Ho_Chi_Minh'::character varying NOT NULL,
    total integer NOT NULL,
    accepted integer NOT NULL,
    rejected_count integer DEFAULT 0 NOT NULL,
    sent_count integer DEFAULT 0 NOT NULL,
    failed_count integer DEFAULT 0 NOT NULL,
    suppressed_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    scope character varying(32),
    agency_id uuid,
    CONSTRAINT ck_mail_batches_scope_consistency CHECK ((((workspace_id IS NOT NULL) AND (agency_id IS NULL)) OR ((workspace_id IS NULL) AND ((scope)::text = ANY ((ARRAY['ADMIN_SYSTEM_BROADCAST'::character varying, 'TRANSACTIONAL_AUTO'::character varying])::text[]))) OR ((workspace_id IS NULL) AND (agency_id IS NOT NULL) AND ((scope)::text = ANY ((ARRAY['AGENCY_INTERNAL'::character varying, 'AGENCY_CLIENT'::character varying])::text[]))))),
    CONSTRAINT mail_batches_kind_check CHECK (((kind)::text = ANY ((ARRAY['SEND'::character varying, 'TEST'::character varying])::text[]))),
    CONSTRAINT mail_batches_status_check CHECK (((status)::text = ANY ((ARRAY['SCHEDULED'::character varying, 'QUEUED'::character varying, 'SENDING'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'FAILED'::character varying])::text[])))
);


--
-- Name: mail_deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_deliveries (
    id uuid NOT NULL,
    batch_id uuid NOT NULL,
    recipient character varying(255) NOT NULL,
    recipient_name character varying(255),
    variables jsonb,
    rendered_subject character varying(255) NOT NULL,
    rendered_body_html text NOT NULL,
    external_audience boolean DEFAULT false NOT NULL,
    status character varying(16) DEFAULT 'PENDING'::character varying NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    last_error character varying(500),
    next_attempt_at timestamp with time zone DEFAULT now() NOT NULL,
    sent_at timestamp with time zone,
    event_key character varying(300) NOT NULL,
    CONSTRAINT mail_deliveries_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'SUPPRESSED'::character varying])::text[])))
);


--
-- Name: mail_send_quota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_send_quota (
    day date NOT NULL,
    scope character varying(16) NOT NULL,
    scope_id character varying(64) NOT NULL,
    sent_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT mail_send_quota_scope_check CHECK (((scope)::text = ANY ((ARRAY['SYSTEM'::character varying, 'WORKSPACE'::character varying, 'AGENCY'::character varying])::text[])))
);


--
-- Name: mail_suppressions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_suppressions (
    id uuid NOT NULL,
    workspace_id uuid,
    email_lower character varying(255) NOT NULL,
    reason character varying(32) DEFAULT 'UNSUBSCRIBED'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    agency_id uuid,
    CONSTRAINT ck_mail_suppressions_one_scope CHECK (((workspace_id IS NULL) OR (agency_id IS NULL)))
);


--
-- Name: material_audit_receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.material_audit_receipts (
    event_id character varying(160) NOT NULL,
    delivered_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: material_quota_releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.material_quota_releases (
    material_id character varying(64) NOT NULL,
    agency_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    released_bytes bigint NOT NULL,
    released_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT material_quota_releases_released_bytes_check CHECK ((released_bytes >= 0))
);


--
-- Name: media_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_campaigns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_media_package_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    strategy_detail text,
    package_terms_snapshot jsonb,
    package_terms_version integer,
    allocation_period character varying(7),
    allocations jsonb DEFAULT '[]'::jsonb NOT NULL,
    deliverable_plan jsonb DEFAULT '[]'::jsonb NOT NULL,
    work_items jsonb DEFAULT '[]'::jsonb NOT NULL,
    content_version integer DEFAULT 1 NOT NULL,
    row_version bigint DEFAULT 0 NOT NULL,
    brand_guideline text,
    timeline jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.campaign_status DEFAULT 'DRAFT'::public.campaign_status NOT NULL,
    approved_by_agency_at timestamp with time zone,
    approved_by_agency_id uuid,
    approved_by_agency_version integer,
    approved_by_client_at timestamp with time zone,
    approved_by_client_id uuid,
    approved_by_client_version integer,
    completed_at timestamp with time zone,
    completed_by uuid,
    completion_reason character varying(2000),
    completion_task_summary jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: media_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    is_template boolean DEFAULT false NOT NULL,
    agency_id uuid,
    source_template_id uuid,
    is_available_to_workspaces boolean DEFAULT true NOT NULL,
    duration_weeks integer,
    budget_amount numeric(14,2),
    scope_description text,
    offering_details jsonb,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_media_packages_template_agency_scope CHECK (((is_template AND (agency_id IS NULL)) OR ((NOT is_template) AND (agency_id IS NOT NULL)))),
    CONSTRAINT chk_media_packages_template_source CHECK (((source_template_id IS NULL) OR (NOT is_template)))
);


--
-- Name: monitoring_collectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_collectors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    server_id uuid,
    token_hash character varying(255) NOT NULL,
    last_seen_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT monitoring_collectors_name_check CHECK ((btrim((name)::text) <> ''::text)),
    CONSTRAINT monitoring_collectors_token_hash_check CHECK ((btrim((token_hash)::text) <> ''::text))
);


--
-- Name: TABLE monitoring_collectors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_collectors IS 'Operator-provisioned sources; heartbeat independent of probes. API collectorId maps to id.';


--
-- Name: monitoring_enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_enrollments (
    token_hash character(64) NOT NULL,
    name character varying(255) NOT NULL,
    environment character varying(50) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT monitoring_enrollments_environment_check CHECK ((btrim((environment)::text) <> ''::text)),
    CONSTRAINT monitoring_enrollments_name_check CHECK ((btrim((name)::text) <> ''::text))
);


--
-- Name: TABLE monitoring_enrollments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_enrollments IS 'Single-use admin-issued host enrollment; only token digests are stored. Claimed atomically.';


--
-- Name: monitoring_health_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_health_results (
    target_id uuid NOT NULL,
    collector_id uuid NOT NULL,
    check_id uuid NOT NULL,
    outcome character varying(5) NOT NULL,
    checked_at timestamp with time zone NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    latency_ms numeric(14,3),
    reason_code character varying(80),
    http_status smallint,
    runtime_state character varying(30),
    runtime_health character varying(30),
    CONSTRAINT chk_monitoring_result_clock CHECK ((checked_at <= (received_at + '00:00:10'::interval))),
    CONSTRAINT chk_monitoring_result_reason CHECK (((((outcome)::text = 'PASS'::text) AND (reason_code IS NULL)) OR (((outcome)::text = ANY ((ARRAY['FAIL'::character varying, 'ERROR'::character varying])::text[])) AND (reason_code IS NOT NULL) AND (btrim((reason_code)::text) <> ''::text)))),
    CONSTRAINT monitoring_health_results_http_status_check CHECK (((http_status >= 100) AND (http_status <= 599))),
    CONSTRAINT monitoring_health_results_latency_ms_check CHECK (((latency_ms >= (0)::numeric) AND (latency_ms < 'Infinity'::numeric))),
    CONSTRAINT monitoring_health_results_outcome_check CHECK (((outcome)::text = ANY ((ARRAY['PASS'::character varying, 'FAIL'::character varying, 'ERROR'::character varying])::text[])))
);


--
-- Name: TABLE monitoring_health_results; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_health_results IS 'Exactly zero or one latest result per target. No history or persisted freshness status.';


--
-- Name: COLUMN monitoring_health_results.collector_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_results.collector_id IS 'Result provenance; FK prevents retaining old result under a new assignment. Clear result before reassignment in same transaction.';


--
-- Name: COLUMN monitoring_health_results.check_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_results.check_id IS 'Idempotency key scoped to target. Same current checkId is a no-op; do not update received_at.';


--
-- Name: COLUMN monitoring_health_results.received_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_results.received_at IS 'Backend-assigned; never trust client timestamp. Application enforces ordering and past-age window atomically.';


--
-- Name: monitoring_health_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_health_targets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    kind character varying(20) NOT NULL,
    environment character varying(50) NOT NULL,
    server_id uuid,
    service_name character varying(100),
    instance_id character varying(255),
    collector_id uuid NOT NULL,
    check_scope character varying(100) NOT NULL,
    probe_type character varying(30) NOT NULL,
    probe_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    assertion jsonb DEFAULT '{}'::jsonb NOT NULL,
    credential_ref character varying(255),
    interval_seconds integer DEFAULT 30 NOT NULL,
    timeout_seconds integer DEFAULT 5 NOT NULL,
    stale_after_seconds integer DEFAULT 90 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_monitoring_target_probe CHECK (((((kind)::text = ANY ((ARRAY['SERVICE'::character varying, 'ENDPOINT'::character varying])::text[])) AND ((probe_type)::text = 'HTTP'::text)) OR (((kind)::text = 'CONTAINER'::text) AND ((probe_type)::text = 'DOCKER'::text) AND (server_id IS NOT NULL)) OR (((kind)::text = 'DATABASE'::text) AND ((probe_type)::text = ANY ((ARRAY['HTTP'::character varying, 'POSTGRESQL'::character varying, 'REDIS'::character varying, 'MONGODB'::character varying, 'NEO4J'::character varying])::text[]))))),
    CONSTRAINT chk_monitoring_target_timing CHECK (((timeout_seconds < interval_seconds) AND (interval_seconds < stale_after_seconds))),
    CONSTRAINT monitoring_health_targets_assertion_check CHECK ((jsonb_typeof(assertion) = 'object'::text)),
    CONSTRAINT monitoring_health_targets_check_scope_check CHECK ((btrim((check_scope)::text) <> ''::text)),
    CONSTRAINT monitoring_health_targets_credential_ref_check CHECK (((credential_ref IS NULL) OR (btrim((credential_ref)::text) <> ''::text))),
    CONSTRAINT monitoring_health_targets_environment_check CHECK ((btrim((environment)::text) <> ''::text)),
    CONSTRAINT monitoring_health_targets_interval_seconds_check CHECK ((interval_seconds > 0)),
    CONSTRAINT monitoring_health_targets_kind_check CHECK (((kind)::text = ANY ((ARRAY['SERVICE'::character varying, 'CONTAINER'::character varying, 'DATABASE'::character varying, 'ENDPOINT'::character varying])::text[]))),
    CONSTRAINT monitoring_health_targets_name_check CHECK ((btrim((name)::text) <> ''::text)),
    CONSTRAINT monitoring_health_targets_probe_config_check CHECK ((jsonb_typeof(probe_config) = 'object'::text)),
    CONSTRAINT monitoring_health_targets_probe_type_check CHECK (((probe_type)::text = ANY ((ARRAY['HTTP'::character varying, 'DOCKER'::character varying, 'POSTGRESQL'::character varying, 'REDIS'::character varying, 'MONGODB'::character varying, 'NEO4J'::character varying])::text[]))),
    CONSTRAINT monitoring_health_targets_stale_after_seconds_check CHECK ((stale_after_seconds > 0)),
    CONSTRAINT monitoring_health_targets_timeout_seconds_check CHECK ((timeout_seconds > 0))
);


--
-- Name: TABLE monitoring_health_targets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_health_targets IS 'Persistent allowlist, including targets with no result. Never auto-create from submitted samples.';


--
-- Name: COLUMN monitoring_health_targets.server_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.server_id IS 'NULL for managed/external targets; must not fabricate host metrics.';


--
-- Name: COLUMN monitoring_health_targets.check_scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.check_scope IS 'READINESS/LIVENESS for services; documented scope for other probes. Validate contract in application.';


--
-- Name: COLUMN monitoring_health_targets.probe_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.probe_config IS 'Operator-only address/selector configuration. No plaintext secrets or raw response; omit from public DTOs.';


--
-- Name: COLUMN monitoring_health_targets.credential_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.credential_ref IS 'Reference resolved by worker secret provider; never a password, bearer token, or secret-bearing URI.';


--
-- Name: COLUMN monitoring_health_targets.stale_after_seconds; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.stale_after_seconds IS 'Also used by ingestion as maximum past sample age; compare against backend time.';


--
-- Name: monitoring_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_servers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    ip_address inet NOT NULL,
    environment character varying(50) NOT NULL,
    deployed_services text[] DEFAULT '{}'::text[] NOT NULL,
    agent_token_hash character varying(255) NOT NULL,
    cpu_percent numeric(5,2),
    ram_percent numeric(5,2),
    disk_percent numeric(5,2),
    uptime_seconds bigint,
    last_seen_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_monitoring_server_ip CHECK ((masklen(ip_address) =
CASE family(ip_address)
    WHEN 4 THEN 32
    ELSE 128
END)),
    CONSTRAINT chk_monitoring_server_no_sample CHECK (((last_seen_at IS NOT NULL) OR ((cpu_percent IS NULL) AND (ram_percent IS NULL) AND (disk_percent IS NULL) AND (uptime_seconds IS NULL)))),
    CONSTRAINT monitoring_servers_agent_token_hash_check CHECK ((btrim((agent_token_hash)::text) <> ''::text)),
    CONSTRAINT monitoring_servers_cpu_percent_check CHECK (((cpu_percent >= (0)::numeric) AND (cpu_percent <= (100)::numeric))),
    CONSTRAINT monitoring_servers_disk_percent_check CHECK (((disk_percent >= (0)::numeric) AND (disk_percent <= (100)::numeric))),
    CONSTRAINT monitoring_servers_environment_check CHECK ((btrim((environment)::text) <> ''::text)),
    CONSTRAINT monitoring_servers_name_check CHECK ((btrim((name)::text) <> ''::text)),
    CONSTRAINT monitoring_servers_ram_percent_check CHECK (((ram_percent >= (0)::numeric) AND (ram_percent <= (100)::numeric))),
    CONSTRAINT monitoring_servers_uptime_seconds_check CHECK ((uptime_seconds >= 0))
);


--
-- Name: TABLE monitoring_servers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_servers IS 'Operator-managed physical hosts; one latest sample per host, no history. API serverId maps to id.';


--
-- Name: COLUMN monitoring_servers.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.id IS 'Stable across container redeploys; replacement host gets a new UUID. IP is not identity.';


--
-- Name: COLUMN monitoring_servers.agent_token_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.agent_token_hash IS 'Hash only; never expose via API/logs. Provision a separate random agent credential.';


--
-- Name: COLUMN monitoring_servers.last_seen_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.last_seen_at IS 'Backend receipt time of valid heartbeat; update atomically with all metrics. NULL means NO_DATA.';


--
-- Name: COLUMN monitoring_servers.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.updated_at IS 'Application-maintained metadata update time; heartbeat must not overwrite operator metadata.';


--
-- Name: package_negotiation_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_negotiation_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_media_package_id uuid NOT NULL,
    terms_version integer NOT NULL,
    action character varying(30) NOT NULL,
    actor_id uuid,
    actor_role character varying(20),
    note character varying(2000),
    terms_snapshot jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT package_negotiation_events_action_check CHECK (((action)::text = ANY ((ARRAY['BASELINE'::character varying, 'REQUEST_CHANGE'::character varying, 'COUNTER_OFFER'::character varying])::text[]))),
    CONSTRAINT package_negotiation_events_check CHECK (((((action)::text = 'BASELINE'::text) AND (actor_id IS NULL) AND (actor_role IS NULL)) OR (((action)::text = 'REQUEST_CHANGE'::text) AND (actor_id IS NOT NULL) AND ((actor_role)::text = 'CLIENT'::text)) OR (((action)::text = 'COUNTER_OFFER'::text) AND (actor_id IS NOT NULL) AND ((actor_role)::text = ANY ((ARRAY['OWNER'::character varying, 'MANAGER'::character varying])::text[]))))),
    CONSTRAINT package_negotiation_events_terms_snapshot_check CHECK ((jsonb_typeof(terms_snapshot) = 'object'::text)),
    CONSTRAINT package_negotiation_events_terms_version_check CHECK ((terms_version >= 1))
);


--
-- Name: repository_drive_generations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_drive_generations (
    agency_id uuid NOT NULL,
    generation bigint DEFAULT 0 NOT NULL
);


--
-- Name: repository_drive_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_drive_objects (
    object_key text NOT NULL,
    agency_id uuid NOT NULL,
    connection_id uuid NOT NULL,
    file_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: repository_drive_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_drive_operations (
    agency_id uuid NOT NULL,
    lease_token uuid NOT NULL,
    lease_until timestamp with time zone NOT NULL
);


--
-- Name: repository_drive_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repository_drive_states (
    state_hash text NOT NULL,
    agency_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    verifier_ciphertext text NOT NULL,
    generation bigint DEFAULT 0 NOT NULL,
    expires_at timestamp with time zone NOT NULL
);


--
-- Name: sanction_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sanction_reviews (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(20) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    resolved_at timestamp with time zone,
    resolved_by uuid,
    reason character varying(2000),
    CONSTRAINT sanction_reviews_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'CLOSED'::character varying])::text[])))
);


--
-- Name: seed_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seed_runs (
    dataset character varying(100) NOT NULL,
    dataset_version integer NOT NULL,
    run_id uuid NOT NULL,
    status character varying(16) NOT NULL,
    last_stage character varying(64),
    record_counts jsonb DEFAULT '{}'::jsonb NOT NULL,
    manifest jsonb DEFAULT '{}'::jsonb NOT NULL,
    failure_summary character varying(255),
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    failed_at timestamp with time zone,
    CONSTRAINT seed_runs_check CHECK ((((status)::text = 'complete'::text) = (completed_at IS NOT NULL))),
    CONSTRAINT seed_runs_check1 CHECK ((((status)::text = 'failed'::text) = (failed_at IS NOT NULL))),
    CONSTRAINT seed_runs_dataset_version_check CHECK ((dataset_version > 0)),
    CONSTRAINT seed_runs_status_check CHECK (((status)::text = ANY ((ARRAY['running'::character varying, 'complete'::character varying, 'failed'::character varying])::text[])))
);


--
-- Name: storage_objects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storage_objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    workspace_id uuid,
    reservation_id uuid,
    uploaded_by uuid,
    backend text NOT NULL,
    bucket text NOT NULL,
    object_key text NOT NULL,
    size_bytes bigint NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT storage_objects_check CHECK (((status <> 'DELETED'::text) OR (deleted_at IS NOT NULL))),
    CONSTRAINT storage_objects_size_bytes_check CHECK ((size_bytes >= 0)),
    CONSTRAINT storage_objects_status_check CHECK ((status = ANY (ARRAY['UPLOADING'::text, 'ACTIVE'::text, 'TRASH'::text, 'DELETE_PENDING'::text, 'DELETED'::text])))
);


--
-- Name: storage_reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storage_reservations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    upload_id uuid NOT NULL,
    workspace_id uuid,
    reserved_bytes bigint NOT NULL,
    status text DEFAULT 'RESERVED'::text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT storage_reservations_check CHECK ((expires_at > created_at)),
    CONSTRAINT storage_reservations_reserved_bytes_check CHECK ((reserved_bytes > 0)),
    CONSTRAINT storage_reservations_status_check CHECK ((status = ANY (ARRAY['RESERVED'::text, 'UNKNOWN'::text, 'FINALIZED'::text, 'RELEASED'::text])))
);


--
-- Name: storage_usage_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storage_usage_entries (
    id uuid NOT NULL,
    operation_key character varying(160) NOT NULL,
    agency_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    reservation_id uuid NOT NULL,
    material_id character varying(64) NOT NULL,
    kind character varying(24) NOT NULL,
    used_delta bigint NOT NULL,
    reserved_delta bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT storage_usage_entries_kind_check CHECK (((kind)::text = ANY ((ARRAY['RESERVE'::character varying, 'COMMIT'::character varying, 'RELEASE'::character varying, 'EXPIRE'::character varying, 'PURGE_RELEASE'::character varying])::text[])))
);


--
-- Name: subscription_observation_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_observation_jobs (
    name character varying(40) NOT NULL,
    owner_token uuid,
    lease_until timestamp with time zone,
    agency_cursor uuid,
    order_cursor uuid,
    event_cursor uuid,
    last_started_at timestamp with time zone,
    last_completed_at timestamp with time zone,
    last_outcome character varying(20),
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT subscription_observation_jobs_last_outcome_check CHECK (((last_outcome)::text = ANY ((ARRAY['RUNNING'::character varying, 'COMPLETED'::character varying, 'DEGRADED'::character varying, 'FAILED'::character varying])::text[])))
);


--
-- Name: subscription_operational_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_operational_issues (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    fingerprint character varying(200) NOT NULL,
    detector character varying(40) NOT NULL,
    subject_key character varying(100) NOT NULL,
    rule character varying(80) NOT NULL,
    category character varying(20) NOT NULL,
    severity character varying(10) NOT NULL,
    status character varying(10) DEFAULT 'OPEN'::character varying NOT NULL,
    agency_id uuid,
    order_id uuid,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    request_id character varying(64) NOT NULL,
    occurrences bigint DEFAULT 1 NOT NULL,
    first_seen timestamp with time zone DEFAULT now() NOT NULL,
    last_seen timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone,
    CONSTRAINT subscription_operational_issues_category_check CHECK (((category)::text = ANY ((ARRAY['SERVICE'::character varying, 'DATABASE'::character varying, 'WEBHOOK'::character varying, 'PAYMENT'::character varying, 'CREDIT'::character varying])::text[]))),
    CONSTRAINT subscription_operational_issues_check CHECK ((((status)::text = 'RESOLVED'::text) = (resolved_at IS NOT NULL))),
    CONSTRAINT subscription_operational_issues_details_check CHECK ((jsonb_typeof(details) = 'object'::text)),
    CONSTRAINT subscription_operational_issues_detector_check CHECK (((detector)::text = ANY ((ARRAY['LOCAL_CREDIT'::character varying, 'LOCAL_PAYMENT'::character varying, 'WEBHOOK'::character varying, 'PROVIDER'::character varying])::text[]))),
    CONSTRAINT subscription_operational_issues_occurrences_check CHECK ((occurrences > 0)),
    CONSTRAINT subscription_operational_issues_request_id_check CHECK (((request_id)::text ~ '^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$'::text)),
    CONSTRAINT subscription_operational_issues_severity_check CHECK (((severity)::text = ANY ((ARRAY['WARNING'::character varying, 'CRITICAL'::character varying])::text[]))),
    CONSTRAINT subscription_operational_issues_status_check CHECK (((status)::text = ANY ((ARRAY['OPEN'::character varying, 'RESOLVED'::character varying])::text[])))
);


--
-- Name: subscription_plan_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_plan_changes (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status character varying(10) DEFAULT 'PENDING'::character varying NOT NULL,
    effective_at timestamp with time zone,
    payment_required boolean DEFAULT true NOT NULL,
    requested_by uuid NOT NULL,
    reason character varying(2000) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT subscription_plan_changes_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPLIED'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name public.subscription_plan_name NOT NULL,
    display_name character varying(100) NOT NULL,
    price_monthly numeric(12,2) NOT NULL,
    max_workspaces integer NOT NULL,
    ai_credits_month integer NOT NULL,
    features jsonb DEFAULT '[]'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: subscription_provider_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_provider_checks (
    order_id uuid NOT NULL,
    last_checked_at timestamp with time zone DEFAULT now() NOT NULL,
    next_check_at timestamp with time zone DEFAULT now() NOT NULL,
    outcome character varying(20) NOT NULL,
    CONSTRAINT subscription_provider_checks_outcome_check CHECK (((outcome)::text = ANY ((ARRAY['CHECKING'::character varying, 'COMPLETE'::character varying, 'UNKNOWN'::character varying])::text[])))
);


--
-- Name: system_storage_pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_storage_pools (
    provider character varying(32) NOT NULL,
    capacity_bytes bigint NOT NULL,
    physical_used_bytes bigint DEFAULT 0 NOT NULL,
    reserved_peak_bytes bigint DEFAULT 0 NOT NULL,
    observed_at timestamp with time zone,
    version bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT system_storage_pools_capacity_bytes_check CHECK ((capacity_bytes > 0)),
    CONSTRAINT system_storage_pools_physical_used_bytes_check CHECK ((physical_used_bytes >= 0)),
    CONSTRAINT system_storage_pools_provider_check CHECK (((provider)::text = 'SYSTEM_GDRIVE'::text)),
    CONSTRAINT system_storage_pools_reserved_peak_bytes_check CHECK ((reserved_peak_bytes >= 0))
);


--
-- Name: task_content_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_content_operations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    sequence_number bigint NOT NULL,
    yjs_update text NOT NULL,
    edited_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: task_content_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_content_snapshots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    sequence_number bigint NOT NULL,
    yjs_state text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    type public.task_type DEFAULT 'POST'::public.task_type NOT NULL,
    title character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: third_party_collaborators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.third_party_collaborators (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    partner_name character varying(255) NOT NULL,
    partner_type public.collaborator_type NOT NULL,
    contact_info jsonb DEFAULT '{}'::jsonb NOT NULL,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    first_used_at timestamp with time zone,
    usage_history_verified boolean DEFAULT false NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type public.transaction_type NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'VND'::character varying NOT NULL,
    status public.transaction_status DEFAULT 'PENDING'::public.transaction_status NOT NULL,
    ref_id character varying(255),
    payos_tx_id character varying(255),
    paid_at timestamp with time zone,
    failed_reason character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_notifications (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    notification_id uuid,
    type character varying(20) NOT NULL,
    title character varying(200) NOT NULL,
    content character varying(5000) NOT NULL,
    action_url character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone
);


--
-- Name: user_oauth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    provider public.oauth_provider NOT NULL,
    provider_id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    jti character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    ip_address character varying(45),
    user_agent character varying(255),
    device_info jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_strikes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_strikes (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    level character varying(10) NOT NULL,
    category character varying(100) NOT NULL,
    reason character varying(2000) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    converted_to_id uuid,
    removed_by uuid,
    removed_at timestamp with time zone,
    removal_reason character varying(2000),
    CONSTRAINT user_strikes_check CHECK ((expires_at > created_at)),
    CONSTRAINT user_strikes_check1 CHECK (((removed_at IS NULL) = (removed_by IS NULL))),
    CONSTRAINT user_strikes_check2 CHECK (((converted_to_id IS NULL) OR ((level)::text = 'YELLOW'::text))),
    CONSTRAINT user_strikes_level_check CHECK (((level)::text = ANY ((ARRAY['YELLOW'::character varying, 'ORANGE'::character varying, 'RED'::character varying])::text[])))
);


--
-- Name: user_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status public.subscription_status DEFAULT 'TRIALING'::public.subscription_status NOT NULL,
    current_period_start timestamp with time zone NOT NULL,
    current_period_end timestamp with time zone NOT NULL,
    cancelled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_system_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_system_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    system_role character varying(50) DEFAULT 'USER'::character varying NOT NULL,
    granted_by uuid,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_user_system_roles_role CHECK (((system_role)::text = ANY ((ARRAY['ADMIN'::character varying, 'USER'::character varying])::text[])))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(20),
    password_hash character varying(255),
    full_name character varying(255) NOT NULL,
    avatar_url character varying(255),
    professional_title character varying(255),
    bio text,
    portfolio_urls jsonb DEFAULT '[]'::jsonb NOT NULL,
    working_language character varying(50),
    skills jsonb DEFAULT '[]'::jsonb NOT NULL,
    location character varying(255),
    years_of_experience integer,
    linkedin_url character varying(255),
    facebook_url character varying(255),
    instagram_url character varying(255),
    tiktok_url character varying(255),
    website character varying(255),
    banner_url character varying(255),
    status public.user_status DEFAULT 'ACTIVE'::public.user_status NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    last_banned_at timestamp with time zone,
    preferences jsonb DEFAULT '{}'::jsonb NOT NULL,
    last_login_at timestamp with time zone,
    last_password_change timestamp with time zone,
    otp_code character varying(6),
    otp_expiry timestamp with time zone,
    email_verified_at timestamp with time zone,
    two_factor_enabled boolean DEFAULT false NOT NULL,
    totp_secret character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    clean_period_ends_at timestamp with time zone,
    reactivate_at timestamp with time zone,
    tokens_revoked_before timestamp with time zone,
    row_version bigint DEFAULT 0 NOT NULL,
    session_version bigint DEFAULT 0 NOT NULL,
    require_password_reset boolean DEFAULT false NOT NULL
);


--
-- Name: workspace_credit_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_credit_limits (
    agency_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    cap bigint,
    version bigint DEFAULT 0 NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT workspace_credit_limits_cap_check CHECK ((cap >= 0)),
    CONSTRAINT workspace_credit_limits_version_check CHECK ((version >= 0))
);


--
-- Name: workspace_credit_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_credit_usage (
    agency_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    period_id uuid NOT NULL,
    used bigint DEFAULT 0 NOT NULL,
    reserved bigint DEFAULT 0 NOT NULL,
    CONSTRAINT workspace_credit_usage_reserved_check CHECK ((reserved >= 0)),
    CONSTRAINT workspace_credit_usage_used_check CHECK ((used >= 0))
);


--
-- Name: workspace_drive_folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_drive_folders (
    workspace_id uuid NOT NULL,
    agency_id uuid NOT NULL,
    folder_id text NOT NULL,
    ordinal bigint NOT NULL,
    CONSTRAINT workspace_drive_folders_ordinal_check CHECK ((ordinal > 0))
);


--
-- Name: workspace_hashtags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_hashtags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    tag character varying(100) NOT NULL,
    normalized_tag character varying(100) NOT NULL,
    purpose character varying(30) NOT NULL,
    added_by uuid NOT NULL,
    added_by_name character varying(255) NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    campaign_id uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT workspace_hashtags_purpose_check CHECK (((purpose)::text = ANY ((ARRAY['BRAND'::character varying, 'CAMPAIGN'::character varying, 'TRENDING'::character varying, 'EVENT_SPECIFIC'::character varying])::text[])))
);


--
-- Name: workspace_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    invited_email character varying(255) NOT NULL,
    invited_by uuid NOT NULL,
    token character varying(255) NOT NULL,
    role public.workspace_member_role,
    status public.invitation_status DEFAULT 'PENDING'::public.invitation_status NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_media_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_media_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    package_id uuid NOT NULL,
    negotiation_status public.package_negotiation_status DEFAULT 'DRAFT'::public.package_negotiation_status NOT NULL,
    final_terms jsonb DEFAULT '{}'::jsonb NOT NULL,
    previous_terms jsonb,
    terms_version integer DEFAULT 1 NOT NULL,
    client_proposal_count integer DEFAULT 0 NOT NULL,
    approved_by_agency_at timestamp with time zone,
    approved_by_client_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_workspace_media_packages_client_proposal_count CHECK ((client_proposal_count >= 0)),
    CONSTRAINT chk_workspace_media_packages_terms_version_positive CHECK ((terms_version > 0))
);


--
-- Name: workspace_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    user_id uuid,
    client_profile_id uuid,
    role public.workspace_member_role NOT NULL,
    added_by uuid,
    joined_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_workspace_members_identity CHECK ((((role = 'CLIENT'::public.workspace_member_role) AND (client_profile_id IS NOT NULL)) OR ((role <> 'CLIENT'::public.workspace_member_role) AND (user_id IS NOT NULL) AND (client_profile_id IS NULL))))
);


--
-- Name: workspace_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid,
    name character varying(255) NOT NULL,
    source_workspace_id uuid,
    config_snapshot jsonb NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    workspace_media_package_id uuid,
    source_workspace_id uuid,
    duplication_request_id uuid,
    duplication_fingerprint uuid,
    timezone_config character varying(100) DEFAULT 'Asia/Ho_Chi_Minh'::character varying NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    industry public.workspace_industry,
    company_size public.company_size,
    website character varying(255),
    phone character varying(30),
    location character varying(255),
    description character varying(500),
    brand_color character varying(9),
    logo_icon character varying(50),
    logo_url character varying(255),
    banner_url character varying(255),
    tagline character varying(140),
    founded_year integer,
    facebook_url character varying(255),
    linkedin_url character varying(255),
    instagram_url character varying(255),
    status public.entity_status DEFAULT 'ACTIVE'::public.entity_status NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Data for Name: account_activation_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account_activation_tokens (id, user_id, token_hash, expires_at, used_at, revoked_at, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: admin_account_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_account_operations (user_id, operation_id, payload_hash, created_at) FROM stdin;
\.


--
-- Data for Name: admin_email_outbox; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_email_outbox (id, event_key, recipient, subject, body, created_at, sent_at, next_attempt_at, attempts, notification_id, failed_at, last_error) FROM stdin;
\.


--
-- Data for Name: admin_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_notifications (id, title, content, type, target_type, target_values, action_url, status, scheduled_at, sent_at, recipient_count, created_by, created_at, updated_at, row_version) FROM stdin;
\.


--
-- Data for Name: admin_report_exports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_report_exports (id, report_type, period_start, period_end, timezone, as_of, row_count, file_name, file_size, content, token_hash, expires_at, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: agencies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agencies (id, name, owner_id, logo_url, banner_url, description, category, company_size, website, phone, location, brand_color, logo_icon, tagline, founded_year, facebook_url, linkedin_url, instagram_url, status, deleted_at, created_at, updated_at) FROM stdin;
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	Saatchi & Saatchi Vietnam Agency	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	Diverse asymmetric circuit	RETAIL	SIZE_51_200	http://www.sang-bahringer.org/maiores/deserunttotam?repellendus=veniam&dolorum=distinctio	\N	Archieshire	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.613916+00	2026-10-19 13:05:13.613938+00
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	Yeah1 Network Agency	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	Intuitive background framework	OTHER	SIZE_201_500	https://www.salome-stroman.org/similique/etdoloribus	\N	East Amberview	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.614787+00	2026-10-19 13:05:13.614808+00
1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	Circus Digital Agency	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	\N	\N	Persistent system-worthy conglomeration	FINANCE	SIZE_11_50	https://www.catheryn-rice.name/voluptatibus	\N	Carmeloborough	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.614974+00	2026-10-19 13:05:13.614981+00
5a4f221b-1350-4421-b060-d0eb7ccaf94d	AIM Academy Agency	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	Digitized bifurcated intranet	BEAUTY	SIZE_51_200	https://www.gregory-schiller.org:14537/repellendus/abautem?explicabo=explicabo&optio=ex	\N	Gottliebmouth	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.615763+00	2026-10-19 13:05:13.615777+00
\.


--
-- Data for Name: agency_creator_credit_limits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_creator_credit_limits (agency_id, creator_id, cap, version, updated_by, updated_at) FROM stdin;
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	424	0	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-20 02:01:06.695762+00
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	199	0	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-20 02:01:06.695762+00
1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	308	0	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-20 02:01:06.695762+00
5a4f221b-1350-4421-b060-d0eb7ccaf94d	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	320	0	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-20 02:01:06.695762+00
\.


--
-- Data for Name: agency_credit_wallets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_credit_wallets (agency_id, available_credits, reserved_credits, opening_balance_state, version, updated_at) FROM stdin;
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	5000	0	VERIFIED	1	2026-10-21 15:24:01.500405+00
5a4f221b-1350-4421-b060-d0eb7ccaf94d	5000	0	VERIFIED	3	2026-10-22 09:57:31.339379+00
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	5000	0	VERIFIED	1	2026-10-29 16:01:42.461252+00
1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	5000	0	VERIFIED	1	2026-10-29 16:01:42.461252+00
\.


--
-- Data for Name: agency_drive_connections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_drive_connections (agency_id, connection_id, connected_by, account_id, account_email, refresh_token_ciphertext, root_folder_id, connected, capacity_revision, quota_full_at, created_at, updated_at, disconnecting, granted_scope) FROM stdin;
5a4f221b-1350-4421-b060-d0eb7ccaf94d	cee7d8c7-3e59-4443-acda-54dfb2a8ed7b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	08267003815292641932	winhtuan@gmail.com	q44nY6WRj60WJQqOjp3QnENMw8M0Dt6tbbbdzy0N3ZWYF-yYTbrfyTUJWe2KEKARLv-ntsp0tp7kUg6Wo_2oZXZPk-9NSSmaXTh0EWSWjw05lzTTRD3sbWH2xvqCagGkJXw9FEmArbt88MfXXkTilJa7Dng6VRLTCODdc2zGPl8MAMM	1g049VPRRdibkO6eDgPtR1vp-D6IwPr9V	t	6	\N	2026-10-27 06:50:03.623018+00	2026-10-27 06:50:03.623018+00	f	
\.


--
-- Data for Name: agency_invitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_invitations (id, agency_id, invited_email, invited_by, token, note, workspace_id, role, status, expires_at, accepted_at, created_at) FROM stdin;
195f51fe-d15f-4e5b-8b4d-f49f1218fa5e	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	terina.dibbert@yahoo.com	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	7c3c29dd-538a-4190-bf39-bb948ded9755	\N	\N	CREATOR	PENDING	2026-10-26 13:05:13.633557+00	\N	2026-10-19 13:05:13.633628+00
4fbbd59c-47f5-45d8-8c77-79d9771f4dd7	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	nickole.wyman@hotmail.com	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	4a5bc683-9256-4fa0-8386-8c34c7ae5f69	\N	\N	CREATOR	PENDING	2026-10-26 13:05:13.633983+00	\N	2026-10-19 13:05:13.633993+00
\.


--
-- Data for Name: agency_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_members (id, agency_id, user_id, role, joined_at) FROM stdin;
be7c6730-e053-44a0-9aef-dbec895a2d91	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	OWNER	2026-10-19 13:05:13.626507+00
209e6125-8a38-4bd0-b86d-241f59eb910b	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	eace4871-7580-4f8e-898a-f7f25a838594	MEMBER	2026-10-19 13:05:13.626571+00
07939fb1-b02d-459f-8976-bf3b684b7857	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	180e9676-b334-4115-9641-ec1dfac7fe1d	MEMBER	2026-10-19 13:05:13.626576+00
0a6871f4-9b74-4d0a-9ff2-f4e7c1144171	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	17805121-ff16-40ab-9d0f-dd86b4ed1e47	MEMBER	2026-10-19 13:05:13.626579+00
88611826-538a-4733-ae4c-534209841555	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	b213cbc7-613c-4a34-8aa1-4876684a1ee9	MEMBER	2026-10-19 13:05:13.626582+00
95cb3e9b-5901-4806-b19f-88f7fc7d72b4	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	MEMBER	2026-10-19 13:05:13.626584+00
baee7be1-4879-4188-9b13-649b0d957649	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	OWNER	2026-10-19 13:05:13.626586+00
c521252a-e4af-465c-ae20-7c89c8c1d17d	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	779738d8-e0dd-43e3-83d4-2bcf579433bd	MEMBER	2026-10-19 13:05:13.626588+00
dc3563b6-bf37-472e-a5bd-fceec6053de1	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	c08aa28e-b894-4064-b712-e4f3e7cd0939	MEMBER	2026-10-19 13:05:13.62659+00
614fae20-67e4-4e18-877b-18a7694bf731	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	1dab38ca-17e7-49f6-ab2c-cc8b20fc669f	MEMBER	2026-10-19 13:05:13.626593+00
dab6825a-e46e-4f8c-9fea-7f9fb3b84214	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	3da73a3d-a522-4c48-a293-4338b2969670	MEMBER	2026-10-19 13:05:13.626595+00
c86d90e0-61f1-41fc-b3cb-5f20b7e5149f	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	1845f16a-9e5e-42e2-82f1-de5f565cb7d2	MEMBER	2026-10-19 13:05:13.626597+00
cc07aaf6-0bcc-43bf-8fda-9e8fbe418f93	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	OWNER	2026-10-19 13:05:13.626599+00
d1b42eb5-7ff2-4a17-8e6f-e506caadfebb	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	1dab38ca-17e7-49f6-ab2c-cc8b20fc669f	MEMBER	2026-10-19 13:05:13.626656+00
85af2a14-712e-4cdd-8ce3-dc23e988eaef	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	eace4871-7580-4f8e-898a-f7f25a838594	MEMBER	2026-10-19 13:05:13.626666+00
066ee505-efd5-4590-8513-4e5860b908ec	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	debbe165-84de-460c-b10a-d2cd7ea24966	MEMBER	2026-10-19 13:05:13.62667+00
78ebbfc0-6bbc-4399-ab4a-d9a9f8d85b18	5a4f221b-1350-4421-b060-d0eb7ccaf94d	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	OWNER	2026-10-19 13:05:13.626676+00
7361ae3f-2ac4-478b-84a9-7a392a7abad9	5a4f221b-1350-4421-b060-d0eb7ccaf94d	1dab38ca-17e7-49f6-ab2c-cc8b20fc669f	MEMBER	2026-10-19 13:05:13.626679+00
0ec05e37-8dd5-4530-b2ab-5464bb9a9ea7	5a4f221b-1350-4421-b060-d0eb7ccaf94d	12adcef2-8964-4ed6-95a5-bbb9a601803c	MEMBER	2026-10-19 13:05:13.626681+00
96e399ab-724f-4b56-aafb-58077b60f70f	5a4f221b-1350-4421-b060-d0eb7ccaf94d	debbe165-84de-460c-b10a-d2cd7ea24966	MEMBER	2026-10-19 13:05:13.626683+00
7380bb0e-f9a2-49f8-84a3-9fc9b4c6acea	5a4f221b-1350-4421-b060-d0eb7ccaf94d	17805121-ff16-40ab-9d0f-dd86b4ed1e47	MEMBER	2026-10-19 13:05:13.626685+00
42f7d117-0bfc-46a4-bcf0-2fa99d626ef7	5a4f221b-1350-4421-b060-d0eb7ccaf94d	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	MEMBER	2026-10-19 13:05:13.626687+00
03db48a7-6e43-4a08-ab4f-0d58ba9610f7	5a4f221b-1350-4421-b060-d0eb7ccaf94d	b84cb77d-fb5f-43c9-858b-bb91be0dcf24	MEMBER	2026-10-19 13:05:13.626696+00
bc3f55ea-85c4-4491-ad4d-b832bbeb54f0	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	12adcef2-8964-4ed6-95a5-bbb9a601803c	MEMBER	2026-10-19 13:05:13.812516+00
3bb146c0-79c6-4a0d-8bd2-dfde142634bb	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	b7f7db40-e219-4792-98a7-6b944703bdb4	MEMBER	2026-10-19 13:05:13.812571+00
226617de-2dd3-4367-8f2f-6bb195e25ef2	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	17805121-ff16-40ab-9d0f-dd86b4ed1e47	MEMBER	2026-10-19 13:05:13.812621+00
ebe039cf-46fc-40b8-8bb8-5e1b78b559da	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	MEMBER	2026-10-19 13:05:13.812639+00
7f5eb7e3-490e-41c4-9eb9-546d83954399	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	debbe165-84de-460c-b10a-d2cd7ea24966	MEMBER	2026-10-19 13:05:13.812646+00
18d02f82-7b37-4272-a38a-61fe242d1fcb	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	617f9e26-9faa-458c-b9b9-152f7e367117	MEMBER	2026-10-19 13:05:13.81265+00
07508601-9f33-42f8-bb4b-8c14fcd90d6d	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	b7f7db40-e219-4792-98a7-6b944703bdb4	MEMBER	2026-10-19 13:05:13.812661+00
7a50381a-4855-4e3a-bd6d-3695c80aa89c	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	12adcef2-8964-4ed6-95a5-bbb9a601803c	MEMBER	2026-10-19 13:05:13.812665+00
4858ab64-453c-45e9-bd8d-50473bdc416b	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	cda4ced3-4365-496e-99f9-82b3797f3f11	MEMBER	2026-10-19 13:05:13.81267+00
f460a488-ac77-4a68-af5f-47fb172552b8	5a4f221b-1350-4421-b060-d0eb7ccaf94d	cda4ced3-4365-496e-99f9-82b3797f3f11	MEMBER	2026-10-19 13:05:13.812715+00
017e4c08-0bba-48d0-b3f4-2abc867de09b	5a4f221b-1350-4421-b060-d0eb7ccaf94d	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	MEMBER	2026-10-19 13:05:13.812725+00
07115cbe-c867-4111-9740-67e5ddf37036	5a4f221b-1350-4421-b060-d0eb7ccaf94d	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	MEMBER	2026-10-19 13:05:13.812733+00
8db0fd66-da94-4341-b1a7-a7a3f499889c	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	779738d8-e0dd-43e3-83d4-2bcf579433bd	MEMBER	2026-10-19 13:05:13.812755+00
b037a002-9a29-46da-8bd9-a9917e319f27	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	617f9e26-9faa-458c-b9b9-152f7e367117	MEMBER	2026-10-19 13:05:13.812762+00
9cec9377-5cd7-4aac-b056-2b811cf429a2	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	cda4ced3-4365-496e-99f9-82b3797f3f11	MEMBER	2026-10-19 13:05:13.812766+00
a6fe9d2f-14bf-4fbf-952b-7a8c0667a6e6	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	bf90f67e-ace2-4080-9868-e732b525745d	MEMBER	2026-10-19 13:05:13.812782+00
64afb320-1a0d-48f9-8fa7-2fb1aa4d93a9	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	MEMBER	2026-10-19 13:05:13.812818+00
b545ebea-eba5-4968-be8c-26a6ddf0b94a	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	bf90f67e-ace2-4080-9868-e732b525745d	MEMBER	2026-10-19 13:05:13.812825+00
b7885801-4318-407a-b1a8-1c6157d037d8	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	779738d8-e0dd-43e3-83d4-2bcf579433bd	MEMBER	2026-10-19 13:05:13.812834+00
b63a5109-e3eb-4e60-b4d0-7cd657c765bf	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	c08aa28e-b894-4064-b712-e4f3e7cd0939	MEMBER	2026-10-19 13:05:13.812838+00
\.


--
-- Data for Name: agency_resource_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_resource_usage (agency_id, used_bytes, reserved_bytes, active_workspaces, internal_members, active_clients, inventory_state, version, reconciled_at, updated_at) FROM stdin;
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	0	0	4	10	3	PENDING	0	\N	2026-10-20 02:01:06.695762+00
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	0	0	3	13	3	PENDING	0	\N	2026-10-20 02:01:06.695762+00
1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	0	0	2	10	2	PENDING	0	\N	2026-10-20 02:01:06.695762+00
5a4f221b-1350-4421-b060-d0eb7ccaf94d	0	0	1	10	0	PENDING	0	\N	2026-10-20 02:01:06.695762+00
\.


--
-- Data for Name: agency_storage_reservations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_storage_reservations (id, agency_id, workspace_id, actor_id, material_id, request_key, fingerprint, provider, reserved_bytes, committed_bytes, derivative, state, phase, pool_hold_bytes, staging_cleaned_at, claim_token, claim_until, expires_at, created_at, updated_at) FROM stdin;
aa639c17-a2cc-4865-93b7-5b49393483e1	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	aa639c17-a2cc-4865-93b7-5b49393483e1	3c0399c1-9038-46a0-85b2-9e94dc327d88	98b0bd98ce0859ce09b05cace931be5853d98778a23e27ed40cbc8eac9a3638b	USER_GDRIVE	44453	\N	f	RELEASED	CREATED	0	2026-10-28 10:59:31.515177+00	\N	\N	2026-10-27 08:11:19.072653+00	2026-10-27 08:01:20.39017+00	2026-10-27 08:11:40.363339+00
0fca05dc-6cef-4719-baf7-c710dc967b4e	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	0fca05dc-6cef-4719-baf7-c710dc967b4e	aea9496b-777f-4453-9349-94fa8411f923	4dd3f21763000cc3505e70be77931669c3b4eca177ba3b56b4c4e11dd741cac2	USER_GDRIVE	88	88	f	COMMITTED	READY	0	2026-10-29 10:35:12.632234+00	4ee7c886-ef30-46d8-9507-fbaeca543313	2026-10-28 06:33:44.375327+00	2026-10-28 06:41:25.76845+00	2026-10-28 06:31:27.880892+00	2026-10-28 06:32:11.294014+00
881a84e2-3881-4aa5-9fcb-91dd9e9f099c	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	881a84e2-3881-4aa5-9fcb-91dd9e9f099c	ab81cf82-7912-4a06-b347-85c95bdddcfb	641edec2b4ca171a973d20116971434f3c6d1a5f7c886ef121d75b35a250b1cc	USER_GDRIVE	68536	68536	f	COMMITTED	READY	0	2026-10-29 10:35:14.384915+00	5b9d2706-fb1d-44c3-86b7-dcc0dfb93a42	2026-10-28 06:42:15.562726+00	2026-10-28 06:50:07.594249+00	2026-10-28 06:40:08.605045+00	2026-10-28 06:40:38.454034+00
\.


--
-- Data for Name: agency_storage_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_storage_usage (agency_id, used_bytes, reserved_bytes, inventory_verified_at, version, updated_at) FROM stdin;
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	0	0	2026-10-27 07:29:26.368547+00	1	2026-10-27 07:29:26.368547+00
1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	0	0	2026-10-27 07:34:26.366696+00	1	2026-10-27 07:34:26.366696+00
5a4f221b-1350-4421-b060-d0eb7ccaf94d	68624	0	2026-10-27 08:00:57.839443+00	8	2026-10-28 06:40:38.126289+00
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	0	0	2026-10-29 16:01:42.461252+00	0	2026-10-29 16:01:42.461252+00
\.


--
-- Data for Name: agency_subscription_periods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_subscription_periods (id, agency_id, subscription_id, plan_version_id, order_id, starts_at, ends_at, status, created_at, plan_billing_scope) FROM stdin;
58366f6a-b0b4-4120-a472-974c028f78a4	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	ade41e68-56e0-405a-9d82-f3930aa64dcc	24de5e8f-fcfa-4a98-a40f-84b971a81abe	0df4d0c7-9048-48f7-a336-03d46720e11c	2026-10-21 15:24:00+00	2026-11-21 15:24:00+00	CURRENT	2026-10-21 15:24:01.500405+00	AGENCY
16275413-3309-4ade-ae45-f644656ccbb2	5a4f221b-1350-4421-b060-d0eb7ccaf94d	73aacb1c-aa9d-4d1a-ac60-0179a1fee289	24de5e8f-fcfa-4a98-a40f-84b971a81abe	99b172ee-7071-45ee-a7fa-2b4b80e3b244	2026-10-20 09:48:00+00	2026-10-21 16:59:59+00	ENDED	2026-10-20 09:48:10.077399+00	AGENCY
4099947b-5b39-4d49-b360-774e053220dc	5a4f221b-1350-4421-b060-d0eb7ccaf94d	73aacb1c-aa9d-4d1a-ac60-0179a1fee289	24de5e8f-fcfa-4a98-a40f-84b971a81abe	8f884a25-d44a-4dec-a923-0f88d7bee347	2026-10-21 16:59:59+00	2026-11-21 16:59:59+00	CURRENT	2026-10-21 05:50:36.769292+00	AGENCY
b2000001-0000-4000-8000-000000000004	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	53e83aa5-b9bf-4c71-a25a-4fac39f07af6	24de5e8f-fcfa-4a98-a40f-84b971a81abe	f1df8348-2892-47a8-b3ee-acd626231bf9	2026-10-21 10:00:00+00	2026-11-21 10:00:00+00	CURRENT	2026-10-21 10:00:05+00	AGENCY
b2000001-0000-4000-8000-000000000014	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	99c07e25-8cd6-4807-86ec-7ed8c2857766	24de5e8f-fcfa-4a98-a40f-84b971a81abe	b2000001-0000-4000-8000-000000000011	2026-10-21 11:00:00+00	2026-11-21 11:00:00+00	CURRENT	2026-10-21 11:00:05+00	AGENCY
\.


--
-- Data for Name: agency_subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_subscriptions (id, agency_id, plan_version_id, status, current_period_start, current_period_end, migration_state, version, created_at, updated_at, plan_billing_scope) FROM stdin;
ade41e68-56e0-405a-9d82-f3930aa64dcc	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	24de5e8f-fcfa-4a98-a40f-84b971a81abe	ACTIVE	2026-10-21 15:24:00+00	2026-11-21 15:24:00+00	READY	2	2026-10-20 02:01:06.695762+00	2026-10-21 15:24:01.500405+00	AGENCY
73aacb1c-aa9d-4d1a-ac60-0179a1fee289	5a4f221b-1350-4421-b060-d0eb7ccaf94d	24de5e8f-fcfa-4a98-a40f-84b971a81abe	ACTIVE	2026-10-21 16:59:59+00	2026-11-21 16:59:59+00	READY	4	2026-10-20 02:01:06.695762+00	2026-10-22 09:57:31.339379+00	AGENCY
53e83aa5-b9bf-4c71-a25a-4fac39f07af6	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	24de5e8f-fcfa-4a98-a40f-84b971a81abe	ACTIVE	2026-10-21 10:00:00+00	2026-11-21 10:00:00+00	READY	2	2026-10-20 02:01:06.695762+00	2026-10-29 16:01:42.461252+00	AGENCY
99c07e25-8cd6-4807-86ec-7ed8c2857766	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	24de5e8f-fcfa-4a98-a40f-84b971a81abe	ACTIVE	2026-10-21 11:00:00+00	2026-11-21 11:00:00+00	READY	2	2026-10-20 02:01:06.695762+00	2026-10-29 16:01:42.461252+00	AGENCY
\.


--
-- Data for Name: ai_caption_generations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_caption_generations (id, workspace_id, user_id, task_id, request, variants, context, credits, chosen_type, chosen_action, final_text, chosen_at, created_at) FROM stdin;
\.


--
-- Data for Name: ai_credit_creator_limits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_credit_creator_limits (id, agency_id, creator_id, monthly_limit, set_by, created_at, updated_at) FROM stdin;
8b43218a-8fc3-4436-80a8-fb72306babd4	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	424	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.659152+00	2026-10-19 13:05:13.659154+00
bb3a6133-b56e-4e17-ac2f-38fcaa8a3f94	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	199	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.659163+00	2026-10-19 13:05:13.659164+00
5070a6ad-cf90-49ad-a327-a94f13d1b542	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	308	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-19 13:05:13.659169+00	2026-10-19 13:05:13.65917+00
0a9ed9b3-8a2e-4f24-a347-140db4fc5f19	5a4f221b-1350-4421-b060-d0eb7ccaf94d	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	320	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.659174+00	2026-10-19 13:05:13.659174+00
\.


--
-- Data for Name: ai_credit_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_credit_ledgers (id, agency_id, month, used_amount, created_at, updated_at) FROM stdin;
0a4897f8-a128-40c4-8cfc-c1fa2386d698	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	2026-10	275	2026-10-19 13:05:13.659101+00	2026-10-19 13:05:13.659105+00
082bcf76-588f-46cc-9690-bc5658b4e4b7	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	2026-10	448	2026-10-19 13:05:13.659159+00	2026-10-19 13:05:13.65916+00
746bf092-32b0-44b5-99c1-fa14ad3fdb12	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	2026-10	469	2026-10-19 13:05:13.659166+00	2026-10-19 13:05:13.659167+00
cfa0c9c4-7dc2-4d0f-93b4-8553a9c3e8da	5a4f221b-1350-4421-b060-d0eb7ccaf94d	2026-10	457	2026-10-19 13:05:13.659171+00	2026-10-19 13:05:13.659172+00
\.


--
-- Data for Name: ai_credit_operation_prices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_credit_operation_prices (id, operation, revision, unit_credits, enabled, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: ai_credit_reservations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_credit_reservations (id, job_id, agency_id, workspace_id, actor_id, period_id, action, model, rate_version, status, reserved_amount, charged_amount, provider_job_id, deadline, created_at, settled_at, request_key, payload_hash, price_id, unit_credits, units, successful_units, execution_state, execution_response, execution_updated_at) FROM stdin;
042e2bd2-94a1-4231-b5a2-32f1a300e078	042e2bd2-94a1-4231-b5a2-32f1a300e078	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	f825e63d-fb86-4187-8e9a-af2a99efc79f	HASHTAG_GENERATE	UNSPECIFIED	FREE_V1	SETTLED	0	0	\N	2026-10-28 16:34:34.531272+00	2026-10-27 16:34:34.531272+00	2026-10-27 16:34:39.824655+00	da8b82cd-1a45-4fae-a627-c2fa7ef04fbb	bea1ec8c3608b4d2f9a03addc2f2acf21c4fddcc9a99801bab06c888b7781cb0	\N	0	1	1	SUCCEEDED	{"hashtags": ["#laptop", "#fptshop", "#tansinhvien", "#laptophocsinhsinhvien", "#chonlaptop"], "platform": "facebook", "clamped_count": 5}	2026-10-27 16:34:39.824655+00
7faa8a7a-ae93-446f-ae20-1112ad7f970c	7faa8a7a-ae93-446f-ae20-1112ad7f970c	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	f825e63d-fb86-4187-8e9a-af2a99efc79f	HASHTAG_GENERATE	UNSPECIFIED	FREE_V1	SETTLED	0	0	\N	2026-10-29 12:38:21.37624+00	2026-10-28 12:38:21.37624+00	2026-10-28 12:38:27.095551+00	880006d5-f586-4658-8629-c8197e5d7a28	064ef3ef0fe9af99554c07a124f964059c658b4e2c7c4f211f2f05d3e5911af7	\N	0	1	1	SUCCEEDED	{"hashtags": ["#laptrinhvien", "#devlife", "#code", "#suckhoe", "#pov"], "platform": "facebook", "suggestions": [{"tag": "#laptrinhvien", "source": "AI_GENERATED"}, {"tag": "#devlife", "source": "AI_GENERATED"}, {"tag": "#code", "source": "AI_GENERATED"}, {"tag": "#suckhoe", "source": "AI_GENERATED"}, {"tag": "#pov", "source": "AI_GENERATED"}], "clamped_count": 5}	2026-10-28 12:38:27.095551+00
c02e1e6b-2ee1-4c1f-abfe-184e4369e4a7	c02e1e6b-2ee1-4c1f-abfe-184e4369e4a7	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	f825e63d-fb86-4187-8e9a-af2a99efc79f	HASHTAG_GENERATE	UNSPECIFIED	FREE_V1	SETTLED	0	0	\N	2026-10-29 12:53:39.041115+00	2026-10-28 12:53:39.041115+00	2026-10-28 12:53:43.135727+00	59c69360-0498-4d6b-bd44-7b6836bb7fb5	05a95c4765cad37cb27b3be1af7cd450adb9c010b4186666709e70dca2cb8d14	\N	0	1	1	SUCCEEDED	{"hashtags": ["#manualtester", "#kiemthuphanmem", "#softwaretesting", "#tuyendung", "#vnpt"], "platform": "facebook", "suggestions": [{"tag": "#manualtester", "source": "AI_GENERATED"}, {"tag": "#kiemthuphanmem", "source": "AI_GENERATED"}, {"tag": "#softwaretesting", "source": "AI_GENERATED"}, {"tag": "#tuyendung", "source": "AI_GENERATED"}, {"tag": "#vnpt", "source": "AI_GENERATED"}], "clamped_count": 5}	2026-10-28 12:53:43.135727+00
394dc76d-10dd-4d63-a984-36256ab59b02	394dc76d-10dd-4d63-a984-36256ab59b02	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	f825e63d-fb86-4187-8e9a-af2a99efc79f	HASHTAG_GENERATE	UNSPECIFIED	FREE_V1	SETTLED	0	0	\N	2026-10-29 13:15:41.710863+00	2026-10-28 13:15:41.710863+00	2026-10-28 13:15:54.894493+00	46b04506-02fd-416a-b3cb-ea268457dbd0	e730ec1e75c27ea47167939ff2977ee702823d9ab8320163eacefa69b69918a8	\N	0	1	1	SUCCEEDED	{"hashtags": ["#MuseAI", "#aivideo", "#StableDiffusion", "#aitools", "#côngnghệ"], "platform": "facebook", "suggestions": [{"tag": "#MuseAI", "source": "AI_GENERATED"}, {"tag": "#aivideo", "source": "AI_GENERATED"}, {"tag": "#StableDiffusion", "source": "AI_GENERATED"}, {"tag": "#aitools", "source": "AI_GENERATED"}, {"tag": "#côngnghệ", "source": "AI_GENERATED"}], "clamped_count": 5}	2026-10-28 13:15:54.894493+00
ed7b31a6-1fec-4836-bee0-ded99e0b2b57	ed7b31a6-1fec-4836-bee0-ded99e0b2b57	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	f825e63d-fb86-4187-8e9a-af2a99efc79f	HASHTAG_GENERATE	UNSPECIFIED	FREE_V1	RELEASED	0	0	\N	2026-10-28 16:03:42.016302+00	2026-10-27 16:03:42.016302+00	2026-10-28 16:04:00+00	07f430d4-9f60-4a4e-9b92-b86f4d241594	bea1ec8c3608b4d2f9a03addc2f2acf21c4fddcc9a99801bab06c888b7781cb0	\N	0	1	0	FAILED	\N	2026-10-28 16:04:00+00
\.


--
-- Data for Name: ai_credit_usages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_credit_usages (id, agency_id, user_id, workspace_id, feature, credits, month, reference, refunded_at, created_at) FROM stdin;
\.


--
-- Data for Name: ai_video_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_video_jobs (id, workspace_id, user_id, usage_id, prompt, style_key, ambassador_id, aspect_ratio, status, video_url, error_code, refunded_at, created_at, finished_at, s3_key, reservation_id) FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, agency_id, user_id, action, resource_type, resource_id, ip_address, user_agent, old_value, new_value, created_at) FROM stdin;
1	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	ROLE_CHANGE	user	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	127.0.0.1	\N	\N	\N	2026-08-14 13:05:14.033527+00
2	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	1dab38ca-17e7-49f6-ab2c-cc8b20fc669f	LOGOUT	agency_member	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	127.0.0.1	\N	\N	\N	2026-09-07 13:05:14.033569+00
3	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	VIEW	client_profile	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	127.0.0.1	\N	\N	\N	2026-09-16 13:05:14.033575+00
4	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	b7f7db40-e219-4792-98a7-6b944703bdb4	LOGIN	agency_member	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	127.0.0.1	\N	\N	\N	2026-08-26 13:05:14.033577+00
5	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	agency_member	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	127.0.0.1	\N	\N	\N	2026-08-07 13:05:14.033578+00
6	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	PASSWORD_RESET	client_profile	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	127.0.0.1	\N	\N	\N	2026-10-03 13:05:14.033581+00
7	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	eace4871-7580-4f8e-898a-f7f25a838594	UPDATE	agency_member	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	127.0.0.1	\N	\N	\N	2026-07-30 13:05:14.033584+00
8	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	ROLE_CHANGE	user	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	127.0.0.1	\N	\N	\N	2026-09-20 13:05:14.033585+00
9	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	DELETE	workspace	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	127.0.0.1	\N	\N	\N	2026-08-05 13:05:14.033587+00
10	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	617f9e26-9faa-458c-b9b9-152f7e367117	CREATE	workspace	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	127.0.0.1	\N	\N	\N	2026-10-13 13:05:14.033589+00
11	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	3da73a3d-a522-4c48-a293-4338b2969670	UPDATE	workspace	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	127.0.0.1	\N	\N	\N	2026-09-15 13:05:14.03359+00
12	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	eace4871-7580-4f8e-898a-f7f25a838594	DELETE	media_campaign	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	127.0.0.1	\N	\N	\N	2026-08-16 13:05:14.033592+00
13	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	PASSWORD_RESET	client_profile	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	127.0.0.1	\N	\N	\N	2026-07-29 13:05:14.033598+00
14	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	b213cbc7-613c-4a34-8aa1-4876684a1ee9	EXPORT	agency_member	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	127.0.0.1	\N	\N	\N	2026-08-25 13:05:14.0336+00
15	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	b7f7db40-e219-4792-98a7-6b944703bdb4	VIEW	media_campaign	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	127.0.0.1	\N	\N	\N	2026-08-10 13:05:14.033601+00
16	5a4f221b-1350-4421-b060-d0eb7ccaf94d	17805121-ff16-40ab-9d0f-dd86b4ed1e47	TOKEN_REFRESH	media_campaign	5a4f221b-1350-4421-b060-d0eb7ccaf94d	127.0.0.1	\N	\N	\N	2026-08-24 13:05:14.033602+00
17	5a4f221b-1350-4421-b060-d0eb7ccaf94d	1ad8870e-5bce-421d-a37c-49b15ef97166	PASSWORD_RESET	agency_member	5a4f221b-1350-4421-b060-d0eb7ccaf94d	127.0.0.1	\N	\N	\N	2026-09-10 13:05:14.033604+00
18	\N	f40a1175-dd94-41fe-91ea-c37c38311959	LOGIN	USER	f40a1175-dd94-41fe-91ea-c37c38311959	\N	\N	\N	\N	2026-10-19 13:09:32.893492+00
19	\N	f40a1175-dd94-41fe-91ea-c37c38311959	TOKEN_REFRESH	USER	f40a1175-dd94-41fe-91ea-c37c38311959	\N	\N	\N	\N	2026-10-19 13:09:40.832854+00
20	\N	f40a1175-dd94-41fe-91ea-c37c38311959	LOGOUT	USER	f40a1175-dd94-41fe-91ea-c37c38311959	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-19 13:09:40.876861+00
21	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-19 13:09:42.329781+00
22	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-19 13:10:28.222102+00
23	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGOUT	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-19 13:10:28.270748+00
24	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-19 13:10:30.223628+00
25	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-19 13:57:23.210169+00
26	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 07:17:22.904431+00
27	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 07:47:18.886308+00
28	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 08:04:56.376924+00
29	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 08:12:13.466318+00
30	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 08:20:13.076242+00
31	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 08:39:06.184422+00
32	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:15:00.378444+00
33	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:15:00.378444+00
34	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:19:39.374067+00
35	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-20 09:19:39.418067+00
36	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:19:52.926908+00
37	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:21:22.320003+00
38	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:21:55.123399+00
39	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:23:17.291373+00
40	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:25:19.299455+00
41	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:28:36.346612+00
42	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:35:18.621235+00
43	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 09:47:46.306408+00
44	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 10:02:47.258141+00
45	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 10:17:47.197242+00
46	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 10:32:47.18022+00
47	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 10:47:47.200894+00
48	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 11:02:47.209722+00
49	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 11:22:18.452698+00
50	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 11:37:33.700321+00
51	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 11:52:33.699727+00
52	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 12:07:33.699051+00
53	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 12:22:33.759044+00
54	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 12:37:33.699511+00
55	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 12:52:33.724349+00
56	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 13:07:33.731034+00
57	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 13:22:33.69731+00
58	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 13:37:33.722809+00
59	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 13:52:33.724542+00
60	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 14:07:33.717036+00
61	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 14:22:33.716961+00
62	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 14:37:33.725945+00
63	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 14:52:33.71598+00
64	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 15:07:33.723677+00
65	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 15:22:33.723642+00
66	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 15:37:33.699854+00
67	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 15:52:33.703443+00
68	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-20 16:07:33.703729+00
101	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 04:24:13.831523+00
102	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 04:39:30.890146+00
103	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 05:28:47.950197+00
104	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 05:44:17.438014+00
105	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 05:49:03.317436+00
106	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-21 05:49:03.429095+00
107	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 05:49:05.096024+00
108	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 06:04:38.985557+00
109	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 06:22:47.386804+00
110	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 07:22:57.735675+00
111	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 07:23:00.712815+00
112	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-21 07:23:00.783513+00
113	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-21 07:23:03.165097+00
114	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-21 07:23:15.792423+00
115	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGOUT	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-21 07:23:15.832032+00
116	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 15:22:13.528666+00
117	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 15:49:37.132482+00
118	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-21 15:50:00.571331+00
119	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-21 15:50:00.599672+00
120	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-21 15:50:15.992592+00
121	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:50:22.521584+00
122	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:50:24.19567+00
123	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:50:31.364051+00
124	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:51:03.609661+00
125	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:52:30.87241+00
126	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:52:43.024502+00
127	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-21 15:53:34.241077+00
128	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:53:47.549952+00
129	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 15:54:14.467116+00
130	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:03:32.597514+00
131	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:03:32.886293+00
132	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:03:56.871109+00
133	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:03:57.056394+00
134	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:04:35.048916+00
135	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:04:35.603331+00
136	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:04:48.374651+00
137	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:04:48.956068+00
138	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:06:16.291428+00
139	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:06:16.870494+00
140	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-21 16:06:16.893192+00
141	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:06:16.909157+00
142	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:06:16.970776+00
143	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:06:17.013434+00
144	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:07:09.810475+00
145	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:07:09.954805+00
146	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:08:17.747919+00
208	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 17:19:34.374085+00
147	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:08:17.994603+00
148	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-21 16:23:51.44992+00
149	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:23:51.535335+00
150	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:23:53.618433+00
151	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-21 16:25:21.007744+00
152	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-21", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-21 16:31:27.445841+00
153	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 09:57:59.100766+00
154	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 09:58:04.945961+00
155	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGOUT	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-22 09:58:04.992441+00
156	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 10:11:01.20199+00
157	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-22 10:11:30.745649+00
158	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-22 10:11:31.354341+00
159	\N	f40a1175-dd94-41fe-91ea-c37c38311959	LOGIN	USER	f40a1175-dd94-41fe-91ea-c37c38311959	\N	\N	\N	\N	2026-10-22 10:11:31.959432+00
160	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 10:12:40.008954+00
161	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 10:12:53.639127+00
162	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGOUT	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-22 10:12:53.701212+00
163	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-22 10:12:58.336273+00
164	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-22 10:13:05.945532+00
165	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-22 10:13:05.9936+00
166	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-22 10:13:07.459938+00
167	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 17:59:51.982257+00
168	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 17:59:59.902386+00
169	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 18:00:10.41657+00
170	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 18:00:27.152517+00
171	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 18:06:20.916404+00
172	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-22 18:09:53.769053+00
173	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 04:33:52.432458+00
174	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 04:42:18.16706+00
175	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:19:57.233174+00
176	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:27:01.089674+00
177	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:34:03.66699+00
178	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:34:04.340618+00
179	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:34:02.561602+00
180	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:35:35.211477+00
181	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:35:54.763233+00
182	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:40:37.970301+00
183	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 05:41:43.085472+00
184	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 07:32:38.485669+00
185	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGIN	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-23 08:07:49.977233+00
186	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-25 15:59:03.242073+00
187	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-25 15:59:13.634294+00
188	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	LOGOUT	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-25 15:59:13.700573+00
189	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-25 15:59:17.527819+00
190	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-26 02:51:15.473099+00
191	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-26 05:58:36.955634+00
192	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-26 05:59:18.512923+00
193	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGOUT	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-26 05:59:18.566675+00
194	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-26 05:59:21.291928+00
195	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-26 05:59:23.084926+00
196	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGOUT	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-26 05:59:23.143355+00
197	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 05:59:24.517492+00
198	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 06:21:24.568825+00
199	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 15:31:57.880933+00
200	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 15:46:58.734284+00
201	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 16:01:59.023771+00
202	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 16:02:29.337971+00
203	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 16:17:32.501422+00
204	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 16:17:33.84359+00
205	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 16:17:41.800558+00
206	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 17:18:46.969466+00
207	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-26 17:19:34.373547+00
209	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 04:34:01.215016+00
210	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 04:34:09.606423+00
211	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 04:49:16.056613+00
212	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 05:04:59.139166+00
213	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 05:05:02.789969+00
214	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 05:20:05.297955+00
215	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 05:35:05.196741+00
216	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 05:52:35.413235+00
217	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 05:53:07.539362+00
218	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 06:08:45.326453+00
219	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 06:08:45.325453+00
220	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 06:25:07.160427+00
221	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 06:35:00.069938+00
222	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 06:50:00.341689+00
223	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 06:50:17.00155+00
224	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 06:50:17.073408+00
225	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 06:50:19.130264+00
226	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 07:29:25.91822+00
227	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 07:33:53.676298+00
228	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGOUT	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 07:33:53.81262+00
229	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:33:55.305924+00
230	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:34:09.053196+00
231	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 07:34:09.099549+00
232	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 07:34:11.444099+00
233	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 07:35:12.196949+00
234	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGOUT	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 07:35:12.245036+00
235	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:35:14.391192+00
236	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:35:34.517386+00
237	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 07:35:34.559013+00
238	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:35:36.535149+00
239	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:51:05.65986+00
240	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:53:26.495845+00
241	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 07:53:26.534637+00
242	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 07:53:28.616099+00
243	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 07:53:35.264028+00
244	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGOUT	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 07:53:35.300832+00
245	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGIN	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:53:37.097101+00
246	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	TOKEN_REFRESH	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	\N	\N	\N	2026-10-27 07:58:42.941348+00
247	\N	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	LOGOUT	USER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-27 07:58:42.977713+00
248	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 07:58:44.546877+00
249	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 08:14:02.523323+00
250	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 08:52:21.509439+00
251	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 09:12:31.864801+00
252	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 09:39:38.896496+00
253	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 09:54:42.363752+00
254	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 10:09:47.218128+00
255	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 10:24:49.583656+00
256	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 10:40:00.126152+00
257	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 16:03:09.207182+00
258	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-27 16:26:27.256096+00
259	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 06:04:46.442342+00
260	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	TOKEN_REFRESH	USER	5f46d7d8-6689-4ece-84f8-39e5de081c5c	\N	\N	\N	\N	2026-10-28 06:24:49.624703+00
261	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 06:30:08.103343+00
262	5a4f221b-1350-4421-b060-d0eb7ccaf94d	12adcef2-8964-4ed6-95a5-bbb9a601803c	DELETE	MATERIAL	0fca05dc-6cef-4719-baf7-c710dc967b4e	\N	\N	\N	{"_id": "7035cce9-6066-43a5-8202-44c1166112a8", "name": "debug-upload.png", "actor_id": "12adcef2-8964-4ed6-95a5-bbb9a601803c", "agency_id": "5a4f221b-1350-4421-b060-d0eb7ccaf94d", "delivered": false, "file_size": 88, "operation": "SOFT_DELETE", "created_at": "2026-10-28T06:33:13.919+00:00", "material_id": "0fca05dc-6cef-4719-baf7-c710dc967b4e", "workspace_id": "bb996948-4b50-4761-a682-07a3e7a43eba"}	2026-10-28 06:33:13.919+00
263	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 06:37:29.84417+00
264	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 06:45:32.289111+00
265	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 07:32:07.978823+00
266	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 12:37:15.530979+00
267	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	LOGIN	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 12:52:49.468144+00
268	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 13:08:00.216772+00
269	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 13:24:24.339737+00
270	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 13:39:40.99516+00
271	\N	12adcef2-8964-4ed6-95a5-bbb9a601803c	TOKEN_REFRESH	USER	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	\N	\N	\N	2026-10-28 13:54:44.500369+00
\.


--
-- Data for Name: billing_audit_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_audit_events (id, agency_id, actor_id, action, resource_id, before_value, after_value, created_at) FROM stdin;
23854743-4c05-4649-9181-efd39d541b6e	5a4f221b-1350-4421-b060-d0eb7ccaf94d	\N	TEST_EXPIRY_OVERRIDE	73aacb1c-aa9d-4d1a-ac60-0179a1fee289	{"currentPeriodEnd": "2026-11-20T09:48:00+00:00"}	{"reason": "User-requested renewal test; original payment records preserved", "currentPeriodEnd": "2026-10-21T16:59:59+00:00"}	2026-10-21 05:40:42.685371+00
\.


--
-- Data for Name: billing_migration_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_migration_reviews (id, source_table, source_id, owner_id, candidate_agency_ids, reason, status, resolved_agency_id, resolved_by, resolution_note, resolved_at, created_at) FROM stdin;
a518b68e-0acc-479f-b7c3-96e49b034db6	user_subscriptions	191ec251-3624-43cd-bb23-ae1632f2a764	f40a1175-dd94-41fe-91ea-c37c38311959	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
df06a01e-9455-4ff9-a993-2f340199c826	user_subscriptions	c2d90775-9ed5-4287-b6f5-af9b8acd71ee	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	{1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76,1cb9a40d-7bd8-4096-91aa-d1411cdc961b,5a4f221b-1350-4421-b060-d0eb7ccaf94d}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
800fc66c-844f-4cb6-ae05-e0f8d4f9b389	user_subscriptions	e6875510-46fc-403e-8749-ff79cb096b17	3da73a3d-a522-4c48-a293-4338b2969670	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
9931ad4a-51e8-4f4f-83b5-b3c9727aee0e	user_subscriptions	5b3a966d-8c0b-4e8c-bb4c-735a927c20f0	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
fa870288-f64a-4c0e-b76f-2776d293412e	user_subscriptions	4beb4d28-b953-4340-a48c-6e09f5c5d2dc	1ad8870e-5bce-421d-a37c-49b15ef97166	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
a72b7465-a662-4c0a-b44e-847cd42166f4	user_subscriptions	2c744adb-6c61-4247-a695-190a23768040	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
46bcb718-e2ee-47ac-bd8d-79a8356cc68b	user_subscriptions	e519fc65-b59f-4f8e-8996-157163012fba	debbe165-84de-460c-b10a-d2cd7ea24966	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
13d7a5e8-7dbf-4050-b948-30119d5eefd9	user_subscriptions	6c5a6ba2-213d-478f-a4a7-fc85e06d432a	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	{1fb7ed01-a9d4-4373-afb4-3ac8c47afde5}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
dc7ac067-c224-4780-8493-1c7a32191117	user_subscriptions	c0cc41b6-13dc-4609-9311-d95d170248a3	b213cbc7-613c-4a34-8aa1-4876684a1ee9	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
5a8e41d6-1638-4ebe-8b78-589053f75234	user_subscriptions	3d79e4ce-8f0d-4295-9777-c075636e2610	17805121-ff16-40ab-9d0f-dd86b4ed1e47	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
4159efb4-a1f3-46f8-9286-6a03fe6724e8	user_subscriptions	56caf3ee-89aa-4f91-82a7-6f22796ee2ae	bf90f67e-ace2-4080-9868-e732b525745d	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
271e8324-e87f-4d5b-9bd4-c6a32483f6ce	user_subscriptions	42e1b892-8d8c-411a-b46a-a6f13398017d	1845f16a-9e5e-42e2-82f1-de5f565cb7d2	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
54cc13a7-3e64-4969-924e-29436453fba0	user_subscriptions	08021295-df3b-47f1-85e7-85a55844261e	cda4ced3-4365-496e-99f9-82b3797f3f11	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
daef0c52-35bb-46bd-aa24-bf7f679e8c5b	user_subscriptions	3d744f6f-6690-4f2e-8977-4de7a0115a0b	b84cb77d-fb5f-43c9-858b-bb91be0dcf24	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
a5f5326c-ba75-4bca-b24b-c3be8f9d535f	user_subscriptions	2192fe25-f245-4f7d-908f-5c0036911728	779738d8-e0dd-43e3-83d4-2bcf579433bd	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
da726c0e-3548-4dce-923b-902ea038f8ca	user_subscriptions	9d1d690f-e03f-49c6-8871-32a2f7879dc4	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
063700ff-7cab-402b-8393-14747627bd71	user_subscriptions	9b16dfd7-d998-4905-be9b-9d07aa5c2c95	617f9e26-9faa-458c-b9b9-152f7e367117	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
af056cfd-04ba-4d83-92f9-f6e35e305de3	user_subscriptions	0e037c76-ee39-44fc-a2b1-c6fa2f8f1321	c08aa28e-b894-4064-b712-e4f3e7cd0939	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
1b5fb767-bb06-49c4-907f-30c4f44c491c	user_subscriptions	2cbd63ff-f81d-4da9-914c-88d24b37c993	c71364bf-dd7f-4279-beb0-e31c75b6780e	{}	Legacy entitlement must be mapped and balances reconciled before agency cutover	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
896ff8ab-a07e-402e-bb4d-a5307634a638	transactions	f281e415-caf2-4c65-b45e-24fcb2cb1764	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	{1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76,1cb9a40d-7bd8-4096-91aa-d1411cdc961b,5a4f221b-1350-4421-b060-d0eb7ccaf94d}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
d5fdc929-904a-4248-906a-6ff49724fa6c	transactions	cf86f238-4d4b-4583-9828-283178121501	3da73a3d-a522-4c48-a293-4338b2969670	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
352d51ce-bbf6-420f-948e-fbb6e5f1e5c8	transactions	5a125904-161d-43ca-8462-97a150e32461	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
2e7627c1-122e-49e2-9a1b-807eca40d30c	transactions	f8b3f7ea-2a7d-4cfc-8fb6-b8dfe64163bf	1ad8870e-5bce-421d-a37c-49b15ef97166	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
6c46e549-b36d-425a-a91e-99a5763d27e3	transactions	a40740bc-9e1c-4474-ae54-c7c6d4dd362f	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
6efec981-8005-4177-8e7f-4f4d4c55fa57	transactions	c62652c8-580c-4136-8731-ba25f2d8e1c3	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	{1fb7ed01-a9d4-4373-afb4-3ac8c47afde5}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
879e1644-3eec-4fbd-b7d0-4456e7bd563e	transactions	09cef1fe-f72e-42ac-834b-1bf3a6fcc5b9	17805121-ff16-40ab-9d0f-dd86b4ed1e47	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
5d7ea4fa-e71f-4de6-a1d0-9d8b426b4679	transactions	5cabf39f-5938-4cb2-bba2-e085d3f8a6db	bf90f67e-ace2-4080-9868-e732b525745d	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
84a86e97-9f1f-4fb7-96a4-8ff4d9e25c77	transactions	32beab51-97d5-4cba-b0f4-d461baffd98e	b84cb77d-fb5f-43c9-858b-bb91be0dcf24	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
3024a1a3-e77d-4862-b0e3-32d6dcf95023	transactions	cf623cdb-26cb-4434-9540-b4d58bab58da	779738d8-e0dd-43e3-83d4-2bcf579433bd	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
d708fb15-5647-46f4-b294-4fa7dfe563af	transactions	b1e30473-fc80-4293-ac01-2ef2b7376bb0	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
896e4cd3-0e54-477a-aa74-1c71e72f4daa	transactions	47befa7d-7231-455c-aa3b-8e81d0ecab50	617f9e26-9faa-458c-b9b9-152f7e367117	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
694e7c2b-0792-4668-930f-adc6e217f9f6	transactions	17637c5c-1950-4b73-bc56-dcd9cac173a8	c71364bf-dd7f-4279-beb0-e31c75b6780e	{}	Payer alone does not prove beneficiary agency; preserve original payment	RESOLVED	\N	5f46d7d8-6689-4ece-84f8-39e5de081c5c	Reconciled and verified during agency subscription synchronization	2026-10-29 16:01:42.461252+00	2026-10-20 02:01:06.695762+00
\.


--
-- Data for Name: billing_order_fulfillments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_order_fulfillments (id, agency_id, order_id, benefit_type, created_at) FROM stdin;
a809d0a6-751c-4a02-8ef3-eda064e123f0	5a4f221b-1350-4421-b060-d0eb7ccaf94d	99b172ee-7071-45ee-a7fa-2b4b80e3b244	SUBSCRIPTION_PERIOD	2026-10-20 09:48:10.077399+00
fd513da5-d82b-43c8-99cd-b353c4ee0192	5a4f221b-1350-4421-b060-d0eb7ccaf94d	99b172ee-7071-45ee-a7fa-2b4b80e3b244	CREDIT_GRANT	2026-10-20 09:48:10.077399+00
bc00e35f-7c4e-4f4b-93f8-847df72f8a60	5a4f221b-1350-4421-b060-d0eb7ccaf94d	8f884a25-d44a-4dec-a923-0f88d7bee347	SUBSCRIPTION_PERIOD	2026-10-21 05:50:36.769292+00
d66b4be5-0a89-48e3-977f-4672635316d1	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	0df4d0c7-9048-48f7-a336-03d46720e11c	SUBSCRIPTION_PERIOD	2026-10-21 15:24:01.500405+00
34264130-b867-48ba-b507-9c6af9cd71e6	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	0df4d0c7-9048-48f7-a336-03d46720e11c	CREDIT_GRANT	2026-10-21 15:24:01.500405+00
ace77a61-4f4d-4669-a4f1-8fa6afdd9aff	5a4f221b-1350-4421-b060-d0eb7ccaf94d	8f884a25-d44a-4dec-a923-0f88d7bee347	CREDIT_GRANT	2026-10-22 09:57:31.339379+00
\.


--
-- Data for Name: billing_orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_orders (id, agency_id, payer_user_id, kind, status, idempotency_key, payload_hash, amount, currency, product_snapshot, plan_version_id, period_start, period_end, expires_at, paid_at, fulfilled_at, created_at, updated_at, plan_billing_scope) FROM stdin;
99b172ee-7071-45ee-a7fa-2b4b80e3b244	5a4f221b-1350-4421-b060-d0eb7ccaf94d	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	SUBSCRIPTION	FULFILLED	55bdde18-bafd-43bb-a0c2-12a3e1e3e028	dbeecd6a38c845758af14024975c53b6c00fe7c8936366f9e186cfe7b25453f4	5000	VND	{"planCode": "PLUS", "periodMonths": 1, "planVersionId": "24de5e8f-fcfa-4a98-a40f-84b971a81abe", "monthlyCredits": 5000}	24de5e8f-fcfa-4a98-a40f-84b971a81abe	2026-10-20 09:48:00+00	2026-11-20 09:48:00+00	2026-10-20 10:17:56.389361+00	2026-10-20 09:48:00+00	2026-10-20 09:48:10.077399+00	2026-10-20 09:47:56.379573+00	2026-10-20 09:48:10.077399+00	AGENCY
8f884a25-d44a-4dec-a923-0f88d7bee347	5a4f221b-1350-4421-b060-d0eb7ccaf94d	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	SUBSCRIPTION	FULFILLED	34d61e38-42a0-437e-be09-7842eb346542	8a7f6075e53ad6eeea526378047af8a98d072156d152f07d879fc639aa39ff17	5000	VND	{"action": "RENEWAL", "planCode": "PLUS", "periodMonths": 1, "planVersionId": "24de5e8f-fcfa-4a98-a40f-84b971a81abe", "monthlyCredits": 5000}	24de5e8f-fcfa-4a98-a40f-84b971a81abe	2026-10-21 16:59:59+00	2026-11-21 16:59:59+00	2026-10-21 06:19:12.426941+00	2026-10-21 05:50:00+00	2026-10-21 05:50:36.769292+00	2026-10-21 05:49:12.374921+00	2026-10-21 05:50:36.769292+00	AGENCY
f197d454-fb77-444e-b576-5bf2f0cdc4d3	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	SUBSCRIPTION	EXPIRED	b997b795-5917-4e5a-91e8-eb285aa8090b	8b9b3752bc14a84096384b052dfa5f56fcc6d180dbbd7876ca0be05c4c6e6a01	5000	VND	{"action": "UPGRADE", "planCode": "PLUS", "periodMonths": 1, "planVersionId": "24de5e8f-fcfa-4a98-a40f-84b971a81abe", "monthlyCredits": 5000}	24de5e8f-fcfa-4a98-a40f-84b971a81abe	2026-10-21 05:57:28.181702+00	2026-11-21 05:57:28.181702+00	2026-10-21 06:12:28.181702+00	\N	\N	2026-10-21 05:57:28.15278+00	2026-10-21 15:22:25.242864+00	AGENCY
0df4d0c7-9048-48f7-a336-03d46720e11c	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	SUBSCRIPTION	FULFILLED	2064f954-fb43-4073-a55b-2db1538698f2	8b9b3752bc14a84096384b052dfa5f56fcc6d180dbbd7876ca0be05c4c6e6a01	5000	VND	{"action": "UPGRADE", "planCode": "PLUS", "periodMonths": 1, "planVersionId": "24de5e8f-fcfa-4a98-a40f-84b971a81abe", "monthlyCredits": 5000}	24de5e8f-fcfa-4a98-a40f-84b971a81abe	2026-10-21 15:24:00+00	2026-11-21 15:24:00+00	2026-10-21 15:37:25.265716+00	2026-10-21 15:24:00+00	2026-10-21 15:24:01.500405+00	2026-10-21 15:22:25.242864+00	2026-10-21 15:24:01.500405+00	AGENCY
470a8ce3-76ae-4efd-9732-64d38de64513	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	SUBSCRIPTION	EXPIRED	b26e79bf-f419-4156-9e2f-5d7de62dd365	8a7f6075e53ad6eeea526378047af8a98d072156d152f07d879fc639aa39ff17	5000	VND	{"action": "RENEWAL", "planCode": "PLUS", "periodMonths": 1, "planVersionId": "24de5e8f-fcfa-4a98-a40f-84b971a81abe", "monthlyCredits": 5000}	24de5e8f-fcfa-4a98-a40f-84b971a81abe	2026-10-21 15:24:15.330361+00	2026-11-21 15:24:15.330361+00	2026-10-21 15:39:15.330361+00	\N	\N	2026-10-21 15:24:15.312887+00	2026-10-29 16:01:42.461252+00	AGENCY
f1df8348-2892-47a8-b3ee-acd626231bf9	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	SUBSCRIPTION	FULFILLED	eec13737-5f62-4cf8-90d4-936c242a871d	dbeecd6a38c845758af14024975c53b6c00fe7c8936366f9e186cfe7b25453f4	5000	VND	{"planCode": "PLUS", "periodMonths": 1, "planVersionId": "24de5e8f-fcfa-4a98-a40f-84b971a81abe", "monthlyCredits": 5000}	24de5e8f-fcfa-4a98-a40f-84b971a81abe	2026-10-21 10:00:00+00	2026-11-21 10:00:00+00	2026-10-20 10:07:56.6615+00	2026-10-21 10:00:00+00	2026-10-21 10:00:05+00	2026-10-20 09:37:56.716119+00	2026-10-29 16:01:42.461252+00	AGENCY
b2000001-0000-4000-8000-000000000011	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	SUBSCRIPTION	FULFILLED	c1fc0500-0000-4000-8000-000000000011	dbeecd6a38c845758af14024975c53b6c00fe7c8936366f9e186cfe7b25453f4	5000	VND	{"action": "UPGRADE", "planCode": "PLUS", "periodMonths": 1, "planVersionId": "24de5e8f-fcfa-4a98-a40f-84b971a81abe", "monthlyCredits": 5000}	24de5e8f-fcfa-4a98-a40f-84b971a81abe	2026-10-21 11:00:00+00	2026-11-21 11:00:00+00	2026-10-21 11:30:00+00	2026-10-21 11:00:00+00	2026-10-21 11:00:05+00	2026-10-21 10:55:00+00	2026-10-21 11:00:05+00	AGENCY
\.


--
-- Data for Name: billing_outbox_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_outbox_events (id, agency_id, event_key, event_type, payload, attempts, available_at, published_at, last_error, created_at) FROM stdin;
a5497338-e25a-4092-a950-fbc959f9e56a	5a4f221b-1350-4421-b060-d0eb7ccaf94d	subscription-upgraded:99b172ee-7071-45ee-a7fa-2b4b80e3b244	AGENCY_SUBSCRIPTION_UPGRADED	{"orderId": "99b172ee-7071-45ee-a7fa-2b4b80e3b244", "planCode": "PLUS"}	0	2026-10-20 09:48:10.077399+00	\N	\N	2026-10-20 09:48:10.077399+00
3f2347ed-6dbb-415d-8ac6-c6a0e105e81d	5a4f221b-1350-4421-b060-d0eb7ccaf94d	subscription-renewal:8f884a25-d44a-4dec-a923-0f88d7bee347	AGENCY_SUBSCRIPTION_RENEWED	{"action": "RENEWAL", "orderId": "8f884a25-d44a-4dec-a923-0f88d7bee347", "planCode": "PLUS"}	0	2026-10-21 05:50:36.769292+00	\N	\N	2026-10-21 05:50:36.769292+00
b8851c84-61c7-41b8-b9cf-5d036aa33235	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	subscription-upgrade:0df4d0c7-9048-48f7-a336-03d46720e11c	AGENCY_SUBSCRIPTION_UPGRADED	{"action": "UPGRADE", "orderId": "0df4d0c7-9048-48f7-a336-03d46720e11c", "planCode": "PLUS"}	0	2026-10-21 15:24:01.500405+00	\N	\N	2026-10-21 15:24:01.500405+00
\.


--
-- Data for Name: billing_payment_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_payment_attempts (id, agency_id, order_id, provider, merchant_account, provider_order_code, payment_link_id, status, created_at, updated_at) FROM stdin;
09ab056e-5d30-443f-b5e1-e93ed39dbe5c	5a4f221b-1350-4421-b060-d0eb7ccaf94d	99b172ee-7071-45ee-a7fa-2b4b80e3b244	SEEPAY	0375622474	BH99B172EE707145EEA7FA	\N	SUCCEEDED	2026-10-20 09:47:56.379573+00	2026-10-20 09:48:10.077399+00
c3b371ac-05ed-436d-a485-137ed482d94a	5a4f221b-1350-4421-b060-d0eb7ccaf94d	8f884a25-d44a-4dec-a923-0f88d7bee347	SEEPAY	0375622474	BH8F884A25D44A4DECA923	\N	SUCCEEDED	2026-10-21 05:49:12.374921+00	2026-10-21 05:50:36.769292+00
6ede1ab3-4cc8-44a0-a4a7-1bbb7c974354	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	0df4d0c7-9048-48f7-a336-03d46720e11c	SEEPAY	0375622474	BH0DF4D0C7904848F7A336	\N	SUCCEEDED	2026-10-21 15:22:25.242864+00	2026-10-21 15:24:01.500405+00
3b2c59bd-66fa-4be9-acb8-40a9fe1962b2	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	f197d454-fb77-444e-b576-5bf2f0cdc4d3	SEEPAY	0375622474	BHF197D454FB77444EB576	\N	FAILED	2026-10-21 05:57:28.15278+00	2026-10-29 16:01:42.461252+00
075984b8-1bbb-4b05-b252-9b9816ea6c6a	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	470a8ce3-76ae-4efd-9732-64d38de64513	SEEPAY	0375622474	BH470A8CE376AE4EFD9732	\N	FAILED	2026-10-21 15:24:15.312887+00	2026-10-29 16:01:42.461252+00
3af46cf4-1106-4a05-8740-829e875dd2bd	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	f1df8348-2892-47a8-b3ee-acd626231bf9	SEEPAY	0375622474	BHF1DF8348289247A8B3EE	\N	SUCCEEDED	2026-10-20 09:37:56.716119+00	2026-10-21 10:00:05+00
b2000001-0000-4000-8000-000000000012	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	b2000001-0000-4000-8000-000000000011	SEEPAY	0375622474	BHCIRCUSPLUS20261021	\N	SUCCEEDED	2026-10-21 10:55:00+00	2026-10-21 11:00:05+00
\.


--
-- Data for Name: billing_payment_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_payment_events (id, provider, merchant_account, event_key, payload_hash, order_id, status, received_at, processed_at, last_error) FROM stdin;
4e37af78-2eea-42aa-a53e-0b0aa2443b9b	SEEPAY	0375622474	91667799	98b6936f802200f7b4d8a7430df89a5c656719800de24f455dba07502bacf88b	99b172ee-7071-45ee-a7fa-2b4b80e3b244	PROCESSED	2026-10-20 09:48:10.077399+00	2026-10-20 09:48:10.077399+00	\N
f8d91b94-bb91-415c-ab11-3856ecd1033a	SEEPAY	0375622474	91916760	892eacd1621c26070537300400cf0edafd67d1e62ce1ec2f1ebbfd9335aa3f6c	8f884a25-d44a-4dec-a923-0f88d7bee347	PROCESSED	2026-10-21 05:50:36.769292+00	2026-10-21 05:50:36.769292+00	\N
0a08986e-8798-4888-86d6-db51f141278a	SEEPAY	0375622474	92053587	a613e9ec9d5c4dac2677e75180b3915ac74fe1def4aed873b8ad90f021e544e2	0df4d0c7-9048-48f7-a336-03d46720e11c	PROCESSED	2026-10-21 15:24:01.500405+00	2026-10-21 15:24:01.500405+00	\N
\.


--
-- Data for Name: billing_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_payments (id, agency_id, attempt_id, provider, merchant_account, provider_reference, amount, currency, paid_at, verification_state, created_at) FROM stdin;
0bbcdc50-1d9e-4edb-a0a7-a0494ff514de	5a4f221b-1350-4421-b060-d0eb7ccaf94d	09ab056e-5d30-443f-b5e1-e93ed39dbe5c	SEEPAY	0375622474	91667799	5000	VND	2026-10-20 09:48:00+00	VERIFIED	2026-10-20 09:48:10.077399+00
21484fc8-f2e6-4ab7-a2b9-f4964a3712e7	5a4f221b-1350-4421-b060-d0eb7ccaf94d	c3b371ac-05ed-436d-a485-137ed482d94a	SEEPAY	0375622474	91916760	5000	VND	2026-10-21 05:50:00+00	VERIFIED	2026-10-21 05:50:36.769292+00
c6ca35f4-83fa-471d-9531-496a11d6a906	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	6ede1ab3-4cc8-44a0-a4a7-1bbb7c974354	SEEPAY	0375622474	92053587	5000	VND	2026-10-21 15:24:00+00	VERIFIED	2026-10-21 15:24:01.500405+00
b2000001-0000-4000-8000-000000000003	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	3af46cf4-1106-4a05-8740-829e875dd2bd	SEEPAY	0375622474	92010001	5000	VND	2026-10-21 10:00:00+00	VERIFIED	2026-10-21 10:00:05+00
b2000001-0000-4000-8000-000000000013	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	b2000001-0000-4000-8000-000000000012	SEEPAY	0375622474	92010002	5000	VND	2026-10-21 11:00:00+00	VERIFIED	2026-10-21 11:00:05+00
\.


--
-- Data for Name: billing_plan_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_plan_versions (id, code, version, display_name, price_monthly, currency, max_active_workspaces, max_internal_members, max_clients, storage_limit_bytes, monthly_ai_credits, max_concurrent_ai_jobs, version_retention_days, trash_retention_days, activity_retention_days, features, is_sellable, created_at) FROM stdin;
a3ff6bee-aed7-4cdc-8339-f2f75c121af4	BASIC	1	Basic	0	VND	1	3	5	2000000000	0	1	7	7	30	{}	t	2026-10-20 02:01:06.695762+00
78c008b9-0b25-4f80-b5e0-d65580be8985	PLUS	1	Plus	\N	VND	10	15	50	100000000000	5000	3	90	30	180	{}	f	2026-10-20 02:01:06.695762+00
384ddb4f-0309-40f0-8734-e09370aaf587	ENTERPRISE	1	Enterprise	\N	VND	50	50	200	1000000000000	25000	10	365	90	365	{}	f	2026-10-20 02:01:06.695762+00
cf919472-e8e0-4f22-b2ed-86d653389263	PERSONAL	1	Personal	\N	VND	0	1	0	20000000000	1000	1	30	30	90	{"quota_policy": "PROPOSED", "max_personal_spaces": 1}	f	2026-10-20 08:38:55.944182+00
24de5e8f-fcfa-4a98-a40f-84b971a81abe	PLUS	2	Plus	5000	VND	10	15	50	100000000000	5000	3	90	30	180	{}	t	2026-10-20 09:28:24.889379+00
\.


--
-- Data for Name: brandhub_schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.brandhub_schema_migrations (version, applied_at, description) FROM stdin;
20261020_agency_subscription_expand_v1	2026-10-20 02:01:06.695762+00	Expand only: agency billing catalog, payments, credit, budgets, storage; legacy review required
20261020_payos_to_seepay_v1	2026-10-20 02:08:26.685848+00	Switch default payment provider from PayOS to SeePay
20261020_four_plan_catalog_v1	2026-10-20 08:38:55.944182+00	Ensure four versioned products, derive USER/AGENCY scope, prevent Personal assignment to Agency billing
20261021_subscription_observability_v1	2026-10-21 16:29:19.229818+00	Subscription issues, bounded reconciliation lease/cursors and provider read checkpoints
20261022_workspace_credit_v1	2026-10-22 10:02:36.458453+00	Agency Subscription wallet; Workspace-only caps; durable/idempotent fixed-price AI accounting
20261028_mail_template_scope_postgres	2026-10-29 08:08:43.045341+00	Addendum B: mail_send_quota AGENCY scope, mail_suppressions nullable workspace_id, mail_batches nullable workspace_id + scope/agency_id for non-Workspace scopes
20261029_mail_suppressions_agency	2026-10-29 08:08:43.317595+00	Addendum B: mail_suppressions.agency_id, per-Agency unsubscribe list
\.


--
-- Data for Name: campaign_collaborators; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_collaborators (id, media_campaign_id, collaborator_id, cooperation_status, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: campaign_deployments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_deployments (id, campaign_id, content_version, requested_by, status, attempt_count, last_error_code, created_at, updated_at, completed_at) FROM stdin;
\.


--
-- Data for Name: campaign_review_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_review_events (id, campaign_id, content_version, actor_id, actor_side, event_type, comment, created_at) FROM stdin;
\.


--
-- Data for Name: campaign_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_versions (id, campaign_id, content_version, snapshot, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: client_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_profiles (id, user_id, display_name, company, industry, logo_url, banner_url, phone, website, location, description, social_links, note, contact_name, contact_email, company_size, instagram_url, tax_code, address, tagline, founded_year, budget_range, created_at, updated_at) FROM stdin;
0bcae85a-ccbf-48b3-a748-97ebbc29d344	f40a1175-dd94-41fe-91ea-c37c38311959	Vietjet Air	Vietjet Air	SERVICES	https://placehold.co/200x200	\N	4302643456	https://vietjetair.example.com	Russelton	Function-based composite flexibility. deliver wireless solutions.	{"facebook": "https://facebook.com/vietjetair", "linkedin": "https://linkedin.com/company/vietjetair"}	Voluptate reiciendis molestias quibusdam non quos consectetur beatae.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_11_50	https://instagram.com/vietjetair	4395500941	3782 Lynch Inlet, Daronfort	Profound asynchronous artificial intelligence	1993	RANGE_500M_1B	2026-10-19 13:05:13.641741+00	2026-10-29 16:01:42.461252+00
62c09057-f843-4054-bc13-ecf4b6c351be	f40a1175-dd94-41fe-91ea-c37c38311959	The Coffee House	The Coffee House	FNB	https://placehold.co/200x200	\N	0679324815	https://thecoffeehouse.example.com	East Vicky	Up-sized holistic benchmark. extend innovative mindshare.	{"facebook": "https://facebook.com/thecoffeehouse", "linkedin": "https://linkedin.com/company/thecoffeehouse"}	Modi sunt dolores officiis laboriosam optio.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_500_PLUS	https://instagram.com/thecoffeehouse	7001262823	9939 Oberbrunner Corners, Howetown	Vision-oriented value-added utilisation	1998	RANGE_200M_500M	2026-10-19 13:05:13.642408+00	2026-10-29 16:01:42.461252+00
97e3b2bc-465f-4b78-ba46-239f3e13d0fb	f40a1175-dd94-41fe-91ea-c37c38311959	Coca-Cola	Coca-Cola Vietnam	FNB	https://placehold.co/200x200	\N	9805412875	https://coca-cola.example.com	East Otis	Optional reciprocal policy. synergize extensible communities.	{"facebook": "https://facebook.com/cocacolavn", "linkedin": "https://linkedin.com/company/coca-cola"}	Modi fugiat odit commodi voluptates omnis tenetur.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_201_500	https://instagram.com/cocacolavn	1267551486	39072 Hannah Shoal, Port Lyle	Multi-layered zero administration initiative	2015	RANGE_1B_5B	2026-10-19 13:05:13.642957+00	2026-10-29 16:01:42.461252+00
47615c12-611c-4078-a296-044539c532c0	f40a1175-dd94-41fe-91ea-c37c38311959	TH True Milk	TH True Milk	FNB	https://placehold.co/200x200	\N	8544457374	https://thtruemilk.example.com	New Bernard	Cloned 24 hour array. grow collaborative deliverables.	{"facebook": "https://facebook.com/thtruemilk", "linkedin": "https://linkedin.com/company/thtruemilk"}	Amet cumque ipsum voluptas mollitia adipisci quod dolores.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_51_200	https://instagram.com/thtruemilk	6052547443	04541 Lowe Street, North Bretbury	Down-sized asymmetric extranet	2007	UNDER_50M	2026-10-19 13:05:13.643505+00	2026-10-29 16:01:42.461252+00
521ba53c-5207-4e4d-9f8d-f1e902c9af09	f40a1175-dd94-41fe-91ea-c37c38311959	FPT Shop	FPT Retail (FPT Shop)	RETAIL	https://placehold.co/200x200	\N	4641071316	https://fptshop.example.com	South Ardenchester	Persistent dedicated internet solution. disintermediate B2B functionalities.	{"facebook": "https://facebook.com/fptshop", "linkedin": "https://linkedin.com/company/fptshop"}	Accusantium nam a.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_51_200	https://instagram.com/fptshop	4288397398	571 Bradtke Square, Shanahanberg	Business-focused systematic task-force	2000	RANGE_50M_200M	2026-10-19 13:05:13.643655+00	2026-10-29 16:01:42.461252+00
e8cb0327-35df-46e5-adcd-2eea47f17e6d	f40a1175-dd94-41fe-91ea-c37c38311959	Sunhouse	Sunhouse Group	RETAIL	https://placehold.co/200x200	\N	7007662995	https://sunhouse.example.com	Thaliaview	Cross-group secondary artificial intelligence. redefine front-end applications.	{"facebook": "https://facebook.com/sunhouse", "linkedin": "https://linkedin.com/company/sunhouse"}	Vel eveniet eveniet debitis quas pariatur facilis.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_51_200	https://instagram.com/sunhouse	4255452887	3422 Bogisich Parkways, Elwoodmouth	Phased 5th generation toolset	2022	RANGE_500M_1B	2026-10-19 13:05:13.644093+00	2026-10-29 16:01:42.461252+00
c22aa9b7-f206-4ebc-a63b-c702b01b821b	f40a1175-dd94-41fe-91ea-c37c38311959	P&G	P&G Vietnam	RETAIL	https://placehold.co/200x200	\N	0660714151	https://pg.example.com	Naderberg	Customizable tertiary implementation. extend dot-com bandwidth.	{"facebook": "https://facebook.com/pgvietnam", "linkedin": "https://linkedin.com/company/procter-and-gamble"}	Suscipit facilis sapiente facilis.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_201_500	https://instagram.com/pgvietnam	7706526542	41735 Rice Prairie, North Rossana	Fully-configurable 24 hour pricing structure	1997	RANGE_500M_1B	2026-10-19 13:05:13.64574+00	2026-10-29 16:01:42.461252+00
855dff6e-2b33-404f-92f8-0903af6784f5	f40a1175-dd94-41fe-91ea-c37c38311959	Sabeco	Sabeco (Bia Sài Gòn)	FNB	https://placehold.co/200x200	\N	0040823936	https://sabeco.example.com	North Florside	Digitized cohesive knowledge user. transform one-to-one web-readiness.	{"facebook": "https://facebook.com/sabeco", "linkedin": "https://linkedin.com/company/sabeco"}	Ad expedita asperiores.	Tennie McLaughlin	user59@demo.brandhub.test	SIZE_1_10	https://instagram.com/sabeco	1076356323	53198 Evan Loaf, Port Bettinamouth	Grass-roots even-keeled monitoring	2014	RANGE_1B_5B	2026-10-19 13:05:13.645905+00	2026-10-29 16:04:03.85379+00
\.


--
-- Data for Name: content_moderation_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_moderation_reviews (id, post_id, content_version, content_hash, workspace_id, author_id, source, reason, status, decision_note, strike_level, strike_category, reviewed_by, reviewed_at, created_at, row_version) FROM stdin;
\.


--
-- Data for Name: content_request_completion_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_request_completion_jobs (campaign_id, workspace_id, actor_id, created_at) FROM stdin;
\.


--
-- Data for Name: creator_credit_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.creator_credit_usage (agency_id, creator_id, period_id, used, reserved) FROM stdin;
\.


--
-- Data for Name: credit_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_entries (id, agency_id, operation_id, grant_id, available_delta, reserved_delta, consumed_delta, expired_delta, revoked_delta, created_at) FROM stdin;
067e1dc6-20f4-462a-a311-a0abd578fce0	5a4f221b-1350-4421-b060-d0eb7ccaf94d	8f814127-5964-4248-8c96-cfd7b936cab1	b46b5ef3-4529-4f67-8b06-397ba1635383	5000	0	0	0	0	2026-10-20 09:48:10.077399+00
2ec7fa34-cc42-4da0-a3fc-db6b9b728bfe	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	d7874a94-2991-4689-8541-36188f69ff8e	cef0f658-0acd-4c9a-b145-a9862cd8ca9c	5000	0	0	0	0	2026-10-21 15:24:01.500405+00
fa33df20-22fa-4b19-8066-36570b6b95e6	5a4f221b-1350-4421-b060-d0eb7ccaf94d	7757c234-b20b-4308-b0ed-d5b94fce71eb	b46b5ef3-4529-4f67-8b06-397ba1635383	-5000	0	0	5000	0	2026-10-22 09:57:31.339379+00
e8670111-5d7f-4085-ba66-940352497d92	5a4f221b-1350-4421-b060-d0eb7ccaf94d	1e4cfcd5-8035-4f1f-9f90-d55301a3dfcf	942b4249-174e-47ec-b68e-73d4ab3fec8a	5000	0	0	0	0	2026-10-22 09:57:31.339379+00
b2000001-0000-4000-8000-000000000008	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	b2000001-0000-4000-8000-000000000007	b2000001-0000-4000-8000-000000000006	5000	0	0	0	0	2026-10-21 10:00:05+00
b2000001-0000-4000-8000-000000000018	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	b2000001-0000-4000-8000-000000000017	b2000001-0000-4000-8000-000000000016	5000	0	0	0	0	2026-10-21 11:00:05+00
\.


--
-- Data for Name: credit_grants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_grants (id, agency_id, source_type, source_key, order_id, period_id, trial_owner_id, amount, available, reserved, consumed, expired, revoked, valid_from, expires_at, created_at) FROM stdin;
cef0f658-0acd-4c9a-b145-a9862cd8ca9c	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	PERIOD	0df4d0c7-9048-48f7-a336-03d46720e11c	0df4d0c7-9048-48f7-a336-03d46720e11c	58366f6a-b0b4-4120-a472-974c028f78a4	\N	5000	5000	0	0	0	0	2026-10-21 15:24:00+00	2026-11-21 15:24:00+00	2026-10-21 15:24:01.500405+00
b46b5ef3-4529-4f67-8b06-397ba1635383	5a4f221b-1350-4421-b060-d0eb7ccaf94d	PERIOD	99b172ee-7071-45ee-a7fa-2b4b80e3b244	99b172ee-7071-45ee-a7fa-2b4b80e3b244	16275413-3309-4ade-ae45-f644656ccbb2	\N	5000	0	0	0	5000	0	2026-10-20 09:48:00+00	2026-10-21 16:59:59+00	2026-10-20 09:48:10.077399+00
942b4249-174e-47ec-b68e-73d4ab3fec8a	5a4f221b-1350-4421-b060-d0eb7ccaf94d	PERIOD	8f884a25-d44a-4dec-a923-0f88d7bee347	8f884a25-d44a-4dec-a923-0f88d7bee347	4099947b-5b39-4d49-b360-774e053220dc	\N	5000	5000	0	0	0	0	2026-10-21 16:59:59+00	2026-11-21 16:59:59+00	2026-10-22 09:57:31.339379+00
b2000001-0000-4000-8000-000000000006	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	PERIOD	f1df8348-2892-47a8-b3ee-acd626231bf9	f1df8348-2892-47a8-b3ee-acd626231bf9	b2000001-0000-4000-8000-000000000004	\N	5000	5000	0	0	0	0	2026-10-21 10:00:00+00	2026-11-21 10:00:00+00	2026-10-21 10:00:05+00
b2000001-0000-4000-8000-000000000016	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	PERIOD	b2000001-0000-4000-8000-000000000011	b2000001-0000-4000-8000-000000000011	b2000001-0000-4000-8000-000000000014	\N	5000	5000	0	0	0	0	2026-10-21 11:00:00+00	2026-11-21 11:00:00+00	2026-10-21 11:00:05+00
\.


--
-- Data for Name: credit_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_operations (id, agency_id, operation_key, kind, actor_id, reservation_id, reversal_of, created_at) FROM stdin;
8f814127-5964-4248-8c96-cfd7b936cab1	5a4f221b-1350-4421-b060-d0eb7ccaf94d	subscription-period:99b172ee-7071-45ee-a7fa-2b4b80e3b244	GRANT	\N	\N	\N	2026-10-20 09:48:10.077399+00
d7874a94-2991-4689-8541-36188f69ff8e	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	subscription-period:0df4d0c7-9048-48f7-a336-03d46720e11c	GRANT	\N	\N	\N	2026-10-21 15:24:01.500405+00
7757c234-b20b-4308-b0ed-d5b94fce71eb	5a4f221b-1350-4421-b060-d0eb7ccaf94d	period-expired:b46b5ef3-4529-4f67-8b06-397ba1635383:0	EXPIRE	\N	\N	\N	2026-10-22 09:57:31.339379+00
1e4cfcd5-8035-4f1f-9f90-d55301a3dfcf	5a4f221b-1350-4421-b060-d0eb7ccaf94d	subscription-period:8f884a25-d44a-4dec-a923-0f88d7bee347	GRANT	\N	\N	\N	2026-10-22 09:57:31.339379+00
3685717a-9eab-4ce7-a9c3-1a58e3aabdcd	5a4f221b-1350-4421-b060-d0eb7ccaf94d	reserve:ed7b31a6-1fec-4836-bee0-ded99e0b2b57	RESERVE	12adcef2-8964-4ed6-95a5-bbb9a601803c	ed7b31a6-1fec-4836-bee0-ded99e0b2b57	\N	2026-10-27 16:03:42.016302+00
40318acc-6bef-42ab-b9ad-71dd58f9c8c0	5a4f221b-1350-4421-b060-d0eb7ccaf94d	reserve:042e2bd2-94a1-4231-b5a2-32f1a300e078	RESERVE	12adcef2-8964-4ed6-95a5-bbb9a601803c	042e2bd2-94a1-4231-b5a2-32f1a300e078	\N	2026-10-27 16:34:34.531272+00
72335ac1-1542-40a2-ab7b-2a356e3649c7	5a4f221b-1350-4421-b060-d0eb7ccaf94d	finalize:042e2bd2-94a1-4231-b5a2-32f1a300e078	SETTLE	12adcef2-8964-4ed6-95a5-bbb9a601803c	042e2bd2-94a1-4231-b5a2-32f1a300e078	\N	2026-10-27 16:34:39.824655+00
1d1403f8-066c-4edf-8823-d79730bf391c	5a4f221b-1350-4421-b060-d0eb7ccaf94d	reserve:7faa8a7a-ae93-446f-ae20-1112ad7f970c	RESERVE	12adcef2-8964-4ed6-95a5-bbb9a601803c	7faa8a7a-ae93-446f-ae20-1112ad7f970c	\N	2026-10-28 12:38:21.37624+00
40967ae6-3b15-442a-96e5-bc0bd6e41f87	5a4f221b-1350-4421-b060-d0eb7ccaf94d	finalize:7faa8a7a-ae93-446f-ae20-1112ad7f970c	SETTLE	12adcef2-8964-4ed6-95a5-bbb9a601803c	7faa8a7a-ae93-446f-ae20-1112ad7f970c	\N	2026-10-28 12:38:27.095551+00
742cccf4-3459-4b4a-a694-fc5691bd5750	5a4f221b-1350-4421-b060-d0eb7ccaf94d	reserve:c02e1e6b-2ee1-4c1f-abfe-184e4369e4a7	RESERVE	12adcef2-8964-4ed6-95a5-bbb9a601803c	c02e1e6b-2ee1-4c1f-abfe-184e4369e4a7	\N	2026-10-28 12:53:39.041115+00
a110bc17-2ae6-407b-930e-b48b5a20c31c	5a4f221b-1350-4421-b060-d0eb7ccaf94d	finalize:c02e1e6b-2ee1-4c1f-abfe-184e4369e4a7	SETTLE	12adcef2-8964-4ed6-95a5-bbb9a601803c	c02e1e6b-2ee1-4c1f-abfe-184e4369e4a7	\N	2026-10-28 12:53:43.135727+00
59c52406-306a-4516-b9b2-c5643bd4b662	5a4f221b-1350-4421-b060-d0eb7ccaf94d	reserve:394dc76d-10dd-4d63-a984-36256ab59b02	RESERVE	12adcef2-8964-4ed6-95a5-bbb9a601803c	394dc76d-10dd-4d63-a984-36256ab59b02	\N	2026-10-28 13:15:41.710863+00
4c385a54-6446-49b4-8377-bb0244f2efaa	5a4f221b-1350-4421-b060-d0eb7ccaf94d	finalize:394dc76d-10dd-4d63-a984-36256ab59b02	SETTLE	12adcef2-8964-4ed6-95a5-bbb9a601803c	394dc76d-10dd-4d63-a984-36256ab59b02	\N	2026-10-28 13:15:54.894493+00
b2000001-0000-4000-8000-000000000001	5a4f221b-1350-4421-b060-d0eb7ccaf94d	finalize:ed7b31a6-1fec-4836-bee0-ded99e0b2b57	RELEASE	12adcef2-8964-4ed6-95a5-bbb9a601803c	ed7b31a6-1fec-4836-bee0-ded99e0b2b57	\N	2026-10-28 16:04:00+00
b2000001-0000-4000-8000-000000000007	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	subscription-period:f1df8348-2892-47a8-b3ee-acd626231bf9	GRANT	\N	\N	\N	2026-10-21 10:00:05+00
b2000001-0000-4000-8000-000000000017	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	subscription-period:b2000001-0000-4000-8000-000000000011	GRANT	\N	\N	\N	2026-10-21 11:00:05+00
\.


--
-- Data for Name: credit_reservation_allocations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_reservation_allocations (agency_id, reservation_id, grant_id, amount, charged, released, ordinal) FROM stdin;
\.


--
-- Data for Name: credit_usage_periods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.credit_usage_periods (id, agency_id, starts_at, ends_at, kind, subscription_period_id) FROM stdin;
f825e63d-fb86-4187-8e9a-af2a99efc79f	5a4f221b-1350-4421-b060-d0eb7ccaf94d	2026-10-21 16:59:59+00	2026-11-21 16:59:59+00	PAID	4099947b-5b39-4d49-b360-774e053220dc
b2000001-0000-4000-8000-000000000002	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	2026-10-21 15:24:00+00	2026-11-21 15:24:00+00	PAID	58366f6a-b0b4-4120-a472-974c028f78a4
b2000001-0000-4000-8000-000000000005	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	2026-10-21 10:00:00+00	2026-11-21 10:00:00+00	PAID	b2000001-0000-4000-8000-000000000004
b2000001-0000-4000-8000-000000000015	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	2026-10-21 11:00:00+00	2026-11-21 11:00:00+00	PAID	b2000001-0000-4000-8000-000000000014
\.


--
-- Data for Name: mail_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_attachments (id, workspace_id, uploaded_by, name, content_type, size, s3_key, kind, bound, created_at) FROM stdin;
\.


--
-- Data for Name: mail_batches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_batches (id, workspace_id, workspace_name, template_id, template_name, sent_by, sender_email, sender_name, kind, status, subject, body_html, attachments, scheduled_at, timezone, total, accepted, rejected_count, sent_count, failed_count, suppressed_count, created_at, completed_at, scope, agency_id) FROM stdin;
\.


--
-- Data for Name: mail_deliveries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_deliveries (id, batch_id, recipient, recipient_name, variables, rendered_subject, rendered_body_html, external_audience, status, attempts, last_error, next_attempt_at, sent_at, event_key) FROM stdin;
\.


--
-- Data for Name: mail_send_quota; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_send_quota (day, scope, scope_id, sent_count) FROM stdin;
\.


--
-- Data for Name: mail_suppressions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_suppressions (id, workspace_id, email_lower, reason, created_at, agency_id) FROM stdin;
\.


--
-- Data for Name: material_audit_receipts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.material_audit_receipts (event_id, delivered_at) FROM stdin;
7035cce9-6066-43a5-8202-44c1166112a8	2026-10-28 06:33:44.84721+00
\.


--
-- Data for Name: material_quota_releases; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.material_quota_releases (material_id, agency_id, workspace_id, released_bytes, released_at) FROM stdin;
\.


--
-- Data for Name: media_campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.media_campaigns (id, workspace_media_package_id, name, strategy_detail, package_terms_snapshot, package_terms_version, allocation_period, allocations, deliverable_plan, work_items, content_version, row_version, brand_guideline, timeline, status, approved_by_agency_at, approved_by_agency_id, approved_by_agency_version, approved_by_client_at, approved_by_client_id, approved_by_client_version, completed_at, completed_by, completion_reason, completion_task_summary, created_at, updated_at) FROM stdin;
202ed34d-7b13-4aea-8ce4-8e3df4f12ff0	8e52e1ff-ce74-4234-a4e0-d90e6ba0a3cf	deep dive	Neque corporis ullam eveniet ullam. Ut ex consectetur provident. Ea quidem doloremque impedit dicta a id.	{"name": "Chiến dịch livestream giới thiệu sản phẩm", "budgetAmount": 22000000, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5d627187-e9f1-41d2-895b-6a57ced2daee", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 2, "description": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "3b3659fe-1431-4e6f-bb6d-00bbe5ecde38", "scopeDescription": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng."}	1	\N	[{"quantity": 2, "deliverableId": "5d627187-e9f1-41d2-895b-6a57ced2daee"}]	[{"id": "5d627187-e9f1-41d2-895b-6a57ced2daee", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 2, "description": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-19 13:05:13.998148+00	2026-10-19 13:05:13.998154+00
c3000003-0000-4000-8000-000000000001	c3000002-0000-4000-8000-000000000001	Chiến dịch The Coffee House x Saatchi & Saatchi Vietnam	Chiến lược truyền thông đa kênh đồng bộ nhận diện thương hiệu cho The Coffee House x Saatchi & Saatchi Vietnam	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	1	\N	[{"quantity": 12, "deliverableId": "5123274b-85a9-43da-8cea-0e632bc9b5e3"}]	[{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-21 16:01:42.461252+00	2026-10-29 16:04:03.85379+00
c3000003-0000-4000-8000-000000000002	c3000002-0000-4000-8000-000000000002	Chiến dịch FPT Shop x Yeah1 Network	Chiến lược truyền thông đa kênh đồng bộ nhận diện thương hiệu cho FPT Shop x Yeah1 Network	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	1	\N	[{"quantity": 12, "deliverableId": "5123274b-85a9-43da-8cea-0e632bc9b5e3"}]	[{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-21 16:01:42.461252+00	2026-10-29 16:04:03.85379+00
c3000003-0000-4000-8000-000000000003	c3000002-0000-4000-8000-000000000003	Chiến dịch Sabeco x Yeah1 Network	Chiến lược truyền thông đa kênh đồng bộ nhận diện thương hiệu cho Sabeco x Yeah1 Network	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	1	\N	[{"quantity": 12, "deliverableId": "5123274b-85a9-43da-8cea-0e632bc9b5e3"}]	[{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-21 16:01:42.461252+00	2026-10-29 16:04:03.85379+00
c3000003-0000-4000-8000-000000000004	c3000002-0000-4000-8000-000000000004	Chiến dịch Vietjet Air x Saatchi & Saatchi Vietnam	Chiến lược truyền thông đa kênh đồng bộ nhận diện thương hiệu cho Vietjet Air x Saatchi & Saatchi Vietnam	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	1	\N	[{"quantity": 12, "deliverableId": "5123274b-85a9-43da-8cea-0e632bc9b5e3"}]	[{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-21 16:01:42.461252+00	2026-10-29 16:04:03.85379+00
c3000003-0000-4000-8000-000000000005	c3000002-0000-4000-8000-000000000005	Chiến dịch FPT Shop x AIM Academy	Chiến lược truyền thông đa kênh đồng bộ nhận diện thương hiệu cho FPT Shop x AIM Academy	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	1	\N	[{"quantity": 12, "deliverableId": "5123274b-85a9-43da-8cea-0e632bc9b5e3"}]	[{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-21 16:01:42.461252+00	2026-10-29 16:04:03.85379+00
c3000003-0000-4000-8000-000000000006	c3000002-0000-4000-8000-000000000006	Chiến dịch Sunhouse x Saatchi & Saatchi Vietnam	Chiến lược truyền thông đa kênh đồng bộ nhận diện thương hiệu cho Sunhouse x Saatchi & Saatchi Vietnam	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	1	\N	[{"quantity": 12, "deliverableId": "5123274b-85a9-43da-8cea-0e632bc9b5e3"}]	[{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-21 16:01:42.461252+00	2026-10-29 16:04:03.85379+00
c3000003-0000-4000-8000-000000000007	c3000002-0000-4000-8000-000000000007	Chiến dịch P&G x Yeah1 Network	Chiến lược truyền thông đa kênh đồng bộ nhận diện thương hiệu cho P&G x Yeah1 Network	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	1	\N	[{"quantity": 12, "deliverableId": "5123274b-85a9-43da-8cea-0e632bc9b5e3"}]	[{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]	[]	1	0	\N	{}	DRAFT	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-21 16:01:42.461252+00	2026-10-29 16:04:03.85379+00
\.


--
-- Data for Name: media_packages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.media_packages (id, name, is_template, agency_id, source_template_id, is_available_to_workspaces, duration_weeks, budget_amount, scope_description, offering_details, created_by, created_at, updated_at) FROM stdin;
1c7ee75e-c69b-4f7b-8989-a01cba45bad2	Chiến dịch ra mắt sản phẩm	t	\N	\N	t	6	18000000.00	Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.	{"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.08315+00	2026-10-19 13:05:14.083173+00
22fedf01-a70d-4c0c-8c75-92525aa7599e	Chiến dịch truyền thông sự kiện	t	\N	\N	t	8	24000000.00	Bàn giao kế hoạch sự kiện và nội dung truyền thông; không bao gồm quản lý hậu cần sự kiện.	{"maxChanges": 2, "deliverables": [{"id": "7cc2bf49-f03b-4613-a9a5-9bb4dc3e4cfc", "name": "Kế hoạch truyền thông sự kiện", "unit": "sự kiện", "quantity": 1, "description": "Bàn giao kế hoạch sự kiện và nội dung truyền thông; không bao gồm quản lý hậu cần sự kiện.", "serviceType": "EVENT_PLANNING", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.086098+00	2026-10-19 13:05:14.086116+00
3b3659fe-1431-4e6f-bb6d-00bbe5ecde38	Chiến dịch livestream giới thiệu sản phẩm	t	\N	\N	t	6	22000000.00	Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.	{"maxChanges": 2, "deliverables": [{"id": "5d627187-e9f1-41d2-895b-6a57ced2daee", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 2, "description": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.087095+00	2026-10-19 13:05:14.087106+00
c835fc60-6ba7-4b8a-896c-5254e6a8e028	Chiến dịch truyền thông báo điện tử	t	\N	\N	t	8	30000000.00	Gợi ý các bên báo điện tử phù hợp; không bao gồm booking hoặc quản lý đối tác.	{"maxChanges": 2, "deliverables": [{"id": "454159a9-3151-4f26-8a97-37026e839336", "name": "Danh sách đối tác báo điện tử đề xuất", "unit": "danh sách đề xuất", "quantity": 1, "description": "Gợi ý các bên báo điện tử phù hợp; không bao gồm booking hoặc quản lý đối tác.", "serviceType": "PRESS_RECOMMENDATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.088166+00	2026-10-19 13:05:14.088176+00
9d88fc9b-0df4-4591-9eea-bb209c817c98	Chăm sóc kênh mạng xã hội	t	\N	\N	t	4	12000000.00	Sản lượng là tổng cả gói cho một Campaign.	{"maxChanges": 2, "deliverables": [{"id": "1d908cdd-cc05-4ef5-8a6a-a03926855093", "name": "Bài đăng mạng xã hội", "unit": "bài", "quantity": 12, "description": "Sản lượng là tổng cả gói cho một Campaign.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.088968+00	2026-10-19 13:05:14.088977+00
66db8003-9706-4c1a-bb46-372a2968ad3e	Nội dung thương hiệu	t	\N	\N	t	4	15000000.00	Manager tạo một Campaign; sản lượng là tổng cả gói.	{"maxChanges": 2, "deliverables": [{"id": "efb91816-7198-4f25-b92a-ddc2eb0c4f6a", "name": "Bài nội dung thương hiệu", "unit": "bài", "quantity": 16, "description": "Manager tạo một Campaign; sản lượng là tổng cả gói.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.089915+00	2026-10-19 13:05:14.089922+00
9c87cbd0-8948-4b17-97b9-ff91064fb14d	Workshop	t	\N	\N	t	4	10000000.00	Hỗ trợ tạo link Meet và survey; không quản lý agenda hoặc hậu cần sự kiện.	{"maxChanges": 2, "deliverables": [{"id": "afe9754f-28b6-4b9d-ae8a-07a8210cc98b", "name": "Buổi workshop", "unit": "buổi", "quantity": 2, "description": "Hỗ trợ tạo link Meet và survey; không quản lý agenda hoặc hậu cần sự kiện.", "serviceType": "WORKSHOP_SUPPORT", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.090703+00	2026-10-19 13:05:14.090711+00
055d267f-0857-42bd-945d-d8b1709d4221	Bộ 20 bài đăng mạng xã hội	t	\N	\N	t	12	16000000.00	Bàn giao tổng số bài trong gói cho một Campaign.	{"maxChanges": 2, "deliverables": [{"id": "0881ad92-5fb6-44ce-ba1a-756d75319deb", "name": "Bài đăng mạng xã hội", "unit": "bài", "quantity": 20, "description": "Bàn giao tổng số bài trong gói cho một Campaign.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.091659+00	2026-10-19 13:05:14.091668+00
9b56c581-c1d1-4a78-81de-1baef24f56c8	Bộ hỗ trợ 4 buổi livestream	t	\N	\N	t	12	20000000.00	Chỉ hỗ trợ chuẩn bị, không trực tiếp phát sóng; sản lượng là tổng cả gói.	{"maxChanges": 2, "deliverables": [{"id": "d304fdb4-3e9c-4348-88ec-46e122becb5f", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 4, "description": "Chỉ hỗ trợ chuẩn bị, không trực tiếp phát sóng; sản lượng là tổng cả gói.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.092358+00	2026-10-19 13:05:14.092366+00
46b57b12-73c0-469a-b7f6-ea88c8b8f562	Bộ kế hoạch 3 sự kiện	t	\N	\N	t	12	21000000.00	Bàn giao kế hoạch cho một Campaign; không bao gồm module hậu cần hay vận hành sự kiện.	{"maxChanges": 2, "deliverables": [{"id": "3cce79c7-0d90-4e3c-913f-48060f9793a9", "name": "Kế hoạch sự kiện bàn giao", "unit": "sự kiện", "quantity": 3, "description": "Bàn giao kế hoạch cho một Campaign; không bao gồm module hậu cần hay vận hành sự kiện.", "serviceType": "EVENT_PLANNING", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:14.092963+00	2026-10-19 13:05:14.092972+00
d101bcb4-b24b-4531-926c-3dc331dcac82	Chăm sóc kênh mạng xã hội	f	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	9d88fc9b-0df4-4591-9eea-bb209c817c98	t	4	12000000.00	Sản lượng là tổng cả gói cho một Campaign.	{"maxChanges": 2, "deliverables": [{"id": "1d908cdd-cc05-4ef5-8a6a-a03926855093", "name": "Bài đăng mạng xã hội", "unit": "bài", "quantity": 12, "description": "Sản lượng là tổng cả gói cho một Campaign.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:19:15.884881+00	2026-10-19 13:19:15.884881+00
c3000001-0000-4000-8000-000000000001	Chiến dịch ra mắt sản phẩm	f	5a4f221b-1350-4421-b060-d0eb7ccaf94d	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	t	6	18000000.00	Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.	{"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
c3000001-0000-4000-8000-000000000002	Chiến dịch livestream giới thiệu sản phẩm	f	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	3b3659fe-1431-4e6f-bb6d-00bbe5ecde38	t	6	22000000.00	Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.	{"maxChanges": 2, "deliverables": [{"id": "5d627187-e9f1-41d2-895b-6a57ced2daee", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 2, "description": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
c3000001-0000-4000-8000-000000000003	Bộ 20 bài đăng mạng xã hội	f	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	055d267f-0857-42bd-945d-d8b1709d4221	t	12	16000000.00	Bàn giao tổng số bài trong gói cho một Campaign.	{"maxChanges": 2, "deliverables": [{"id": "0881ad92-5fb6-44ce-ba1a-756d75319deb", "name": "Bài đăng mạng xã hội", "unit": "bài", "quantity": 20, "description": "Bàn giao tổng số bài trong gói cho một Campaign.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
\.


--
-- Data for Name: monitoring_collectors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_collectors (id, name, server_id, token_hash, last_seen_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: monitoring_enrollments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_enrollments (token_hash, name, environment, expires_at) FROM stdin;
\.


--
-- Data for Name: monitoring_health_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_health_results (target_id, collector_id, check_id, outcome, checked_at, received_at, latency_ms, reason_code, http_status, runtime_state, runtime_health) FROM stdin;
\.


--
-- Data for Name: monitoring_health_targets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_health_targets (id, name, kind, environment, server_id, service_name, instance_id, collector_id, check_scope, probe_type, probe_config, assertion, credential_ref, interval_seconds, timeout_seconds, stale_after_seconds, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: monitoring_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_servers (id, name, ip_address, environment, deployed_services, agent_token_hash, cpu_percent, ram_percent, disk_percent, uptime_seconds, last_seen_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: package_negotiation_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.package_negotiation_events (id, workspace_media_package_id, terms_version, action, actor_id, actor_role, note, terms_snapshot, created_at) FROM stdin;
\.


--
-- Data for Name: repository_drive_generations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_drive_generations (agency_id, generation) FROM stdin;
5a4f221b-1350-4421-b060-d0eb7ccaf94d	3
\.


--
-- Data for Name: repository_drive_objects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_drive_objects (object_key, agency_id, connection_id, file_id, created_at) FROM stdin;
repository/bb996948-4b50-4761-a682-07a3e7a43eba/0fca05dc-6cef-4719-baf7-c710dc967b4e/4ee7c886-ef30-46d8-9507-fbaeca543313/original	5a4f221b-1350-4421-b060-d0eb7ccaf94d	cee7d8c7-3e59-4443-acda-54dfb2a8ed7b	1htlFVGt3DweMxs0_87YKKnoOVHg5yW98	2026-10-28 06:32:08.74955+00
repository/bb996948-4b50-4761-a682-07a3e7a43eba/881a84e2-3881-4aa5-9fcb-91dd9e9f099c/5b9d2706-fb1d-44c3-86b7-dcc0dfb93a42/original	5a4f221b-1350-4421-b060-d0eb7ccaf94d	cee7d8c7-3e59-4443-acda-54dfb2a8ed7b	161f3q2Dsb2qBk161U9Au1mNviYFKouCr	2026-10-28 06:40:36.861519+00
\.


--
-- Data for Name: repository_drive_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_drive_operations (agency_id, lease_token, lease_until) FROM stdin;
\.


--
-- Data for Name: repository_drive_states; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.repository_drive_states (state_hash, agency_id, workspace_id, actor_id, verifier_ciphertext, generation, expires_at) FROM stdin;
\.


--
-- Data for Name: sanction_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sanction_reviews (id, user_id, status, created_at, resolved_at, resolved_by, reason) FROM stdin;
\.


--
-- Data for Name: seed_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.seed_runs (dataset, dataset_version, run_id, status, last_stage, record_counts, manifest, failure_summary, started_at, completed_at, failed_at) FROM stdin;
brandhub-dev-demo	2	b0403bb8-654c-41ee-bcc9-771c8ffcd975	complete	complete	{"users": 25, "agencies": 4, "workspaces": 10, "mediaPackages": 10, "clientProfiles": 13, "mediaCampaigns": 1, "workspaceMediaPackages": 3}	{"users": ["5f46d7d8-6689-4ece-84f8-39e5de081c5c", "12adcef2-8964-4ed6-95a5-bbb9a601803c", "f40a1175-dd94-41fe-91ea-c37c38311959", "dbdc427b-e39f-4cdd-b7c2-1de84fec003f", "3da73a3d-a522-4c48-a293-4338b2969670", "1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2", "eace4871-7580-4f8e-898a-f7f25a838594", "1ad8870e-5bce-421d-a37c-49b15ef97166", "efde2a2c-eb47-41ff-afe2-03499b0bb5c4", "debbe165-84de-460c-b10a-d2cd7ea24966", "1dab38ca-17e7-49f6-ab2c-cc8b20fc669f", "56a8c930-e8d4-4a6b-8bc9-fe58b4994b40", "b213cbc7-613c-4a34-8aa1-4876684a1ee9", "17805121-ff16-40ab-9d0f-dd86b4ed1e47", "bf90f67e-ace2-4080-9868-e732b525745d", "1845f16a-9e5e-42e2-82f1-de5f565cb7d2", "cda4ced3-4365-496e-99f9-82b3797f3f11", "180e9676-b334-4115-9641-ec1dfac7fe1d", "b84cb77d-fb5f-43c9-858b-bb91be0dcf24", "779738d8-e0dd-43e3-83d4-2bcf579433bd", "8927b0b4-3bd6-4fd7-a3d0-daa19304b757", "617f9e26-9faa-458c-b9b9-152f7e367117", "c08aa28e-b894-4064-b712-e4f3e7cd0939", "b7f7db40-e219-4792-98a7-6b944703bdb4", "c71364bf-dd7f-4279-beb0-e31c75b6780e"], "agencies": ["1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76", "1cb9a40d-7bd8-4096-91aa-d1411cdc961b", "1fb7ed01-a9d4-4373-afb4-3ac8c47afde5", "5a4f221b-1350-4421-b060-d0eb7ccaf94d"], "workspaces": ["b97cd7c7-60b4-4f52-82cd-bc56a56648a4", "80b54360-b724-4fed-925e-94f4d580a3a4", "feed94e7-e87f-421f-b36a-2aa9bfca0052", "42752736-29eb-4bb9-acb1-3e97da7f4e75", "bb996948-4b50-4761-a682-07a3e7a43eba", "bb4d08cb-a413-4ebc-bc60-57367cb32ae6", "68b29a5c-4518-47f9-aea7-8c33235ee85c", "4e189bda-9dd0-45fb-942f-ab44012cc9c3", "c0104b6c-09aa-4500-8a19-e08ab2a023ed", "ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7"], "mediaPackages": ["1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "22fedf01-a70d-4c0c-8c75-92525aa7599e", "3b3659fe-1431-4e6f-bb6d-00bbe5ecde38", "c835fc60-6ba7-4b8a-896c-5254e6a8e028", "9d88fc9b-0df4-4591-9eea-bb209c817c98", "66db8003-9706-4c1a-bb46-372a2968ad3e", "9c87cbd0-8948-4b17-97b9-ff91064fb14d", "055d267f-0857-42bd-945d-d8b1709d4221", "9b56c581-c1d1-4a78-81de-1baef24f56c8", "46b57b12-73c0-469a-b7f6-ea88c8b8f562"], "clientProfiles": ["0bcae85a-ccbf-48b3-a748-97ebbc29d344", "62c09057-f843-4054-bc13-ecf4b6c351be", "97e3b2bc-465f-4b78-ba46-239f3e13d0fb", "47615c12-611c-4078-a296-044539c532c0", "521ba53c-5207-4e4d-9f8d-f1e902c9af09", "e8cb0327-35df-46e5-adcd-2eea47f17e6d", "66bb4667-51d1-48a2-a15f-2caf02de8e27", "fd7c3f89-75fe-42a6-8545-7e03de723771", "9f5415ca-d187-4045-9860-b951fc5082bf", "e36743be-7c6d-41c0-adc0-956951becc2e", "55199434-96e6-453e-a1bc-884fd5f449b8", "c22aa9b7-f206-4ebc-a63b-c702b01b821b", "855dff6e-2b33-404f-92f8-0903af6784f5"], "mediaCampaigns": ["202ed34d-7b13-4aea-8ce4-8e3df4f12ff0"], "workspaceMediaPackages": ["8e52e1ff-ce74-4234-a4e0-d90e6ba0a3cf", "bc3febaa-0a5e-456e-b12b-aa3781d83722", "c6c39106-4100-440e-963a-c5a18dbaf661"]}	\N	2026-10-19 13:05:12.836988+00	2026-10-19 13:05:12.845416+00	\N
\.


--
-- Data for Name: storage_objects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.storage_objects (id, agency_id, workspace_id, reservation_id, uploaded_by, backend, bucket, object_key, size_bytes, status, created_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: storage_reservations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.storage_reservations (id, agency_id, upload_id, workspace_id, reserved_bytes, status, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: storage_usage_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.storage_usage_entries (id, operation_key, agency_id, workspace_id, reservation_id, material_id, kind, used_delta, reserved_delta, created_at) FROM stdin;
a6193e26-14b3-473e-88b8-0bfca955224d	aa639c17-a2cc-4865-93b7-5b49393483e1:RESERVE	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	aa639c17-a2cc-4865-93b7-5b49393483e1	aa639c17-a2cc-4865-93b7-5b49393483e1	RESERVE	0	44453	2026-10-27 08:01:20.39017+00
e7f533f9-a710-4898-9079-f1d8c8c4831a	aa639c17-a2cc-4865-93b7-5b49393483e1:RELEASE	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	aa639c17-a2cc-4865-93b7-5b49393483e1	aa639c17-a2cc-4865-93b7-5b49393483e1	RELEASE	0	-44453	2026-10-27 08:11:40.363339+00
808b8ad5-6b84-46d8-9136-f6509efb05fe	0fca05dc-6cef-4719-baf7-c710dc967b4e:RESERVE	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	0fca05dc-6cef-4719-baf7-c710dc967b4e	0fca05dc-6cef-4719-baf7-c710dc967b4e	RESERVE	0	88	2026-10-28 06:31:27.880892+00
81019982-7f57-4cb0-802b-9922a40ea8a3	0fca05dc-6cef-4719-baf7-c710dc967b4e:COMMIT	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	0fca05dc-6cef-4719-baf7-c710dc967b4e	0fca05dc-6cef-4719-baf7-c710dc967b4e	COMMIT	88	-88	2026-10-28 06:32:10.292806+00
147e4d65-82a0-4140-9b5a-7dc0b4826778	881a84e2-3881-4aa5-9fcb-91dd9e9f099c:RESERVE	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	881a84e2-3881-4aa5-9fcb-91dd9e9f099c	881a84e2-3881-4aa5-9fcb-91dd9e9f099c	RESERVE	0	68536	2026-10-28 06:40:08.605045+00
e0af780d-0d1b-45e3-ad52-473db8a45d62	881a84e2-3881-4aa5-9fcb-91dd9e9f099c:COMMIT	5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	881a84e2-3881-4aa5-9fcb-91dd9e9f099c	881a84e2-3881-4aa5-9fcb-91dd9e9f099c	COMMIT	68536	-68536	2026-10-28 06:40:38.126289+00
\.


--
-- Data for Name: subscription_observation_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_observation_jobs (name, owner_token, lease_until, agency_cursor, order_cursor, event_cursor, last_started_at, last_completed_at, last_outcome, updated_at) FROM stdin;
\.


--
-- Data for Name: subscription_operational_issues; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_operational_issues (id, fingerprint, detector, subject_key, rule, category, severity, status, agency_id, order_id, details, request_id, occurrences, first_seen, last_seen, resolved_at) FROM stdin;
\.


--
-- Data for Name: subscription_plan_changes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_plan_changes (id, user_id, plan_id, status, effective_at, payment_required, requested_by, reason, created_at) FROM stdin;
\.


--
-- Data for Name: subscription_plans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_plans (id, name, display_name, price_monthly, max_workspaces, ai_credits_month, features, is_active, created_at) FROM stdin;
c7245eb9-a2fa-4709-869a-4a638848af44	BASIC	Basic	490000.00	3	200	["scheduling", "approval_workflow"]	t	2026-10-19 13:03:59.483989+00
878b8819-a244-4d56-a26f-f67ce8b7565a	PRO	Pro	990000.00	10	1000	["scheduling", "approval_workflow", "ai_content", "analytics"]	t	2026-10-19 13:03:59.483989+00
3d463e7d-a850-488e-b69f-505a4a64e484	ENTERPRISE	Enterprise	2990000.00	-1	5000	["all_features", "unlimited_workspaces", "dedicated_support"]	t	2026-10-19 13:03:59.483989+00
\.


--
-- Data for Name: subscription_provider_checks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_provider_checks (order_id, last_checked_at, next_check_at, outcome) FROM stdin;
\.


--
-- Data for Name: system_storage_pools; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.system_storage_pools (provider, capacity_bytes, physical_used_bytes, reserved_peak_bytes, observed_at, version, updated_at) FROM stdin;
SYSTEM_GDRIVE	5000000000000	0	0	\N	0	2026-10-26 17:16:27.126915+00
\.


--
-- Data for Name: task_content_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_content_operations (id, task_id, sequence_number, yjs_update, edited_by, created_at) FROM stdin;
\.


--
-- Data for Name: task_content_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_content_snapshots (id, task_id, sequence_number, yjs_state, created_at) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tasks (id, workspace_id, type, title, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: third_party_collaborators; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.third_party_collaborators (id, agency_id, partner_name, partner_type, contact_info, notes, is_active, first_used_at, usage_history_verified, version, created_by, created_at, updated_at) FROM stdin;
11d763ad-3ae3-45fa-b816-eb556c5baf67	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	Bednar-McDermott	OTHER	{}	\N	t	\N	f	0	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.655235+00	2026-10-19 13:05:13.655263+00
55fde9e6-eb7d-4d49-bd77-776a481962d7	5a4f221b-1350-4421-b060-d0eb7ccaf94d	Mueller LLC	TV	{}	\N	t	\N	f	0	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.655939+00	2026-10-19 13:05:13.655976+00
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (id, user_id, type, amount, currency, status, ref_id, payos_tx_id, paid_at, failed_reason, created_at, updated_at) FROM stdin;
f281e415-caf2-4c65-b45e-24fcb2cb1764	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-09-07 13:05:13.596416+00	\N	2026-10-19 13:05:13.596609+00	2026-10-19 13:05:13.596611+00
cf86f238-4d4b-4583-9828-283178121501	3da73a3d-a522-4c48-a293-4338b2969670	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-10-12 13:05:13.596416+00	\N	2026-10-19 13:05:13.596625+00	2026-10-19 13:05:13.596626+00
5a125904-161d-43ca-8462-97a150e32461	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-09-25 13:05:13.596416+00	\N	2026-10-19 13:05:13.596635+00	2026-10-19 13:05:13.596636+00
f8b3f7ea-2a7d-4cfc-8fb6-b8dfe64163bf	1ad8870e-5bce-421d-a37c-49b15ef97166	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-08-06 13:05:13.596416+00	\N	2026-10-19 13:05:13.596644+00	2026-10-19 13:05:13.596645+00
a40740bc-9e1c-4474-ae54-c7c6d4dd362f	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-09-13 13:05:13.596416+00	\N	2026-10-19 13:05:13.596652+00	2026-10-19 13:05:13.596653+00
c62652c8-580c-4136-8731-ba25f2d8e1c3	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-08-22 13:05:13.596416+00	\N	2026-10-19 13:05:13.596666+00	2026-10-19 13:05:13.596668+00
09cef1fe-f72e-42ac-834b-1bf3a6fcc5b9	17805121-ff16-40ab-9d0f-dd86b4ed1e47	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-08-08 13:05:13.596416+00	\N	2026-10-19 13:05:13.596682+00	2026-10-19 13:05:13.596683+00
5cabf39f-5938-4cb2-bba2-e085d3f8a6db	bf90f67e-ace2-4080-9868-e732b525745d	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-10-14 13:05:13.596416+00	\N	2026-10-19 13:05:13.59669+00	2026-10-19 13:05:13.596691+00
32beab51-97d5-4cba-b0f4-d461baffd98e	b84cb77d-fb5f-43c9-858b-bb91be0dcf24	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-07-27 13:05:13.596416+00	\N	2026-10-19 13:05:13.596735+00	2026-10-19 13:05:13.596737+00
cf623cdb-26cb-4434-9540-b4d58bab58da	779738d8-e0dd-43e3-83d4-2bcf579433bd	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-09-29 13:05:13.596416+00	\N	2026-10-19 13:05:13.596748+00	2026-10-19 13:05:13.596749+00
b1e30473-fc80-4293-ac01-2ef2b7376bb0	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-10-12 13:05:13.596416+00	\N	2026-10-19 13:05:13.596757+00	2026-10-19 13:05:13.596759+00
47befa7d-7231-455c-aa3b-8e81d0ecab50	617f9e26-9faa-458c-b9b9-152f7e367117	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-09-11 13:05:13.596416+00	\N	2026-10-19 13:05:13.596766+00	2026-10-19 13:05:13.596768+00
17637c5c-1950-4b73-bc56-dcd9cac173a8	c71364bf-dd7f-4279-beb0-e31c75b6780e	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-08-26 13:05:13.596416+00	\N	2026-10-19 13:05:13.596802+00	2026-10-19 13:05:13.596804+00
\.


--
-- Data for Name: user_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_notifications (id, user_id, notification_id, type, title, content, action_url, created_at, read_at) FROM stdin;
\.


--
-- Data for Name: user_oauth_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_oauth_providers (id, user_id, provider, provider_id, created_at) FROM stdin;
62dc3e3c-f34b-4956-b205-1c4accf19822	617f9e26-9faa-458c-b9b9-152f7e367117	GOOGLE	eaa24a26-fb4d-4e89-b586-e324f61afd36	2026-10-19 13:05:13.484975+00
\.


--
-- Data for Name: user_refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_refresh_tokens (id, user_id, token_hash, jti, expires_at, ip_address, user_agent, device_info, created_at) FROM stdin;
\.


--
-- Data for Name: user_strikes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_strikes (id, user_id, level, category, reason, created_by, created_at, expires_at, converted_to_id, removed_by, removed_at, removal_reason) FROM stdin;
\.


--
-- Data for Name: user_subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_subscriptions (id, user_id, plan_id, status, current_period_start, current_period_end, cancelled_at, created_at, updated_at) FROM stdin;
191ec251-3624-43cd-bb23-ae1632f2a764	f40a1175-dd94-41fe-91ea-c37c38311959	c7245eb9-a2fa-4709-869a-4a638848af44	ACTIVE	2026-10-08 13:05:13.596416+00	2026-11-08 13:05:13.596416+00	\N	2026-10-19 13:05:13.596512+00	2026-10-19 13:05:13.596535+00
c2d90775-9ed5-4287-b6f5-af9b8acd71ee	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	878b8819-a244-4d56-a26f-f67ce8b7565a	EXPIRED	2026-09-07 13:05:13.596416+00	2026-10-07 13:05:13.596416+00	\N	2026-10-19 13:05:13.596553+00	2026-10-19 13:05:13.596555+00
e6875510-46fc-403e-8749-ff79cb096b17	3da73a3d-a522-4c48-a293-4338b2969670	878b8819-a244-4d56-a26f-f67ce8b7565a	ACTIVE	2026-10-12 13:05:13.596416+00	2026-11-12 13:05:13.596416+00	\N	2026-10-19 13:05:13.596621+00	2026-10-19 13:05:13.596623+00
5b3a966d-8c0b-4e8c-bb4c-735a927c20f0	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	3d463e7d-a850-488e-b69f-505a4a64e484	ACTIVE	2026-09-25 13:05:13.596416+00	2026-10-25 13:05:13.596416+00	\N	2026-10-19 13:05:13.596632+00	2026-10-19 13:05:13.596633+00
4beb4d28-b953-4340-a48c-6e09f5c5d2dc	1ad8870e-5bce-421d-a37c-49b15ef97166	878b8819-a244-4d56-a26f-f67ce8b7565a	EXPIRED	2026-08-06 13:05:13.596416+00	2026-09-06 13:05:13.596416+00	\N	2026-10-19 13:05:13.596641+00	2026-10-19 13:05:13.596642+00
2c744adb-6c61-4247-a695-190a23768040	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	3d463e7d-a850-488e-b69f-505a4a64e484	EXPIRED	2026-09-13 13:05:13.596416+00	2026-10-13 13:05:13.596416+00	\N	2026-10-19 13:05:13.596649+00	2026-10-19 13:05:13.59665+00
e519fc65-b59f-4f8e-8996-157163012fba	debbe165-84de-460c-b10a-d2cd7ea24966	c7245eb9-a2fa-4709-869a-4a638848af44	EXPIRED	2026-08-16 13:05:13.596416+00	2026-09-16 13:05:13.596416+00	\N	2026-10-19 13:05:13.596657+00	2026-10-19 13:05:13.596658+00
6c5a6ba2-213d-478f-a4a7-fc85e06d432a	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	3d463e7d-a850-488e-b69f-505a4a64e484	EXPIRED	2026-08-22 13:05:13.596416+00	2026-09-22 13:05:13.596416+00	\N	2026-10-19 13:05:13.596662+00	2026-10-19 13:05:13.596664+00
c0cc41b6-13dc-4609-9311-d95d170248a3	b213cbc7-613c-4a34-8aa1-4876684a1ee9	c7245eb9-a2fa-4709-869a-4a638848af44	EXPIRED	2026-09-03 13:05:13.596416+00	2026-10-03 13:05:13.596416+00	\N	2026-10-19 13:05:13.596672+00	2026-10-19 13:05:13.596673+00
3d79e4ce-8f0d-4295-9777-c075636e2610	17805121-ff16-40ab-9d0f-dd86b4ed1e47	878b8819-a244-4d56-a26f-f67ce8b7565a	EXPIRED	2026-08-08 13:05:13.596416+00	2026-09-08 13:05:13.596416+00	\N	2026-10-19 13:05:13.596678+00	2026-10-19 13:05:13.59668+00
56caf3ee-89aa-4f91-82a7-6f22796ee2ae	bf90f67e-ace2-4080-9868-e732b525745d	878b8819-a244-4d56-a26f-f67ce8b7565a	ACTIVE	2026-10-14 13:05:13.596416+00	2026-11-14 13:05:13.596416+00	\N	2026-10-19 13:05:13.596687+00	2026-10-19 13:05:13.596688+00
42e1b892-8d8c-411a-b46a-a6f13398017d	1845f16a-9e5e-42e2-82f1-de5f565cb7d2	c7245eb9-a2fa-4709-869a-4a638848af44	EXPIRED	2026-08-21 13:05:13.596416+00	2026-09-21 13:05:13.596416+00	\N	2026-10-19 13:05:13.596696+00	2026-10-19 13:05:13.596697+00
08021295-df3b-47f1-85e7-85a55844261e	cda4ced3-4365-496e-99f9-82b3797f3f11	c7245eb9-a2fa-4709-869a-4a638848af44	ACTIVE	2026-10-08 13:05:13.596416+00	2026-11-08 13:05:13.596416+00	\N	2026-10-19 13:05:13.596701+00	2026-10-19 13:05:13.596702+00
3d744f6f-6690-4f2e-8977-4de7a0115a0b	b84cb77d-fb5f-43c9-858b-bb91be0dcf24	3d463e7d-a850-488e-b69f-505a4a64e484	EXPIRED	2026-07-27 13:05:13.596416+00	2026-08-27 13:05:13.596416+00	\N	2026-10-19 13:05:13.596706+00	2026-10-19 13:05:13.596707+00
2192fe25-f245-4f7d-908f-5c0036911728	779738d8-e0dd-43e3-83d4-2bcf579433bd	878b8819-a244-4d56-a26f-f67ce8b7565a	ACTIVE	2026-09-29 13:05:13.596416+00	2026-10-29 13:05:13.596416+00	\N	2026-10-19 13:05:13.596744+00	2026-10-19 13:05:13.596746+00
9d1d690f-e03f-49c6-8871-32a2f7879dc4	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	878b8819-a244-4d56-a26f-f67ce8b7565a	ACTIVE	2026-10-12 13:05:13.596416+00	2026-11-12 13:05:13.596416+00	\N	2026-10-19 13:05:13.596754+00	2026-10-19 13:05:13.596755+00
9b16dfd7-d998-4905-be9b-9d07aa5c2c95	617f9e26-9faa-458c-b9b9-152f7e367117	878b8819-a244-4d56-a26f-f67ce8b7565a	EXPIRED	2026-09-11 13:05:13.596416+00	2026-10-11 13:05:13.596416+00	\N	2026-10-19 13:05:13.596763+00	2026-10-19 13:05:13.596764+00
0e037c76-ee39-44fc-a2b1-c6fa2f8f1321	c08aa28e-b894-4064-b712-e4f3e7cd0939	c7245eb9-a2fa-4709-869a-4a638848af44	EXPIRED	2026-08-04 13:05:13.596416+00	2026-09-04 13:05:13.596416+00	\N	2026-10-19 13:05:13.596772+00	2026-10-19 13:05:13.596789+00
2cbd63ff-f81d-4da9-914c-88d24b37c993	c71364bf-dd7f-4279-beb0-e31c75b6780e	878b8819-a244-4d56-a26f-f67ce8b7565a	EXPIRED	2026-08-26 13:05:13.596416+00	2026-09-26 13:05:13.596416+00	\N	2026-10-19 13:05:13.596798+00	2026-10-19 13:05:13.5968+00
\.


--
-- Data for Name: user_system_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_system_roles (id, user_id, system_role, granted_by, granted_at) FROM stdin;
c7e8ada7-0e74-4e96-b57c-5d4d4522aa26	5f46d7d8-6689-4ece-84f8-39e5de081c5c	ADMIN	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.480789+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, phone, password_hash, full_name, avatar_url, professional_title, bio, portfolio_urls, working_language, skills, location, years_of_experience, linkedin_url, facebook_url, instagram_url, tiktok_url, website, banner_url, status, is_active, last_banned_at, preferences, last_login_at, last_password_change, otp_code, otp_expiry, email_verified_at, two_factor_enabled, totp_secret, created_at, updated_at, clean_period_ends_at, reactivate_at, tokens_revoked_before, row_version, session_version, require_password_reset) FROM stdin;
3da73a3d-a522-4c48-a293-4338b2969670	user4@demo.brandhub.test	9043252706	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Gregorio Rice	\N	Account Manager	Recusandae ab animi blanditiis maxime natus consectetur dicta pariatur officia amet repellat expedita mollitia cumque reprehenderit asperiores.	["https://kerluke.org/case-study"]	fr	["market-research", "community-management"]	Clemmiemouth, Việt Nam	7	https://linkedin.com/in/abbie.harber	\N	https://instagram.com/sherron.kihn	https://tiktok.com/@malia.ullrich	https://cronin.com	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-06-20 13:05:13.40362+00	f	\N	2026-10-19 13:05:13.706339+00	2026-10-19 13:05:13.706356+00	\N	\N	\N	0	0	f
1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	user5@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Gussie Bernier III	\N	Business Owner	Ipsum sit voluptates quam pariatur repellendus fugiat voluptas consequuntur enim dolores maiores sint aliquam aliquid.	["https://pagac.io/portfolio", "https://champlin.com/work"]	zh,ko	["video-editing", "ecommerce"]	Moorestad, Việt Nam	\N	\N	https://facebook.com/floyd.lesch	https://instagram.com/stacey.becker	https://tiktok.com/@tamekia.schiller	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-01-29 13:05:13.405318+00	f	\N	2026-10-19 13:05:13.708155+00	2026-10-19 13:05:13.708171+00	\N	\N	\N	0	0	f
eace4871-7580-4f8e-898a-f7f25a838594	user6@demo.brandhub.test	8917642254	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Mrs. Parker Pollich	\N	Agency Owner	\N	[]	ja	["photography", "content-strategy", "graphic-design"]	New Melanichester, Việt Nam	\N	https://linkedin.com/in/noel.doyle	https://facebook.com/terina.oconner	https://instagram.com/coreen.batz	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-10-08 13:05:13.40594+00	f	\N	2026-10-19 13:05:13.70921+00	2026-10-19 13:05:13.709225+00	\N	\N	\N	0	0	f
1ad8870e-5bce-421d-a37c-49b15ef97166	user7@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Augusta Hoppe	\N	Project Manager	\N	[]	ru,ar	["photography", "email-marketing", "branding", "analytics"]	Lake Rico, Việt Nam	15	https://linkedin.com/in/rachael.zulauf	https://facebook.com/yolando.glover	\N	https://tiktok.com/@simonne.corkery	https://sipes.name	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-01-05 13:05:13.406506+00	f	\N	2026-10-19 13:05:13.710454+00	2026-10-19 13:05:13.710491+00	\N	\N	\N	0	0	f
efde2a2c-eb47-41ff-afe2-03499b0bb5c4	user8@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Dyan Flatley	\N	Videographer	Adipisci reprehenderit quia esse delectus minima vitae ratione velit quas pariatur maiores sit eos porro repellendus quaerat molestias assumenda in.	[]	id	["paid-ads", "ai-tools", "community-management", "ecommerce"]	Halport, Việt Nam	6	https://linkedin.com/in/nikita.kuhn	\N	https://instagram.com/alejandro.hauck	https://tiktok.com/@michale.ohara	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-07-24 13:05:13.407002+00	f	\N	2026-10-19 13:05:13.711649+00	2026-10-19 13:05:13.711667+00	\N	\N	\N	0	0	f
debbe165-84de-460c-b10a-d2cd7ea24966	user9@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Mr. Regan Anderson	\N	Content Creator	\N	["https://lakin.co/portfolio"]	ru	["community-management", "storytelling", "seo"]	East Nicolas, Việt Nam	\N	https://linkedin.com/in/jude.lueilwitz	\N	\N	\N	https://hamill.co	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-06-01 13:05:13.407351+00	f	\N	2026-10-19 13:05:13.71311+00	2026-10-19 13:05:13.713146+00	\N	\N	\N	0	0	f
1dab38ca-17e7-49f6-ab2c-cc8b20fc669f	user10@demo.brandhub.test	9201247560	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Mireille Heathcote	\N	Videographer	\N	[]	id	["account-management", "storytelling", "email-marketing", "photography"]	Tadstad, Việt Nam	\N	https://linkedin.com/in/steven.dickens	\N	https://instagram.com/oren.bernhard	\N	https://lubowitz.com	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-09-17 13:05:13.407718+00	f	\N	2026-10-19 13:05:13.714159+00	2026-10-19 13:05:13.714184+00	\N	\N	\N	0	0	f
56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	user11@demo.brandhub.test	0241523925	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Mertie Windler	\N	Project Manager	Quos ea culpa deserunt in sapiente consectetur placeat expedita nesciunt voluptas ut omnis nobis laboriosam deserunt.	["https://blick.com/work", "https://dach.org/case-study"]	ru	["motion-graphics", "ecommerce"]	Lednerland, Việt Nam	\N	https://linkedin.com/in/tyesha.hermann	\N	\N	https://tiktok.com/@chelsie.champlin	https://waters.name	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-06-22 13:05:13.40806+00	f	\N	2026-10-19 13:05:13.715576+00	2026-10-19 13:05:13.715616+00	\N	\N	\N	0	0	f
b213cbc7-613c-4a34-8aa1-4876684a1ee9	user12@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Fern Hackett	\N	Content Creator	Optio esse quae consectetur quae et commodi blanditiis neque quisquam iste ex aut consectetur eligendi dolore repudiandae pariatur.	["https://farrell.name/portfolio", "https://lesch.io/work"]	hi	["graphic-design", "market-research"]	West Gino, Việt Nam	10	\N	\N	https://instagram.com/marilynn.medhurst	\N	https://bogisich.name	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-12-07 13:05:13.409261+00	f	\N	2026-10-19 13:05:13.716859+00	2026-10-19 13:05:13.716872+00	\N	\N	\N	0	0	f
17805121-ff16-40ab-9d0f-dd86b4ed1e47	user13@demo.brandhub.test	8391509011	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Elfriede Watsica MD	\N	Agency Owner	Eum temporibus architecto voluptatum blanditiis ratione quos porro reprehenderit quidem libero quos architecto vel natus.	["https://goldner.co/work", "https://nikolaus.io/case-study"]	en,ar	["analytics", "event-marketing"]	Uptonville, Việt Nam	\N	https://linkedin.com/in/neta.pacocha	https://facebook.com/wallace.cremin	https://instagram.com/esteban.block	https://tiktok.com/@judson.smitham	https://maggio.info	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-03-24 13:05:13.409788+00	f	\N	2026-10-19 13:05:13.717783+00	2026-10-19 13:05:13.717794+00	\N	\N	\N	0	0	f
bf90f67e-ace2-4080-9868-e732b525745d	user14@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Adah Balistreri	\N	Brand Manager	Iure rerum distinctio sit asperiores asperiores animi accusamus magnam perferendis sed fugit neque possimus doloremque maiores fuga.	["https://greenfelder.io/portfolio", "https://nikolaus.io/case-study"]	zh	["copywriting", "analytics", "social-media", "market-research"]	Littlefurt, Việt Nam	4	https://linkedin.com/in/winston.jacobs	https://facebook.com/claude.brekke	\N	\N	https://mosciski.info	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-06-19 13:05:13.410184+00	f	\N	2026-10-19 13:05:13.718618+00	2026-10-19 13:05:13.718628+00	\N	\N	\N	0	0	f
dbdc427b-e39f-4cdd-b7c2-1de84fec003f	user177@demo.brandhub.test	4505321474	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Dr. Hosea Corwin	\N	Project Manager	\N	["https://schmidt.co/work"]	en,ar	["copywriting", "photography", "email-marketing"]	Claudineville, Việt Nam	2	\N	\N	\N	https://tiktok.com/@pandora.reilly	https://huels.org	\N	ACTIVE	t	\N	{}	2026-10-27 07:53:37.079994+00	\N	\N	\N	2026-04-23 13:05:13.402254+00	f	\N	2026-10-19 13:05:13.704877+00	2026-10-27 07:53:37.083965+00	\N	\N	\N	24	0	f
12adcef2-8964-4ed6-95a5-bbb9a601803c	user1@demo.brandhub.test	4332501066	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Debrah Predovic	\N	Content Manager	Officia at ipsum similique magni voluptatem ducimus quidem non voluptatibus distinctio praesentium cupiditate sed explicabo praesentium numquam possimus magnam adipisci.	["https://kautzer.com/case-study"]	ru	["copywriting", "influencer-marketing"]	South Ellsworthchester, Việt Nam	\N	https://linkedin.com/in/kymberly.schoen	\N	https://instagram.com/humberto.cormier	\N	https://mitchell.co	\N	ACTIVE	t	\N	{}	2026-10-28 12:52:49.381822+00	\N	\N	\N	2026-05-15 13:05:13.399111+00	f	\N	2026-10-19 13:05:13.701305+00	2026-10-28 12:52:49.449128+00	\N	\N	\N	11	0	f
5f46d7d8-6689-4ece-84f8-39e5de081c5c	admin@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	BrandHub Admin	\N	\N	\N	[]	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	t	\N	{}	2026-10-23 08:07:49.878518+00	\N	\N	\N	2026-10-19 13:05:13.09504+00	f	\N	2026-10-19 13:05:13.686807+00	2026-10-23 08:07:49.947437+00	\N	\N	\N	24	0	f
1845f16a-9e5e-42e2-82f1-de5f565cb7d2	user15@demo.brandhub.test	2260144170	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Elina Effertz	\N	Art Director	\N	[]	en	["graphic-design", "campaign-management"]	East Julianville, Việt Nam	11	https://linkedin.com/in/magali.bailey	\N	https://instagram.com/terry.quigley	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-02-04 13:05:13.410447+00	f	\N	2026-10-19 13:05:13.719401+00	2026-10-19 13:05:13.71941+00	\N	\N	\N	0	0	f
cda4ced3-4365-496e-99f9-82b3797f3f11	user16@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Chery Kerluke	\N	Consultant	\N	["https://borer.io/case-study", "https://ritchie.info/portfolio"]	ru	["project-management", "ai-tools", "branding", "video-editing", "pr-communications"]	East Dillon, Việt Nam	1	https://linkedin.com/in/aldo.skiles	https://facebook.com/georgiann.brakus	\N	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-05-01 13:05:13.410785+00	f	\N	2026-10-19 13:05:13.720287+00	2026-10-19 13:05:13.720297+00	\N	\N	\N	0	0	f
180e9676-b334-4115-9641-ec1dfac7fe1d	user17@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Tamera Auer	\N	Social Media Manager	Voluptates assumenda tempore quisquam voluptatibus repellendus ratione culpa perspiciatis tempore esse asperiores blanditiis totam vero aperiam incidunt numquam quam.	[]	ko	["account-management", "storytelling", "ui-ux", "ai-tools"]	Harberfort, Việt Nam	12	https://linkedin.com/in/jennefer.stracke	\N	https://instagram.com/bryan.roob	https://tiktok.com/@wilton.smitham	https://windler.io	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-07-25 13:05:13.411165+00	f	\N	2026-10-19 13:05:13.721076+00	2026-10-19 13:05:13.721091+00	\N	\N	\N	0	0	f
b84cb77d-fb5f-43c9-858b-bb91be0dcf24	user18@demo.brandhub.test	9163580349	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Dario Littel	\N	Copywriter	Molestias ratione unde sapiente dignissimos officiis eaque illum sequi maiores soluta itaque distinctio ex natus blanditiis alias officia dolores harum.	[]	hi,zh	["motion-graphics", "pr-communications", "campaign-management", "copywriting", "seo"]	Beckerville, Việt Nam	8	\N	\N	https://instagram.com/zane.smitham	\N	https://zemlak.org	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-10-25 13:05:13.411573+00	f	\N	2026-10-19 13:05:13.722103+00	2026-10-19 13:05:13.722115+00	\N	\N	\N	0	0	f
779738d8-e0dd-43e3-83d4-2bcf579433bd	user19@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Mr. Anibal Greenholt	\N	Consultant	Voluptates soluta blanditiis et officiis amet vel similique molestias soluta nam odio fugiat iste veniam debitis modi expedita doloribus porro.	["https://kulas.com/portfolio", "https://casper.net/case-study"]	ko	["content-strategy", "copywriting", "email-marketing", "ai-tools"]	Blickland, Việt Nam	12	https://linkedin.com/in/derek.schmidt	\N	\N	https://tiktok.com/@brandon.roberts	https://heller.co	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-05-25 13:05:13.411946+00	f	\N	2026-10-19 13:05:13.723029+00	2026-10-19 13:05:13.723042+00	\N	\N	\N	0	0	f
8927b0b4-3bd6-4fd7-a3d0-daa19304b757	user20@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Dr. Janell Erdman	\N	Business Owner	Modi vitae repudiandae libero ducimus eius voluptates neque quasi non sequi alias beatae accusamus eveniet fuga excepturi architecto officiis.	["https://upton.io/work"]	id	["branding", "ecommerce", "ui-ux"]	South Rufusfort, Việt Nam	15	https://linkedin.com/in/joleen.jones	https://facebook.com/molly.hills	https://instagram.com/bryant.wiza	\N	https://ortiz.biz	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-10-15 13:05:13.413116+00	f	\N	2026-10-19 13:05:13.72393+00	2026-10-19 13:05:13.723945+00	\N	\N	\N	0	0	f
617f9e26-9faa-458c-b9b9-152f7e367117	user21@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Jake Kessler	\N	Agency Owner	\N	["https://quigley.com/work", "https://hermiston.co/case-study"]	th	["account-management", "analytics", "photography"]	Port Eleonoraport, Việt Nam	\N	https://linkedin.com/in/gerald.mills	https://facebook.com/concepcion.bechtelar	https://instagram.com/wm.armstrong	\N	https://sporer.co	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-03-14 13:05:13.413723+00	f	\N	2026-10-19 13:05:13.725055+00	2026-10-19 13:05:13.725066+00	\N	\N	\N	0	0	f
c08aa28e-b894-4064-b712-e4f3e7cd0939	user22@demo.brandhub.test	0579228063	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Ms. Reid Schmitt	\N	Project Manager	\N	[]	ko,en	["paid-ads", "branding"]	North Jeanie, Việt Nam	\N	https://linkedin.com/in/keesha.witting	https://facebook.com/yong.kuphal	\N	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-01-22 13:05:13.414091+00	f	\N	2026-10-19 13:05:13.72623+00	2026-10-19 13:05:13.726245+00	\N	\N	\N	0	0	f
b7f7db40-e219-4792-98a7-6b944703bdb4	user23@demo.brandhub.test	9150103406	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Essie Cummings V	\N	Content Manager	\N	["https://boyle.net/case-study"]	ar	["content-strategy", "project-management", "video-editing", "ai-tools", "campaign-management"]	Bethannport, Việt Nam	13	\N	https://facebook.com/rodger.schaden	\N	https://tiktok.com/@celsa.greenfelder	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-01-09 13:05:13.414617+00	f	\N	2026-10-19 13:05:13.727267+00	2026-10-19 13:05:13.727282+00	\N	\N	\N	0	0	f
c71364bf-dd7f-4279-beb0-e31c75b6780e	user24@demo.brandhub.test	\N	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Nakia Thiel	\N	Freelancer	Quisquam hic architecto consequuntur quas excepturi ipsa impedit voluptatibus iusto laborum accusamus dignissimos aperiam sit beatae rem.	[]	en	["influencer-marketing", "seo", "paid-ads"]	West Colene, Việt Nam	12	\N	https://facebook.com/barton.hermann	\N	https://tiktok.com/@lynette.jacobson	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-03-08 13:05:13.41528+00	f	\N	2026-10-19 13:05:13.728209+00	2026-10-19 13:05:13.728222+00	\N	\N	\N	0	0	f
f40a1175-dd94-41fe-91ea-c37c38311959	user59@demo.brandhub.test	0736118039	$2a$12$IpCt28kyTDbChGAjeulNfOg7bJMECbwcQazMIMd3mmLNpCpi3uOiu	Tennie McLaughlin	\N	Social Media Manager	\N	["https://gibson.net/portfolio"]	en,fr	["ecommerce", "graphic-design", "account-management", "market-research", "influencer-marketing"]	Schmelerhaven, Việt Nam	\N	\N	https://facebook.com/clarita.pollich	\N	\N	\N	\N	ACTIVE	t	\N	{}	2026-10-22 10:11:31.952515+00	\N	\N	\N	2025-10-20 13:05:13.400734+00	f	\N	2026-10-19 13:05:13.703493+00	2026-10-22 10:11:31.956377+00	\N	\N	\N	2	0	f
\.


--
-- Data for Name: workspace_credit_limits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_credit_limits (agency_id, workspace_id, cap, version, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: workspace_credit_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_credit_usage (agency_id, workspace_id, period_id, used, reserved) FROM stdin;
5a4f221b-1350-4421-b060-d0eb7ccaf94d	bb996948-4b50-4761-a682-07a3e7a43eba	f825e63d-fb86-4187-8e9a-af2a99efc79f	0	0
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	4e189bda-9dd0-45fb-942f-ab44012cc9c3	b2000001-0000-4000-8000-000000000002	0	0
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	feed94e7-e87f-421f-b36a-2aa9bfca0052	b2000001-0000-4000-8000-000000000002	0	0
1cb9a40d-7bd8-4096-91aa-d1411cdc961b	80b54360-b724-4fed-925e-94f4d580a3a4	b2000001-0000-4000-8000-000000000002	0	0
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	b2000001-0000-4000-8000-000000000005	0	0
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	c0104b6c-09aa-4500-8a19-e08ab2a023ed	b2000001-0000-4000-8000-000000000005	0	0
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	bb4d08cb-a413-4ebc-bc60-57367cb32ae6	b2000001-0000-4000-8000-000000000005	0	0
1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	42752736-29eb-4bb9-acb1-3e97da7f4e75	b2000001-0000-4000-8000-000000000005	0	0
1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	68b29a5c-4518-47f9-aea7-8c33235ee85c	b2000001-0000-4000-8000-000000000015	0	0
1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	b97cd7c7-60b4-4f52-82cd-bc56a56648a4	b2000001-0000-4000-8000-000000000015	0	0
\.


--
-- Data for Name: workspace_drive_folders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_drive_folders (workspace_id, agency_id, folder_id, ordinal) FROM stdin;
bb996948-4b50-4761-a682-07a3e7a43eba	5a4f221b-1350-4421-b060-d0eb7ccaf94d	1lPospaTLF13g80xkAdR-mBzKHUTUms8Z	1
\.


--
-- Data for Name: workspace_hashtags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_hashtags (id, workspace_id, tag, normalized_tag, purpose, added_by, added_by_name, is_required, campaign_id, deleted_at, deleted_by, created_at, updated_at, version) FROM stdin;
cf000338-345a-5bbd-b682-718cc23c2dfe	bb996948-4b50-4761-a682-07a3e7a43eba	2010	2010	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
fcccb137-ce55-5e14-bfef-d5d89635ed59	bb996948-4b50-4761-a682-07a3e7a43eba	ahappycup	ahappycup	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
49331bb8-c88a-5e04-9894-ce2ae69ad52d	bb996948-4b50-4761-a682-07a3e7a43eba	aimag2026	aimag2026	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
3b9bacd4-c594-55fe-b686-63b23c744f53	bb996948-4b50-4761-a682-07a3e7a43eba	albumtanmui	albumtanmui	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
553fa7c8-b553-591c-a5c5-afb169831a78	bb996948-4b50-4761-a682-07a3e7a43eba	allyachiraya	allyachiraya	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
c59b0bfa-f2e6-5f88-baaf-87bbfe805e31	bb996948-4b50-4761-a682-07a3e7a43eba	anhdavang	anhdavang	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
654ca944-9fa3-5bee-a361-272733ee59f3	bb996948-4b50-4761-a682-07a3e7a43eba	archive026	archive026	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
c566367b-69ff-5258-b0db-78f1d4f09b56	bb996948-4b50-4761-a682-07a3e7a43eba	beatvn	beatvn	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
1b8419d5-c0fb-5f9e-a6b3-6d9990ac135b	bb996948-4b50-4761-a682-07a3e7a43eba	benthanhcollection	benthanhcollection	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
09054886-5588-5dc5-be86-942251795332	bb996948-4b50-4761-a682-07a3e7a43eba	bitis	bitis	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
aca2e9a2-e853-5226-99c5-4336388cb7b1	bb996948-4b50-4761-a682-07a3e7a43eba	bitiswomen	bitiswomen	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e5ece191-1185-5939-93d6-df6e91f07495	bb996948-4b50-4761-a682-07a3e7a43eba	blvquanghuy	blvquanghuy	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
cc10a834-79d8-5f43-ae20-392f9e6a326c	bb996948-4b50-4761-a682-07a3e7a43eba	blvquanghuynews	blvquanghuynews	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
05a12485-ebf2-5178-a828-59484f1b55e2	bb996948-4b50-4761-a682-07a3e7a43eba	blvquanghuyqa	blvquanghuyqa	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
d0ff3338-edfd-5d59-84c3-9d5dfc12c1c7	bb996948-4b50-4761-a682-07a3e7a43eba	blvquanghuyshow	blvquanghuyshow	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
dafaded8-85a9-5f15-bf80-b59b8334fba6	bb996948-4b50-4761-a682-07a3e7a43eba	bongchuyen	bongchuyen	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
b039b79c-1ddf-57e9-b50b-e10c9909c5c5	bb996948-4b50-4761-a682-07a3e7a43eba	bongdaplus	bongdaplus	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
590235a8-33e5-571d-92a9-a8b5b9f4b319	bb996948-4b50-4761-a682-07a3e7a43eba	bongrotv	bongrotv	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e8b06ff8-d162-5fdd-bddb-6da1885cdb6b	bb996948-4b50-4761-a682-07a3e7a43eba	branding	branding	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
62cc9f8b-c16a-523e-bb19-5bdc4da95276	bb996948-4b50-4761-a682-07a3e7a43eba	chatkichthichlanhmanh	chatkichthichlanhmanh	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e1234078-fe0f-50ea-9cc6-f716f782b890	bb996948-4b50-4761-a682-07a3e7a43eba	chuâ	chuâ	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
1d1c78b3-9d21-5ee7-ae14-1e2d974eca2d	bb996948-4b50-4761-a682-07a3e7a43eba	chuẩnâuganicvừalòngmẹá	chuẩnâuganicvừalòngmẹá	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
31645ea7-ebda-5f6e-b883-8eb74151c4b1	bb996948-4b50-4761-a682-07a3e7a43eba	chínhtrị	chínhtrị	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e09f205b-f82f-5fe0-92c4-9942f9d166e5	bb996948-4b50-4761-a682-07a3e7a43eba	citigym	citigym	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
c358c473-d92f-56df-9e10-b37468808713	bb996948-4b50-4761-a682-07a3e7a43eba	cooking	cooking	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
9bf99f28-9ece-57a1-bf6e-64bc49a718c7	bb996948-4b50-4761-a682-07a3e7a43eba	cungchamdinh	cungchamdinh	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
0c419929-16ae-5437-9722-3b59ef13758d	bb996948-4b50-4761-a682-07a3e7a43eba	cupphanboncamau2026	cupphanboncamau2026	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
9e365835-3a80-5d7c-b2dd-6d105dee8c28	bb996948-4b50-4761-a682-07a3e7a43eba	curry	curry	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
3961c8de-125e-5b1d-9914-755f063e778c	bb996948-4b50-4761-a682-07a3e7a43eba	cuồngphim	cuồngphim	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
f3c04a56-f813-5fee-9dc0-80f0f97b4648	bb996948-4b50-4761-a682-07a3e7a43eba	cuồngphimnetwork	cuồngphimnetwork	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e1d4ac11-06f1-5669-81fe-15035f3fdd4d	bb996948-4b50-4761-a682-07a3e7a43eba	cùngchạmđỉnh	cùngchạmđỉnh	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
faf734af-e543-5b84-af49-a3b9878ed094	bb996948-4b50-4761-a682-07a3e7a43eba	dailystyle	dailystyle	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
ee3642c1-ba17-5201-a3e2-162b94e31744	bb996948-4b50-4761-a682-07a3e7a43eba	daomedianetwork	daomedianetwork	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e350e6b2-36e8-5086-bf76-5c6c0d7b2783	bb996948-4b50-4761-a682-07a3e7a43eba	dealthantoc	dealthantoc	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
cb4fab9a-6768-5144-9750-78fae936097d	bb996948-4b50-4761-a682-07a3e7a43eba	design	design	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
3eb6c05b-10df-5eed-a83b-40a479f1a1c9	bb996948-4b50-4761-a682-07a3e7a43eba	diceblue	diceblue	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
1cf67037-266d-550c-afd3-142a37478e26	bb996948-4b50-4761-a682-07a3e7a43eba	dinhhuongmoi	dinhhuongmoi	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
ef3d9ba6-0884-5418-b184-2413b54b3ffe	bb996948-4b50-4761-a682-07a3e7a43eba	doituyenfutsalvietnam	doituyenfutsalvietnam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
854d8c2e-5d10-5421-b79a-203709769da8	bb996948-4b50-4761-a682-07a3e7a43eba	doncic	doncic	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
d62a785a-558e-5e6f-89ff-55dc8bacba74	bb996948-4b50-4761-a682-07a3e7a43eba	dubnation	dubnation	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e7c9c88a-4fd9-5131-8111-2f524da96cc0	bb996948-4b50-4761-a682-07a3e7a43eba	durex	durex	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e0a03191-074f-5829-af0a-0cc540d9af41	bb996948-4b50-4761-a682-07a3e7a43eba	durexjeans	durexjeans	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
73152336-c37b-5e25-aaca-a0139860ac2b	bb996948-4b50-4761-a682-07a3e7a43eba	durexplayclassic	durexplayclassic	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
58cc90bd-7d1a-5dd2-ae17-cd0314694b1d	bb996948-4b50-4761-a682-07a3e7a43eba	durexplaystrawberry	durexplaystrawberry	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
f60d64ac-9c9b-5fe1-a7d7-a1ce6c72b158	bb996948-4b50-4761-a682-07a3e7a43eba	durexvietnam	durexvietnam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
1d900cad-5665-57e1-9aec-13a2936161f7	bb996948-4b50-4761-a682-07a3e7a43eba	efw26aticonsiam	efw26aticonsiam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
de90fc0f-5c43-5a79-b8bd-aa9fb04a7543	bb996948-4b50-4761-a682-07a3e7a43eba	ellefashionweek2026	ellefashionweek2026	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
cf7751cd-4139-5ed6-8c64-8efb198ff960	bb996948-4b50-4761-a682-07a3e7a43eba	ellevietnam	ellevietnam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
1a654eb0-7268-5bad-a393-ef5cb2735952	bb996948-4b50-4761-a682-07a3e7a43eba	enjoyitsfromeurope	enjoyitsfromeurope	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
5c2cee5b-029b-5536-9e8f-f181dabc8c3c	bb996948-4b50-4761-a682-07a3e7a43eba	euagripromo	euagripromo	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
7297f6de-493f-5bed-8940-e8f49f86b6c6	bb996948-4b50-4761-a682-07a3e7a43eba	europeanorganic	europeanorganic	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
7b8a507c-8e24-5cad-a245-9e71da6928b9	bb996948-4b50-4761-a682-07a3e7a43eba	fetherlite	fetherlite	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
ecd25064-9b26-5c43-99ce-90fe8720a455	bb996948-4b50-4761-a682-07a3e7a43eba	fifau15worldcupandfestival2026	fifau15worldcupandfestival2026	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e9b7bd8a-6425-5f04-b81e-3ac337118ab9	bb996948-4b50-4761-a682-07a3e7a43eba	fptplay	fptplay	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
8f7719f7-abbd-5aed-a43c-1b627d705fb5	bb996948-4b50-4761-a682-07a3e7a43eba	fptplaysport	fptplaysport	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
778c75e4-59a4-5e48-a749-0bf811671431	bb996948-4b50-4761-a682-07a3e7a43eba	fyp	fyp	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
c1ddefdc-5621-587f-90da-b8142c26e34e	bb996948-4b50-4761-a682-07a3e7a43eba	gearvn	gearvn	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
f01e768b-9292-5b0c-8af8-0e0c47bbcc3b	bb996948-4b50-4761-a682-07a3e7a43eba	gearvn_acer	gearvn_acer	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e8bcfe1a-e461-50dc-baac-9a87bf576a33	bb996948-4b50-4761-a682-07a3e7a43eba	gearvn_laptop	gearvn_laptop	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
0d2d901c-211c-5682-a579-62e32fa34ede	bb996948-4b50-4761-a682-07a3e7a43eba	gearvn_tainghe	gearvn_tainghe	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
0a07c80c-ace7-56e1-8047-02b7057f529b	bb996948-4b50-4761-a682-07a3e7a43eba	giaihangbaquocgia2026	giaihangbaquocgia2026	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
11c0b006-e11f-50b1-a2b8-b9246699f902	bb996948-4b50-4761-a682-07a3e7a43eba	gosto	gosto	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
98ccefc4-6fe7-56bd-8b9b-1832dbd0c5a8	bb996948-4b50-4761-a682-07a3e7a43eba	grabfood	grabfood	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
14b6d05a-7232-5cb5-a88a-b55094930da9	bb996948-4b50-4761-a682-07a3e7a43eba	gsw	gsw	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
3f558d73-c237-5d0f-be99-4797703a49d4	bb996948-4b50-4761-a682-07a3e7a43eba	gvn_marco	gvn_marco	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
7119ae11-357b-5398-aa17-0d875d3a1540	bb996948-4b50-4761-a682-07a3e7a43eba	gvn_mixom	gvn_mixom	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
12341b45-82b4-543a-b63c-eb76ddf0b2dc	bb996948-4b50-4761-a682-07a3e7a43eba	highlandsbuudienvanthanh	highlandsbuudienvanthanh	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
70453924-741b-58a5-a435-cdf2bc74c378	bb996948-4b50-4761-a682-07a3e7a43eba	highlandscoffee	highlandscoffee	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
d35e9229-6170-55f4-b340-3a2a2b3268b4	bb996948-4b50-4761-a682-07a3e7a43eba	huyseoul	huyseoul	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
702ac64c-83ac-5587-9aa3-d0fddea3fd59	bb996948-4b50-4761-a682-07a3e7a43eba	hư	hư	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
43447932-8d75-5c31-8d1e-b580a1a2a38c	bb996948-4b50-4761-a682-07a3e7a43eba	hữucơeu	hữucơeu	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
821ec1b6-6bd4-521f-9a39-955b70748988	bb996948-4b50-4761-a682-07a3e7a43eba	kfc	kfc	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
ad32bf55-4c29-5cff-b28b-a3811696e39d	bb996948-4b50-4761-a682-07a3e7a43eba	kfcthanhhoa	kfcthanhhoa	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
002f65cd-77b1-5440-8834-b33b7da2c6d4	bb996948-4b50-4761-a682-07a3e7a43eba	kfcvietnam	kfcvietnam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
f4c33f38-e25d-50da-a47b-1c32dd1f40f1	bb996948-4b50-4761-a682-07a3e7a43eba	kongjiro	kongjiro	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
44619a6d-d259-5ad1-baad-72c725aabf99	bb996948-4b50-4761-a682-07a3e7a43eba	lakers	lakers	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e28489d6-ecf4-539c-9fc0-06fdca7c90cf	bb996948-4b50-4761-a682-07a3e7a43eba	leaguepass	leaguepass	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
8867bba4-0450-5255-bebe-e067b158214d	bb996948-4b50-4761-a682-07a3e7a43eba	lpb	lpb	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
fb709503-a7a3-5955-9a9c-30ae306a43b4	bb996948-4b50-4761-a682-07a3e7a43eba	lpbank	lpbank	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
53436daf-deb0-527b-8781-ed52522cad98	bb996948-4b50-4761-a682-07a3e7a43eba	lygiònănđược	lygiònănđược	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
02c4552e-1931-5692-83b8-3b3c282089ab	bb996948-4b50-4761-a682-07a3e7a43eba	mentos	mentos	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
38ecfbb6-4d36-5d02-b4b3-ae354b755d75	bb996948-4b50-4761-a682-07a3e7a43eba	minigame	minigame	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
9b1647a8-94b3-5ba9-9cb4-726df3b7d7b2	bb996948-4b50-4761-a682-07a3e7a43eba	motchatphintu1999	motchatphintu1999	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
b8304160-c522-5330-98ef-1ca03bff33c5	bb996948-4b50-4761-a682-07a3e7a43eba	mutualclimax	mutualclimax	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
339f83d1-cf30-5c5f-9baa-d05a00a639ad	bb996948-4b50-4761-a682-07a3e7a43eba	mảnhghépphúclong	mảnhghépphúclong	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
c621eaa8-f8ab-5666-baf2-efeb9ae577d1	bb996948-4b50-4761-a682-07a3e7a43eba	nangniubanchanviet	nangniubanchanviet	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
cd2042ef-3084-5188-b033-86eaac43f2b3	bb996948-4b50-4761-a682-07a3e7a43eba	naturland	naturland	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
daefa3ff-eacf-56f2-b783-acf2bf9d9217	bb996948-4b50-4761-a682-07a3e7a43eba	nba	nba	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
5212758e-8424-5fc6-88b9-8e02fc252da8	bb996948-4b50-4761-a682-07a3e7a43eba	nbaplayoffs	nbaplayoffs	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
64a0d9d2-fc19-52fd-8b82-3f0285321df5	bb996948-4b50-4761-a682-07a3e7a43eba	nbarecap	nbarecap	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
92957dee-af49-5c1a-8b4e-5bf7f79412cd	bb996948-4b50-4761-a682-07a3e7a43eba	nbavietnam	nbavietnam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e3c530ad-1307-58ed-8796-3cdd182ab402	bb996948-4b50-4761-a682-07a3e7a43eba	newstoreopening	newstoreopening	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
bc23a12a-ab9b-51aa-b68e-d9a007613485	bb996948-4b50-4761-a682-07a3e7a43eba	ngayphunuvietnam	ngayphunuvietnam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
570285ea-c109-5f43-a62a-b219e79805d2	bb996948-4b50-4761-a682-07a3e7a43eba	ngumieuphaan	ngumieuphaan	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
3608ab53-a7dd-515d-842a-4b23d6485710	bb996948-4b50-4761-a682-07a3e7a43eba	oppahuy	oppahuy	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
a7e8ef8f-8d7e-5387-862b-1eb5beaa8469	bb996948-4b50-4761-a682-07a3e7a43eba	pannacotta	pannacotta	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
19b88b9b-5174-50d7-a5f6-ae334e88e688	bb996948-4b50-4761-a682-07a3e7a43eba	phamtthuc	phamtthuc	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
43513c6e-fd24-5fdc-971c-3ea7c1b8d87b	bb996948-4b50-4761-a682-07a3e7a43eba	phamvinh99	phamvinh99	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e9b01e0c-d687-5619-8b6f-651b1af8b158	bb996948-4b50-4761-a682-07a3e7a43eba	phanboncamau	phanboncamau	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
11b1d0e4-2de0-5d3f-a56e-af995af2da73	bb996948-4b50-4761-a682-07a3e7a43eba	phúclong	phúclong	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
f10efe85-e782-51cd-8946-8764f2a36758	bb996948-4b50-4761-a682-07a3e7a43eba	pt	pt	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
44e172bf-438d-5473-a12f-87f1aeee063a	bb996948-4b50-4761-a682-07a3e7a43eba	pvcfc	pvcfc	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
f16a0b10-d943-5efb-9855-f7688161742d	bb996948-4b50-4761-a682-07a3e7a43eba	qnhh	qnhh	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e7eb53bb-9eff-581f-a64e-f7d0e530f412	bb996948-4b50-4761-a682-07a3e7a43eba	quannhahaha	quannhahaha	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
2452b510-bee0-5810-ad18-96693c9f57c1	bb996948-4b50-4761-a682-07a3e7a43eba	quatang	quatang	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
818cc9ce-3b29-5fb2-b359-668fed76af05	bb996948-4b50-4761-a682-07a3e7a43eba	rgb	rgb	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
85fff94f-fe83-53e5-8a44-aae3ce0232c7	bb996948-4b50-4761-a682-07a3e7a43eba	sacrangro	sacrangro	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e85dad8c-eb18-58fe-b7da-72b05e93855d	bb996948-4b50-4761-a682-07a3e7a43eba	saigonamap	saigonamap	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
4bfe1acc-1ac1-51b3-8bc2-88b973c5a097	bb996948-4b50-4761-a682-07a3e7a43eba	seeyouatthetent	seeyouatthetent	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e2d4a27d-10cf-5d80-a865-32dcf97c6329	bb996948-4b50-4761-a682-07a3e7a43eba	shopeelive	shopeelive	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
031071ce-0fd0-5612-a7cb-5cf0a20838d5	bb996948-4b50-4761-a682-07a3e7a43eba	spicybox10thbirthday	spicybox10thbirthday	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
bd9c625c-146f-5d9f-a441-e76306360def	bb996948-4b50-4761-a682-07a3e7a43eba	stephencurry	stephencurry	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
fb241155-35d1-5c7f-b942-4a54b014dd19	bb996948-4b50-4761-a682-07a3e7a43eba	tanmui	tanmui	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
1a39cd3c-1c71-5310-8e06-cf59ea453cf6	bb996948-4b50-4761-a682-07a3e7a43eba	tanmuishowcase	tanmuishowcase	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
5ea1f4d5-3732-50e0-936e-c245ba0acfb4	bb996948-4b50-4761-a682-07a3e7a43eba	theartofsoftness	theartofsoftness	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
b27f8a37-4d8b-5e0c-81c3-23253dc35dac	bb996948-4b50-4761-a682-07a3e7a43eba	thiennguyenbenvung	thiennguyenbenvung	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
33ec018f-149f-5f45-a05b-09b1e4f49852	bb996948-4b50-4761-a682-07a3e7a43eba	tháng10củanàng	tháng10củanàng	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
126b691b-a7c7-51fb-a175-bedf42221e2c	bb996948-4b50-4761-a682-07a3e7a43eba	thờisự	thờisự	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
cf20f521-f058-5017-be04-1dbbd1f21bba	bb996948-4b50-4761-a682-07a3e7a43eba	tieuthat2000	tieuthat2000	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
a19e8013-202b-5557-b224-22202caddef8	bb996948-4b50-4761-a682-07a3e7a43eba	trangmieng	trangmieng	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
f7ba9290-642b-5c09-8077-d4b3dc2b2466	bb996948-4b50-4761-a682-07a3e7a43eba	tronmuottruotme	tronmuottruotme	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
c2be2fc1-3bff-5ae6-9ea1-3c098ffb8523	bb996948-4b50-4761-a682-07a3e7a43eba	trucnhan	trucnhan	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
4474f2dc-bf22-5af1-bc7e-3d31027254fe	bb996948-4b50-4761-a682-07a3e7a43eba	tràsữaphúclong	tràsữaphúclong	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
fd9c14a6-b2a7-5408-8045-cb0a6782741e	bb996948-4b50-4761-a682-07a3e7a43eba	tthomastc	tthomastc	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
4a60be01-e66c-5243-8f08-3e5685ce7ae4	bb996948-4b50-4761-a682-07a3e7a43eba	u15vietnam	u15vietnam	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
9b96caf3-685f-5784-9db4-b27507989657	bb996948-4b50-4761-a682-07a3e7a43eba	urbox	urbox	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
15fd84ed-88ed-52c8-a41a-e9ffc52df4e6	bb996948-4b50-4761-a682-07a3e7a43eba	vanhleg	vanhleg	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
e6bd991a-e39b-50f5-8106-2f5711e67eee	bb996948-4b50-4761-a682-07a3e7a43eba	vietcombankxquánnhàhaha	vietcombankxquánnhàhaha	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
56ceca31-a1e6-5256-baef-1c3c679ab2a1	bb996948-4b50-4761-a682-07a3e7a43eba	vietcontent	vietcontent	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
b17e2bbc-449f-591d-96af-dede3e5e94a9	bb996948-4b50-4761-a682-07a3e7a43eba	vietnamnet	vietnamnet	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
43d9924b-bbcb-58aa-9fd0-b38930cb4237	bb996948-4b50-4761-a682-07a3e7a43eba	viral	viral	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
188a249f-bdf3-5dc0-9c4f-61db13edab3d	bb996948-4b50-4761-a682-07a3e7a43eba	vl1	vl1	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
3a305712-4784-57ac-b429-b1e27b623bdb	bb996948-4b50-4761-a682-07a3e7a43eba	vleague	vleague	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
c213e10c-6dee-5488-8067-1f57e6c33429	bb996948-4b50-4761-a682-07a3e7a43eba	vmgenz	vmgenz	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
a560e817-8d8e-5e67-aa2c-f564ea7d783d	bb996948-4b50-4761-a682-07a3e7a43eba	vulaci	vulaci	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
b0b214b1-867b-5a63-ad84-7a1914f68bd5	bb996948-4b50-4761-a682-07a3e7a43eba	webthethao	webthethao	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
2f7b79d7-e171-56f3-8fb5-e9452be162a8	bb996948-4b50-4761-a682-07a3e7a43eba	xhtiktok	xhtiktok	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
386cfde7-8e5a-52c0-9eb3-9c2cb9867e26	bb996948-4b50-4761-a682-07a3e7a43eba	xuhuong	xuhuong	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
b309a3d5-6976-5017-a55e-a1f7e3a5946f	bb996948-4b50-4761-a682-07a3e7a43eba	y1t26	y1t26	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
96864420-6050-51c1-a074-ac17b6c2b701	bb996948-4b50-4761-a682-07a3e7a43eba	yeah1	yeah1	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
1da3b4a2-5de1-5668-9ca4-c891d30d6c2e	bb996948-4b50-4761-a682-07a3e7a43eba	yogaworkshop	yogaworkshop	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
27b20993-fd80-55e3-84b3-ae54f1ce7d54	bb996948-4b50-4761-a682-07a3e7a43eba	đậmtràđộcbản	đậmtràđộcbản	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	\N	\N	2026-10-27 10:37:25.740334+00	2026-10-27 10:37:25.740334+00	0
8d57f68e-0876-6f62-a2a1-418a0e01ac95	bb996948-4b50-4761-a682-07a3e7a43eba	FPTShop	fptshop	BRAND	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:32:08.812235+00	2026-10-27 10:38:51.3793+00	1
94a0bd5b-ff6e-caab-776d-957d18fb13df	bb996948-4b50-4761-a682-07a3e7a43eba	AIMAcademy	aimacademy	BRAND	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:31:08.812235+00	2026-10-27 10:38:51.3793+00	1
f8cd4725-cf83-6462-0107-4225631803f9	bb996948-4b50-4761-a682-07a3e7a43eba	FPTShopOfficial	fptshopofficial	BRAND	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:30:08.812235+00	2026-10-27 10:38:51.3793+00	1
bd8b2091-c6a9-a0dd-4e18-b0e461d98209	bb996948-4b50-4761-a682-07a3e7a43eba	CongNgheChoMoiNha	congnghechomoinha	BRAND	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:29:08.812235+00	2026-10-27 10:38:51.3793+00	1
370d8c9e-fcc2-6f0f-038e-9b79250d34f1	bb996948-4b50-4761-a682-07a3e7a43eba	DongHanhCungFPT	donghanhcungfpt	BRAND	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:28:08.812235+00	2026-10-27 10:38:51.3793+00	1
733e9f28-094d-6a32-5176-ce26436de986	bb996948-4b50-4761-a682-07a3e7a43eba	TraiNghiemFPTShop	trainghiemfptshop	BRAND	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:27:08.812235+00	2026-10-27 10:38:51.3793+00	1
2bd53dc5-f543-f26d-ca88-d783c642741d	bb996948-4b50-4761-a682-07a3e7a43eba	TuVanCongNghe	tuvancongnghe	BRAND	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:26:08.812235+00	2026-10-27 10:38:51.3793+00	1
3a7236e6-256e-68f9-ec94-2cf86a72c995	bb996948-4b50-4761-a682-07a3e7a43eba	KetNoiTuongLai	ketnoituonglai	BRAND	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:25:08.812235+00	2026-10-27 10:38:51.3793+00	1
2bb38bc6-7c3e-6f64-48ac-430f7d62f81b	bb996948-4b50-4761-a682-07a3e7a43eba	DemoBackToSchool	demobacktoschool	CAMPAIGN	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:24:08.812235+00	2026-10-27 10:38:51.3793+00	1
a479b86a-af45-3f33-b791-fad391a02d47	bb996948-4b50-4761-a682-07a3e7a43eba	DemoLaptopSinhVien	demolaptopsinhvien	CAMPAIGN	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:23:08.812235+00	2026-10-27 10:38:51.3793+00	1
d9f00f23-e56a-76fd-00a0-e7cf9394d45f	bb996948-4b50-4761-a682-07a3e7a43eba	DemoUuDaiCuoiTuan	demouudaicuoituan	CAMPAIGN	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:22:08.812235+00	2026-10-27 10:38:51.3793+00	1
58eb3f4c-adea-71ad-a8da-b2cb2f59c3ca	bb996948-4b50-4761-a682-07a3e7a43eba	DemoDoiMayMoi	demodoimaymoi	CAMPAIGN	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:21:08.812235+00	2026-10-27 10:38:51.3793+00	1
8ff1e791-3b37-5f3d-b3d8-935f08c05add	bb996948-4b50-4761-a682-07a3e7a43eba	DemoSanDealCongNghe	demosandealcongnghe	CAMPAIGN	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:20:08.812235+00	2026-10-27 10:38:51.3793+00	1
6cffd643-e770-52fe-5657-1d5a3f6b980b	bb996948-4b50-4761-a682-07a3e7a43eba	DemoMuaSamThongMinh	demomuasamthongminh	CAMPAIGN	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:19:08.812235+00	2026-10-27 10:38:51.3793+00	1
11eae7e8-6bae-0303-4554-a1f4097fa987	bb996948-4b50-4761-a682-07a3e7a43eba	DemoQuaTangCongNghe	demoquatangcongnghe	CAMPAIGN	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:18:08.812235+00	2026-10-27 10:38:51.3793+00	1
a300b712-b203-53ac-0eb7-a5258d17301d	bb996948-4b50-4761-a682-07a3e7a43eba	DemoTraiNghiemSanPham	demotrainghiemsanpham	CAMPAIGN	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:17:08.812235+00	2026-10-27 10:38:51.3793+00	1
8fece06f-2af2-a101-5dfd-75d4c2cc2c52	bb996948-4b50-4761-a682-07a3e7a43eba	DemoTechTrend	demotechtrend	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:16:08.812235+00	2026-10-27 10:38:51.3793+00	1
d8b11056-236c-6ee8-5ff7-6bdb0d9d61d1	bb996948-4b50-4761-a682-07a3e7a43eba	DemoAIChoSinhVien	demoaichosinhvien	TRENDING	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:15:08.812235+00	2026-10-27 10:38:51.3793+00	1
f43da05a-0eb9-6d5f-b074-282d3a536d96	bb996948-4b50-4761-a682-07a3e7a43eba	DemoGocHocTap	demogochoctap	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:14:08.812235+00	2026-10-27 10:38:51.3793+00	1
deade3b5-67a8-3a3b-9f0a-30402538f42d	bb996948-4b50-4761-a682-07a3e7a43eba	DemoSetupBanLamViec	demosetupbanlamviec	TRENDING	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:13:08.812235+00	2026-10-27 10:38:51.3793+00	1
abf2d00a-a5d7-0818-20ee-7dec0e92eeb2	bb996948-4b50-4761-a682-07a3e7a43eba	DemoReviewDienThoai	demoreviewdienthoai	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:12:08.812235+00	2026-10-27 10:38:51.3793+00	1
caa3be71-f88f-2867-acc0-be9456b216ff	bb996948-4b50-4761-a682-07a3e7a43eba	DemoMeoCongNghe	demomeocongnghe	TRENDING	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:11:08.812235+00	2026-10-27 10:38:51.3793+00	1
04ed7e10-2ebd-3986-e2bf-c0d3763009d7	bb996948-4b50-4761-a682-07a3e7a43eba	DemoSongSo	demosongso	TRENDING	12adcef2-8964-4ed6-95a5-bbb9a601803c	Debrah Predovic	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:10:08.812235+00	2026-10-27 10:38:51.3793+00	1
e1ef3ef7-8c01-89b0-cca3-adef8c0b9b17	bb996948-4b50-4761-a682-07a3e7a43eba	DemoSangTaoNoiDung	demosangtaonoidung	TRENDING	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	Dr. Hosea Corwin	f	\N	2026-10-27 10:38:51.3793+00	12adcef2-8964-4ed6-95a5-bbb9a601803c	2026-10-27 10:09:08.812235+00	2026-10-27 10:38:51.3793+00	1
\.


--
-- Data for Name: workspace_invitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_invitations (id, workspace_id, invited_email, invited_by, token, role, status, expires_at, accepted_at, created_at) FROM stdin;
a42a623a-b004-43be-b418-f291e51192d2	80b54360-b724-4fed-925e-94f4d580a3a4	jamee.reynolds@yahoo.com	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	094d3524-fadc-4975-a6c6-8b9c8707a3f0	CREATOR	PENDING	2026-10-26 13:05:13.819618+00	\N	2026-10-19 13:05:13.819648+00
8c3482a6-1ddf-4a3f-a0a2-0c93fa02b43d	bb4d08cb-a413-4ebc-bc60-57367cb32ae6	rosaline.connelly@yahoo.com	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	e338c125-6fec-46af-8ed7-bcfd143669df	CREATOR	PENDING	2026-10-26 13:05:13.819693+00	\N	2026-10-19 13:05:13.819694+00
fac6bb52-01e4-4cbb-ab4e-95f6a9ed690c	68b29a5c-4518-47f9-aea7-8c33235ee85c	tori.stamm@yahoo.com	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	a317a5d7-51f8-413e-a678-a350d7ba5ef8	CREATOR	PENDING	2026-10-26 13:05:13.81975+00	\N	2026-10-19 13:05:13.819752+00
90fa2559-e14e-4940-9209-757e00bd64df	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	inez.thiel@hotmail.com	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	f8244e66-b4ed-453a-9f4b-315939ab1ac2	CREATOR	PENDING	2026-10-26 13:05:13.819924+00	\N	2026-10-19 13:05:13.819934+00
\.


--
-- Data for Name: workspace_media_packages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_media_packages (id, workspace_id, package_id, negotiation_status, final_terms, previous_terms, terms_version, client_proposal_count, approved_by_agency_at, approved_by_client_at, created_at, updated_at) FROM stdin;
8e52e1ff-ce74-4234-a4e0-d90e6ba0a3cf	b97cd7c7-60b4-4f52-82cd-bc56a56648a4	3b3659fe-1431-4e6f-bb6d-00bbe5ecde38	APPROVED	{"name": "Chiến dịch livestream giới thiệu sản phẩm", "budgetAmount": 22000000, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5d627187-e9f1-41d2-895b-6a57ced2daee", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 2, "description": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "3b3659fe-1431-4e6f-bb6d-00bbe5ecde38", "scopeDescription": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng."}	\N	1	0	2026-10-19 13:05:13.914264+00	2026-10-19 13:05:13.914264+00	2026-10-19 13:05:14.093647+00	2026-10-19 13:05:14.093657+00
bc3febaa-0a5e-456e-b12b-aa3781d83722	68b29a5c-4518-47f9-aea7-8c33235ee85c	9d88fc9b-0df4-4591-9eea-bb209c817c98	CLIENT_REQUESTED_CHANGE	{"name": "Chăm sóc kênh mạng xã hội", "budgetAmount": 12000000, "durationWeeks": 4, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "1d908cdd-cc05-4ef5-8a6a-a03926855093", "name": "Bài đăng mạng xã hội", "unit": "bài", "quantity": 12, "description": "Sản lượng là tổng cả gói cho một Campaign.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "9d88fc9b-0df4-4591-9eea-bb209c817c98", "scopeDescription": "Sản lượng là tổng cả gói cho một Campaign."}	\N	1	0	\N	\N	2026-10-19 13:05:14.094942+00	2026-10-19 13:05:14.094958+00
c6c39106-4100-440e-963a-c5a18dbaf661	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	46b57b12-73c0-469a-b7f6-ea88c8b8f562	AGENCY_COUNTERED	{"name": "Bộ kế hoạch 3 sự kiện", "budgetAmount": 21000000, "durationWeeks": 12, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "3cce79c7-0d90-4e3c-913f-48060f9793a9", "name": "Kế hoạch sự kiện bàn giao", "unit": "sự kiện", "quantity": 3, "description": "Bàn giao kế hoạch cho một Campaign; không bao gồm module hậu cần hay vận hành sự kiện.", "serviceType": "EVENT_PLANNING", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "46b57b12-73c0-469a-b7f6-ea88c8b8f562", "scopeDescription": "Bàn giao kế hoạch cho một Campaign; không bao gồm module hậu cần hay vận hành sự kiện."}	\N	1	0	\N	\N	2026-10-19 13:05:14.095756+00	2026-10-19 13:05:14.095763+00
c3000002-0000-4000-8000-000000000001	42752736-29eb-4bb9-acb1-3e97da7f4e75	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	APPROVED	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	\N	1	0	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00
c3000002-0000-4000-8000-000000000002	4e189bda-9dd0-45fb-942f-ab44012cc9c3	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	APPROVED	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	\N	1	0	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00
c3000002-0000-4000-8000-000000000003	80b54360-b724-4fed-925e-94f4d580a3a4	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	APPROVED	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	\N	1	0	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00
c3000002-0000-4000-8000-000000000004	bb4d08cb-a413-4ebc-bc60-57367cb32ae6	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	APPROVED	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	\N	1	0	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00
c3000002-0000-4000-8000-000000000005	bb996948-4b50-4761-a682-07a3e7a43eba	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	APPROVED	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	\N	1	0	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00
c3000002-0000-4000-8000-000000000006	c0104b6c-09aa-4500-8a19-e08ab2a023ed	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	APPROVED	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	\N	1	0	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00
c3000002-0000-4000-8000-000000000007	feed94e7-e87f-421f-b36a-2aa9bfca0052	1c7ee75e-c69b-4f7b-8989-a01cba45bad2	APPROVED	{"name": "Chiến dịch ra mắt sản phẩm", "budgetAmount": 18000000.00, "durationWeeks": 6, "quantityBasis": "TOTAL", "offeringDetails": {"maxChanges": 2, "deliverables": [{"id": "5123274b-85a9-43da-8cea-0e632bc9b5e3", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}, "sourcePackageId": "1c7ee75e-c69b-4f7b-8989-a01cba45bad2", "scopeDescription": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm."}	\N	1	0	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00	2026-10-19 16:01:42.461252+00	2026-10-20 16:01:42.461252+00
\.


--
-- Data for Name: workspace_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_members (id, workspace_id, user_id, client_profile_id, role, added_by, joined_at, is_active, created_at, updated_at) FROM stdin;
ef9fb197-b828-4e4d-a77f-bab1c86106d6	b97cd7c7-60b4-4f52-82cd-bc56a56648a4	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	MANAGER	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-19 13:05:13.812374+00	t	2026-10-19 13:05:13.812394+00	2026-10-19 13:05:13.812398+00
5441571a-04d4-4e47-9677-af6850a220ed	b97cd7c7-60b4-4f52-82cd-bc56a56648a4	b7f7db40-e219-4792-98a7-6b944703bdb4	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-10 13:05:13.812543+00	t	2026-10-19 13:05:13.812604+00	2026-10-19 13:05:13.812606+00
979b5961-2cbb-47b9-9b7c-04517df5f5e6	b97cd7c7-60b4-4f52-82cd-bc56a56648a4	17805121-ff16-40ab-9d0f-dd86b4ed1e47	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-08 13:05:13.812616+00	t	2026-10-19 13:05:13.812622+00	2026-10-19 13:05:13.812623+00
a2e56def-9e82-4819-a2e5-ece4e6098c46	80b54360-b724-4fed-925e-94f4d580a3a4	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812625+00	t	2026-10-19 13:05:13.812627+00	2026-10-19 13:05:13.812629+00
3a9f7d49-6a4f-44da-8a45-255eb2150e5b	80b54360-b724-4fed-925e-94f4d580a3a4	8927b0b4-3bd6-4fd7-a3d0-daa19304b757	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-08-22 13:05:13.812635+00	t	2026-10-19 13:05:13.81264+00	2026-10-19 13:05:13.81264+00
4f863456-9c92-4561-97a8-c6c6a5994787	80b54360-b724-4fed-925e-94f4d580a3a4	debbe165-84de-460c-b10a-d2cd7ea24966	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-12 13:05:13.812643+00	t	2026-10-19 13:05:13.812646+00	2026-10-19 13:05:13.812647+00
2425b919-1d29-422a-b07a-f092efe0a035	80b54360-b724-4fed-925e-94f4d580a3a4	617f9e26-9faa-458c-b9b9-152f7e367117	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-25 13:05:13.812648+00	t	2026-10-19 13:05:13.812651+00	2026-10-19 13:05:13.812651+00
48fbe7d9-335e-4c22-9ca2-e1f95043ab5f	80b54360-b724-4fed-925e-94f4d580a3a4	1dab38ca-17e7-49f6-ab2c-cc8b20fc669f	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-30 13:05:13.812652+00	t	2026-10-19 13:05:13.812654+00	2026-10-19 13:05:13.812655+00
31e03d49-bfcf-472e-be63-017acb07b989	feed94e7-e87f-421f-b36a-2aa9bfca0052	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812657+00	t	2026-10-19 13:05:13.812658+00	2026-10-19 13:05:13.812658+00
fa6ed4de-691a-4dd2-bbb8-85e08b103435	feed94e7-e87f-421f-b36a-2aa9bfca0052	b7f7db40-e219-4792-98a7-6b944703bdb4	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-09 13:05:13.812659+00	t	2026-10-19 13:05:13.812662+00	2026-10-19 13:05:13.812663+00
8ad4e467-28cb-451e-bdec-ea7f068d8bd3	feed94e7-e87f-421f-b36a-2aa9bfca0052	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-21 13:05:13.812663+00	t	2026-10-19 13:05:13.812666+00	2026-10-19 13:05:13.812666+00
c56c17c6-705e-4e40-8d16-1842e196f6d0	feed94e7-e87f-421f-b36a-2aa9bfca0052	cda4ced3-4365-496e-99f9-82b3797f3f11	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-08-26 13:05:13.812667+00	t	2026-10-19 13:05:13.81267+00	2026-10-19 13:05:13.812671+00
40675a7e-1123-46c0-8c9a-899a2e8e8ffa	42752736-29eb-4bb9-acb1-3e97da7f4e75	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812675+00	t	2026-10-19 13:05:13.812675+00	2026-10-19 13:05:13.812676+00
87fdfc14-0955-49d1-8bb8-23f9b362c241	bb996948-4b50-4761-a682-07a3e7a43eba	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812683+00	t	2026-10-19 13:05:13.812683+00	2026-10-19 13:05:13.812683+00
93f9cf40-24f6-46de-bf7f-0ba5d0ff8816	bb996948-4b50-4761-a682-07a3e7a43eba	cda4ced3-4365-496e-99f9-82b3797f3f11	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-24 13:05:13.812684+00	t	2026-10-19 13:05:13.812717+00	2026-10-19 13:05:13.812718+00
0b861377-8e63-45af-922c-5cd586bff29d	bb996948-4b50-4761-a682-07a3e7a43eba	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-08-27 13:05:13.81272+00	t	2026-10-19 13:05:13.812726+00	2026-10-19 13:05:13.812726+00
012088c7-4433-47b9-b9f0-7adb3827d029	bb996948-4b50-4761-a682-07a3e7a43eba	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-14 13:05:13.81273+00	t	2026-10-19 13:05:13.812734+00	2026-10-19 13:05:13.812734+00
d52776f9-3c33-4100-9c97-d5d58572f622	bb4d08cb-a413-4ebc-bc60-57367cb32ae6	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812735+00	t	2026-10-19 13:05:13.812736+00	2026-10-19 13:05:13.812736+00
5e6cc742-f77e-4cc3-b9d6-f0cb2da215d7	bb4d08cb-a413-4ebc-bc60-57367cb32ae6	180e9676-b334-4115-9641-ec1dfac7fe1d	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-16 13:05:13.812746+00	t	2026-10-19 13:05:13.812749+00	2026-10-19 13:05:13.81275+00
12bc076d-9f82-4f69-bdcf-e70c10c8ad3e	68b29a5c-4518-47f9-aea7-8c33235ee85c	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	\N	MANAGER	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-19 13:05:13.812751+00	t	2026-10-19 13:05:13.812751+00	2026-10-19 13:05:13.812752+00
adfd335a-72b6-4d20-b8f4-4d72a5333bf9	68b29a5c-4518-47f9-aea7-8c33235ee85c	779738d8-e0dd-43e3-83d4-2bcf579433bd	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-09-16 13:05:13.812753+00	t	2026-10-19 13:05:13.812756+00	2026-10-19 13:05:13.812756+00
c927b1f9-0192-41d1-a02e-231f30f64e58	68b29a5c-4518-47f9-aea7-8c33235ee85c	debbe165-84de-460c-b10a-d2cd7ea24966	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-08-26 13:05:13.812757+00	t	2026-10-19 13:05:13.812759+00	2026-10-19 13:05:13.812759+00
d46dd7ef-416b-4414-8a38-edffd6711599	68b29a5c-4518-47f9-aea7-8c33235ee85c	617f9e26-9faa-458c-b9b9-152f7e367117	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-09-21 13:05:13.81276+00	t	2026-10-19 13:05:13.812763+00	2026-10-19 13:05:13.812763+00
7925d86c-a797-45af-a933-7dcccc708e06	68b29a5c-4518-47f9-aea7-8c33235ee85c	cda4ced3-4365-496e-99f9-82b3797f3f11	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-10-08 13:05:13.812764+00	t	2026-10-19 13:05:13.812766+00	2026-10-19 13:05:13.812767+00
90fcd2f0-4f83-4cf3-9869-ec19e9612337	68b29a5c-4518-47f9-aea7-8c33235ee85c	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-09-07 13:05:13.812767+00	t	2026-10-19 13:05:13.812769+00	2026-10-19 13:05:13.81277+00
53a20566-1179-4a57-8d60-67023cc356a7	4e189bda-9dd0-45fb-942f-ab44012cc9c3	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812773+00	t	2026-10-19 13:05:13.812774+00	2026-10-19 13:05:13.812774+00
9ca0198b-4d35-44fc-9590-c074b33ab12f	4e189bda-9dd0-45fb-942f-ab44012cc9c3	bf90f67e-ace2-4080-9868-e732b525745d	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-07 13:05:13.812779+00	t	2026-10-19 13:05:13.812797+00	2026-10-19 13:05:13.812798+00
eff732ef-2df4-47d5-b6d2-a5e713fd3932	c0104b6c-09aa-4500-8a19-e08ab2a023ed	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812806+00	t	2026-10-19 13:05:13.812807+00	2026-10-19 13:05:13.812807+00
97932269-1723-4c38-a3a3-37f716ca9f75	c0104b6c-09aa-4500-8a19-e08ab2a023ed	1f0bfc05-861b-4a10-92a6-34e9d9e3b1f2	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-05 13:05:13.812809+00	t	2026-10-19 13:05:13.812813+00	2026-10-19 13:05:13.812814+00
3459c27e-63ca-493d-bef0-739cb86d98b2	c0104b6c-09aa-4500-8a19-e08ab2a023ed	efde2a2c-eb47-41ff-afe2-03499b0bb5c4	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-08-31 13:05:13.812815+00	t	2026-10-19 13:05:13.812819+00	2026-10-19 13:05:13.812819+00
0ca6b08d-a1f5-4928-ad90-eab888c7e8d1	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	\N	MANAGER	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.812821+00	t	2026-10-19 13:05:13.812821+00	2026-10-19 13:05:13.812821+00
11c84432-ad68-42ad-96b0-6ead4ed3d234	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	bf90f67e-ace2-4080-9868-e732b525745d	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-02 13:05:13.812822+00	t	2026-10-19 13:05:13.812826+00	2026-10-19 13:05:13.812826+00
883103ee-18b8-4c73-88e1-78ad71c1957a	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	779738d8-e0dd-43e3-83d4-2bcf579433bd	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-06 13:05:13.812832+00	t	2026-10-19 13:05:13.812835+00	2026-10-19 13:05:13.812835+00
521f588f-031f-481e-9099-977c07e2f385	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	c08aa28e-b894-4064-b712-e4f3e7cd0939	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-09 13:05:13.812836+00	t	2026-10-19 13:05:13.812839+00	2026-10-19 13:05:13.812839+00
6b3d8cbe-111d-4c46-999c-018431d41d11	bb996948-4b50-4761-a682-07a3e7a43eba	12adcef2-8964-4ed6-95a5-bbb9a601803c	\N	CREATOR	\N	2026-10-27 07:59:48.365227+00	t	2026-10-27 07:59:48.365227+00	2026-10-27 07:59:48.365227+00
6aabe002-60fa-4957-aa8d-98826429baca	b97cd7c7-60b4-4f52-82cd-bc56a56648a4	f40a1175-dd94-41fe-91ea-c37c38311959	47615c12-611c-4078-a296-044539c532c0	CLIENT	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-09-19 13:05:13.812523+00	t	2026-10-19 13:05:13.812536+00	2026-10-29 16:01:42.461252+00
59596a65-f369-41da-90c0-d4e1d92b3399	68b29a5c-4518-47f9-aea7-8c33235ee85c	f40a1175-dd94-41fe-91ea-c37c38311959	62c09057-f843-4054-bc13-ecf4b6c351be	CLIENT	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-08-27 13:05:13.812771+00	t	2026-10-19 13:05:13.812772+00	2026-10-29 16:01:42.461252+00
efdd9c25-37cd-4779-9169-a22c1c6e3db1	ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	f40a1175-dd94-41fe-91ea-c37c38311959	97e3b2bc-465f-4b78-ba46-239f3e13d0fb	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-19 13:05:13.812827+00	t	2026-10-19 13:05:13.812829+00	2026-10-29 16:01:42.461252+00
f08a742c-d90e-4c5e-b864-de759277a8a5	42752736-29eb-4bb9-acb1-3e97da7f4e75	f40a1175-dd94-41fe-91ea-c37c38311959	62c09057-f843-4054-bc13-ecf4b6c351be	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-17 13:05:13.812677+00	t	2026-10-19 13:05:13.812678+00	2026-10-29 16:01:42.461252+00
a6f2727c-f922-4ef1-8e24-0e60c80f6860	bb4d08cb-a413-4ebc-bc60-57367cb32ae6	f40a1175-dd94-41fe-91ea-c37c38311959	0bcae85a-ccbf-48b3-a748-97ebbc29d344	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-02 13:05:13.812738+00	t	2026-10-19 13:05:13.812741+00	2026-10-29 16:01:42.461252+00
df4ac06f-12a6-4ed9-9b55-d7475ff7b6b4	4e189bda-9dd0-45fb-942f-ab44012cc9c3	f40a1175-dd94-41fe-91ea-c37c38311959	521ba53c-5207-4e4d-9f8d-f1e902c9af09	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-28 13:05:13.812775+00	t	2026-10-19 13:05:13.812776+00	2026-10-29 16:01:42.461252+00
f4402f74-a0c9-4fe4-8ae8-b6e51db1d381	feed94e7-e87f-421f-b36a-2aa9bfca0052	f40a1175-dd94-41fe-91ea-c37c38311959	c22aa9b7-f206-4ebc-a63b-c702b01b821b	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-30 13:05:13.812671+00	t	2026-10-19 13:05:13.812673+00	2026-10-29 16:01:42.461252+00
bfa571a8-f7f0-4b75-b529-7d423d7862d6	80b54360-b724-4fed-925e-94f4d580a3a4	f40a1175-dd94-41fe-91ea-c37c38311959	855dff6e-2b33-404f-92f8-0903af6784f5	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-09-19 13:05:13.812631+00	t	2026-10-19 13:05:13.812634+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000001	bb996948-4b50-4761-a682-07a3e7a43eba	f40a1175-dd94-41fe-91ea-c37c38311959	521ba53c-5207-4e4d-9f8d-f1e902c9af09	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-04 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000002	c0104b6c-09aa-4500-8a19-e08ab2a023ed	f40a1175-dd94-41fe-91ea-c37c38311959	e8cb0327-35df-46e5-adcd-2eea47f17e6d	CLIENT	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-09 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000003	b97cd7c7-60b4-4f52-82cd-bc56a56648a4	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	\N	CREATOR	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	2026-09-29 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000004	42752736-29eb-4bb9-acb1-3e97da7f4e75	b213cbc7-613c-4a34-8aa1-4876684a1ee9	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-14 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000005	42752736-29eb-4bb9-acb1-3e97da7f4e75	eace4871-7580-4f8e-898a-f7f25a838594	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-15 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000006	bb996948-4b50-4761-a682-07a3e7a43eba	b84cb77d-fb5f-43c9-858b-bb91be0dcf24	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-17 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000007	4e189bda-9dd0-45fb-942f-ab44012cc9c3	1845f16a-9e5e-42e2-82f1-de5f565cb7d2	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
a1000001-0000-4000-8000-000000000008	4e189bda-9dd0-45fb-942f-ab44012cc9c3	3da73a3d-a522-4c48-a293-4338b2969670	\N	CREATOR	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 16:01:42.461252+00	t	2026-10-29 16:01:42.461252+00	2026-10-29 16:01:42.461252+00
\.


--
-- Data for Name: workspace_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_templates (id, agency_id, name, source_workspace_id, config_snapshot, created_by, created_at) FROM stdin;
5e111dba-ddce-4c62-8863-fa9d78f7e29c	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	Heavy Duty Concrete Watch Template	\N	{"phone": "(730) 205-5696", "tagline": "3rd generation", "website": "https://www.normand-macejkovic.info:3880/hic/ab#ipsa", "industry": "FASHION", "location": "Lake Rea", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_201_500", "description": "Open-source systematic migration", "facebookUrl": "https://facebook.com/iusto_laudantium", "foundedYear": 2002, "linkedinUrl": "https://linkedin.com/company/doloremque_molestiae", "instagramUrl": "https://instagram.com/nam_temporibus", "industryFields": {"productCategories": "Áo, Quần, Phụ kiện", "seasonalCollections": "Xuân Hè, Thu Đông"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	2026-10-19 13:05:13.896125+00
bc5ab747-acb4-4e30-9dd7-9b4db5eae25f	\N	Beauty Spa & Salon	\N	{"phone": "(983) 958-1633", "tagline": "collaboration", "website": "https://www.ira-gerhold.net:32643/delectus/molestiaeeum#placeat", "industry": "BEAUTY", "location": "West Eddiefort", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_1_10", "description": "Secured client-server analyzer", "facebookUrl": "https://facebook.com/occaecati_quidem", "foundedYear": 1993, "linkedinUrl": "https://linkedin.com/company/natus_fugit", "instagramUrl": "https://instagram.com/vel_corrupti", "industryFields": {"serviceTypes": "Chăm sóc da, Trang điểm", "certifications": "ISO 22716"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.899328+00
8afeb35a-fe47-4a50-a870-ff3320616316	\N	Beauty Skincare Brand	\N	{"phone": "(983) 354-0461", "tagline": "Function-based", "website": "https://www.dustin-bahringer.info/libero/ut#odit", "industry": "BEAUTY", "location": "Bednarburgh", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_201_500", "description": "Focused motivating alliance", "facebookUrl": "https://facebook.com/ipsa_unde", "foundedYear": 2011, "linkedinUrl": "https://linkedin.com/company/repellat_voluptas", "instagramUrl": "https://instagram.com/alias_beatae", "industryFields": {"serviceTypes": "Chăm sóc da, Trang điểm", "certifications": "ISO 22716"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.900073+00
94ef1266-e3f3-4a5e-913f-29bf34f937cd	\N	Tech Startup SaaS	\N	{"phone": "(730) 242-7583", "tagline": "monitoring", "website": "https://www.jayme-orn.net:10185/ut/tempora", "industry": "TECHNOLOGY", "location": "Mervinside", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_51_200", "description": "Profit-focused tangible knowledge base", "facebookUrl": "https://facebook.com/cum_quos", "foundedYear": 2009, "linkedinUrl": "https://linkedin.com/company/autem_esse", "instagramUrl": "https://instagram.com/ut_odio", "industryFields": {"techStack": "React, Spring Boot", "productType": "SaaS"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.900641+00
818bb6c1-1125-4317-b64b-5af9876cb942	\N	Tech Mobile App	\N	{"phone": "(586) 973-6268", "tagline": "Robust", "website": "https://www.ofelia-wisozk.name:47554/ullam", "industry": "TECHNOLOGY", "location": "South Jaeport", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_500_PLUS", "description": "Pre-emptive cohesive application", "facebookUrl": "https://facebook.com/minus_natus", "foundedYear": 2003, "linkedinUrl": "https://linkedin.com/company/quia_alias", "instagramUrl": "https://instagram.com/perspiciatis_quas", "industryFields": {"techStack": "React, Spring Boot", "productType": "SaaS"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.900979+00
348aba75-9d48-466b-8b89-11cad07ec347	\N	FnB Khởi nghiệp	\N	{"phone": "(458) 833-7185", "tagline": "Cross-group", "website": "http://www.rayna-heaney.biz:20051/rerum#commodi", "industry": "FNB", "location": "North Thaddeusborough", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_51_200", "description": "Seamless hybrid firmware", "facebookUrl": "https://facebook.com/corporis_cupiditate", "foundedYear": 2021, "linkedinUrl": "https://linkedin.com/company/laboriosam_voluptas", "instagramUrl": "https://instagram.com/repellat_molestiae", "industryFields": {"cuisineType": "Chilli con Carne", "seatingCapacity": "28", "deliveryPlatforms": "GrabFood, ShopeeFood"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.904536+00
378e919d-d9ac-4aa7-a5f1-fc37dd740d6c	\N	FnB Chuỗi nhà hàng	\N	{"phone": "(983) 881-3499", "tagline": "coherent", "website": "https://www.mandi-ernser.biz/ea?harum=ut&eos=beatae", "industry": "FNB", "location": "Richardton", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_500_PLUS", "description": "Triple-buffered bifurcated database", "facebookUrl": "https://facebook.com/sed_accusantium", "foundedYear": 2020, "linkedinUrl": "https://linkedin.com/company/inventore_sapiente", "instagramUrl": "https://instagram.com/autem_inventore", "industryFields": {"cuisineType": "Kebab", "seatingCapacity": "70", "deliveryPlatforms": "GrabFood, ShopeeFood"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.904848+00
597a0408-65c9-479d-91de-6852d0d5c8e0	\N	FnB Quán cà phê	\N	{"phone": "(619) 391-2198", "tagline": "architecture", "website": "http://www.buck-klein.com/vitae/ratione#ducimus", "industry": "FNB", "location": "Rodriguezland", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_11_50", "description": "Secured dedicated matrix", "facebookUrl": "https://facebook.com/sunt_voluptas", "foundedYear": 1995, "linkedinUrl": "https://linkedin.com/company/atque_provident", "instagramUrl": "https://instagram.com/laudantium_est", "industryFields": {"cuisineType": "Salmon Nigiri", "seatingCapacity": "87", "deliveryPlatforms": "GrabFood, ShopeeFood"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.905121+00
3d09de7f-9aa3-4db4-a516-166ae4730ee0	\N	Fashion Local Brand	\N	{"phone": "(730) 603-6885", "tagline": "middleware", "website": "http://www.edwardo-muller.com/debitis/atmolestiae?animi=reiciendis&magni=ab", "industry": "FASHION", "location": "Waelchiville", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_11_50", "description": "Organized upward-trending secured line", "facebookUrl": "https://facebook.com/iusto_quae", "foundedYear": 1992, "linkedinUrl": "https://linkedin.com/company/laudantium_officia", "instagramUrl": "https://instagram.com/aut_autem", "industryFields": {"productCategories": "Áo, Quần, Phụ kiện", "seasonalCollections": "Xuân Hè, Thu Đông"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.905437+00
66679f33-a7ac-4c33-aa12-27d4494f4f86	\N	Fashion Boutique	\N	{"phone": "(305) 206-6452", "tagline": "exuding", "website": "https://www.cleo-hilpert.co:14628/", "industry": "FASHION", "location": "New Albertine", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_201_500", "description": "Organic multimedia application", "facebookUrl": "https://facebook.com/sint_illo", "foundedYear": 2021, "linkedinUrl": "https://linkedin.com/company/officia_vitae", "instagramUrl": "https://instagram.com/esse_totam", "industryFields": {"productCategories": "Áo, Quần, Phụ kiện", "seasonalCollections": "Xuân Hè, Thu Đông"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	5f46d7d8-6689-4ece-84f8-39e5de081c5c	2026-10-19 13:05:13.905844+00
\.


--
-- Data for Name: workspaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspaces (id, agency_id, name, created_by, workspace_media_package_id, source_workspace_id, duplication_request_id, duplication_fingerprint, timezone_config, settings, industry, company_size, website, phone, location, description, brand_color, logo_icon, logo_url, banner_url, tagline, founded_year, facebook_url, linkedin_url, instagram_url, status, deleted_at, created_at, updated_at) FROM stdin;
b97cd7c7-60b4-4f52-82cd-bc56a56648a4	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	TH True Milk x Circus Digital	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	8e52e1ff-ce74-4234-a4e0-d90e6ba0a3cf	\N	\N	\N	Asia/Ho_Chi_Minh	{}	HEALTHCARE	SIZE_201_500	https://www.deangelo-gerlach.com:26996/odio/modi?dolore=exercitationem&itaque=eos#veritatis	\N	Lake Tristatown	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.665789+00	2026-10-19 13:05:12.845416+00
68b29a5c-4518-47f9-aea7-8c33235ee85c	1fb7ed01-a9d4-4373-afb4-3ac8c47afde5	The Coffee House x Circus Digital	56a8c930-e8d4-4a6b-8bc9-fe58b4994b40	bc3febaa-0a5e-456e-b12b-aa3781d83722	\N	\N	\N	Asia/Ho_Chi_Minh	{}	TECHNOLOGY	SIZE_500_PLUS	https://www.denis-schroeder.name/#molestias	\N	Cruickshankville	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.666928+00	2026-10-19 13:05:12.845416+00
ef3b84a4-0a92-4f6a-a2b7-8b08891aebe7	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	Coca-Cola x Saatchi & Saatchi Vietnam	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c6c39106-4100-440e-963a-c5a18dbaf661	\N	\N	\N	Asia/Ho_Chi_Minh	{}	REAL_ESTATE	SIZE_500_PLUS	http://www.britney-vonrueden.io/explicabo/excepturi?vitae=doloribus&quam=quasi#perspiciatis	\N	Debbyville	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.66705+00	2026-10-19 13:05:12.845416+00
42752736-29eb-4bb9-acb1-3e97da7f4e75	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	The Coffee House x Saatchi & Saatchi Vietnam	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c3000002-0000-4000-8000-000000000001	\N	\N	\N	Asia/Ho_Chi_Minh	{}	REAL_ESTATE	SIZE_1_10	http://www.rebbecca-orn.name:31720/cum/etquae#incidunt	\N	Doyleland	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.6663+00	2026-10-29 16:01:42.461252+00
4e189bda-9dd0-45fb-942f-ab44012cc9c3	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	FPT Shop x Yeah1 Network	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c3000002-0000-4000-8000-000000000002	\N	\N	\N	Asia/Ho_Chi_Minh	{}	OTHER	SIZE_51_200	https://www.rodger-mante.net:13535/?nemo=veniam&omnis=odit	\N	New Berry	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.666973+00	2026-10-29 16:01:42.461252+00
80b54360-b724-4fed-925e-94f4d580a3a4	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	Sabeco x Yeah1 Network	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c3000002-0000-4000-8000-000000000003	\N	\N	\N	Asia/Ho_Chi_Minh	{}	OTHER	SIZE_51_200	https://www.ralph-stroman.biz:46047/voluptatem/dignissimosquasi	\N	New Ionefort	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.666027+00	2026-10-29 16:01:42.461252+00
bb4d08cb-a413-4ebc-bc60-57367cb32ae6	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	Vietjet Air x Saatchi & Saatchi Vietnam	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c3000002-0000-4000-8000-000000000004	\N	\N	\N	Asia/Ho_Chi_Minh	{}	REAL_ESTATE	SIZE_51_200	https://www.waltraud-stoltenberg.io:19942/ab/laudantium?autem=amet&officia=perferendis#error	\N	Botsfordton	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.666848+00	2026-10-29 16:01:42.461252+00
bb996948-4b50-4761-a682-07a3e7a43eba	5a4f221b-1350-4421-b060-d0eb7ccaf94d	FPT Shop x AIM Academy	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c3000002-0000-4000-8000-000000000005	\N	\N	\N	Asia/Ho_Chi_Minh	{}	EDUCATION	SIZE_11_50	https://www.jonnie-bahringer.io/?occaecati=quibusdam&ut=officia#minus	\N	Dustinview	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.666627+00	2026-10-29 16:01:42.461252+00
c0104b6c-09aa-4500-8a19-e08ab2a023ed	1aa8ef6d-ba61-4c16-a319-3ee9e39dfc76	Sunhouse x Saatchi & Saatchi Vietnam	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c3000002-0000-4000-8000-000000000006	\N	\N	\N	Asia/Ho_Chi_Minh	{}	TECHNOLOGY	SIZE_1_10	https://www.robbie-hane.co:9560/voluptatem/atquelabore#officia	\N	Dariusside	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.667017+00	2026-10-29 16:01:42.461252+00
feed94e7-e87f-421f-b36a-2aa9bfca0052	1cb9a40d-7bd8-4096-91aa-d1411cdc961b	P&G x Yeah1 Network	dbdc427b-e39f-4cdd-b7c2-1de84fec003f	c3000002-0000-4000-8000-000000000007	\N	\N	\N	Asia/Ho_Chi_Minh	{}	EDUCATION	SIZE_51_200	https://www.enriqueta-ruecker.io/molestiae?modi=id&iusto=dolorum#error	\N	Port Lucinaborough	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-19 13:05:13.666103+00	2026-10-29 16:01:42.461252+00
\.


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 271, true);


--
-- Name: account_activation_tokens account_activation_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_pkey PRIMARY KEY (id);


--
-- Name: account_activation_tokens account_activation_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: admin_account_operations admin_account_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_account_operations
    ADD CONSTRAINT admin_account_operations_pkey PRIMARY KEY (user_id, operation_id);


--
-- Name: admin_email_outbox admin_email_outbox_event_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_email_outbox
    ADD CONSTRAINT admin_email_outbox_event_key_key UNIQUE (event_key);


--
-- Name: admin_email_outbox admin_email_outbox_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_email_outbox
    ADD CONSTRAINT admin_email_outbox_pkey PRIMARY KEY (id);


--
-- Name: admin_notifications admin_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_notifications
    ADD CONSTRAINT admin_notifications_pkey PRIMARY KEY (id);


--
-- Name: admin_report_exports admin_report_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_report_exports
    ADD CONSTRAINT admin_report_exports_pkey PRIMARY KEY (id);


--
-- Name: agencies agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: agency_creator_credit_limits agency_creator_credit_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_creator_credit_limits
    ADD CONSTRAINT agency_creator_credit_limits_pkey PRIMARY KEY (agency_id, creator_id);


--
-- Name: agency_credit_wallets agency_credit_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_credit_wallets
    ADD CONSTRAINT agency_credit_wallets_pkey PRIMARY KEY (agency_id);


--
-- Name: agency_drive_connections agency_drive_connections_connection_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_drive_connections
    ADD CONSTRAINT agency_drive_connections_connection_id_key UNIQUE (connection_id);


--
-- Name: agency_drive_connections agency_drive_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_drive_connections
    ADD CONSTRAINT agency_drive_connections_pkey PRIMARY KEY (agency_id);


--
-- Name: agency_invitations agency_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_pkey PRIMARY KEY (id);


--
-- Name: agency_invitations agency_invitations_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_token_key UNIQUE (token);


--
-- Name: agency_members agency_members_agency_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_agency_id_user_id_key UNIQUE (agency_id, user_id);


--
-- Name: agency_members agency_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_pkey PRIMARY KEY (id);


--
-- Name: agency_resource_usage agency_resource_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_resource_usage
    ADD CONSTRAINT agency_resource_usage_pkey PRIMARY KEY (agency_id);


--
-- Name: agency_storage_reservations agency_storage_reservations_agency_id_actor_id_request_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_reservations
    ADD CONSTRAINT agency_storage_reservations_agency_id_actor_id_request_key_key UNIQUE (agency_id, actor_id, request_key);


--
-- Name: agency_storage_reservations agency_storage_reservations_material_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_reservations
    ADD CONSTRAINT agency_storage_reservations_material_id_key UNIQUE (material_id);


--
-- Name: agency_storage_reservations agency_storage_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_reservations
    ADD CONSTRAINT agency_storage_reservations_pkey PRIMARY KEY (id);


--
-- Name: agency_storage_usage agency_storage_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_usage
    ADD CONSTRAINT agency_storage_usage_pkey PRIMARY KEY (agency_id);


--
-- Name: agency_subscription_periods agency_subscription_periods_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: agency_subscription_periods agency_subscription_periods_order_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_order_id_key UNIQUE (order_id);


--
-- Name: agency_subscription_periods agency_subscription_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_pkey PRIMARY KEY (id);


--
-- Name: agency_subscription_periods agency_subscription_periods_subscription_id_starts_at_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_subscription_id_starts_at_key UNIQUE (subscription_id, starts_at);


--
-- Name: agency_subscriptions agency_subscriptions_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscriptions
    ADD CONSTRAINT agency_subscriptions_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: agency_subscriptions agency_subscriptions_agency_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscriptions
    ADD CONSTRAINT agency_subscriptions_agency_id_key UNIQUE (agency_id);


--
-- Name: agency_subscriptions agency_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscriptions
    ADD CONSTRAINT agency_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: ai_caption_generations ai_caption_generations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_caption_generations
    ADD CONSTRAINT ai_caption_generations_pkey PRIMARY KEY (id);


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_agency_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_agency_id_creator_id_key UNIQUE (agency_id, creator_id);


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_pkey PRIMARY KEY (id);


--
-- Name: ai_credit_ledgers ai_credit_ledgers_agency_id_month_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_ledgers
    ADD CONSTRAINT ai_credit_ledgers_agency_id_month_key UNIQUE (agency_id, month);


--
-- Name: ai_credit_ledgers ai_credit_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_ledgers
    ADD CONSTRAINT ai_credit_ledgers_pkey PRIMARY KEY (id);


--
-- Name: ai_credit_operation_prices ai_credit_operation_prices_operation_revision_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_operation_prices
    ADD CONSTRAINT ai_credit_operation_prices_operation_revision_key UNIQUE (operation, revision);


--
-- Name: ai_credit_operation_prices ai_credit_operation_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_operation_prices
    ADD CONSTRAINT ai_credit_operation_prices_pkey PRIMARY KEY (id);


--
-- Name: ai_credit_reservations ai_credit_reservations_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_reservations
    ADD CONSTRAINT ai_credit_reservations_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: ai_credit_reservations ai_credit_reservations_job_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_reservations
    ADD CONSTRAINT ai_credit_reservations_job_id_key UNIQUE (job_id);


--
-- Name: ai_credit_reservations ai_credit_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_reservations
    ADD CONSTRAINT ai_credit_reservations_pkey PRIMARY KEY (id);


--
-- Name: ai_credit_usages ai_credit_usages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_usages
    ADD CONSTRAINT ai_credit_usages_pkey PRIMARY KEY (id);


--
-- Name: ai_video_jobs ai_video_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_video_jobs
    ADD CONSTRAINT ai_video_jobs_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: billing_audit_events billing_audit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_audit_events
    ADD CONSTRAINT billing_audit_events_pkey PRIMARY KEY (id);


--
-- Name: billing_migration_reviews billing_migration_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_migration_reviews
    ADD CONSTRAINT billing_migration_reviews_pkey PRIMARY KEY (id);


--
-- Name: billing_migration_reviews billing_migration_reviews_source_table_source_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_migration_reviews
    ADD CONSTRAINT billing_migration_reviews_source_table_source_id_key UNIQUE (source_table, source_id);


--
-- Name: billing_order_fulfillments billing_order_fulfillments_order_id_benefit_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_order_fulfillments
    ADD CONSTRAINT billing_order_fulfillments_order_id_benefit_type_key UNIQUE (order_id, benefit_type);


--
-- Name: billing_order_fulfillments billing_order_fulfillments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_order_fulfillments
    ADD CONSTRAINT billing_order_fulfillments_pkey PRIMARY KEY (id);


--
-- Name: billing_orders billing_orders_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_orders
    ADD CONSTRAINT billing_orders_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: billing_orders billing_orders_agency_id_kind_idempotency_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_orders
    ADD CONSTRAINT billing_orders_agency_id_kind_idempotency_key_key UNIQUE (agency_id, kind, idempotency_key);


--
-- Name: billing_orders billing_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_orders
    ADD CONSTRAINT billing_orders_pkey PRIMARY KEY (id);


--
-- Name: billing_outbox_events billing_outbox_events_event_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_outbox_events
    ADD CONSTRAINT billing_outbox_events_event_key_key UNIQUE (event_key);


--
-- Name: billing_outbox_events billing_outbox_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_outbox_events
    ADD CONSTRAINT billing_outbox_events_pkey PRIMARY KEY (id);


--
-- Name: billing_payment_attempts billing_payment_attempts_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_attempts
    ADD CONSTRAINT billing_payment_attempts_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: billing_payment_attempts billing_payment_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_attempts
    ADD CONSTRAINT billing_payment_attempts_pkey PRIMARY KEY (id);


--
-- Name: billing_payment_attempts billing_payment_attempts_provider_merchant_account_payment__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_attempts
    ADD CONSTRAINT billing_payment_attempts_provider_merchant_account_payment__key UNIQUE (provider, merchant_account, payment_link_id);


--
-- Name: billing_payment_attempts billing_payment_attempts_provider_merchant_account_provider_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_attempts
    ADD CONSTRAINT billing_payment_attempts_provider_merchant_account_provider_key UNIQUE (provider, merchant_account, provider_order_code);


--
-- Name: billing_payment_events billing_payment_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_events
    ADD CONSTRAINT billing_payment_events_pkey PRIMARY KEY (id);


--
-- Name: billing_payment_events billing_payment_events_provider_merchant_account_event_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_events
    ADD CONSTRAINT billing_payment_events_provider_merchant_account_event_key_key UNIQUE (provider, merchant_account, event_key);


--
-- Name: billing_payments billing_payments_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payments
    ADD CONSTRAINT billing_payments_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: billing_payments billing_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payments
    ADD CONSTRAINT billing_payments_pkey PRIMARY KEY (id);


--
-- Name: billing_payments billing_payments_provider_merchant_account_provider_referen_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payments
    ADD CONSTRAINT billing_payments_provider_merchant_account_provider_referen_key UNIQUE (provider, merchant_account, provider_reference);


--
-- Name: billing_plan_versions billing_plan_versions_code_version_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_plan_versions
    ADD CONSTRAINT billing_plan_versions_code_version_key UNIQUE (code, version);


--
-- Name: billing_plan_versions billing_plan_versions_id_scope_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_plan_versions
    ADD CONSTRAINT billing_plan_versions_id_scope_key UNIQUE (id, billing_scope);


--
-- Name: billing_plan_versions billing_plan_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_plan_versions
    ADD CONSTRAINT billing_plan_versions_pkey PRIMARY KEY (id);


--
-- Name: brandhub_schema_migrations brandhub_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brandhub_schema_migrations
    ADD CONSTRAINT brandhub_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: campaign_collaborators campaign_collaborators_media_campaign_id_collaborator_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_media_campaign_id_collaborator_id_key UNIQUE (media_campaign_id, collaborator_id);


--
-- Name: campaign_collaborators campaign_collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_pkey PRIMARY KEY (id);


--
-- Name: campaign_deployments campaign_deployments_campaign_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_campaign_id_key UNIQUE (campaign_id);


--
-- Name: campaign_deployments campaign_deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_pkey PRIMARY KEY (id);


--
-- Name: campaign_review_events campaign_review_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_review_events
    ADD CONSTRAINT campaign_review_events_pkey PRIMARY KEY (id);


--
-- Name: campaign_versions campaign_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT campaign_versions_pkey PRIMARY KEY (id);


--
-- Name: client_profiles client_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_profiles
    ADD CONSTRAINT client_profiles_pkey PRIMARY KEY (id);


--
-- Name: content_moderation_reviews content_moderation_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT content_moderation_reviews_pkey PRIMARY KEY (id);


--
-- Name: content_request_completion_jobs content_request_completion_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_request_completion_jobs
    ADD CONSTRAINT content_request_completion_jobs_pkey PRIMARY KEY (campaign_id);


--
-- Name: creator_credit_usage creator_credit_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creator_credit_usage
    ADD CONSTRAINT creator_credit_usage_pkey PRIMARY KEY (agency_id, creator_id, period_id);


--
-- Name: credit_entries credit_entries_operation_id_grant_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_entries
    ADD CONSTRAINT credit_entries_operation_id_grant_id_key UNIQUE (operation_id, grant_id);


--
-- Name: credit_entries credit_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_entries
    ADD CONSTRAINT credit_entries_pkey PRIMARY KEY (id);


--
-- Name: credit_grants credit_grants_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_grants
    ADD CONSTRAINT credit_grants_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: credit_grants credit_grants_agency_id_source_type_source_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_grants
    ADD CONSTRAINT credit_grants_agency_id_source_type_source_key_key UNIQUE (agency_id, source_type, source_key);


--
-- Name: credit_grants credit_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_grants
    ADD CONSTRAINT credit_grants_pkey PRIMARY KEY (id);


--
-- Name: credit_operations credit_operations_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_operations
    ADD CONSTRAINT credit_operations_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: credit_operations credit_operations_agency_id_operation_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_operations
    ADD CONSTRAINT credit_operations_agency_id_operation_key_key UNIQUE (agency_id, operation_key);


--
-- Name: credit_operations credit_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_operations
    ADD CONSTRAINT credit_operations_pkey PRIMARY KEY (id);


--
-- Name: credit_reservation_allocations credit_reservation_allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_reservation_allocations
    ADD CONSTRAINT credit_reservation_allocations_pkey PRIMARY KEY (reservation_id, grant_id);


--
-- Name: credit_usage_periods credit_usage_periods_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_usage_periods
    ADD CONSTRAINT credit_usage_periods_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: credit_usage_periods credit_usage_periods_agency_id_starts_at_kind_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_usage_periods
    ADD CONSTRAINT credit_usage_periods_agency_id_starts_at_kind_key UNIQUE (agency_id, starts_at, kind);


--
-- Name: credit_usage_periods credit_usage_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_usage_periods
    ADD CONSTRAINT credit_usage_periods_pkey PRIMARY KEY (id);


--
-- Name: mail_attachments mail_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_attachments
    ADD CONSTRAINT mail_attachments_pkey PRIMARY KEY (id);


--
-- Name: mail_batches mail_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_batches
    ADD CONSTRAINT mail_batches_pkey PRIMARY KEY (id);


--
-- Name: mail_deliveries mail_deliveries_event_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_deliveries
    ADD CONSTRAINT mail_deliveries_event_key_key UNIQUE (event_key);


--
-- Name: mail_deliveries mail_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_deliveries
    ADD CONSTRAINT mail_deliveries_pkey PRIMARY KEY (id);


--
-- Name: mail_send_quota mail_send_quota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_send_quota
    ADD CONSTRAINT mail_send_quota_pkey PRIMARY KEY (day, scope, scope_id);


--
-- Name: mail_suppressions mail_suppressions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_suppressions
    ADD CONSTRAINT mail_suppressions_pkey PRIMARY KEY (id);


--
-- Name: mail_suppressions mail_suppressions_workspace_id_email_lower_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_suppressions
    ADD CONSTRAINT mail_suppressions_workspace_id_email_lower_key UNIQUE (workspace_id, email_lower);


--
-- Name: material_audit_receipts material_audit_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_audit_receipts
    ADD CONSTRAINT material_audit_receipts_pkey PRIMARY KEY (event_id);


--
-- Name: material_quota_releases material_quota_releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_quota_releases
    ADD CONSTRAINT material_quota_releases_pkey PRIMARY KEY (material_id);


--
-- Name: media_campaigns media_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_campaigns
    ADD CONSTRAINT media_campaigns_pkey PRIMARY KEY (id);


--
-- Name: media_packages media_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT media_packages_pkey PRIMARY KEY (id);


--
-- Name: monitoring_collectors monitoring_collectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_collectors
    ADD CONSTRAINT monitoring_collectors_pkey PRIMARY KEY (id);


--
-- Name: monitoring_enrollments monitoring_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_enrollments
    ADD CONSTRAINT monitoring_enrollments_pkey PRIMARY KEY (token_hash);


--
-- Name: monitoring_health_results monitoring_health_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_results
    ADD CONSTRAINT monitoring_health_results_pkey PRIMARY KEY (target_id);


--
-- Name: monitoring_health_targets monitoring_health_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT monitoring_health_targets_pkey PRIMARY KEY (id);


--
-- Name: monitoring_servers monitoring_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_servers
    ADD CONSTRAINT monitoring_servers_pkey PRIMARY KEY (id);


--
-- Name: package_negotiation_events package_negotiation_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_negotiation_events
    ADD CONSTRAINT package_negotiation_events_pkey PRIMARY KEY (id);


--
-- Name: package_negotiation_events package_negotiation_events_workspace_media_package_id_terms_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_negotiation_events
    ADD CONSTRAINT package_negotiation_events_workspace_media_package_id_terms_key UNIQUE (workspace_media_package_id, terms_version);


--
-- Name: repository_drive_generations repository_drive_generations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_generations
    ADD CONSTRAINT repository_drive_generations_pkey PRIMARY KEY (agency_id);


--
-- Name: repository_drive_objects repository_drive_objects_file_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_objects
    ADD CONSTRAINT repository_drive_objects_file_id_key UNIQUE (file_id);


--
-- Name: repository_drive_objects repository_drive_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_objects
    ADD CONSTRAINT repository_drive_objects_pkey PRIMARY KEY (object_key);


--
-- Name: repository_drive_operations repository_drive_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_operations
    ADD CONSTRAINT repository_drive_operations_pkey PRIMARY KEY (agency_id);


--
-- Name: repository_drive_states repository_drive_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_states
    ADD CONSTRAINT repository_drive_states_pkey PRIMARY KEY (state_hash);


--
-- Name: sanction_reviews sanction_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sanction_reviews
    ADD CONSTRAINT sanction_reviews_pkey PRIMARY KEY (id);


--
-- Name: seed_runs seed_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seed_runs
    ADD CONSTRAINT seed_runs_pkey PRIMARY KEY (dataset, dataset_version);


--
-- Name: seed_runs seed_runs_run_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seed_runs
    ADD CONSTRAINT seed_runs_run_id_key UNIQUE (run_id);


--
-- Name: storage_objects storage_objects_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: storage_objects storage_objects_backend_bucket_object_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_backend_bucket_object_key_key UNIQUE (backend, bucket, object_key);


--
-- Name: storage_objects storage_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_pkey PRIMARY KEY (id);


--
-- Name: storage_reservations storage_reservations_agency_id_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_reservations
    ADD CONSTRAINT storage_reservations_agency_id_id_key UNIQUE (agency_id, id);


--
-- Name: storage_reservations storage_reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_reservations
    ADD CONSTRAINT storage_reservations_pkey PRIMARY KEY (id);


--
-- Name: storage_reservations storage_reservations_upload_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_reservations
    ADD CONSTRAINT storage_reservations_upload_id_key UNIQUE (upload_id);


--
-- Name: storage_usage_entries storage_usage_entries_operation_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_usage_entries
    ADD CONSTRAINT storage_usage_entries_operation_key_key UNIQUE (operation_key);


--
-- Name: storage_usage_entries storage_usage_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_usage_entries
    ADD CONSTRAINT storage_usage_entries_pkey PRIMARY KEY (id);


--
-- Name: subscription_observation_jobs subscription_observation_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_observation_jobs
    ADD CONSTRAINT subscription_observation_jobs_pkey PRIMARY KEY (name);


--
-- Name: subscription_operational_issues subscription_operational_issues_fingerprint_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_operational_issues
    ADD CONSTRAINT subscription_operational_issues_fingerprint_key UNIQUE (fingerprint);


--
-- Name: subscription_operational_issues subscription_operational_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_operational_issues
    ADD CONSTRAINT subscription_operational_issues_pkey PRIMARY KEY (id);


--
-- Name: subscription_plan_changes subscription_plan_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_pkey PRIMARY KEY (id);


--
-- Name: subscription_plans subscription_plans_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_name_key UNIQUE (name);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: subscription_provider_checks subscription_provider_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_provider_checks
    ADD CONSTRAINT subscription_provider_checks_pkey PRIMARY KEY (order_id);


--
-- Name: system_storage_pools system_storage_pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_storage_pools
    ADD CONSTRAINT system_storage_pools_pkey PRIMARY KEY (provider);


--
-- Name: task_content_operations task_content_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_operations
    ADD CONSTRAINT task_content_operations_pkey PRIMARY KEY (id);


--
-- Name: task_content_operations task_content_operations_task_id_sequence_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_operations
    ADD CONSTRAINT task_content_operations_task_id_sequence_number_key UNIQUE (task_id, sequence_number);


--
-- Name: task_content_snapshots task_content_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_snapshots
    ADD CONSTRAINT task_content_snapshots_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: third_party_collaborators third_party_collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.third_party_collaborators
    ADD CONSTRAINT third_party_collaborators_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_payos_tx_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_payos_tx_id_key UNIQUE (payos_tx_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: campaign_versions ukk0pnt9rnkhmegtd08lnloiscq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT ukk0pnt9rnkhmegtd08lnloiscq UNIQUE (campaign_id, content_version);


--
-- Name: campaign_versions uq_campaign_versions_campaign_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT uq_campaign_versions_campaign_version UNIQUE (campaign_id, content_version);


--
-- Name: content_moderation_reviews uq_moderation_post_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT uq_moderation_post_version UNIQUE (post_id, content_version);


--
-- Name: monitoring_health_targets uq_monitoring_target_collector; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT uq_monitoring_target_collector UNIQUE (id, collector_id);


--
-- Name: user_notifications uq_user_notification; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT uq_user_notification UNIQUE (notification_id, user_id);


--
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- Name: user_oauth_providers user_oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_oauth_providers
    ADD CONSTRAINT user_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: user_oauth_providers user_oauth_providers_provider_provider_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_oauth_providers
    ADD CONSTRAINT user_oauth_providers_provider_provider_id_key UNIQUE (provider, provider_id);


--
-- Name: user_refresh_tokens user_refresh_tokens_jti_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_jti_key UNIQUE (jti);


--
-- Name: user_refresh_tokens user_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: user_refresh_tokens user_refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: user_strikes user_strikes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_pkey PRIMARY KEY (id);


--
-- Name: user_subscriptions user_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_subscriptions user_subscriptions_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_key UNIQUE (user_id);


--
-- Name: user_system_roles user_system_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_pkey PRIMARY KEY (id);


--
-- Name: user_system_roles user_system_roles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_user_id_key UNIQUE (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workspace_credit_limits workspace_credit_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_credit_limits
    ADD CONSTRAINT workspace_credit_limits_pkey PRIMARY KEY (agency_id, workspace_id);


--
-- Name: workspace_credit_usage workspace_credit_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_credit_usage
    ADD CONSTRAINT workspace_credit_usage_pkey PRIMARY KEY (agency_id, workspace_id, period_id);


--
-- Name: workspace_drive_folders workspace_drive_folders_agency_id_ordinal_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_drive_folders
    ADD CONSTRAINT workspace_drive_folders_agency_id_ordinal_key UNIQUE (agency_id, ordinal);


--
-- Name: workspace_drive_folders workspace_drive_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_drive_folders
    ADD CONSTRAINT workspace_drive_folders_pkey PRIMARY KEY (workspace_id);


--
-- Name: workspace_hashtags workspace_hashtags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_pkey PRIMARY KEY (id);


--
-- Name: workspace_invitations workspace_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_pkey PRIMARY KEY (id);


--
-- Name: workspace_invitations workspace_invitations_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_token_key UNIQUE (token);


--
-- Name: workspace_invitations workspace_invitations_workspace_id_invited_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_workspace_id_invited_email_key UNIQUE (workspace_id, invited_email);


--
-- Name: workspace_media_packages workspace_media_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_pkey PRIMARY KEY (id);


--
-- Name: workspace_media_packages workspace_media_packages_workspace_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_workspace_id_key UNIQUE (workspace_id);


--
-- Name: workspace_members workspace_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_pkey PRIMARY KEY (id);


--
-- Name: workspace_templates workspace_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: idx_activation_tokens_open; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activation_tokens_open ON public.account_activation_tokens USING btree (user_id) WHERE ((used_at IS NULL) AND (revoked_at IS NULL));


--
-- Name: idx_admin_email_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_email_due ON public.admin_email_outbox USING btree (next_attempt_at) WHERE (sent_at IS NULL);


--
-- Name: idx_admin_email_outbox_notification; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_email_outbox_notification ON public.admin_email_outbox USING btree (notification_id) WHERE (notification_id IS NOT NULL);


--
-- Name: idx_admin_notifications_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_notifications_due ON public.admin_notifications USING btree (scheduled_at) WHERE ((status)::text = 'SCHEDULED'::text);


--
-- Name: idx_admin_notifications_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_notifications_history ON public.admin_notifications USING btree (created_at DESC, id DESC);


--
-- Name: idx_admin_report_exports_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_report_exports_expiry ON public.admin_report_exports USING btree (expires_at) WHERE (content IS NOT NULL);


--
-- Name: idx_agencies_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agencies_owner_id ON public.agencies USING btree (owner_id);


--
-- Name: idx_agency_inv_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agency_inv_agency_id ON public.agency_invitations USING btree (agency_id);


--
-- Name: idx_agency_inv_unique_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_agency_inv_unique_pending ON public.agency_invitations USING btree (agency_id, invited_email) WHERE (status = 'PENDING'::public.invitation_status);


--
-- Name: idx_agency_members_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agency_members_agency_id ON public.agency_members USING btree (agency_id);


--
-- Name: idx_agency_sub_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agency_sub_due ON public.agency_subscriptions USING btree (current_period_end) WHERE (current_period_end IS NOT NULL);


--
-- Name: idx_ai_caption_generations_task; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_caption_generations_task ON public.ai_caption_generations USING btree (task_id) WHERE (task_id IS NOT NULL);


--
-- Name: idx_ai_caption_generations_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_caption_generations_workspace ON public.ai_caption_generations USING btree (workspace_id, created_at DESC);


--
-- Name: idx_ai_credit_usages_agency_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_credit_usages_agency_month ON public.ai_credit_usages USING btree (agency_id, month);


--
-- Name: idx_ai_credit_usages_user_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_credit_usages_user_month ON public.ai_credit_usages USING btree (user_id, agency_id, month) WHERE (refunded_at IS NULL);


--
-- Name: idx_ai_reservation_reconcile; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_reservation_reconcile ON public.ai_credit_reservations USING btree (deadline) WHERE (status = ANY (ARRAY['RESERVED'::text, 'UNKNOWN'::text]));


--
-- Name: idx_ai_video_jobs_open; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_video_jobs_open ON public.ai_video_jobs USING btree (created_at) WHERE ((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PROCESSING'::character varying])::text[]));


--
-- Name: idx_ai_video_jobs_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ai_video_jobs_workspace ON public.ai_video_jobs USING btree (workspace_id, created_at DESC);


--
-- Name: idx_audit_agency_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_agency_time ON public.audit_logs USING btree (agency_id, created_at DESC);


--
-- Name: idx_audit_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_resource ON public.audit_logs USING btree (resource_type, resource_id);


--
-- Name: idx_audit_user_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_user_time ON public.audit_logs USING btree (user_id, created_at DESC);


--
-- Name: idx_billing_orders_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_orders_history ON public.billing_orders USING btree (agency_id, created_at DESC, id);


--
-- Name: idx_billing_outbox_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_outbox_due ON public.billing_outbox_events USING btree (available_at, id) WHERE (published_at IS NULL);


--
-- Name: idx_campaign_deployments_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_campaign_deployments_status_created ON public.campaign_deployments USING btree (status, created_at);


--
-- Name: idx_campaign_review_events_campaign_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_campaign_review_events_campaign_created ON public.campaign_review_events USING btree (campaign_id, created_at DESC);


--
-- Name: idx_client_profiles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_client_profiles_user_id ON public.client_profiles USING btree (user_id);


--
-- Name: idx_collaborators_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_collaborators_agency_id ON public.third_party_collaborators USING btree (agency_id);


--
-- Name: idx_content_req_completion_jobs_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_req_completion_jobs_created ON public.content_request_completion_jobs USING btree (created_at);


--
-- Name: idx_credit_entries_agency_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_entries_agency_time ON public.credit_entries USING btree (agency_id, created_at, id);


--
-- Name: idx_credit_video_reconciliation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_credit_video_reconciliation ON public.ai_credit_reservations USING btree (execution_updated_at) WHERE (((execution_state)::text = 'WAITING'::text) AND (status = ANY (ARRAY['RESERVED'::text, 'UNKNOWN'::text])));


--
-- Name: idx_grant_spend; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_grant_spend ON public.credit_grants USING btree (agency_id, expires_at, id) WHERE (available > 0);


--
-- Name: idx_mail_attachments_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_attachments_workspace ON public.mail_attachments USING btree (workspace_id, bound, created_at);


--
-- Name: idx_mail_batches_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_batches_due ON public.mail_batches USING btree (status, scheduled_at);


--
-- Name: idx_mail_batches_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_batches_workspace ON public.mail_batches USING btree (workspace_id, created_at DESC);


--
-- Name: idx_mail_deliveries_batch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_deliveries_batch ON public.mail_deliveries USING btree (batch_id);


--
-- Name: idx_mail_deliveries_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_deliveries_due ON public.mail_deliveries USING btree (status, next_attempt_at);


--
-- Name: idx_material_releases_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_material_releases_date ON public.material_quota_releases USING btree (released_at);


--
-- Name: idx_media_campaigns_wmp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_campaigns_wmp_id ON public.media_campaigns USING btree (workspace_media_package_id);


--
-- Name: idx_media_packages_agency_available; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_packages_agency_available ON public.media_packages USING btree (agency_id, is_available_to_workspaces) WHERE (NOT is_template);


--
-- Name: idx_media_packages_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_packages_agency_id ON public.media_packages USING btree (agency_id);


--
-- Name: idx_media_packages_is_template; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_packages_is_template ON public.media_packages USING btree (is_template);


--
-- Name: idx_moderation_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_moderation_author ON public.content_moderation_reviews USING btree (author_id);


--
-- Name: idx_moderation_queue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_moderation_queue ON public.content_moderation_reviews USING btree (status, created_at, id);


--
-- Name: idx_monitoring_collectors_server; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_collectors_server ON public.monitoring_collectors USING btree (server_id);


--
-- Name: idx_monitoring_enrollments_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_enrollments_expiry ON public.monitoring_enrollments USING btree (expires_at);


--
-- Name: idx_monitoring_servers_environment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_servers_environment ON public.monitoring_servers USING btree (environment, name, id);


--
-- Name: idx_monitoring_targets_collector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_collector ON public.monitoring_health_targets USING btree (collector_id);


--
-- Name: idx_monitoring_targets_environment_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_environment_kind ON public.monitoring_health_targets USING btree (environment, kind);


--
-- Name: idx_monitoring_targets_server; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_server ON public.monitoring_health_targets USING btree (server_id);


--
-- Name: idx_monitoring_targets_service; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_service ON public.monitoring_health_targets USING btree (environment, service_name, instance_id);


--
-- Name: idx_oauth_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauth_user_id ON public.user_oauth_providers USING btree (user_id);


--
-- Name: idx_package_negotiation_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_negotiation_history ON public.package_negotiation_events USING btree (workspace_media_package_id, terms_version DESC);


--
-- Name: idx_rt_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rt_expires_at ON public.user_refresh_tokens USING btree (expires_at);


--
-- Name: idx_rt_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rt_user_id ON public.user_refresh_tokens USING btree (user_id);


--
-- Name: idx_sanction_one_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_sanction_one_pending ON public.sanction_reviews USING btree (user_id) WHERE ((status)::text = 'PENDING'::text);


--
-- Name: idx_storage_agency_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_storage_agency_status ON public.storage_objects USING btree (agency_id, status);


--
-- Name: idx_storage_entries_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_storage_entries_scope ON public.storage_usage_entries USING btree (agency_id, workspace_id);


--
-- Name: idx_storage_res_agency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_storage_res_agency ON public.agency_storage_reservations USING btree (agency_id, state);


--
-- Name: idx_storage_res_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_storage_res_expiry ON public.agency_storage_reservations USING btree (state, expires_at);


--
-- Name: idx_subscription_issues_open; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscription_issues_open ON public.subscription_operational_issues USING btree (status, id);


--
-- Name: idx_subscription_issues_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscription_issues_subject ON public.subscription_operational_issues USING btree (detector, subject_key, status);


--
-- Name: idx_subscription_provider_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subscription_provider_due ON public.subscription_provider_checks USING btree (next_check_at, order_id);


--
-- Name: idx_task_content_operations_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_content_operations_task_id ON public.task_content_operations USING btree (task_id);


--
-- Name: idx_task_content_snapshots_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_content_snapshots_task_id ON public.task_content_snapshots USING btree (task_id, sequence_number DESC);


--
-- Name: idx_tasks_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tasks_workspace_id ON public.tasks USING btree (workspace_id);


--
-- Name: idx_transactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transactions_user_id ON public.transactions USING btree (user_id);


--
-- Name: idx_user_notifications_inbox; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_notifications_inbox ON public.user_notifications USING btree (user_id, created_at DESC, id DESC);


--
-- Name: idx_user_notifications_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_notifications_unread ON public.user_notifications USING btree (user_id) WHERE (read_at IS NULL);


--
-- Name: idx_user_strikes_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_strikes_history ON public.user_strikes USING btree (user_id, created_at DESC, id DESC);


--
-- Name: idx_user_strikes_live; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_strikes_live ON public.user_strikes USING btree (user_id, expires_at) WHERE (removed_at IS NULL);


--
-- Name: idx_user_sub_status_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sub_status_period ON public.user_subscriptions USING btree (status, current_period_end);


--
-- Name: idx_users_clean_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_clean_period ON public.users USING btree (clean_period_ends_at) WHERE (clean_period_ends_at IS NOT NULL);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_reactivate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_reactivate ON public.users USING btree (reactivate_at) WHERE (reactivate_at IS NOT NULL);


--
-- Name: idx_wm_one_manager; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_wm_one_manager ON public.workspace_members USING btree (workspace_id) WHERE ((role = 'MANAGER'::public.workspace_member_role) AND (is_active = true));


--
-- Name: idx_wm_unique_client; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_wm_unique_client ON public.workspace_members USING btree (workspace_id, client_profile_id) WHERE (client_profile_id IS NOT NULL);


--
-- Name: idx_wm_unique_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_wm_unique_user ON public.workspace_members USING btree (workspace_id, user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_wm_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wm_workspace_id ON public.workspace_members USING btree (workspace_id);


--
-- Name: idx_workspace_credit_actor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_credit_actor ON public.ai_credit_reservations USING btree (agency_id, actor_id, created_at DESC);


--
-- Name: idx_workspace_credit_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_credit_period ON public.ai_credit_reservations USING btree (agency_id, workspace_id, period_id);


--
-- Name: idx_workspace_inv_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_inv_workspace_id ON public.workspace_invitations USING btree (workspace_id);


--
-- Name: idx_workspace_templates_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_templates_agency_id ON public.workspace_templates USING btree (agency_id);


--
-- Name: idx_workspaces_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspaces_agency_id ON public.workspaces USING btree (agency_id);


--
-- Name: idx_workspaces_source_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspaces_source_workspace ON public.workspaces USING btree (source_workspace_id) WHERE (source_workspace_id IS NOT NULL);


--
-- Name: ix_customer_drive_account; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_customer_drive_account ON public.agency_drive_connections USING btree (account_id);


--
-- Name: ix_customer_drive_state_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_customer_drive_state_expiry ON public.repository_drive_states USING btree (expires_at);


--
-- Name: ix_storage_provider_capacity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_storage_provider_capacity ON public.agency_storage_reservations USING btree (agency_id, provider, state);


--
-- Name: ix_workspace_hashtags_list; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_workspace_hashtags_list ON public.workspace_hashtags USING btree (workspace_id, created_at DESC, id DESC) WHERE (deleted_at IS NULL);


--
-- Name: uq_ai_video_jobs_reservation; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_ai_video_jobs_reservation ON public.ai_video_jobs USING btree (reservation_id) WHERE (reservation_id IS NOT NULL);


--
-- Name: uq_credit_period_once; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_credit_period_once ON public.credit_grants USING btree (period_id) WHERE (source_type = 'PERIOD'::text);


--
-- Name: uq_credit_provider_job; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_credit_provider_job ON public.ai_credit_reservations USING btree (provider_job_id) WHERE (provider_job_id IS NOT NULL);


--
-- Name: uq_credit_topup_once; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_credit_topup_once ON public.credit_grants USING btree (order_id) WHERE (source_type = 'TOPUP'::text);


--
-- Name: uq_credit_trial_once; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_credit_trial_once ON public.credit_grants USING btree (trial_owner_id, source_key) WHERE (source_type = 'TRIAL'::text);


--
-- Name: uq_mail_suppressions_agency_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_mail_suppressions_agency_email ON public.mail_suppressions USING btree (agency_id, email_lower) WHERE (agency_id IS NOT NULL);


--
-- Name: uq_mail_suppressions_system_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_mail_suppressions_system_email ON public.mail_suppressions USING btree (email_lower) WHERE ((workspace_id IS NULL) AND (agency_id IS NULL));


--
-- Name: uq_media_campaigns_agreement; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_media_campaigns_agreement ON public.media_campaigns USING btree (workspace_media_package_id);


--
-- Name: uq_one_current_period; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_one_current_period ON public.agency_subscription_periods USING btree (agency_id) WHERE (status = 'CURRENT'::text);


--
-- Name: uq_one_future_period; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_one_future_period ON public.agency_subscription_periods USING btree (agency_id) WHERE (status = 'FUTURE'::text);


--
-- Name: uq_pending_agency_subscription_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_pending_agency_subscription_order ON public.billing_orders USING btree (agency_id) WHERE ((kind = 'SUBSCRIPTION'::text) AND (status = ANY (ARRAY['PENDING_PAYMENT'::text, 'PAID'::text])));


--
-- Name: uq_plan_change_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_plan_change_pending ON public.subscription_plan_changes USING btree (user_id) WHERE ((status)::text = 'PENDING'::text);


--
-- Name: uq_workspace_credit_allocation_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_workspace_credit_allocation_order ON public.credit_reservation_allocations USING btree (reservation_id, ordinal);


--
-- Name: uq_workspace_credit_request; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_workspace_credit_request ON public.ai_credit_reservations USING btree (agency_id, actor_id, request_key);


--
-- Name: uq_workspace_hashtags_active_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_workspace_hashtags_active_tag ON public.workspace_hashtags USING btree (workspace_id, normalized_tag) WHERE (deleted_at IS NULL);


--
-- Name: uq_workspaces_agency_identity_billing; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_workspaces_agency_identity_billing ON public.workspaces USING btree (agency_id, id);


--
-- Name: uq_workspaces_duplication_request; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_workspaces_duplication_request ON public.workspaces USING btree (agency_id, duplication_request_id) WHERE (duplication_request_id IS NOT NULL);


--
-- Name: billing_audit_events billing_audit_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER billing_audit_immutable BEFORE DELETE OR UPDATE ON public.billing_audit_events FOR EACH ROW EXECUTE FUNCTION public.billing_reject_ledger_mutation();


--
-- Name: billing_audit_events billing_audit_no_truncate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER billing_audit_no_truncate BEFORE TRUNCATE ON public.billing_audit_events FOR EACH STATEMENT EXECUTE FUNCTION public.billing_reject_ledger_mutation();


--
-- Name: agency_subscription_periods billing_period_overlap; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER billing_period_overlap BEFORE INSERT OR UPDATE ON public.agency_subscription_periods FOR EACH ROW EXECUTE FUNCTION public.billing_guard_period_overlap();


--
-- Name: billing_plan_versions billing_plan_version_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER billing_plan_version_immutable BEFORE DELETE OR UPDATE ON public.billing_plan_versions FOR EACH ROW EXECUTE FUNCTION public.billing_guard_plan_version();


--
-- Name: billing_plan_versions billing_plan_version_no_truncate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER billing_plan_version_no_truncate BEFORE TRUNCATE ON public.billing_plan_versions FOR EACH STATEMENT EXECUTE FUNCTION public.billing_guard_plan_version();


--
-- Name: credit_entries credit_entries_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER credit_entries_immutable BEFORE DELETE OR UPDATE ON public.credit_entries FOR EACH ROW EXECUTE FUNCTION public.billing_reject_ledger_mutation();


--
-- Name: credit_entries credit_entries_no_truncate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER credit_entries_no_truncate BEFORE TRUNCATE ON public.credit_entries FOR EACH STATEMENT EXECUTE FUNCTION public.billing_reject_ledger_mutation();


--
-- Name: credit_operations credit_operations_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER credit_operations_immutable BEFORE DELETE OR UPDATE ON public.credit_operations FOR EACH ROW EXECUTE FUNCTION public.billing_reject_ledger_mutation();


--
-- Name: credit_operations credit_operations_no_truncate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER credit_operations_no_truncate BEFORE TRUNCATE ON public.credit_operations FOR EACH STATEMENT EXECUTE FUNCTION public.billing_reject_ledger_mutation();


--
-- Name: agencies trg_agencies_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_agencies_updated_at BEFORE UPDATE ON public.agencies FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: ai_credit_creator_limits trg_ai_credit_creator_limits_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ai_credit_creator_limits_updated_at BEFORE UPDATE ON public.ai_credit_creator_limits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: ai_credit_ledgers trg_ai_credit_ledgers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ai_credit_ledgers_updated_at BEFORE UPDATE ON public.ai_credit_ledgers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: audit_logs trg_audit_logs_no_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_audit_logs_no_delete BEFORE DELETE ON public.audit_logs FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_log_mutation();


--
-- Name: audit_logs trg_audit_logs_no_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_audit_logs_no_update BEFORE UPDATE ON public.audit_logs FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_log_mutation();


--
-- Name: campaign_collaborators trg_campaign_collaborator_mark_used; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_campaign_collaborator_mark_used BEFORE INSERT ON public.campaign_collaborators FOR EACH ROW EXECUTE FUNCTION public.mark_collaborator_usage_on_link();


--
-- Name: campaign_collaborators trg_campaign_partner_usage; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_campaign_partner_usage BEFORE INSERT OR UPDATE OF collaborator_id ON public.campaign_collaborators FOR EACH ROW EXECUTE FUNCTION public.guard_campaign_partner_usage();


--
-- Name: client_profiles trg_client_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_client_profiles_updated_at BEFORE UPDATE ON public.client_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: third_party_collaborators trg_collaborators_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_collaborators_updated_at BEFORE UPDATE ON public.third_party_collaborators FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: ai_credit_operation_prices trg_credit_price_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_credit_price_history BEFORE DELETE OR UPDATE ON public.ai_credit_operation_prices FOR EACH ROW EXECUTE FUNCTION public.guard_credit_price_history();


--
-- Name: media_campaigns trg_media_campaigns_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_media_campaigns_updated_at BEFORE UPDATE ON public.media_campaigns FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: media_packages trg_media_packages_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_media_packages_updated_at BEFORE UPDATE ON public.media_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: package_negotiation_events trg_package_negotiation_events_append_only; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_package_negotiation_events_append_only BEFORE DELETE OR UPDATE ON public.package_negotiation_events FOR EACH ROW EXECUTE FUNCTION public.protect_package_negotiation_history();


--
-- Name: package_negotiation_events trg_package_negotiation_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_package_negotiation_immutable BEFORE DELETE OR UPDATE ON public.package_negotiation_events FOR EACH ROW EXECUTE FUNCTION public.guard_package_negotiation_history();


--
-- Name: transactions trg_transactions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_transactions_updated_at BEFORE UPDATE ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: user_subscriptions trg_user_subscriptions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_user_subscriptions_updated_at BEFORE UPDATE ON public.user_subscriptions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: users trg_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: workspace_media_packages trg_workspace_media_packages_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_workspace_media_packages_updated_at BEFORE UPDATE ON public.workspace_media_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: workspace_members trg_workspace_members_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_workspace_members_updated_at BEFORE UPDATE ON public.workspace_members FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: workspaces trg_workspaces_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_workspaces_updated_at BEFORE UPDATE ON public.workspaces FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: account_activation_tokens account_activation_tokens_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: account_activation_tokens account_activation_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: admin_account_operations admin_account_operations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_account_operations
    ADD CONSTRAINT admin_account_operations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: admin_email_outbox admin_email_outbox_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_email_outbox
    ADD CONSTRAINT admin_email_outbox_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.admin_notifications(id);


--
-- Name: admin_notifications admin_notifications_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_notifications
    ADD CONSTRAINT admin_notifications_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: admin_report_exports admin_report_exports_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_report_exports
    ADD CONSTRAINT admin_report_exports_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: agencies agencies_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: agency_creator_credit_limits agency_creator_credit_limits_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_creator_credit_limits
    ADD CONSTRAINT agency_creator_credit_limits_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: agency_creator_credit_limits agency_creator_credit_limits_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_creator_credit_limits
    ADD CONSTRAINT agency_creator_credit_limits_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: agency_creator_credit_limits agency_creator_credit_limits_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_creator_credit_limits
    ADD CONSTRAINT agency_creator_credit_limits_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: agency_credit_wallets agency_credit_wallets_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_credit_wallets
    ADD CONSTRAINT agency_credit_wallets_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: agency_drive_connections agency_drive_connections_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_drive_connections
    ADD CONSTRAINT agency_drive_connections_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: agency_drive_connections agency_drive_connections_connected_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_drive_connections
    ADD CONSTRAINT agency_drive_connections_connected_by_fkey FOREIGN KEY (connected_by) REFERENCES public.users(id);


--
-- Name: agency_invitations agency_invitations_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: agency_invitations agency_invitations_invited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: agency_members agency_members_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: agency_members agency_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: agency_resource_usage agency_resource_usage_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_resource_usage
    ADD CONSTRAINT agency_resource_usage_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: agency_storage_reservations agency_storage_reservations_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_reservations
    ADD CONSTRAINT agency_storage_reservations_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: agency_storage_reservations agency_storage_reservations_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_reservations
    ADD CONSTRAINT agency_storage_reservations_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: agency_storage_reservations agency_storage_reservations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_reservations
    ADD CONSTRAINT agency_storage_reservations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: agency_storage_usage agency_storage_usage_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_storage_usage
    ADD CONSTRAINT agency_storage_usage_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: agency_subscription_periods agency_subscription_periods_agency_id_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_agency_id_order_id_fkey FOREIGN KEY (agency_id, order_id) REFERENCES public.billing_orders(agency_id, id) ON DELETE RESTRICT;


--
-- Name: agency_subscription_periods agency_subscription_periods_agency_id_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_agency_id_subscription_id_fkey FOREIGN KEY (agency_id, subscription_id) REFERENCES public.agency_subscriptions(agency_id, id) ON DELETE RESTRICT;


--
-- Name: agency_subscription_periods agency_subscription_periods_plan_scope_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_plan_scope_fkey FOREIGN KEY (plan_version_id, plan_billing_scope) REFERENCES public.billing_plan_versions(id, billing_scope) ON DELETE RESTRICT;


--
-- Name: agency_subscription_periods agency_subscription_periods_plan_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscription_periods
    ADD CONSTRAINT agency_subscription_periods_plan_version_id_fkey FOREIGN KEY (plan_version_id) REFERENCES public.billing_plan_versions(id) ON DELETE RESTRICT;


--
-- Name: agency_subscriptions agency_subscriptions_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscriptions
    ADD CONSTRAINT agency_subscriptions_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: agency_subscriptions agency_subscriptions_plan_scope_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscriptions
    ADD CONSTRAINT agency_subscriptions_plan_scope_fkey FOREIGN KEY (plan_version_id, plan_billing_scope) REFERENCES public.billing_plan_versions(id, billing_scope) ON DELETE RESTRICT;


--
-- Name: agency_subscriptions agency_subscriptions_plan_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_subscriptions
    ADD CONSTRAINT agency_subscriptions_plan_version_id_fkey FOREIGN KEY (plan_version_id) REFERENCES public.billing_plan_versions(id) ON DELETE RESTRICT;


--
-- Name: ai_caption_generations ai_caption_generations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_caption_generations
    ADD CONSTRAINT ai_caption_generations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ai_caption_generations ai_caption_generations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_caption_generations
    ADD CONSTRAINT ai_caption_generations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_set_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_set_by_fkey FOREIGN KEY (set_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: ai_credit_ledgers ai_credit_ledgers_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_ledgers
    ADD CONSTRAINT ai_credit_ledgers_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: ai_credit_operation_prices ai_credit_operation_prices_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_operation_prices
    ADD CONSTRAINT ai_credit_operation_prices_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: ai_credit_reservations ai_credit_reservations_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_reservations
    ADD CONSTRAINT ai_credit_reservations_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: ai_credit_reservations ai_credit_reservations_agency_id_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_reservations
    ADD CONSTRAINT ai_credit_reservations_agency_id_period_id_fkey FOREIGN KEY (agency_id, period_id) REFERENCES public.credit_usage_periods(agency_id, id) ON DELETE RESTRICT;


--
-- Name: ai_credit_reservations ai_credit_reservations_agency_id_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_reservations
    ADD CONSTRAINT ai_credit_reservations_agency_id_workspace_id_fkey FOREIGN KEY (agency_id, workspace_id) REFERENCES public.workspaces(agency_id, id) ON DELETE RESTRICT;


--
-- Name: ai_credit_reservations ai_credit_reservations_price_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_reservations
    ADD CONSTRAINT ai_credit_reservations_price_id_fkey FOREIGN KEY (price_id) REFERENCES public.ai_credit_operation_prices(id) ON DELETE RESTRICT;


--
-- Name: ai_credit_usages ai_credit_usages_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_usages
    ADD CONSTRAINT ai_credit_usages_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: ai_credit_usages ai_credit_usages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_usages
    ADD CONSTRAINT ai_credit_usages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ai_credit_usages ai_credit_usages_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_usages
    ADD CONSTRAINT ai_credit_usages_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: ai_video_jobs ai_video_jobs_usage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_video_jobs
    ADD CONSTRAINT ai_video_jobs_usage_id_fkey FOREIGN KEY (usage_id) REFERENCES public.ai_credit_usages(id) ON DELETE SET NULL;


--
-- Name: ai_video_jobs ai_video_jobs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_video_jobs
    ADD CONSTRAINT ai_video_jobs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ai_video_jobs ai_video_jobs_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_video_jobs
    ADD CONSTRAINT ai_video_jobs_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: audit_logs audit_logs_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE SET NULL;


--
-- Name: billing_audit_events billing_audit_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_audit_events
    ADD CONSTRAINT billing_audit_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: billing_audit_events billing_audit_events_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_audit_events
    ADD CONSTRAINT billing_audit_events_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: billing_migration_reviews billing_migration_reviews_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_migration_reviews
    ADD CONSTRAINT billing_migration_reviews_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: billing_migration_reviews billing_migration_reviews_resolved_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_migration_reviews
    ADD CONSTRAINT billing_migration_reviews_resolved_agency_id_fkey FOREIGN KEY (resolved_agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: billing_migration_reviews billing_migration_reviews_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_migration_reviews
    ADD CONSTRAINT billing_migration_reviews_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: billing_order_fulfillments billing_order_fulfillments_agency_id_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_order_fulfillments
    ADD CONSTRAINT billing_order_fulfillments_agency_id_order_id_fkey FOREIGN KEY (agency_id, order_id) REFERENCES public.billing_orders(agency_id, id) ON DELETE RESTRICT;


--
-- Name: billing_orders billing_orders_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_orders
    ADD CONSTRAINT billing_orders_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: billing_orders billing_orders_payer_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_orders
    ADD CONSTRAINT billing_orders_payer_user_id_fkey FOREIGN KEY (payer_user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: billing_orders billing_orders_plan_scope_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_orders
    ADD CONSTRAINT billing_orders_plan_scope_fkey FOREIGN KEY (plan_version_id, plan_billing_scope) REFERENCES public.billing_plan_versions(id, billing_scope) ON DELETE RESTRICT;


--
-- Name: billing_orders billing_orders_plan_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_orders
    ADD CONSTRAINT billing_orders_plan_version_id_fkey FOREIGN KEY (plan_version_id) REFERENCES public.billing_plan_versions(id) ON DELETE RESTRICT;


--
-- Name: billing_outbox_events billing_outbox_events_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_outbox_events
    ADD CONSTRAINT billing_outbox_events_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: billing_payment_attempts billing_payment_attempts_agency_id_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_attempts
    ADD CONSTRAINT billing_payment_attempts_agency_id_order_id_fkey FOREIGN KEY (agency_id, order_id) REFERENCES public.billing_orders(agency_id, id) ON DELETE RESTRICT;


--
-- Name: billing_payment_events billing_payment_events_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payment_events
    ADD CONSTRAINT billing_payment_events_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.billing_orders(id) ON DELETE RESTRICT;


--
-- Name: billing_payments billing_payments_agency_id_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_payments
    ADD CONSTRAINT billing_payments_agency_id_attempt_id_fkey FOREIGN KEY (agency_id, attempt_id) REFERENCES public.billing_payment_attempts(agency_id, id) ON DELETE RESTRICT;


--
-- Name: campaign_collaborators campaign_collaborators_collaborator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_collaborator_id_fkey FOREIGN KEY (collaborator_id) REFERENCES public.third_party_collaborators(id) ON DELETE RESTRICT;


--
-- Name: campaign_collaborators campaign_collaborators_media_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_media_campaign_id_fkey FOREIGN KEY (media_campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_collaborators campaign_collaborators_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: campaign_deployments campaign_deployments_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_deployments campaign_deployments_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: campaign_review_events campaign_review_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_review_events
    ADD CONSTRAINT campaign_review_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: campaign_review_events campaign_review_events_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_review_events
    ADD CONSTRAINT campaign_review_events_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_versions campaign_versions_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT campaign_versions_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_versions campaign_versions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT campaign_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: client_profiles client_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_profiles
    ADD CONSTRAINT client_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: content_moderation_reviews content_moderation_reviews_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT content_moderation_reviews_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: content_moderation_reviews content_moderation_reviews_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT content_moderation_reviews_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id);


--
-- Name: content_request_completion_jobs content_request_completion_jobs_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_request_completion_jobs
    ADD CONSTRAINT content_request_completion_jobs_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: content_request_completion_jobs content_request_completion_jobs_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_request_completion_jobs
    ADD CONSTRAINT content_request_completion_jobs_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: creator_credit_usage creator_credit_usage_agency_id_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creator_credit_usage
    ADD CONSTRAINT creator_credit_usage_agency_id_period_id_fkey FOREIGN KEY (agency_id, period_id) REFERENCES public.credit_usage_periods(agency_id, id) ON DELETE RESTRICT;


--
-- Name: creator_credit_usage creator_credit_usage_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.creator_credit_usage
    ADD CONSTRAINT creator_credit_usage_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: credit_entries credit_entries_agency_id_grant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_entries
    ADD CONSTRAINT credit_entries_agency_id_grant_id_fkey FOREIGN KEY (agency_id, grant_id) REFERENCES public.credit_grants(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_entries credit_entries_agency_id_operation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_entries
    ADD CONSTRAINT credit_entries_agency_id_operation_id_fkey FOREIGN KEY (agency_id, operation_id) REFERENCES public.credit_operations(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_grants credit_grants_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_grants
    ADD CONSTRAINT credit_grants_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency_credit_wallets(agency_id) ON DELETE RESTRICT;


--
-- Name: credit_grants credit_grants_agency_id_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_grants
    ADD CONSTRAINT credit_grants_agency_id_order_id_fkey FOREIGN KEY (agency_id, order_id) REFERENCES public.billing_orders(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_grants credit_grants_agency_id_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_grants
    ADD CONSTRAINT credit_grants_agency_id_period_id_fkey FOREIGN KEY (agency_id, period_id) REFERENCES public.agency_subscription_periods(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_grants credit_grants_trial_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_grants
    ADD CONSTRAINT credit_grants_trial_owner_id_fkey FOREIGN KEY (trial_owner_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: credit_operations credit_operations_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_operations
    ADD CONSTRAINT credit_operations_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: credit_operations credit_operations_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_operations
    ADD CONSTRAINT credit_operations_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: credit_operations credit_operations_agency_id_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_operations
    ADD CONSTRAINT credit_operations_agency_id_reservation_id_fkey FOREIGN KEY (agency_id, reservation_id) REFERENCES public.ai_credit_reservations(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_operations credit_operations_agency_id_reversal_of_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_operations
    ADD CONSTRAINT credit_operations_agency_id_reversal_of_fkey FOREIGN KEY (agency_id, reversal_of) REFERENCES public.credit_operations(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_reservation_allocations credit_reservation_allocations_agency_id_grant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_reservation_allocations
    ADD CONSTRAINT credit_reservation_allocations_agency_id_grant_id_fkey FOREIGN KEY (agency_id, grant_id) REFERENCES public.credit_grants(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_reservation_allocations credit_reservation_allocations_agency_id_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_reservation_allocations
    ADD CONSTRAINT credit_reservation_allocations_agency_id_reservation_id_fkey FOREIGN KEY (agency_id, reservation_id) REFERENCES public.ai_credit_reservations(agency_id, id) ON DELETE RESTRICT;


--
-- Name: credit_usage_periods credit_usage_periods_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_usage_periods
    ADD CONSTRAINT credit_usage_periods_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: credit_usage_periods credit_usage_periods_agency_id_subscription_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_usage_periods
    ADD CONSTRAINT credit_usage_periods_agency_id_subscription_period_id_fkey FOREIGN KEY (agency_id, subscription_period_id) REFERENCES public.agency_subscription_periods(agency_id, id) ON DELETE RESTRICT;


--
-- Name: agency_invitations fk_agency_inv_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT fk_agency_inv_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: ai_video_jobs fk_ai_video_jobs_reservation; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_video_jobs
    ADD CONSTRAINT fk_ai_video_jobs_reservation FOREIGN KEY (reservation_id) REFERENCES public.ai_credit_reservations(id);


--
-- Name: media_packages fk_media_packages_agency; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT fk_media_packages_agency FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: media_packages fk_media_packages_source_template; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT fk_media_packages_source_template FOREIGN KEY (source_template_id) REFERENCES public.media_packages(id) ON DELETE SET NULL;


--
-- Name: monitoring_health_results fk_monitoring_result_owner; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_results
    ADD CONSTRAINT fk_monitoring_result_owner FOREIGN KEY (target_id, collector_id) REFERENCES public.monitoring_health_targets(id, collector_id) ON DELETE RESTRICT;


--
-- Name: workspaces fk_workspaces_media_package; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT fk_workspaces_media_package FOREIGN KEY (workspace_media_package_id) REFERENCES public.workspace_media_packages(id) ON DELETE SET NULL;


--
-- Name: mail_attachments mail_attachments_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_attachments
    ADD CONSTRAINT mail_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: mail_attachments mail_attachments_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_attachments
    ADD CONSTRAINT mail_attachments_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: mail_batches mail_batches_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_batches
    ADD CONSTRAINT mail_batches_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: mail_batches mail_batches_sent_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_batches
    ADD CONSTRAINT mail_batches_sent_by_fkey FOREIGN KEY (sent_by) REFERENCES public.users(id);


--
-- Name: mail_batches mail_batches_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_batches
    ADD CONSTRAINT mail_batches_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: mail_deliveries mail_deliveries_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_deliveries
    ADD CONSTRAINT mail_deliveries_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.mail_batches(id) ON DELETE CASCADE;


--
-- Name: mail_suppressions mail_suppressions_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_suppressions
    ADD CONSTRAINT mail_suppressions_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: mail_suppressions mail_suppressions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_suppressions
    ADD CONSTRAINT mail_suppressions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: material_quota_releases material_quota_releases_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_quota_releases
    ADD CONSTRAINT material_quota_releases_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: material_quota_releases material_quota_releases_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.material_quota_releases
    ADD CONSTRAINT material_quota_releases_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: media_campaigns media_campaigns_workspace_media_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_campaigns
    ADD CONSTRAINT media_campaigns_workspace_media_package_id_fkey FOREIGN KEY (workspace_media_package_id) REFERENCES public.workspace_media_packages(id) ON DELETE RESTRICT;


--
-- Name: media_packages media_packages_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT media_packages_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: monitoring_collectors monitoring_collectors_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_collectors
    ADD CONSTRAINT monitoring_collectors_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.monitoring_servers(id) ON DELETE RESTRICT;


--
-- Name: monitoring_health_targets monitoring_health_targets_collector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT monitoring_health_targets_collector_id_fkey FOREIGN KEY (collector_id) REFERENCES public.monitoring_collectors(id) ON DELETE RESTRICT;


--
-- Name: monitoring_health_targets monitoring_health_targets_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT monitoring_health_targets_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.monitoring_servers(id) ON DELETE RESTRICT;


--
-- Name: package_negotiation_events package_negotiation_events_workspace_media_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_negotiation_events
    ADD CONSTRAINT package_negotiation_events_workspace_media_package_id_fkey FOREIGN KEY (workspace_media_package_id) REFERENCES public.workspace_media_packages(id) ON DELETE CASCADE;


--
-- Name: repository_drive_generations repository_drive_generations_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_generations
    ADD CONSTRAINT repository_drive_generations_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: repository_drive_objects repository_drive_objects_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_objects
    ADD CONSTRAINT repository_drive_objects_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency_drive_connections(agency_id);


--
-- Name: repository_drive_operations repository_drive_operations_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_operations
    ADD CONSTRAINT repository_drive_operations_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: repository_drive_states repository_drive_states_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_states
    ADD CONSTRAINT repository_drive_states_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: repository_drive_states repository_drive_states_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_states
    ADD CONSTRAINT repository_drive_states_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: repository_drive_states repository_drive_states_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repository_drive_states
    ADD CONSTRAINT repository_drive_states_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: sanction_reviews sanction_reviews_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sanction_reviews
    ADD CONSTRAINT sanction_reviews_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(id);


--
-- Name: sanction_reviews sanction_reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sanction_reviews
    ADD CONSTRAINT sanction_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: storage_objects storage_objects_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: storage_objects storage_objects_agency_id_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_agency_id_reservation_id_fkey FOREIGN KEY (agency_id, reservation_id) REFERENCES public.storage_reservations(agency_id, id) ON DELETE RESTRICT;


--
-- Name: storage_objects storage_objects_agency_id_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_agency_id_workspace_id_fkey FOREIGN KEY (agency_id, workspace_id) REFERENCES public.workspaces(agency_id, id) ON DELETE RESTRICT;


--
-- Name: storage_objects storage_objects_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_objects
    ADD CONSTRAINT storage_objects_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: storage_reservations storage_reservations_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_reservations
    ADD CONSTRAINT storage_reservations_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: storage_reservations storage_reservations_agency_id_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_reservations
    ADD CONSTRAINT storage_reservations_agency_id_workspace_id_fkey FOREIGN KEY (agency_id, workspace_id) REFERENCES public.workspaces(agency_id, id) ON DELETE RESTRICT;


--
-- Name: storage_usage_entries storage_usage_entries_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_usage_entries
    ADD CONSTRAINT storage_usage_entries_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id);


--
-- Name: storage_usage_entries storage_usage_entries_reservation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_usage_entries
    ADD CONSTRAINT storage_usage_entries_reservation_id_fkey FOREIGN KEY (reservation_id) REFERENCES public.agency_storage_reservations(id);


--
-- Name: storage_usage_entries storage_usage_entries_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_usage_entries
    ADD CONSTRAINT storage_usage_entries_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: subscription_operational_issues subscription_operational_issues_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_operational_issues
    ADD CONSTRAINT subscription_operational_issues_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: subscription_operational_issues subscription_operational_issues_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_operational_issues
    ADD CONSTRAINT subscription_operational_issues_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.billing_orders(id) ON DELETE RESTRICT;


--
-- Name: subscription_plan_changes subscription_plan_changes_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id);


--
-- Name: subscription_plan_changes subscription_plan_changes_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id);


--
-- Name: subscription_plan_changes subscription_plan_changes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: subscription_provider_checks subscription_provider_checks_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_provider_checks
    ADD CONSTRAINT subscription_provider_checks_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.billing_orders(id) ON DELETE RESTRICT;


--
-- Name: task_content_operations task_content_operations_edited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_operations
    ADD CONSTRAINT task_content_operations_edited_by_fkey FOREIGN KEY (edited_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: third_party_collaborators third_party_collaborators_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.third_party_collaborators
    ADD CONSTRAINT third_party_collaborators_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: third_party_collaborators third_party_collaborators_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.third_party_collaborators
    ADD CONSTRAINT third_party_collaborators_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: transactions transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: user_notifications user_notifications_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.admin_notifications(id);


--
-- Name: user_notifications user_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_oauth_providers user_oauth_providers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_oauth_providers
    ADD CONSTRAINT user_oauth_providers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_refresh_tokens user_refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_strikes user_strikes_converted_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_converted_to_id_fkey FOREIGN KEY (converted_to_id) REFERENCES public.user_strikes(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_strikes user_strikes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: user_strikes user_strikes_removed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_removed_by_fkey FOREIGN KEY (removed_by) REFERENCES public.users(id);


--
-- Name: user_strikes user_strikes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_subscriptions user_subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) ON DELETE RESTRICT;


--
-- Name: user_subscriptions user_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: user_system_roles user_system_roles_granted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_system_roles user_system_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workspace_credit_limits workspace_credit_limits_agency_id_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_credit_limits
    ADD CONSTRAINT workspace_credit_limits_agency_id_workspace_id_fkey FOREIGN KEY (agency_id, workspace_id) REFERENCES public.workspaces(agency_id, id) ON DELETE RESTRICT;


--
-- Name: workspace_credit_limits workspace_credit_limits_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_credit_limits
    ADD CONSTRAINT workspace_credit_limits_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: workspace_credit_usage workspace_credit_usage_agency_id_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_credit_usage
    ADD CONSTRAINT workspace_credit_usage_agency_id_period_id_fkey FOREIGN KEY (agency_id, period_id) REFERENCES public.credit_usage_periods(agency_id, id) ON DELETE RESTRICT;


--
-- Name: workspace_credit_usage workspace_credit_usage_agency_id_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_credit_usage
    ADD CONSTRAINT workspace_credit_usage_agency_id_workspace_id_fkey FOREIGN KEY (agency_id, workspace_id) REFERENCES public.workspaces(agency_id, id) ON DELETE RESTRICT;


--
-- Name: workspace_drive_folders workspace_drive_folders_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_drive_folders
    ADD CONSTRAINT workspace_drive_folders_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agency_drive_connections(agency_id);


--
-- Name: workspace_drive_folders workspace_drive_folders_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_drive_folders
    ADD CONSTRAINT workspace_drive_folders_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: workspace_hashtags workspace_hashtags_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: workspace_hashtags workspace_hashtags_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id);


--
-- Name: workspace_hashtags workspace_hashtags_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: workspace_hashtags workspace_hashtags_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: workspace_invitations workspace_invitations_invited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: workspace_invitations workspace_invitations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: workspace_media_packages workspace_media_packages_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.media_packages(id) ON DELETE RESTRICT;


--
-- Name: workspace_media_packages workspace_media_packages_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE RESTRICT;


--
-- Name: workspace_members workspace_members_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workspace_members workspace_members_client_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_client_profile_id_fkey FOREIGN KEY (client_profile_id) REFERENCES public.client_profiles(id) ON DELETE RESTRICT;


--
-- Name: workspace_members workspace_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: workspace_members workspace_members_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE RESTRICT;


--
-- Name: workspace_templates workspace_templates_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: workspace_templates workspace_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: workspace_templates workspace_templates_source_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_source_workspace_id_fkey FOREIGN KEY (source_workspace_id) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: workspaces workspaces_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: workspaces workspaces_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict 4xxYm31diX1GUbZLWUQjKeBJhHyXxutiaCe1vyrEu5cp1fsoxRYuudFGzO98Ibb

