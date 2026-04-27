output "np_apply_trigger_id" {
  description = "NP apply trigger ID"
  value       = google_cloudbuild_trigger.np_apply.trigger_id
}

output "pr_apply_trigger_id" {
  description = "PR apply trigger ID"
  value       = google_cloudbuild_trigger.pr_apply.trigger_id
}

output "plan_trigger_id" {
  description = "Plan trigger ID"
  value       = google_cloudbuild_trigger.plan.trigger_id
}
